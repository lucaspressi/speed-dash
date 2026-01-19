-- FORCE_RELOAD_MODULES.lua
-- Força o reload dos módulos de progressão, limpando o cache
-- ✅ Cole este código no Command Bar do Roblox Studio e execute

print("\n")
print("========================================")
print("🔄 FORÇANDO RELOAD DOS MÓDULOS")
print("========================================")
print("\n")

-- ==================== LIMPAR PACKAGE.LOADED ====================
print("🧹 TESTE 1: Limpando cache de require()")
print("----------------------------------------")

-- Limpar cache do Luau
if package.loaded then
    local cleared = 0
    for key, _ in pairs(package.loaded) do
        if type(key) == "string" then
            if string.find(key, "Progression") or string.find(key, "Config") then
                print("  Limpando: " .. key)
                package.loaded[key] = nil
                cleared = cleared + 1
            end
        end
    end

    if cleared > 0 then
        print("✅ " .. cleared .. " módulo(s) removido(s) do cache")
    else
        print("⚠️ Nenhum módulo relacionado encontrado no cache")
        print("   (Isso pode ser normal no Roblox)")
    end
else
    print("⚠️ package.loaded não disponível")
    print("   (Isso é normal no Roblox - o cache é gerenciado internamente)")
end

print("\n")

-- ==================== RECARREGAR MÓDULOS ====================
print("📦 TESTE 2: Recarregando módulos frescos")
print("----------------------------------------")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:FindFirstChild("Shared")

if not shared then
    print("❌ ReplicatedStorage.Shared não encontrado!")
    print("   Execute o script FIND_ALL_PROGRESSIONCONFIG primeiro")
    print("\n")
    return
end

local progressionConfig = shared:FindFirstChild("ProgressionConfig")
local progressionMath = shared:FindFirstChild("ProgressionMath")

if not progressionConfig or not progressionMath then
    print("❌ Módulos não encontrados em Shared")
    print("   ProgressionConfig: " .. tostring(progressionConfig ~= nil))
    print("   ProgressionMath: " .. tostring(progressionMath ~= nil))
    print("\n")
    return
end

print("✅ Módulos encontrados")
print("   ProgressionConfig: " .. progressionConfig:GetFullName())
print("   ProgressionMath: " .. progressionMath:GetFullName())
print("\n")

-- ==================== VERIFICAR SOURCE CODE ====================
print("📝 TESTE 3: Verificando source code")
print("----------------------------------------")

