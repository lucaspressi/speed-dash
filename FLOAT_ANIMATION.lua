-- FLOAT_ANIMATION.lua
-- Animação de flutuação SEM recursão, SEM memory leak
-- ✅ Cole como LocalScript dentro do GamepassButton com nome "FloatAnimation"

-- Proteção contra múltiplas instâncias
local button = script.Parent
if not button or not button:IsA("GuiButton") then
    warn("[FloatAnimation] Parent is not a GuiButton!")
    script.Enabled = false
    return
end

if button:GetAttribute("FloatAnimationActive") then
    warn("[FloatAnimation] Already active on", button.Name)
    script.Enabled = false
    return
end

button:SetAttribute("FloatAnimationActive", true)

local RunService = game:GetService("RunService")

print("🎈 FloatAnimation iniciando para " .. button.Name)

-- ==================== CONFIGURAÇÃO ====================
local FLOAT_DISTANCE = 10  -- pixels para cima e para baixo
local FLOAT_SPEED = 2      -- velocidade (quanto maior, mais rápido)

-- ==================== SALVAR POSIÇÃO ORIGINAL ====================
local originalPosition = button.Position

-- ==================== VARIÁVEIS DE ESTADO ====================
local startTime = tick()
local running = true

-- ==================== ANIMAÇÃO USANDO SENO (SEM RECURSÃO!) ====================
local connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not button or not button.Parent then
        -- Botão foi removido, parar animação
        running = false
        return
    end

    -- Calcular offset usando função seno (movimento suave)
    local elapsed = tick() - startTime
    local offset = math.sin(elapsed * FLOAT_SPEED) * FLOAT_DISTANCE

    -- Atualizar posição
    button.Position = UDim2.new(
        originalPosition.X.Scale,
        originalPosition.X.Offset,
        originalPosition.Y.Scale,
        originalPosition.Y.Offset + offset
    )
end)

print("✅ FloatAnimation ativa para " .. button.Name)

-- ==================== LIMPEZA ADEQUADA ====================
button.AncestryChanged:Connect(function()
    if not button.Parent then
        -- Botão foi removido, desconectar
        connection:Disconnect()
        running = false
        print("🛑 FloatAnimation parada para " .. button.Name)
    end
end)

-- Cleanup quando script é desabilitado
script.AncestryChanged:Connect(function()
    if not script.Parent or script.Disabled then
        connection:Disconnect()
        button:SetAttribute("FloatAnimationActive", nil)
        running = false
        print("🛑 FloatAnimation script desabilitado/removido")
    end
end)
