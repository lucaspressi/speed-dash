-- ProgressionMath.lua
-- Funções puras para cálculos de progressão (XP, Level, Speed)
-- ✅ PATCH: Usa ProgressionConfig como fonte da verdade

local ProgressionConfig = require(script.Parent.ProgressionConfig)

local ProgressionMath = {}

-- ==================== CORE FUNCTIONS ====================

-- Calcula XP necessário para passar de um level para o próximo
-- Exemplo: XPRequired(64) = XP para passar do Level 64 → 65
function ProgressionMath.XPRequired(level)
	local formula = ProgressionConfig.FORMULA

	if formula.type == "mixed" then
		-- XPRequired(level) = BASE + SCALE * level^EXPONENT
		-- ✅ CURVA ADAPTATIVA: Níveis iniciais são MUITO mais rápidos
		local BASE = formula.BASE or 0
		local SCALE = formula.SCALE or 1
		local EXPONENT = formula.EXPONENT or 1.5

		-- 🎯 Ajuste de curva para early game mais rápido
		if level <= 10 then
			-- Level 1-10: Progressão MUITO rápida (38% mais rápido)
			EXPONENT = 1.15
		elseif level <= 25 then
			-- Level 11-25: Progressão rápida (35% mais rápido)
			EXPONENT = 1.30
		end
		-- Level 26+: usa EXPONENT normal do config (1.45)

		return math.floor(BASE + SCALE * (level ^ EXPONENT))

	elseif formula.type == "power_law" then
		-- Legacy: XPRequired(level) = A * level^B
		local A = formula.A or 1000
		local B = formula.B or 1.5
		return math.floor(A * (level ^ B))

	elseif formula.type == "exponential" then
		-- Fallback para fórmula exponencial
		local A = formula.A or 1000
		local B = formula.B or 1.1
		return math.floor(A * (B ^ level))

	else
		-- Fallback para fórmula linear
		warn("[PROGRESSION] Unknown formula type:", formula.type, "- using linear fallback")
		local A = formula.A or 1000
		local B = formula.B or 100
		return math.floor(A * level + B)
	end
end

-- Calcula TotalXP acumulado necessário para ALCANÇAR um level
-- Exemplo: TotalXPToReachLevel(64) = soma de XPRequired(1) até XPRequired(63)
-- Retorna o TotalXP mínimo para estar no Level 64 com XP=0
function ProgressionMath.TotalXPToReachLevel(targetLevel)
	if targetLevel <= 1 then
		return 0
	end

	local total = 0
	for level = 1, targetLevel - 1 do
		total = total + ProgressionMath.XPRequired(level)
	end

	return total
end

-- Calcula o Level atual baseado em TotalXP acumulado
-- Usa busca linear (eficiente até ~1000 levels)
-- Retorna: level, xpIntoLevel, xpRequired
function ProgressionMath.LevelFromTotalXP(totalXP)
	if totalXP < 0 then
		return 1, 0, ProgressionMath.XPRequired(1)
	end

	local level = 1
	local xpConsumed = 0

	while true do
		local xpRequired = ProgressionMath.XPRequired(level)

		if xpConsumed + xpRequired > totalXP then
			-- Encontrou o level atual
			local xpIntoLevel = totalXP - xpConsumed
			return level, xpIntoLevel, xpRequired
		end

		-- Avança para o próximo level
		xpConsumed = xpConsumed + xpRequired
		level = level + 1

		-- Safety: limita a 10000 levels (previne loop infinito)
		if level > 10000 then
			warn("[PROGRESSION] LevelFromTotalXP: exceeded max level (10000)!")
			return 10000, 0, ProgressionMath.XPRequired(10000)
		end
	end
end

-- Calcula Speed Display (baseado em TotalXP)
-- ⚠️ IMPORTANTE: Rebirth multiplier NÃO é aplicado aqui (usa raw TotalXP)
function ProgressionMath.SpeedFromTotalXP(totalXP, rebirthMultiplier, auraMultiplier)
	-- Speed display = TotalXP raw (sem multiplicar por rebirth/aura)
	if ProgressionConfig.DISPLAY.speedDisplayUseRawTotalXP then
		return totalXP
	else
		-- Fallback: aplica multipliers (caso queira mudar comportamento no futuro)
		rebirthMultiplier = rebirthMultiplier or 1
		auraMultiplier = auraMultiplier or 1
		return math.floor(totalXP * rebirthMultiplier * auraMultiplier)
	end
