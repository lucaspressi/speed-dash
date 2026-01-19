--[[
    DIAGNÓSTICO E LIMPEZA DE AVATARES

    Este script vai:
    1. Mostrar o que está em cada ImageLabel
    2. Limpar TUDO
    3. Mostrar o resultado
]]

local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

print("========================================")
print("🔍 DIAGNÓSTICO DE AVATARES")
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n📊 Verificando: " .. lbName)

    local lb = workspace:FindFirstChild(lbName)
    if not lb then
        warn("❌ " .. lbName .. " não encontrada!")
        continue
    end

    local scoreBlock = lb:FindFirstChild("ScoreBlock")
    if not scoreBlock then
        warn("❌ ScoreBlock não encontrada!")
        continue
    end

    local surfaceGui = scoreBlock:FindFirstChild("Leaderboard")
    if not surfaceGui then
        warn("❌ SurfaceGui não encontrada!")
        continue
    end

    local avatarsFolder = surfaceGui:FindFirstChild("Avatars")
    if not avatarsFolder then
        warn("❌ Pasta Avatars não encontrada!")
        continue
    end

    print("✅ Estrutura OK, verificando ImageLabels...")
    print("")

    for i = 1, 10 do
        local avatarName = "Avatar" .. i
        local img = avatarsFolder:FindFirstChild(avatarName)

        if img and img:IsA("ImageLabel") then
            -- Mostrar o que tem atualmente
            if img.Image ~= "" then
                print("🖼️  " .. avatarName .. " tem imagem: " .. string.sub(img.Image, 1, 50))
            else
                print("⚪ " .. avatarName .. " está vazio (OK)")
            end

            -- LIMPAR FORÇADAMENTE
            img.Image = ""
            img.BackgroundTransparency = 1
            img.BorderSizePixel = 0

            -- Garantir tamanho correto
            img.Size = UDim2.new(0, 60, 0, 60)
            img.Position = UDim2.new(0, 20, 0, 5 + (i-1)*38)

            print("   ✅ LIMPO e redimensionado")
        else
            warn("   ❌ " .. avatarName .. " não existe ou não é ImageLabel!")
        end
    end
end

print("\n========================================")
print("✨ LIMPEZA CONCLUÍDA!")
print("========================================")
print("⚠️  IMPORTANTE:")
print("1. Vá em File > Save (Ctrl+S)")
print("2. Vá em File > Publish to Roblox")
print("3. Rode o jogo novamente")
print("========================================")
