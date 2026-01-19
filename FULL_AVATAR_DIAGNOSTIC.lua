--[[
    DIAGNÓSTICO COMPLETO DOS AVATARES

    Este script vai verificar TUDO:
    - Se os ImageLabels existem
    - Se estão visíveis
    - Posição exata
    - Se tem imagem carregada
    - ZIndex
    - Clipping
]]

local ws = game:GetService("Workspace")

print("========================================")
print("🔍 DIAGNÓSTICO COMPLETO DOS AVATARES")
print("========================================")

for _, lbName in ipairs({"SpeedLeaderboard", "WinsLeaderboard"}) do
    print("\n" .. string.rep("=", 40))
    print("📊 " .. lbName)
    print(string.rep("=", 40))

    local lb = ws:FindFirstChild(lbName)
    if not lb then
        warn("❌ Leaderboard não encontrada!")
        continue
    end

    local sg = lb:FindFirstChild("ScoreBlock") and lb.ScoreBlock:FindFirstChild("Leaderboard")
    if not sg then
        warn("❌ SurfaceGui não encontrada!")
        continue
    end

    print("✅ SurfaceGui encontrada")
    print("   ClipsDescendants: " .. tostring(sg.ClipsDescendants))
    print("   CanvasSize: " .. tostring(sg.CanvasSize))

    local af = sg:FindFirstChild("Avatars")
    if not af then
        warn("❌ Pasta Avatars não encontrada!")
        continue
    end

    print("✅ Pasta Avatars encontrada")
    print("")

    for i = 1, 10 do
        local av = af:FindFirstChild("Avatar" .. i)

        print("Avatar" .. i .. ":")

        if not av then
            print("  ❌ NÃO EXISTE")
        elseif not av:IsA("ImageLabel") then
            print("  ❌ NÃO É ImageLabel (é " .. av.ClassName .. ")")
        else
            print("  ✅ Existe e é ImageLabel")
            print("  📍 Position: " .. tostring(av.Position))
            print("  📏 Size: " .. tostring(av.Size))
            print("  👁️  Visible: " .. tostring(av.Visible))
            print("  🎨 BackgroundTransparency: " .. tostring(av.BackgroundTransparency))
            print("  📊 ZIndex: " .. tostring(av.ZIndex))

            if av.Image == "" then
                print("  🖼️  Image: VAZIO (sem imagem)")
            else
                print("  🖼️  Image: " .. string.sub(av.Image, 1, 50) .. "...")
            end

            -- Verificar se está fora da tela
            local x = av.Position.X.Offset
            local y = av.Position.Y.Offset

            if x < -100 then
                warn("  ⚠️  MUITO À ESQUERDA (X=" .. x .. ")")
            elseif x > 1000 then
                warn("  ⚠️  MUITO À DIREITA (X=" .. x .. ")")
            end

            if y < -100 then
                warn("  ⚠️  MUITO ACIMA (Y=" .. y .. ")")
            elseif y > 1000 then
                warn("  ⚠️  MUITO ABAIXO (Y=" .. y .. ")")
            end
        end

        print("")
    end
end

print("\n========================================")
print("✨ DIAGNÓSTICO COMPLETO")
print("========================================")