end

-- Calcula WalkSpeed baseado no Level
function ProgressionMath.WalkSpeedFromLevel(level)
	local base = ProgressionConfig.DISPLAY.baseWalkSpeed
	local maxLevel = ProgressionConfig.DISPLAY.maxLevelForWalkSpeed
	return base + math.min(level, maxLevel)
end

-- ==================== UTILITY FUNCTIONS ====================

-- Formata número com sufixos (K, M, B)
function ProgressionMath.formatNumber(num)
	if num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- Formata número com vírgulas (1,234,567)
function ProgressionMath.formatComma(num)
	local formatted = tostring(math.floor(num))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

-- ==================== VALIDATION ====================

-- Valida se os cálculos batem com os anchors
function ProgressionMath.validateAnchors()
	if not ProgressionConfig.DEBUG then return end

	print("[PROGRESSION] ============================================")
	print("[PROGRESSION] Validating ProgressionMath...")

	for i, anchor in ipairs(ProgressionConfig.ANCHORS) do
		print(string.format("[PROGRESSION] Testing Anchor #%d (Level %d):", i, anchor.level))

		-- Test 1: XPRequired
		local xpReq = ProgressionMath.XPRequired(anchor.level)
		local errorXP = math.abs(xpReq - anchor.xpRequired)
		local errorPercentXP = (errorXP / anchor.xpRequired) * 100

		print(string.format("[PROGRESSION]   XPRequired: %d (expected: %d, error: %.2f%%)",
			xpReq, anchor.xpRequired, errorPercentXP))

		if errorPercentXP < 0.5 then
			print("[PROGRESSION]     ✅ PASS")
		else
			warn("[PROGRESSION]     ❌ FAIL")
		end

		-- Test 2: TotalXP
		local totalXPToReach = ProgressionMath.TotalXPToReachLevel(anchor.level)
		local totalXPInLevel = totalXPToReach + anchor.xpIntoLevel
		local errorTotalXP = math.abs(totalXPInLevel - anchor.totalXP)
		local errorPercentTotalXP = (errorTotalXP / anchor.totalXP) * 100

		print(string.format("[PROGRESSION]   TotalXP: %d (expected: %d, error: %.2f%%)",
			totalXPInLevel, anchor.totalXP, errorPercentTotalXP))

		if errorPercentTotalXP < 0.5 then
			print("[PROGRESSION]     ✅ PASS")
		else
			warn("[PROGRESSION]     ❌ FAIL")
		end

		-- Test 3: LevelFromTotalXP (reverse calculation)
		local calculatedLevel, xpInto, xpReq2 = ProgressionMath.LevelFromTotalXP(totalXPInLevel)

		print(string.format("[PROGRESSION]   LevelFromTotalXP(%d) = Level %d (xpIntoLevel: %d/%d)",
			totalXPInLevel, calculatedLevel, xpInto, xpReq2))

		if calculatedLevel == anchor.level then
			print("[PROGRESSION]     ✅ PASS (level match)")
		else
			warn(string.format("[PROGRESSION]     ❌ FAIL (expected level %d, got %d)", anchor.level, calculatedLevel))
		end

		local errorXPInto = math.abs(xpInto - anchor.xpIntoLevel)
		if errorXPInto < 10 then
			print("[PROGRESSION]     ✅ PASS (xpIntoLevel match)")
		else
			warn(string.format("[PROGRESSION]     ❌ FAIL (expected xpIntoLevel %d, got %d)", anchor.xpIntoLevel, xpInto))
		end

		-- Test 4: Progress bar
		local progress = xpInto / xpReq2
		local expectedProgress = anchor.xpIntoLevel / anchor.xpRequired

		print(string.format("[PROGRESSION]   Progress: %.4f (expected: %.4f)",
			progress, expectedProgress))

		if math.abs(progress - expectedProgress) < 0.001 then
			print("[PROGRESSION]     ✅ PASS")
		else
			warn("[PROGRESSION]     ❌ FAIL")
		end
	end

	print("[PROGRESSION] ============================================")
end

-- Auto-valida ao carregar
ProgressionMath.validateAnchors()

-- ==================== EXPORT ====================
return ProgressionMath
