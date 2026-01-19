--[[
    SCRIPT: Ajustar tamanho e posição dos avatares

    Cole este código no Command Bar do Roblox Studio
    (tudo em uma linha só, sem quebras)
]]

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
                        img.Size = UDim2.new(0, 50, 0, 50)
                        img.Position = UDim2.new(0, 15, 0, 10 + (i-1)*35)
                        print("Ajustado Avatar"..i.." em "..lbName)
                    end
                end
            end
        end
    end
end
print("Avatares redimensionados!")
