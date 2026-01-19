--[[
    SCRIPT AUXILIAR: Criar ImageLabels para avatares na Leaderboard

    COMO USAR:
    1. Abra o Roblox Studio
    2. Copie TODO este script
    3. Cole no Command Bar (View > Command Bar)
    4. Pressione Enter para executar

    Este script vai criar automaticamente os ImageLabels Avatar1-Avatar10
    nas pastas Avatars de ambas leaderboards (Speed e Wins)
]]

local workspace = game:GetService("Workspace")

-- Função para criar ImageLabels em uma leaderboard
local function createAvatarImageLabels(leaderboardName)
    local leaderboard = workspace:FindFirstChild(leaderboardName)

    if not leaderboard then
        warn("❌ " .. leaderboardName .. " não encontrada!")
        return
    end

    local scoreBlock = leaderboard:FindFirstChild("ScoreBlock")
    if not scoreBlock then
        warn("❌ ScoreBlock não encontrada em " .. leaderboardName)
        return
    end

    local surfaceGui = scoreBlock:FindFirstChild("Leaderboard")
    if not surfaceGui then
        warn("❌ SurfaceGui 'Leaderboard' não encontrada em " .. leaderboardName)
        return
    end

    -- Criar pasta Avatars se não existir
    local avatarsFolder = surfaceGui:FindFirstChild("Avatars")
    if not avatarsFolder then
        avatarsFolder = Instance.new("Folder")
        avatarsFolder.Name = "Avatars"
        avatarsFolder.Parent = surfaceGui
        print("✅ Pasta 'Avatars' criada em " .. leaderboardName)
    else
        print("ℹ️ Pasta 'Avatars' já existe em " .. leaderboardName)
    end

    -- Criar 10 ImageLabels
    for i = 1, 10 do
        local avatarName = "Avatar" .. i
        local existingAvatar = avatarsFolder:FindFirstChild(avatarName)

        if existingAvatar then
            print("ℹ️ " .. avatarName .. " já existe, pulando...")
        else
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Name = avatarName

            -- Posição: à esquerda, espaçado verticalmente
            -- Ajuste esses valores conforme necessário para sua leaderboard
            local avatarSize = 80
            local spacing = avatarSize + 10
            imageLabel.Position = UDim2.new(0, 25, 0, 10 + (i - 1) * spacing)
            imageLabel.Size = UDim2.new(0, avatarSize, 0, avatarSize)

            -- Aparência
            imageLabel.BackgroundTransparency = 1
            imageLabel.BorderSizePixel = 0
            imageLabel.ScaleType = Enum.ScaleType.Fit
            imageLabel.Image = "" -- Será preenchido pelo script

            -- Adicionar UICorner para deixar circular
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(1, 0) -- Totalmente redondo
            uiCorner.Parent = imageLabel

            imageLabel.Parent = avatarsFolder
            print("✅ Criado " .. avatarName .. " em " .. leaderboardName)
        end
    end

    print("🎉 ImageLabels criados com sucesso em " .. leaderboardName .. "!")
end

-- Criar ImageLabels nas duas leaderboards
print("🚀 Iniciando criação de ImageLabels...")
print("")

createAvatarImageLabels("SpeedLeaderboard")
print("")
createAvatarImageLabels("WinsLeaderboard")

print("")
print("✨ CONCLUÍDO! Agora teste o jogo e as miniaturas devem aparecer automaticamente.")
print("📝 Se precisar ajustar a posição, edite os valores em Position no Explorer.")
