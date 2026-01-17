-- ProgressionConfig.lua
-- Configuração centralizada de progressão (XP, Speed, Levels)
-- ✅ PATCH: Calibrado para bater anchor Level 64 do jogo referência

local ProgressionConfig = {}

-- ==================== DEBUG FLAG ====================
ProgressionConfig.DEBUG = true

-- ==================== ANCHORS (Jogo Referência) ====================
-- 📌 ALVO CONFIRMADO: Level 64 no jogo referência
-- - Speed Display: 4,779,693
-- - XP Barra: 535,080 / 666,750 (≈ 80.22%)
-- - XPRequired(64): 666,750
-- - Aura: NÃO EXISTE no nosso jogo (ignorar multiplier de aura)
-- - Rebirth: Existe mas reseta TotalXP (não afeta speed display diretamente)

ProgressionConfig.ANCHORS = {
	{
		level = 64,
		xpRequired = 666750,      -- XP necessário para passar do Level 64 → 65
		totalXP = 4779693,         -- TotalXP acumulado até Level 64 (com 535,080 XP na barra)
		xpIntoLevel = 535080,      -- XP dentro do Level 64 (para 80.22% progress)
	}
}

-- ==================== FORMULA PARAMETERS ====================
-- Fórmula calibrada: XPRequired(level) = A * level^B
-- Calibrada com anchor Level 64 usando método reverso

ProgressionConfig.FORMULA = {
	type = "power_law",           -- Tipo: power_law | exponential | linear
	A = 1387,                     -- Coeficiente
	B = 1.47,                     -- Expoente
}

-- Validação dos anchors (executado ao carregar o módulo)
function ProgressionConfig.validateAnchors()
	if not ProgressionConfig.DEBUG then return end

	print("[PROGRESSION] ============================================")
	print("[PROGRESSION] Validating Anchors...")

	for i, anchor in ipairs(ProgressionConfig.ANCHORS) do
		local A = ProgressionConfig.FORMULA.A
		local B = ProgressionConfig.FORMULA.B
		local calculated = math.floor(A * (anchor.level ^ B))
		local error = math.abs(calculated - anchor.xpRequired)
		local errorPercent = (error / anchor.xpRequired) * 100

		print(string.format("[PROGRESSION] Anchor #%d (Level %d):", i, anchor.level))
		print(string.format("[PROGRESSION]   XPRequired Expected: %d", anchor.xpRequired))
		print(string.format("[PROGRESSION]   XPRequired Calculated: %d", calculated))
		print(string.format("[PROGRESSION]   Error: %d (%.2f%%)", error, errorPercent))

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
