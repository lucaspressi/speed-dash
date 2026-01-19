--[[
    RESETAR AVATARES PARA POSIÇÃO SEGURA

    Este script vai resetar os avatares para uma posição visível e segura
]]

local ws = game:GetService("Workspace")

print("========================================")
print("🔧 RESETANDO AVATARES")
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n📊 Processando: " .. lbName)

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
            -- Resetar para posição segura
            local nameX = nm.Position.X.Offset
            local nameY = nm.Position.Y.Offset

            -- Avatar à esquerda do nome, alinhado verticalmente
            av.Size = UDim2.new(0, 50, 0, 50)
            av.Position = UDim2.new(0, nameX - 60, 0, nameY)
            av.BackgroundTransparency = 1
            av.BorderSizePixel = 0
            av.ScaleType = Enum.ScaleType.Fit
            av.Visible = true

            print(string.format("✅ Avatar%d resetado para X=%d, Y=%d",
                i, nameX - 60, nameY))

            -- Mostrar se tem imagem carregada
            if av.Image ~= "" then
                print("   🖼️  Tem imagem: " .. string.sub(av.Image, 1, 40) .. "...")
            else
                print("   ⚪ Sem imagem (aguardando carregamento)")
            end
        end
    end
end

print("\n========================================")
print("✨ RESET COMPLETO!")
print("Os avatares devem estar visíveis agora")
print("Salve (Ctrl+S) e Publique o jogo")
print("========================================")
