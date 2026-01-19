--[[
    TESTAR AVATARES COM FUNDO VERMELHO

    Este script coloca fundo vermelho nos avatares para você ver onde estão
]]

local ws = game:GetService("Workspace")

print("========================================")
print("🔴 TESTANDO AVATARES COM FUNDO VERMELHO")
print("========================================")

for _, n in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    local l = ws:FindFirstChild(n)
    if l then
        local sg = l:FindFirstChild("ScoreBlock") and l.ScoreBlock:FindFirstChild("Leaderboard")
        if sg then
            local af = sg:FindFirstChild("Avatars")
            if af then
                print("\n📊 " .. n .. ":")
                for i = 1, 10 do
                    local av = af:FindFirstChild("Avatar" .. i)
                    if av and av:IsA("ImageLabel") then
                        -- Forçar visibilidade
                        av.Visible = true
                        av.ZIndex = 10

                        -- Posição simples e visível
                        av.Position = UDim2.new(0, 20, 0, 20 + (i - 1) * 40)
                        av.Size = UDim2.new(0, 50, 0, 50)

                        -- FUNDO VERMELHO para ver onde está
                        av.BackgroundColor3 = Color3.new(1, 0, 0)
                        av.BackgroundTransparency = 0

                        print(string.format("  Avatar%d: X=%d, Y=%d",
                            i, av.Position.X.Offset, av.Position.Y.Offset))
                    else
                        warn("  Avatar" .. i .. " não encontrado!")
                    end
                end
            else
                warn("❌ Pasta Avatars não encontrada em " .. n)
            end
        else
            warn("❌ SurfaceGui não encontrada em " .. n)
        end
    else
        warn("❌ " .. n .. " não encontrada!")
    end
end

print("\n========================================")
print("✅ TESTE COMPLETO!")
print("Se você VER quadrados VERMELHOS na leaderboard,")
print("os avatares estão lá mas algo está errado com as imagens.")
print("Se NÃO VER NADA, há um problema de posicionamento.")
print("========================================")
