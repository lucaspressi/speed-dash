-- TreadmillConfig.lua
-- Módulo centralizado para configuração e validação de treadmills

local TreadmillConfig = {}

-- ==================== DEBUG FLAG ====================
TreadmillConfig.DEBUG = true

local function debugLog(message)
	if TreadmillConfig.DEBUG then
		print("[TREADMILL-FIX] " .. message)
	end
end

-- ==================== CONFIGURAÇÕES ====================
TreadmillConfig.TREADMILL_DEFINITIONS = {
	{
		name = "TreadmillFree",
		productId = 0,  -- 0 = FREE (não precisa de compra)
		multiplier = 1,
		isFree = true,
		color = Color3.fromRGB(255, 255, 255)
	},
	{
		name = "TreadmillPaid",  -- 3x Speed Treadmill (dourada) - 59 Robux
		productId = 3510639799,
		multiplier = 3,
		isFree = false,
		color = Color3.fromRGB(255, 215, 0)
	},
	{
		name = "TreadmillBlue",  -- 9x Speed Treadmill (azul) - 149 Robux
		productId = 3510662188,
		multiplier = 9,
		isFree = false,
		color = Color3.fromRGB(0, 150, 255)
	},
	{
		name = "TreadmillPurple",  -- 25x Speed Treadmill (roxa) - 399 Robux
		productId = 3510662405,
		multiplier = 25,
		isFree = false,
		color = Color3.fromRGB(150, 0, 255)
	}
}

-- Mapa de ProductId -> Multiplier (para lookup rápido)
TreadmillConfig.PRODUCT_TO_MULT = {}
for _, def in ipairs(TreadmillConfig.TREADMILL_DEFINITIONS) do
	if def.productId > 0 then
		TreadmillConfig.PRODUCT_TO_MULT[def.productId] = def.multiplier
	end
end

-- ==================== FUNÇÕES DE VALIDAÇÃO ====================

-- Valida se uma zone tem os dados necessários
function TreadmillConfig.validateZone(zone)
	if not zone then
		debugLog("validateZone: zone is nil")
		return false, "Zone is nil"
	end

	local multiplier = zone:GetAttribute("Multiplier")
	local isFree = zone:GetAttribute("IsFree")
	local productId = zone:GetAttribute("ProductId")

	debugLog("validateZone: " .. zone:GetFullName())
	debugLog("  Multiplier: " .. tostring(multiplier))
	debugLog("  IsFree: " .. tostring(isFree))
	debugLog("  ProductId: " .. tostring(productId))

	-- Regra 1: FREE zones (Multiplier=1 ou IsFree=true)
	if isFree == true or multiplier == 1 then
		debugLog("  → Validated as FREE zone (no ProductId required)")
		return true, "free"
	end

	-- Regra 2: PAID zones (Multiplier>1) exigem ProductId válido
	if multiplier and multiplier > 1 then
		if not productId or productId == 0 then
			local errorMsg = "PAID zone missing ProductId! Zone: " .. zone:GetFullName() .. " (Multiplier=" .. tostring(multiplier) .. ")"
			warn("[TREADMILL-FIX] " .. errorMsg)
			return false, errorMsg
		end
		debugLog("  → Validated as PAID zone (ProductId=" .. productId .. ", Multiplier=" .. multiplier .. ")")
		return true, "paid"
	end

	-- Regra 3: Se não tem Multiplier nem IsFree, é inválido
	local errorMsg = "Zone missing required attributes! Zone: " .. zone:GetFullName()
	warn("[TREADMILL-FIX] " .. errorMsg)
	return false, errorMsg
end

