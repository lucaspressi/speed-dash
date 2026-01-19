--[[
    ALINHAR AVATARES COM OS NOMES

    Este script vai:
    1. Detectar a posição dos nomes (Name1-Name10)
    2. Alinhar os avatares com os nomes
    3. Ajustar o tamanho dos avatares
]]

local workspace = game:GetService("Workspace")

-- Tamanho dos avatares (ajuste aqui se quiser maior/menor)
local AVATAR_SIZE = 50  -- Diminuído de 70 para 50
local AVATAR_OFFSET_X = -60  -- Quanto à esquerda do nome (negativo = esquerda)
local AVATAR_OFFSET_Y = -5  -- Ajuste vertical em relação ao nome (negativo = sobe)

print("========================================")
print("🎯 ALINHANDO AVATARES COM OS NOMES")
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n📊 Processando: " .. lbName)

    local lb = workspace:FindFirstChild(lbName)
    if not lb then
        warn("❌ " .. lbName .. " não encontrada!")
        continue
    end

    local sg = lb:FindFirstChild("ScoreBlock") and lb.ScoreBlock:FindFirstChild("Leaderboard")
    if not sg then
        warn("❌ SurfaceGui não encontrada!")
        continue
    end

    local namesFolder = sg:FindFirstChild("Names")
    local avatarsFolder = sg:FindFirstChild("Avatars")

    if not namesFolder then
        warn("❌ Pasta 'Names' não encontrada!")
        continue
    end

    if not avatarsFolder then
        warn("❌ Pasta 'Avatars' não encontrada!")
        continue
    end

    print("✅ Estrutura OK, alinhando...")

    for i = 1, 10 do
        local nameLabel = namesFolder:FindFirstChild("Name" .. i)
        local avatarImage = avatarsFolder:FindFirstChild("Avatar" .. i)

        if nameLabel and avatarImage and avatarImage:IsA("ImageLabel") then
            -- Pegar a posição do nome
            local namePos = nameLabel.Position
            local nameSize = nameLabel.Size

            -- Calcular posição do avatar alinhado com o nome
            -- Avatar ficará à esquerda do nome, alinhado verticalmente ao centro
            local avatarX = namePos.X.Offset + AVATAR_OFFSET_X
            local avatarY = namePos.Y.Offset + AVATAR_OFFSET_Y

            -- Aplicar nova posição e tamanho
            avatarImage.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)
            avatarImage.Position = UDim2.new(0, avatarX, 0, avatarY)

            -- Garantir configurações corretas
            avatarImage.BackgroundTransparency = 1
            avatarImage.BorderSizePixel = 0
            avatarImage.ScaleType = Enum.ScaleType.Fit

            -- Verificar UICorner
            local corner = avatarImage:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = UDim.new(1, 0)
            end

            print(string.format("✅ Avatar%d alinhado: X=%d, Y=%d (baseado em Name%d)",
                i, avatarX, avatarY, i))
        else
            if not nameLabel then
                warn("⚠️  Name" .. i .. " não encontrado!")
            end
            if not avatarImage then
                warn("⚠️  Avatar" .. i .. " não encontrado!")
            end
        end
    end

    print("✅ " .. lbName .. " concluída!")
end

print("\n========================================")
print("✨ ALINHAMENTO CONCLUÍDO!")
print("========================================")
print("Tamanho dos avatares: " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE .. " px")
print("Offset horizontal: " .. AVATAR_OFFSET_X .. " px (à esquerda do nome)")
print("Offset vertical: " .. AVATAR_OFFSET_Y .. " px")
print("\n📝 Se precisar ajustar:")
print("- Edite AVATAR_SIZE (linha 10) para mudar o tamanho")
print("- Edite AVATAR_OFFSET_X (linha 11) para mover horizontalmente")
print("- Edite AVATAR_OFFSET_Y (linha 12) para mover verticalmente")
print("\n⚠️  Depois: File > Save + Publish")
print("========================================")
