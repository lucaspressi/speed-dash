-- FLOAT ANIMATION - Animação de flutuação do PriceTag
-- ⚠️ VERSÃO CORRIGIDA - Sem recursão infinita, com cleanup adequado

local TweenService = game:GetService("TweenService")

local priceTag = script.Parent
if not priceTag or not priceTag:IsA("GuiObject") then
	warn("[FloatAnimation] ⚠️ Script deve estar dentro de um GuiObject (PriceTag)")
	return
end

print("[FloatAnimation] ✅ Inicializando para:", priceTag:GetFullName())

-- ==================== CONFIGURAÇÕES ====================
local FLOAT_DISTANCE = 5      -- Pixels de movimento vertical
local FLOAT_DURATION = 1.5    -- Segundos por ciclo completo
local EASING_STYLE = Enum.EasingStyle.Sine
local EASING_DIRECTION = Enum.EasingDirection.InOut

-- ==================== ESTADO ====================
local isRunning = false
local originalPosition = priceTag.Position
local currentTween = nil

-- ==================== CLEANUP ====================
local function cleanup()
	isRunning = false

	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end

	-- Restaurar posição original
	priceTag.Position = originalPosition

	print("[FloatAnimation] 🧹 Cleanup realizado")
end

-- ==================== ANIMAÇÃO PRINCIPAL ====================
local function startFloating()
	if isRunning then
		warn("[FloatAnimation] ⚠️ Animação já está rodando!")
		return
	end

	isRunning = true
	print("[FloatAnimation] 🎬 Iniciando loop de flutuação")

	-- Posições de destino
	local upPosition = UDim2.new(
		originalPosition.X.Scale,
		originalPosition.X.Offset,
		originalPosition.Y.Scale,
		originalPosition.Y.Offset - FLOAT_DISTANCE
	)

	local downPosition = originalPosition

	-- Informações do tween
	local tweenInfo = TweenInfo.new(
		FLOAT_DURATION / 2,  -- Metade do ciclo completo
		EASING_STYLE,
		EASING_DIRECTION,
		0,  -- Não repetir automaticamente (vamos controlar manualmente)
		false,  -- Não reverter
		0  -- Sem delay
	)

	-- ✅ LOOP SEGURO COM WHILE (não recursão!)
	task.spawn(function()
		while isRunning and priceTag and priceTag.Parent do
			-- Fase 1: Subir
			if not isRunning then break end

			currentTween = TweenService:Create(priceTag, tweenInfo, {Position = upPosition})
			currentTween:Play()
			currentTween.Completed:Wait()
			currentTween = nil

			-- Fase 2: Descer
			if not isRunning then break end

			currentTween = TweenService:Create(priceTag, tweenInfo, {Position = downPosition})
			currentTween:Play()
			currentTween.Completed:Wait()
			currentTween = nil

			-- Pequeno delay entre ciclos (opcional, para suavizar)
			if isRunning then
				task.wait(0.1)
			end
		end

		-- Cleanup ao sair do loop
		cleanup()
		print("[FloatAnimation] ⏹️ Loop de flutuação finalizado")
	end)
end

-- ==================== EVENTOS DE LIMPEZA ====================

-- Parar quando o elemento for destruído
priceTag.Destroying:Connect(function()
	print("[FloatAnimation] 🗑️ PriceTag sendo destruído, parando animação")
	cleanup()
end)

-- Parar quando o elemento sair da hierarquia
priceTag.AncestryChanged:Connect(function(_, parent)
	if not parent then
		print("[FloatAnimation] 📤 PriceTag removido da hierarquia, parando animação")
		cleanup()
	end
end)

-- ==================== INICIAR ====================
-- Aguardar 1 frame para garantir que tudo está carregado
task.wait()
startFloating()

print("[FloatAnimation] ✅ Sistema de flutuação ativado com sucesso!")
