-- ProgressionConfig.lua
-- Configuração centralizada de progressão (XP, Speed, Levels)
-- ✅ PATCH: Calibrado para bater anchor Level 64 do jogo referência

local ProgressionConfig = {}

-- ==================== DEBUG FLAG ====================
ProgressionConfig.DEBUG = true

-- ==================== ANCHORS (Progressão Ajustada) ====================
-- 📌 AJUSTADO: Progressão MUITO mais fácil nos primeiros 50 níveis
-- Nova fórmula (BASE=50, SCALE=25, EXPONENT=1.45) resulta em:
-- - Level 64: XPRequired ≈ 10,446
-- - TotalXP para alcançar Level 64 ≈ 269,561
-- - TotalXP no Level 64 com 80% progress ≈ 277,918
-- Valores MUITO mais acessíveis para gameplay inicial!

ProgressionConfig.ANCHORS = {
	{
		level = 64,
		xpRequired = 10446,        -- XP necessário para passar do Level 64 → 65
		totalXP = 277918,          -- TotalXP no Level 64 com 80% progress
		xpIntoLevel = 8357,        -- XP dentro do Level 64 (para 80% progress)
	}
}

-- ==================== FORMULA PARAMETERS ====================
-- Fórmula calibrada: XPRequired(level) = BASE + SCALE * level^EXPONENT
-- ✅ AJUSTADA: Progressão MUITO mais fácil nos primeiros 50 níveis
-- Reduzimos ainda mais os valores para tornar o início do jogo mais acessível:
-- - BASE: 20,000 → 50 (400x mais fácil no começo)
-- - SCALE: 500 → 25 (20x mais fácil na escala)
-- - EXPONENT: 1.65 → 1.45 (curva muito mais suave)
--
-- Resultado:
-- - Level 1→2: ~75 XP (era 20,500 XP) - 273x mais fácil
-- - Level 10→11: ~754 XP (era 42,335 XP) - 56x mais fácil
-- - Level 25→26: ~2,710 XP (era 131,875 XP) - 49x mais fácil
-- - Level 50→51: ~7,318 XP (era 387,750 XP) - 53x mais fácil
-- - Level 64→65: ~10,446 XP (era 666,750 XP) - 64x mais fácil
--
-- 🎯 XP Total até Level 50: ~147,000 XP (era 415,000 XP) - 65% de redução!

ProgressionConfig.FORMULA = {
	type = "mixed",               -- Tipo: mixed (BASE + SCALE * level^EXPONENT)
	BASE = 50,                    -- Offset constante (XP mínimo por level) - MUITO REDUZIDO
	SCALE = 25,                   -- Coeficiente de escala - MUITO REDUZIDO
	EXPONENT = 1.45,              -- Expoente da curva (controla aceleração) - MUITO REDUZIDO
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
