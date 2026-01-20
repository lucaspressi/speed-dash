-- DISABLE_FLOAT_ANIMATION.lua
-- Script de emergência para desabilitar FloatAnimation e parar crashes
-- ✅ Cole no Command Bar do Roblox Studio e execute

print("\n")
print("========================================")
print("🛑 DESABILITANDO FLOATANIMATION")
print("========================================")
print("\n")

local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local count = 0

-- Buscar todos os FloatAnimation scripts
for _, gui in ipairs(playerGui:GetDescendants()) do
    if gui:IsA("LocalScript") and gui.Name == "FloatAnimation" then
        gui.Disabled = true
        count = count + 1
        print("🛑 Desabilitado: " .. gui:GetFullName())
    end
end

print("\n")
print("========================================")
print("✅ " .. count .. " FloatAnimation(s) desabilitado(s)")
print("   Studio NÃO deve crashar mais")
print("========================================")
print("\n")
