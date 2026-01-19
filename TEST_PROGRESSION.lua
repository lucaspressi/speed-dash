-- TEST_PROGRESSION.lua
-- Script para testar se a progressão está funcionando corretamente
-- ✅ Cole este código no Command Bar do Roblox Studio e execute

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== CARREGAR MÓDULOS ====================
local ProgressionMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionMath"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionConfig"))

print("\n")
print("========================================")
print("🧪 TESTE DE PROGRESSÃO - SPEED DASH")
print("========================================")
print("\n")

-- ==================== TESTE 1: FÓRMULA DE XP ====================
print("📊 TESTE 1: Verificando Fórmula de XP")
print("----------------------------------------")

local tests = {
	{level = 1, expected = 75, desc = "Level 1→2 (início)"},
	{level = 5, expected = 209, desc = "Level 5→6 (early game)"},
	{level = 10, expected = 403, desc = "Level 10→11 (fim early game)"},
	{level = 15, expected = 895, desc = "Level 15→16 (mid game)"},
	{level = 25, expected = 1691, desc = "Level 25→26 (primeiro rebirth)"},
	{level = 30, expected = 3515, desc = "Level 30→31 (após rebirth)"},
	{level = 50, expected = 7318, desc = "Level 50→51 (segundo rebirth)"},
}

local allPassed = true

for _, test in ipairs(tests) do
	local actual = ProgressionMath.XPRequired(test.level)
	local diff = math.abs(actual - test.expected)
	local tolerance = test.expected * 0.05 -- 5% tolerance

	if diff <= tolerance then
		print("✅ " .. test.desc)
		print("   Esperado: ~" .. test.expected .. " XP | Real: " .. actual .. " XP")
	else
		print("❌ " .. test.desc)
		print("   Esperado: ~" .. test.expected .. " XP | Real: " .. actual .. " XP")
		print("   ⚠️ DIFERENÇA GRANDE: " .. diff .. " XP")
		allPassed = false
	end
end

print("\n")

-- ==================== TESTE 2: CURVA ADAPTATIVA ====================
print("🎯 TESTE 2: Verificando Curva Adaptativa")
print("----------------------------------------")

-- Testar que Level 1-10 está mais fácil que Level 26+
local xp10 = ProgressionMath.XPRequired(10)
local xp30 = ProgressionMath.XPRequired(30)

print("Level 10 XP: " .. xp10)
print("Level 30 XP: " .. xp30)

if xp10 < 450 then
	print("✅ Early game está RÁPIDO (Level 10 < 450 XP)")
else
	print("❌ Early game está LENTO (Level 10 >= 450 XP)")
	print("   ⚠️ A fórmula antiga ainda está ativa!")
	allPassed = false
end

-- Verificar que a curva não é linear
local xp1 = ProgressionMath.XPRequired(1)
local xp5 = ProgressionMath.XPRequired(5)

local ratio = xp5 / xp1
if ratio > 2.0 and ratio < 3.5 then
	print("✅ Curva exponencial correta (ratio: " .. string.format("%.2f", ratio) .. ")")
else
	print("❌ Curva parece incorreta (ratio: " .. string.format("%.2f", ratio) .. ")")
	allPassed = false
end

print("\n")

-- ==================== TESTE 3: REBIRTH TIERS ====================
print("🔄 TESTE 3: Verificando Rebirth Tiers")
print("----------------------------------------")

local expectedTiers = {
	{level = 25, mult = 1.5},
	{level = 50, mult = 2.0},
	{level = 100, mult = 2.5},
	{level = 150, mult = 3.0},
	{level = 500, mult = 5.0},
	{level = 1500, mult = 10.0},
}

local tiers = ProgressionConfig.REBIRTH_TIERS

