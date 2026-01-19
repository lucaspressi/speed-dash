--[[
    CORRIGIR AVATARES COM ESPAÇAMENTO MANUAL

    Este script posiciona os avatares com espaçamento vertical correto,
    independente de como os nomes estão organizados
]]

local ws = game:GetService("Workspace")

-- ⭐ CONFIGURAÇÕES - AJUSTE AQUI ⭐
local AVATAR_SIZE = 50
local START_X = 20  -- Posição X inicial (da esquerda)
local START_Y = 10  -- Posição Y inicial (do topo)
local SPACING_Y = 35  -- Espaçamento entre avatares (vertical)

print("========================================")
print("🔧 CORRIGINDO AVATARES COM ESPAÇAMENTO MANUAL")
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

    -- Primeiro, verificar onde os nomes realmente estão
    print("\n🔍 Verificando posição dos nomes:")
    local name1 = nf:FindFirstChild("Name1")
    if name1 then
        -- Tentar pegar posição absoluta (posição real na tela)
        if name1:IsA("GuiObject") then
            print("  Name1 AbsolutePosition: " .. tostring(name1.AbsolutePosition))
            print("  Name1 Position: " .. tostring(name1.Position))
        end

        -- Verificar se tem UIListLayout
        local listLayout = nf:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            print("  ✅ Encontrado UIListLayout!")
            print("     Padding: " .. tostring(listLayout.Padding))
        end
    end

    print("\n📐 Posicionando avatares manualmente:")

    for i = 1, 10 do
        local av = af:FindFirstChild("Avatar" .. i)

        if av and av:IsA("ImageLabel") then
            -- Calcular posição vertical baseada no índice
            local avatarY = START_Y + (i - 1) * SPACING_Y

            -- Aplicar posição
            av.Position = UDim2.new(0, START_X, 0, avatarY)
            av.Size = UDim2.new(0, AVATAR_SIZE, 0, AVATAR_SIZE)
            av.Visible = true
            av.BackgroundTransparency = 1
            av.BorderSizePixel = 0
            av.ZIndex = 2

            print(string.format("  Avatar%d → X=%d, Y=%d", i, START_X, avatarY))
        end
    end

    print("✅ " .. lbName .. " corrigida!")
end

print("\n========================================")
print("✨ CORREÇÃO COMPLETA!")
print("========================================")
print("Configuração usada:")
print("  - Tamanho: " .. AVATAR_SIZE .. "x" .. AVATAR_SIZE .. " pixels")
print("  - Início: X=" .. START_X .. ", Y=" .. START_Y)
print("  - Espaçamento: " .. SPACING_Y .. " pixels")
print("\n💡 Se precisar ajustar:")
print("  - Edite START_X (linha 12) para mover horizontalmente")
print("  - Edite START_Y (linha 13) para mover verticalmente")
print("  - Edite SPACING_Y (linha 14) para ajustar espaçamento")
print("\n⚠️  Salve (Ctrl+S) e Publique o jogo")
print("========================================")
