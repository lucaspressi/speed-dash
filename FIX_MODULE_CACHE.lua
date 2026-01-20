-- FIX_MODULE_CACHE.lua
-- Corrige o cache do require() deletando e recriando os módulos
-- ✅ Cole este código no Command Bar do Roblox Studio e execute

print("\n")
print("========================================")
print("🔧 CORRIGINDO CACHE DE MÓDULOS")
print("========================================")
print("\n")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:FindFirstChild("Shared")

if not shared then
    print("❌ ReplicatedStorage.Shared não encontrado!")
    return
end

local progressionConfig = shared:FindFirstChild("ProgressionConfig")
local progressionMath = shared:FindFirstChild("ProgressionMath")

print("📦 Módulos encontrados:")
print("   ProgressionConfig: " .. tostring(progressionConfig ~= nil))
print("   ProgressionMath: " .. tostring(progressionMath ~= nil))
print("")

-- ==================== DELETAR MÓDULOS ====================
print("🗑️ PASSO 1: Deletando módulos cacheados...")

if progressionConfig then
    progressionConfig:Destroy()
    print("   ✅ ProgressionConfig deletado")
else
    print("   ⚠️ ProgressionConfig já estava ausente")
end

if progressionMath then
    progressionMath:Destroy()
    print("   ✅ ProgressionMath deletado")
else
    print("   ⚠️ ProgressionMath já estava ausente")
end

print("")

-- ==================== INSTRUÇÕES ====================
print("========================================")
print("📋 PRÓXIMOS PASSOS (MANUAL)")
print("========================================")
print("")
print("1. No Roblox Studio:")
print("   → Plugins → Rojo → Sync In")
print("")
print("2. Verifique que os módulos foram recriados:")
print("   → ReplicatedStorage → Shared → ProgressionConfig")
print("   → ReplicatedStorage → Shared → ProgressionMath")
print("")
print("3. Execute este teste no Command Bar:")
print("")
print("   local PM = require(game.ReplicatedStorage.Shared.ProgressionMath)")
print("   print(\"XPRequired(10) = \" .. PM.XPRequired(10))")
print("")
print("   Esperado: ~403 XP")
print("   Se retornar 1874 XP, o cache ainda está ativo.")
print("")
print("4. Se ainda retornar 1874:")
print("   → File → Save")
print("   → FECHE o Studio completamente")
print("   → Reabra o Studio")
print("   → Rode o teste novamente")
print("")
print("========================================")
print("")
