-- TelemetryService.lua
-- Sistema unificado de telemetria e logging
-- Pode ser usado tanto no Server quanto no Client (ReplicatedStorage)

local TelemetryService = {}

-- ==================== CONFIGURAÇÃO ====================
TelemetryService.DEBUG = true
TelemetryService.VERBOSE = false  -- Logs muito detalhados

-- 🔄 PATCH 4: Rate limiting para reduzir spam
TelemetryService.RATE_LIMIT_ENABLED = true
TelemetryService.RATE_LIMIT_INTERVAL = 1.0  -- Max 1 log por segundo por categoria

-- Níveis de log
local LogLevel = {
	DEBUG = 1,    -- Informação de debug (verbose)
	INFO = 2,     -- Informação normal
	WARNING = 3,  -- Avisos (warn)
	ERROR = 4,    -- Erros (warn)
	CRITICAL = 5  -- Crítico (error)
}

TelemetryService.LogLevel = LogLevel

-- Categorias de log
local Category = {
	TREADMILL = "TREADMILL",
	OWNERSHIP = "OWNERSHIP",
	PURCHASE = "PURCHASE",
	XP_GAIN = "XP_GAIN",
	PLAYER = "PLAYER",
	ZONE = "ZONE",
	SYNC = "SYNC",
	INIT = "INIT"
}

TelemetryService.Category = Category

-- ==================== ESTADO INTERNO ====================
local lastLogTime = {}  -- [category] = timestamp

-- ==================== FUNÇÕES INTERNAS ====================
local function getCurrentTimestamp()
	return string.format("%.3f", tick())
end

-- Rate limiting check
local function shouldLog(category, level)
	if not TelemetryService.RATE_LIMIT_ENABLED then
		return true  -- Rate limiting desabilitado
	end

	-- Rate limiting não se aplica a WARNING, ERROR, CRITICAL
	if level >= LogLevel.WARNING then
		return true
	end

	local now = tick()
	local lastTime = lastLogTime[category] or 0

	if (now - lastTime) >= TelemetryService.RATE_LIMIT_INTERVAL then
		lastLogTime[category] = now
		return true
	end

	return false  -- Suprimido por rate limit
end

local function formatLogMessage(level, category, message, context)
	local timestamp = getCurrentTimestamp()
	local prefix = ""

	-- Determina prefixo baseado no nível
	if level == LogLevel.DEBUG then
		prefix = "🔍"
	elseif level == LogLevel.INFO then
		prefix = "ℹ️"
	elseif level == LogLevel.WARNING then
		prefix = "⚠️"
	elseif level == LogLevel.ERROR then
		prefix = "❌"
	elseif level == LogLevel.CRITICAL then
		prefix = "🔥"
	end

	-- Monta mensagem base
	local fullMessage = string.format("[%s] [%s:%s] %s",
		timestamp,
		category,
		prefix,
		message
	)

	-- Adiciona contexto se disponível
	if context and type(context) == "table" then
		for key, value in pairs(context) do
			fullMessage = fullMessage .. string.format("\n  %s: %s", key, tostring(value))
		end
	end

	return fullMessage
end

-- ==================== FUNÇÕES PÚBLICAS ====================

function TelemetryService.log(level, category, message, context)
	-- Filtra por nível de debug
	if not TelemetryService.DEBUG and level <= LogLevel.INFO then
		return
	end

	if not TelemetryService.VERBOSE and level == LogLevel.DEBUG then
		return
	end

	-- 🔄 PATCH 4: Rate limiting
	if not shouldLog(category, level) then
		return  -- Suprimido por rate limit
	end

	local formattedMessage = formatLogMessage(level, category, message, context)

	-- Output baseado no nível
	if level >= LogLevel.ERROR then
		error(formattedMessage, 0)
	elseif level == LogLevel.WARNING then
		warn(formattedMessage)
	else
		print(formattedMessage)
	end
end

-- Atalhos para facilitar uso
function TelemetryService.debug(category, message, context)
	TelemetryService.log(LogLevel.DEBUG, category, message, context)
end

function TelemetryService.info(category, message, context)
	TelemetryService.log(LogLevel.INFO, category, message, context)
end

function TelemetryService.warning(category, message, context)
	TelemetryService.log(LogLevel.WARNING, category, message, context)
end

function TelemetryService.error(category, message, context)
	TelemetryService.log(LogLevel.ERROR, category, message, context)
end

function TelemetryService.critical(category, message, context)
	TelemetryService.log(LogLevel.CRITICAL, category, message, context)
end

-- ==================== TELEMETRIA ESPECÍFICA DE TREADMILL ====================

-- Log de tentativa de uso de treadmill
function TelemetryService.logTreadmillAttempt(playerName, multiplier, hasAccess, position)
	local context = {
		Player = playerName,
		Multiplier = multiplier,
		HasAccess = hasAccess,
		Position = tostring(position)
	}

	if hasAccess then
		TelemetryService.debug(Category.TREADMILL, "Player using treadmill", context)
	else
		TelemetryService.info(Category.TREADMILL, "Player blocked (no access)", context)
	end
end

-- Log de mudança de ownership
function TelemetryService.logOwnershipChange(playerName, multiplier, oldValue, newValue, source)
	local context = {
		Player = playerName,
		Multiplier = multiplier,
		OldValue = oldValue,
		NewValue = newValue,
		Source = source  -- "DataStore", "Purchase", "Snapshot"
	}

	TelemetryService.info(Category.OWNERSHIP, "Ownership changed", context)
end

-- Log de XP gain
function TelemetryService.logXPGain(playerName, xpAmount, multiplier, totalMultiplier)
	local context = {
		Player = playerName,
		XP = xpAmount,
		TreadmillMult = multiplier,
		TotalMult = totalMultiplier
	}

	TelemetryService.debug(Category.XP_GAIN, "XP gained", context)
end

-- Log de sync entre server e client
function TelemetryService.logSync(playerName, action, data)
	local context = {
		Player = playerName,
		Action = action,  -- "SnapshotSent", "SnapshotReceived", "AttributeChanged"
	}

	-- Adiciona dados específicos
	if type(data) == "table" then
		for k, v in pairs(data) do
			context[k] = v
		end
	end

	TelemetryService.debug(Category.SYNC, "Sync event", context)
end

-- Log de zona detectada
function TelemetryService.logZoneDetected(zonePath, multiplier, isFree, isValid)
	local context = {
		Zone = zonePath,
		Multiplier = multiplier,
		IsFree = isFree,
		IsValid = isValid
	}

	if isValid then
		TelemetryService.debug(Category.ZONE, "Zone detected and validated", context)
	else
		TelemetryService.warning(Category.ZONE, "Invalid zone detected", context)
	end
end

-- ==================== EXPORT ====================
return TelemetryService