print("Total de tiers: " .. #tiers)

if #tiers == 10 then
	print("✅ 10 tiers de rebirth encontrados")
else
	print("❌ Número incorreto de tiers: " .. #tiers)
	allPassed = false
end

-- Verificar alguns tiers específicos
for _, expected in ipairs(expectedTiers) do
	local found = false
	for _, tier in ipairs(tiers) do
		if tier.level == expected.level and tier.multiplier == expected.mult then
			found = true
			break
		end
	end

	if found then
		print("✅ Tier Level " .. expected.level .. " → " .. expected.mult .. "x")
	else
		print("❌ Tier Level " .. expected.level .. " NÃO ENCONTRADO")
		allPassed = false
	end
end

print("\n")

-- ==================== TESTE 4: TOTALXP CALCULATION ====================
print("📈 TESTE 4: Verificando TotalXP até Milestones")
print("----------------------------------------")

local function calculateTotalXP(targetLevel)
	local total = 0
	for level = 1, targetLevel - 1 do
		total = total + ProgressionMath.XPRequired(level)
	end
	return total
end

local milestones = {
	{level = 10, expectedMax = 2500, desc = "Level 10 (early game)"},
	{level = 25, expectedMax = 20000, desc = "Level 25 (primeiro rebirth)"},
	{level = 50, expectedMax = 160000, desc = "Level 50 (segundo rebirth)"},
}

for _, milestone in ipairs(milestones) do
	local totalXP = calculateTotalXP(milestone.level)

	if totalXP < milestone.expectedMax then
		print("✅ " .. milestone.desc)
		print("   TotalXP: " .. string.format("%d", totalXP) .. " (< " .. milestone.expectedMax .. ")")
	else
		print("❌ " .. milestone.desc)
		print("   TotalXP: " .. string.format("%d", totalXP) .. " (>= " .. milestone.expectedMax .. ")")
		print("   ⚠️ Progressão muito lenta!")
		allPassed = false
	end
end

print("\n")

-- ==================== TESTE 5: CONFIG CONSISTENCY ====================
print("⚙️ TESTE 5: Verificando Consistência de Configs")
print("----------------------------------------")

local formula = ProgressionConfig.FORMULA

print("Tipo de fórmula: " .. (formula.type or "UNDEFINED"))
print("BASE: " .. (formula.BASE or "UNDEFINED"))
print("SCALE: " .. (formula.SCALE or "UNDEFINED"))
print("EXPONENT: " .. (formula.EXPONENT or "UNDEFINED"))

if formula.type == "mixed" and formula.BASE == 50 and formula.SCALE == 25 and formula.EXPONENT == 1.45 then
	print("✅ Config correto (BASE=50, SCALE=25, EXPONENT=1.45)")
else
	print("❌ Config incorreto ou desatualizado")
	allPassed = false
end

print("\n")

-- ==================== TESTE 6: COMPARAÇÃO COM FÓRMULA ANTIGA ====================
print("📊 TESTE 6: Comparação com Progressão Antiga")
print("----------------------------------------")

local oldFormula = function(level)
	return math.floor(100 + 50 * (level ^ 1.55))
end

local improvements = {
	{level = 10, desc = "Level 10"},
	{level = 25, desc = "Level 25"},
}

for _, test in ipairs(improvements) do
	local newXP = ProgressionMath.XPRequired(test.level)
	local oldXP = oldFormula(test.level)
	local improvement = ((oldXP - newXP) / oldXP) * 100

	print(test.desc .. ":")
	print("  Antiga: " .. oldXP .. " XP")
	print("  Nova: " .. newXP .. " XP")
	print("  Melhoria: " .. string.format("%.1f", improvement) .. "% mais rápido")

	if improvement > 30 then
		print("  ✅ Progressão significativamente mais rápida")
	else
		print("  ❌ Melhoria insuficiente")
		allPassed = false
	end
end

print("\n")

-- ==================== RESULTADO FINAL ====================
print("========================================")
if allPassed then
	print("✅ TODOS OS TESTES PASSARAM!")
	print("========================================")
	print("🎉 Progressão está funcionando corretamente!")
	print("🎮 O jogo está pronto para ser testado!")
else
	print("❌ ALGUNS TESTES FALHARAM!")
	print("========================================")
	print("⚠️ A progressão NÃO está funcionando como esperado.")
	print("🔧 Verifique se você sincronizou via Rojo:")
	print("   1. Terminal: rojo serve default.project.json")
	print("   2. Studio: Plugins → Rojo → Connect → Sync In")
	print("   3. Studio: File → Save")
	print("   4. Rode este teste novamente")
end
print("\n")

-- ==================== TESTE BÔNUS: VALORES ESPECÍFICOS ====================
print("🎁 TESTE BÔNUS: Valores Específicos do Usuário")
print("----------------------------------------")
print("Você reportou ver 1,870 XP no Level 10.")
print("Vamos verificar o que está acontecendo:")
print("")

local xp10_actual = ProgressionMath.XPRequired(10)
print("XPRequired(10) atual: " .. xp10_actual .. " XP")

if xp10_actual >= 1800 and xp10_actual <= 1900 then
	print("❌ FÓRMULA ANTIGA AINDA ATIVA!")
	print("   Isso significa que o Rojo NÃO sincronizou.")
	print("   Execute: rojo serve default.project.json")
	print("   Depois: Sync In no Studio")
elseif xp10_actual >= 380 and xp10_actual <= 450 then
	print("✅ NOVA FÓRMULA ATIVA!")
	print("   Perfeito! A progressão adaptativa está funcionando.")
else
	print("⚠️ VALOR INESPERADO!")
	print("   Pode haver um problema de sincronização.")
end

print("\n")
print("========================================")
print("📝 ANOTE ESTE VALOR: XPRequired(10) = " .. xp10_actual)
print("========================================")
print("\n")
