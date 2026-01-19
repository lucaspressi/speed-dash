--[[
    CORRIGIR POSIÇÃO DOS AVATARES DEFINITIVAMENTE

    Este script vai:
    1. Detectar onde estão os nomes
    2. Posicionar os avatares corretamente
    3. Garantir que fiquem visíveis
]]

local ws = game:GetService("Workspace")

print("========================================")
print("🔧 CORRIGINDO POSIÇÃO DOS AVATARES")
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n📊 " .. lbName)

    local lb = ws:FindFirstChild(lbName)
    if not lb then continue end

    local sg = lb:FindFirstChild("ScoreBlock") and lb.ScoreBlock:FindFirstChild("Leaderboard")
    if not sg then continue end

    local nf = sg:FindFirstChild("Names")
    local af = sg:FindFirstChild("Avatars")

    if not nf or not af then
        warn("Names ou Avatars não encontrados!")
        continue
    end

    for i = 1, 10 do
        local nm = nf:FindFirstChild("Name" .. i)
        local av = af:FindFirstChild("Avatar" .. i)

        if nm and av and av:IsA("ImageLabel") then
            -- Pegar posição do nome
            local nameX = nm.Position.X.Offset
            local nameY = nm.Position.Y.Offset

            -- POSICIONAR AVATAR
            -- Se o nome está muito à esquerda, colocar avatar antes
            local avatarX = nameX - 65  -- 65 pixels à esquerda do nome

            -- Se ficar negativo, ajustar para dentro da tela
            if avatarX < 5 then
                avatarX = 5  -- Mínimo de 5 pixels da borda
            end

            -- Ajustar Y para alinhar com o nome (subir 5px)
            local avatarY = nameY - 5

            -- Aplicar nova posição
            av.Position = UDim2.new(0, avatarX, 0, avatarY)
            av.Size = UDim2.new(0, 50, 0, 50)
            av.Visible = true
            av.BackgroundTransparency = 1
            av.BorderSizePixel = 0
            av.ZIndex = 2

            print(string.format("  Avatar%d: Name está em (%d, %d) → Avatar em (%d, %d)",
                i, nameX, nameY, avatarX, avatarY))
        end
    end

    print("✅ " .. lbName .. " corrigida!")
end

print("\n========================================")
print("✨ CORREÇÃO COMPLETA!")
print("Agora os avatares devem estar visíveis!")
print("⚠️  Salve (Ctrl+S) e Publique o jogo")
print("========================================")
