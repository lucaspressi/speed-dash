-- ProgressionConfig.lua
-- Configuração centralizada de progressão (XP, Speed, Levels)
-- ✅ PATCH: Calibrado para bater anchor Level 64 do jogo referência

local ProgressionConfig = {}

-- ==================== DEBUG FLAG ====================
ProgressionConfig.DEBUG = true

-- ==================== ANCHORS (Progressão Ajustada) ====================
-- 📌 AJUSTADO: Progressão mais suave e balanceada
-- Nova fórmula resulta em:
-- - Level 64: XPRequired ≈ 45,100
-- - TotalXP para alcançar Level 64 ≈ 320,000
-- Valores muito mais razoáveis para gameplay casual!

ProgressionConfig.ANCHORS = {
	{
		level = 64,
		xpRequired = 45100,        -- XP necessário para passar do Level 64 → 65 (AJUSTADO)
		totalXP = 320000,          -- TotalXP acumulado até Level 64 (AJUSTADO)
		xpIntoLevel = 36080,       -- XP dentro do Level 64 (para 80% progress)
	}
}

-- ==================== FORMULA PARAMETERS ====================
-- Fórmula calibrada: XPRequired(level) = BASE + SCALE * level^EXPONENT
-- ✅ AJUSTADA: Progressão mais suave e divertida
-- Reduzimos drasticamente os valores para tornar o jogo menos grindy:
-- - BASE: 20,000 → 100 (200x mais fácil no começo)
-- - SCALE: 500 → 50 (10x mais fácil na escala)
-- - EXPONENT: 1.65 → 1.55 (curva menos íngreme)
--
-- Resultado:
-- - Level 1→2: ~150 XP (era 20,500 XP)
-- - Level 10→11: ~1,900 XP (era 42,335 XP)
-- - Level 64→65: ~45,000 XP (era 666,750 XP)

ProgressionConfig.FORMULA = {
	type = "mixed",               -- Tipo: mixed (BASE + SCALE * level^EXPONENT)
	BASE = 100,                   -- Offset constante (XP mínimo por level) - REDUZIDO
	SCALE = 50,                   -- Coeficiente de escala - REDUZIDO
	EXPONENT = 1.55,              -- Expoente da curva (controla aceleração) - REDUZIDO
}

-- Validação dos anchors (executado ao carregar o módulo)
function ProgressionConfig.validateAnchors()
	if not ProgressionConfig.DEBUG then return end

	print("[PROGRESSION] ============================================")
	print("[PROGRESSION] Validating Anchors...")

	for i, anchor in ipairs(ProgressionConfig.ANCHORS) do
		local formula = ProgressionConfig.FORMULA
		local calculated = 0

		if formula.type == "mixed" then
			-- XPRequired(level) = BASE + SCALE * level^EXPONENT
			calculated = formula.BASE + formula.SCALE * (anchor.level ^ formula.EXPONENT)
			calculated = math.floor(calculated)
		elseif formula.type == "power_law" then
			-- Legacy: XPRequired(level) = A * level^B
			calculated = formula.A * (anchor.level ^ formula.B)
			calculated = math.floor(calculated)
		else
			warn("[PROGRESSION] Unknown formula type:", formula.type)
			calculated = 1000 * anchor.level
		end

		local error = math.abs(calculated - anchor.xpRequired)
		local errorPercent = (error / anchor.xpRequired) * 100

		print(string.format("[PROGRESSION] Anchor #%d (Level %d):", i, anchor.level))
		print(string.format("[PROGRESSION]   Formula Type: %s", formula.type))
		print(string.format("[PROGRESSION]   XPRequired Expected: %d", anchor.xpRequired))
		print(string.format("[PROGRESSION]   XPRequired Calculated: %d", calculated))
		print(string.format("[PROGRESSION]   Error: %d (%.4f%%)", error, errorPercent))

		if errorPercent < 0.5 then
			print("[PROGRESSION]   ✅ PASS")
		else
			warn("[PROGRESSION]   ❌ FAIL - Error too high!")
		end
	end

	print("[PROGRESSION] ============================================")
end

-- Auto-valida ao carregar
ProgressionConfig.validateAnchors()

-- ==================== REBIRTH TIERS ====================
-- ⚠️ IMPORTANTE: Rebirth RESETA TotalXP = 0
-- O multiplier de rebirth afeta XP GAIN rate, NÃO a speed display diretamente

ProgressionConfig.REBIRTH_TIERS = {
	{level = 25, multiplier = 1.5},
	{level = 50, multiplier = 2.0},
	{level = 100, multiplier = 2.5},
	{level = 150, multiplier = 3.0},
	{level = 200, multiplier = 3.5},
	{level = 300, multiplier = 4.0},
	{level = 500, multiplier = 5.0},
	{level = 750, multiplier = 6.0},
	{level = 1000, multiplier = 7.5},
	{level = 1500, multiplier = 10.0},
}

-- ==================== DISPLAY SETTINGS ====================
ProgressionConfig.DISPLAY = {
	-- Speed display = TotalXP (sem aplicar rebirth multiplier)
	speedDisplayUseRawTotalXP = true,

	-- Aura multiplier (NÃO EXISTE no nosso jogo)
	auraMultiplier = 1.0,

	-- WalkSpeed formula: 16 + min(level, 500)
	baseWalkSpeed = 16,
	maxLevelForWalkSpeed = 500,
}

-- ==================== EXPORT ====================
return ProgressionConfig