if progressionConfig:IsA("ModuleScript") then
    local source = progressionConfig.Source
    print("ProgressionConfig.Source length: " .. #source .. " caracteres")

    -- Verificar valores no source
    if string.find(source, "BASE%s*=%s*50") then
        print("  ✅ Source contém 'BASE = 50'")
    elseif string.find(source, "BASE%s*=%s*100") then
        print("  ❌ Source contém 'BASE = 100' (VALOR ANTIGO!)")
    else
        print("  ⚠️ BASE não encontrado")
    end

    if string.find(source, "SCALE%s*=%s*25") then
        print("  ✅ Source contém 'SCALE = 25'")
    elseif string.find(source, "SCALE%s*=%s*50") then
        print("  ❌ Source contém 'SCALE = 50' (VALOR ANTIGO!)")
    else
        print("  ⚠️ SCALE não encontrado")
    end

    if string.find(source, "EXPONENT%s*=%s*1%.45") then
        print("  ✅ Source contém 'EXPONENT = 1.45'")
    elseif string.find(source, "EXPONENT%s*=%s*1%.55") then
        print("  ❌ Source contém 'EXPONENT = 1.55' (VALOR ANTIGO!)")
    else
        print("  ⚠️ EXPONENT não encontrado")
    end
end

print("\n")

-- ==================== CARREGAR MÓDULOS ====================
print("🔄 TESTE 4: Carregando módulos")
print("----------------------------------------")

local configModule, mathModule

local success1, result1 = pcall(function()
    return require(progressionConfig)
end)

if success1 then
    configModule = result1
    print("✅ ProgressionConfig carregado")
else
    print("❌ Erro ao carregar ProgressionConfig:")
    print("   " .. tostring(result1))
    print("\n")
    return
end

local success2, result2 = pcall(function()
    return require(progressionMath)
end)

if success2 then
    mathModule = result2
    print("✅ ProgressionMath carregado")
else
    print("❌ Erro ao carregar ProgressionMath:")
    print("   " .. tostring(result2))
    print("\n")
    return
end

print("\n")

-- ==================== VERIFICAR VALORES CARREGADOS ====================
print("🔍 TESTE 5: Verificando valores carregados")
print("----------------------------------------")

if configModule and configModule.FORMULA then
    local formula = configModule.FORMULA
    print("ProgressionConfig.FORMULA:")
    print("  type: " .. tostring(formula.type))
    print("  BASE: " .. tostring(formula.BASE))
    print("  SCALE: " .. tostring(formula.SCALE))
    print("  EXPONENT: " .. tostring(formula.EXPONENT))
    print("")

    if formula.BASE == 50 and formula.SCALE == 25 and formula.EXPONENT == 1.45 then
        print("✅ VALORES CORRETOS!")
    else
        print("❌ VALORES INCORRETOS!")
        print("")
        print("   Esperado: BASE=50, SCALE=25, EXPONENT=1.45")
        print("   Encontrado: BASE=" .. formula.BASE .. ", SCALE=" .. formula.SCALE .. ", EXPONENT=" .. formula.EXPONENT)
    end
end

print("\n")

-- ==================== TESTAR XPRequired ====================
print("🧪 TESTE 6: Testando XPRequired()")
print("----------------------------------------")

if mathModule and mathModule.XPRequired then
    local tests = {
        {level = 1, expectedMin = 70, expectedMax = 80, desc = "Level 1"},
        {level = 10, expectedMin = 380, expectedMax = 450, desc = "Level 10"},
        {level = 25, expectedMin = 1600, expectedMax = 1800, desc = "Level 25"},
    }

    local allCorrect = true

    for _, test in ipairs(tests) do
        local actual = mathModule.XPRequired(test.level)
        local isCorrect = actual >= test.expectedMin and actual <= test.expectedMax

        if isCorrect then
            print("✅ " .. test.desc .. ": " .. actual .. " XP (esperado: " .. test.expectedMin .. "-" .. test.expectedMax .. ")")
        else
            print("❌ " .. test.desc .. ": " .. actual .. " XP (esperado: " .. test.expectedMin .. "-" .. test.expectedMax .. ")")
            allCorrect = false
        end
    end

    print("")

    if allCorrect then
        print("✅ TODOS OS TESTES PASSARAM!")
        print("   A nova fórmula está funcionando corretamente.")
    else
        print("❌ ALGUNS TESTES FALHARAM!")
        print("   A fórmula antiga ainda está ativa.")
    end
end

print("\n")

-- ==================== DIAGNÓSTICO FINAL ====================
print("========================================")
print("📊 DIAGNÓSTICO FINAL")
print("========================================")
print("")

local sourceHasNewValues = progressionConfig:IsA("ModuleScript") and string.find(progressionConfig.Source, "BASE%s*=%s*50")
local moduleHasNewValues = configModule and configModule.FORMULA and configModule.FORMULA.BASE == 50
local xpIsCorrect = mathModule and mathModule.XPRequired and mathModule.XPRequired(10) >= 380 and mathModule.XPRequired(10) <= 450

print("Source code tem valores novos: " .. tostring(sourceHasNewValues))
print("Módulo carregado tem valores novos: " .. tostring(moduleHasNewValues))
print("XPRequired() retorna valores corretos: " .. tostring(xpIsCorrect))
print("")

if sourceHasNewValues and moduleHasNewValues and xpIsCorrect then
    print("✅ TUDO ESTÁ CORRETO!")
    print("   O Rojo sincronizou e a fórmula está funcionando.")
    print("")
    print("   Se ainda vê valores antigos no jogo:")
    print("   1. REINICIE o Roblox Studio completamente (File → Exit)")
    print("   2. Abra o Studio novamente")
    print("   3. Teste o jogo (Play)")
    print("   4. Verifique os valores no jogo")
elseif sourceHasNewValues and not moduleHasNewValues then
    print("⚠️ CACHE DO REQUIRE()")
    print("   O source code está correto, mas o módulo carregado tem valores antigos.")
    print("   Solução: REINICIE o Roblox Studio completamente")
elseif not sourceHasNewValues then
    print("❌ SOURCE CODE DESATUALIZADO!")
    print("   O Rojo NÃO sincronizou os valores novos.")
    print("")
    print("   Passos para corrigir:")
    print("   1. Feche o Studio")
    print("   2. No terminal: rojo serve default.project.json")
    print("   3. Abra o Studio")
    print("   4. Plugins → Rojo → Connect → Sync In")
    print("   5. File → Save")
    print("   6. Rode este script novamente")
else
    print("⚠️ PROBLEMA DESCONHECIDO")
    print("   Execute o script FIND_ALL_PROGRESSIONCONFIG para mais detalhes")
end

print("\n")
print("========================================")
print("")