-- Lê configuração de uma zone (com fallback para legacy IntValues)
function TreadmillConfig.readZoneConfig(zone)
	local config = {
		multiplier = nil,
		isFree = nil,
		productId = nil
	}

	-- Prioridade 1: Attributes (novo sistema)
	config.multiplier = zone:GetAttribute("Multiplier")
	config.isFree = zone:GetAttribute("IsFree")
	config.productId = zone:GetAttribute("ProductId")

	-- Fallback: IntValues (sistema legado)
	if not config.multiplier then
		local multValue = zone:FindFirstChild("Multiplier")
		if multValue and multValue:IsA("IntValue") then
			config.multiplier = multValue.Value
			debugLog("Fallback: Read Multiplier from IntValue = " .. config.multiplier)
		end
	end

	if not config.productId then
		local prodValue = zone:FindFirstChild("ProductId")
		if prodValue and prodValue:IsA("IntValue") then
			config.productId = prodValue.Value
			debugLog("Fallback: Read ProductId from IntValue = " .. config.productId)
		end
	end

	-- Detecta IsFree baseado em multiplier ou productId
	if not config.isFree then
		if config.multiplier == 1 or config.productId == 0 then
			config.isFree = true
			debugLog("Auto-detected IsFree=true based on Multiplier or ProductId")
		end
	end

	return config
end

-- Aplica configuração em uma zone (seta Attributes)
function TreadmillConfig.applyConfigToZone(zone, treadmillDef)
	debugLog("Applying config to zone: " .. zone:GetFullName())
	debugLog("  Definition: " .. treadmillDef.name .. " (Mult=" .. treadmillDef.multiplier .. ", ProductId=" .. treadmillDef.productId .. ")")

	-- Seta attributes (sistema novo)
	zone:SetAttribute("Multiplier", treadmillDef.multiplier)
	zone:SetAttribute("IsFree", treadmillDef.isFree)
	zone:SetAttribute("ProductId", treadmillDef.productId)

	-- Remove IntValues legados (evita conflito)
	for _, child in ipairs(zone:GetChildren()) do
		if child.Name == "ProductId" or child.Name == "Multiplier" or child.Name == "Value" then
			debugLog("  Removing legacy IntValue: " .. child.Name)
			child:Destroy()
		end
	end

	debugLog("  ✓ Config applied successfully")
end

-- ==================== FUNÇÕES DE MIGRAÇÃO ====================

-- Normaliza nome do parent (remove espaços, case-insensitive)
local function normalizeParentName(name)
	return string.lower(string.gsub(name or "", "%s+", ""))
end

-- Detecta qual tipo de treadmill baseado no parent name
function TreadmillConfig.detectTreadmillType(parentName)
	local normalized = normalizeParentName(parentName)

	-- Patterns para detecção (ordem de prioridade)
	local patterns = {
		{pattern = "purple", type = "TreadmillPurple"},
		{pattern = "blue", type = "TreadmillBlue"},
		{pattern = "gold", type = "TreadmillPaid"},
		{pattern = "paid", type = "TreadmillPaid"},
		{pattern = "x25", type = "TreadmillPurple"},
		{pattern = "x9", type = "TreadmillBlue"},
		{pattern = "x3", type = "TreadmillPaid"},
		{pattern = "x1", type = "TreadmillFree"},
		{pattern = "free", type = "TreadmillFree"},
		{pattern = "esteira", type = "TreadmillFree"},  -- Legacy support
	}

	for _, p in ipairs(patterns) do
		if string.find(normalized, p.pattern, 1, true) then
			debugLog("Detected type '" .. p.type .. "' from parent name '" .. parentName .. "' (matched pattern: " .. p.pattern .. ")")
			return p.type
		end
	end

	-- Default: FREE se não detectou nada
	debugLog("Could not detect type from parent name '" .. parentName .. "', defaulting to TreadmillFree")
	return "TreadmillFree"
end

-- Busca definição por nome
function TreadmillConfig.getDefinitionByName(name)
	for _, def in ipairs(TreadmillConfig.TREADMILL_DEFINITIONS) do
		if def.name == name then
			return def
		end
	end
	return nil
end

-- ==================== EXPORT ====================
TreadmillConfig.debugLog = debugLog
return TreadmillConfig
