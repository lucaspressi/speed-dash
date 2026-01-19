--[[
    SCRIPT: Limpar placeholders e aumentar avatares

    COPIE A LINHA ABAIXO E COLE NO COMMAND BAR:
]]

-- VERSÃO COMMAND BAR (copie a linha abaixo inteira):
-- local ws=game:GetService("Workspace")for _,n in ipairs({"SpeedLeaderboard","WinsLeaderboard"})do local l=ws:FindFirstChild(n)if l then local s=l:FindFirstChild("ScoreBlock")and l.ScoreBlock:FindFirstChild("Leaderboard")if s then local a=s:FindFirstChild("Avatars")if a then for i=1,10 do local m=a:FindFirstChild("Avatar"..i)if m then m.Image=""m.Size=UDim2.new(0,60,0,60)m.Position=UDim2.new(0,20,0,5+(i-1)*38)print("Avatar"..i.." limpo e ajustado")end end end end end end print("Concluido!")

-- VERSÃO NORMAL (se preferir usar como Script):
local ws = game:GetService("Workspace")
for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    local lb = ws:FindFirstChild(lbName)
    if lb then
        local sg = lb:FindFirstChild("ScoreBlock") and lb.ScoreBlock:FindFirstChild("Leaderboard")
        if sg then
            local av = sg:FindFirstChild("Avatars")
            if av then
                for i = 1, 10 do
                    local img = av:FindFirstChild("Avatar"..i)
                    if img then
                        -- LIMPAR imagem placeholder
                        img.Image = ""

                        -- AUMENTAR tamanho para 60x60
                        img.Size = UDim2.new(0, 60, 0, 60)

                        -- AJUSTAR posição
                        img.Position = UDim2.new(0, 20, 0, 5 + (i-1)*38)

                        print("✅ Avatar"..i.." limpo e aumentado em "..lbName)
                    end
                end
                print("🎉 Avatares ajustados em "..lbName)
            else
                warn("❌ Pasta Avatars não encontrada em "..lbName)
            end
        end
    end
end
print("✨ CONCLUÍDO! Rode o jogo para carregar as novas thumbnails.")
