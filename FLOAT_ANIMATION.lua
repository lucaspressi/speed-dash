-- FLOAT_ANIMATION.lua
-- Animação de flutuação suave para botões
-- ✅ Cole como LocalScript dentro do GamepassButton com nome "FloatAnimation"

local button = script.Parent
local TweenService = game:GetService("TweenService")

print("🎈 FloatAnimation iniciando para " .. button.Name)

-- ==================== CONFIGURAÇÃO ====================
local FLOAT_DISTANCE = 10  -- pixels para cima e para baixo
local FLOAT_DURATION = 2   -- segundos para completar um ciclo
local EASING_STYLE = Enum.EasingStyle.Sine

-- ==================== SALVAR POSIÇÃO ORIGINAL ====================
local originalPosition = button.Position

-- ==================== CRIAR ANIMAÇÕES ====================
local function createFloatAnimation()
    -- Posição para cima
    local upPosition = UDim2.new(
        originalPosition.X.Scale,
        originalPosition.X.Offset,
        originalPosition.Y.Scale,
        originalPosition.Y.Offset - FLOAT_DISTANCE
    )

    -- Posição para baixo
    local downPosition = UDim2.new(
        originalPosition.X.Scale,
        originalPosition.X.Offset,
        originalPosition.Y.Scale,
        originalPosition.Y.Offset + FLOAT_DISTANCE
    )

    -- Animação: Original → Up
    local tweenUp = TweenService:Create(
        button,
        TweenInfo.new(FLOAT_DURATION / 2, EASING_STYLE, Enum.EasingDirection.InOut),
        {Position = upPosition}
    )

    -- Animação: Up → Down
    local tweenDown = TweenService:Create(
        button,
        TweenInfo.new(FLOAT_DURATION, EASING_STYLE, Enum.EasingDirection.InOut),
        {Position = downPosition}
    )

    -- Animação: Down → Up
    local tweenBackUp = TweenService:Create(
        button,
        TweenInfo.new(FLOAT_DURATION, EASING_STYLE, Enum.EasingDirection.InOut),
        {Position = upPosition}
    )

    return tweenUp, tweenDown, tweenBackUp
end

local tweenUp, tweenDown, tweenBackUp = createFloatAnimation()

-- ==================== LOOP DE FLUTUAÇÃO ====================
local function startFloating()
    -- Começar indo para cima
    tweenUp:Play()

    tweenUp.Completed:Connect(function()
        if not button or not button.Parent then return end

        -- Agora desce
        tweenDown:Play()

        tweenDown.Completed:Connect(function()
            if not button or not button.Parent then return end

            -- Agora sobe de novo
            tweenBackUp:Play()

            tweenBackUp.Completed:Connect(function()
                if not button or not button.Parent then return end

                -- Loop infinito: reinicia o ciclo
                task.wait(0.1)
                startFloating()
            end)
        end)
    end)
end

-- ==================== INICIAR ====================
task.wait(math.random() * 0.5) -- Delay aleatório para não sincronizar todos os botões
startFloating()

print("✅ FloatAnimation ativa para " .. button.Name)

-- ==================== LIMPEZA ====================
button.AncestryChanged:Connect(function()
    if not button.Parent then
        -- Botão foi removido, parar animações
        tweenUp:Cancel()
        tweenDown:Cancel()
        tweenBackUp:Cancel()
        print("🛑 FloatAnimation parada para " .. button.Name)
    end
end)
