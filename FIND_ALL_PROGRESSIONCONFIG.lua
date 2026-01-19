-- FIND_ALL_PROGRESSIONCONFIG.lua
-- Encontra TODAS as cópias de ProgressionConfig no jogo
-- ✅ Cole este código no Command Bar do Roblox Studio e execute

print("\n")
print("========================================")
print("🔍 BUSCANDO TODAS AS CÓPIAS DE ProgressionConfig")
print("========================================")
print("\n")

local function findAllDescendants(parent, name)
    local results = {}
    for _, child in ipairs(parent:GetDescendants()) do
        if child.Name == name then
            table.insert(results, child)
        end
    end
    return results
end

local allConfigs = {}

-- Buscar em todos os services
local services = {
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterPlayer"),
    game:GetService("StarterPack"),
    game:GetService("StarterGui"),
    game:GetService("Workspace"),
    game:GetService("Lighting"),
}

print("📁 Buscando em todos os services...")
print("")

for _, service in ipairs(services) do
    local found = findAllDescendants(service, "ProgressionConfig")
    for _, config in ipairs(found) do
        table.insert(allConfigs, config)
    end
end

if #allConfigs == 0 then
    print("❌ NENHUMA cópia de ProgressionConfig encontrada!")
    print("   Isso é MUITO ESTRANHO.")
    print("   O Rojo deveria ter criado ReplicatedStorage.Shared.ProgressionConfig")
    print("\n")
    return
end

print("✅ Encontradas " .. #allConfigs .. " cópia(s) de ProgressionConfig")
print("\n")

-- Analisar cada cópia
for i, config in ipairs(allConfigs) do
    print("========================================")
    print("📦 CÓPIA #" .. i)
    print("========================================")
    print("Path: " .. config:GetFullName())
    print("Tipo: " .. config.ClassName)
    print("")

    if config:IsA("ModuleScript") then
        print("Source Code Length: " .. #config.Source .. " caracteres")
        print("")

        -- Procurar valores no source
        local source = config.Source

        -- Procurar BASE
        if string.find(source, "BASE%s*=%s*50") then
            print("✅ BASE = 50 (NOVO - CORRETO)")
        elseif string.find(source, "BASE%s*=%s*100") then
            print("❌ BASE = 100 (ANTIGO - INCORRETO)")
        else
            print("⚠️ BASE não encontrado no source")
        end

        -- Procurar SCALE
        if string.find(source, "SCALE%s*=%s*25") then
            print("✅ SCALE = 25 (NOVO - CORRETO)")
        elseif string.find(source, "SCALE%s*=%s*50") then
            print("❌ SCALE = 50 (ANTIGO - INCORRETO)")
        else
            print("⚠️ SCALE não encontrado no source")
        end

        -- Procurar EXPONENT
        if string.find(source, "EXPONENT%s*=%s*1%.45") then
            print("✅ EXPONENT = 1.45 (NOVO - CORRETO)")
        elseif string.find(source, "EXPONENT%s*=%s*1%.55") then
            print("❌ EXPONENT = 1.55 (ANTIGO - INCORRETO)")
        else
            print("⚠️ EXPONENT não encontrado no source")
        end

        print("")

        -- Tentar carregar o módulo
        print("🧪 Tentando carregar módulo...")
        local success, result = pcall(function()
            return require(config)
        end)

        if success then
            print("✅ Módulo carregado com sucesso")
            if result.FORMULA then
                print("   FORMULA:")
                print("     type: " .. tostring(result.FORMULA.type))
                print("     BASE: " .. tostring(result.FORMULA.BASE))
                print("     SCALE: " .. tostring(result.FORMULA.SCALE))
                print("     EXPONENT: " .. tostring(result.FORMULA.EXPONENT))

                if result.FORMULA.BASE == 50 and result.FORMULA.SCALE == 25 and result.FORMULA.EXPONENT == 1.45 then
                    print("   ✅ VALORES CORRETOS NO MÓDULO CARREGADO")
                else
                    print("   ❌ VALORES INCORRETOS NO MÓDULO CARREGADO")
                end
            else
                print("   ⚠️ Módulo não tem FORMULA")
            end
        else
            print("❌ ERRO ao carregar módulo:")
            print("   " .. tostring(result))
        end
    else
        print("⚠️ Este objeto NÃO é um ModuleScript")
    end

    print("")
end

print("========================================")
print("📊 RESUMO")
print("========================================")
print("")

if #allConfigs == 1 then
    print("✅ Apenas UMA cópia encontrada (esperado)")
    print("   Se os valores estiverem incorretos, o problema é:")
    print("   1. O Rojo não sincronizou corretamente")
    print("   2. Ou há cache do require() no Studio")
elseif #allConfigs > 1 then
    print("⚠️ MÚLTIPLAS CÓPIAS ENCONTRADAS!")
    print("   Isso pode causar conflitos.")
    print("   Recomendação:")
    print("   1. Delete TODAS as cópias manualmente")
    print("   2. Faça Sync In via Rojo novamente")
    print("   3. Verifique que só há 1 cópia em ReplicatedStorage.Shared")
end

print("\n")
print("========================================")
print("")
