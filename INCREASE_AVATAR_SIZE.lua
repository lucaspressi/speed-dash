--[[
    AUMENTAR TAMANHO DOS AVATARES

    Este script permite você testar diferentes tamanhos.
    Ajuste a variável AVATAR_SIZE abaixo:
]]

-- ⭐ AJUSTE AQUI O TAMANHO DOS AVATARES ⭐
local AVATAR_SIZE = 80  -- Tente 80, 100, ou 120

local workspace = game:GetService("Workspace")

print("========================================")
print("🔧 AUMENTANDO AVATARES PARA " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE)
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n📊 Processando: " .. lbName)

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

    -- Calcular espaçamento vertical baseado no tamanho
    local spacing = AVATAR_SIZE + 10  -- 10 pixels de espaço entre avatares

    for i = 1, 10 do
        local avatarName = "Avatar" .. i
        local img = avatarsFolder:FindFirstChild(avatarName)

        if img and img:IsA("ImageLabel") then
            -- Definir novo tamanho
            img.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)

            -- Ajustar posição vertical com espaçamento
            img.Position = UDim2.new(0, 25, 0, 10 + (i-1) * spacing)

            -- Garantir que está configurado corretamente
            img.BackgroundTransparency = 1
            img.BorderSizePixel = 0
            img.ScaleType = Enum.ScaleType.Fit

            -- Verificar se tem UICorner para deixar redondo
            local corner = img:FindFirstChild("UICorner")
            if corner then
                corner.CornerRadius = UDim.new(1, 0)
            end

            print("✅ " .. avatarName .. ": " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE .. " px")
        else
            warn("❌ " .. avatarName .. " não encontrado!")
        end
    end

    print("✅ " .. lbName .. " atualizada!")
end

print("\n========================================")
print("✨ CONCLUÍDO!")
print("Tamanho dos avatares: " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE .. " pixels")
print("========================================")
print("Se ficou muito grande ou pequeno:")
print("1. Edite a linha 8 do script (AVATAR_SIZE)")
print("2. Rode novamente")
print("3. Depois salve: File > Save + Publish")
print("========================================")
