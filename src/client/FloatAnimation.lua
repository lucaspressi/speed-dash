-- ═══════════════════════════════════════════════════════════════
-- 🎈 FLOAT_ANIMATION.lua
-- Animação de flutuação suave para PriceTag (FLUIDA)
-- ✅ Cole como LocalScript dentro de PriceTag
-- ═══════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  🎛️ CONFIGURAÇÕES - AJUSTE AQUI!                              ║
-- ╚═══════════════════════════════════════════════════════════════╝

local CONFIG = {
	-- 📏 DISTÂNCIA DA FLUTUAÇÃO (em pixels)
	-- Quanto menor, menos o botão sobe/desce
	FLOAT_DISTANCE = 5,

	-- ⏱️ DURAÇÃO DO CICLO COMPLETO (em segundos)
	-- Quanto maior, mais lento o movimento
	-- Recomendado: 2-4 segundos para movimento suave
	FLOAT_DURATION = 2.5,

	-- 🎨 ESTILO DE EASING (suavização do movimento)
	-- Para movimento fluido, use: Sine, Quad, ou Cubic
	-- EVITE: Bounce, Elastic, Back (causam pausas)
	EASING_STYLE = Enum.EasingStyle.Sine,

	-- 🎲 DELAY ALEATÓRIO NO INÍCIO (em segundos)
	-- Para desincronizar múltiplos botões
	RANDOM_DELAY_MAX = 0.5,

	-- 📊 FREQUÊNCIA DE LOGS (a cada quantos ciclos mostrar log)
	-- 0 = sem logs
	LOG_FREQUENCY = 0,

	-- 🐛 MODO DEBUG (mostra todos os logs)
	DEBUG_MODE = false
}

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  🔧 CÓDIGO (NÃO MEXA ABAIXO DESTA LINHA)                      ║
-- ╚═══════════════════════════════════════════════════════════════╝

local priceTag = script.Parent
local gamepassButton = priceTag.Parent
local TweenService = game:GetService("TweenService")

-- ==================== FUNÇÃO DE LOG ====================
local function log(message, forceShow)
	if CONFIG.DEBUG_MODE or forceShow then
		print("[FloatAnimation] " .. message)
	end
end

-- ==================== LOG INICIAL ====================
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", true)
log("🎈 Iniciando para: " .. gamepassButton:GetFullName(), true)
log("📦 PriceTag: " .. priceTag:GetFullName(), true)

-- ==================== VALIDAÇÃO ====================
if not priceTag:IsA("GuiObject") then
	warn("[FloatAnimation] ❌ PriceTag deve ser um GuiObject (Frame, ImageLabel, etc)")
	return
end

if not gamepassButton:IsA("GuiObject") then
	warn("[FloatAnimation] ❌ GamepassButton deve ser um GuiObject")
	return
end

log("✅ Validação de elementos OK", true)

-- ==================== MOSTRAR CONFIGURAÇÕES ====================
log("⚙️ Configuração:", true)
log("   - Distância: " .. CONFIG.FLOAT_DISTANCE .. "px", true)
log("   - Duração: " .. CONFIG.FLOAT_DURATION .. "s", true)
log("   - Easing: " .. tostring(CONFIG.EASING_STYLE), true)

-- ==================== VARIÁVEIS DE CONTROLE ====================
local running = true
local originalPosition = priceTag.Position

log("📍 Posição original salva", true)

-- ==================== CRIAR POSIÇÕES ====================
local upPosition = UDim2.new(
	originalPosition.X.Scale,
	originalPosition.X.Offset,
	originalPosition.Y.Scale,
	originalPosition.Y.Offset - CONFIG.FLOAT_DISTANCE
)

local downPosition = UDim2.new(
	originalPosition.X.Scale,
	originalPosition.X.Offset,
	originalPosition.Y.Scale,
	originalPosition.Y.Offset + CONFIG.FLOAT_DISTANCE
)

log("✅ Posições calculadas", true)

-- ==================== CRIAR TWEENS (APENAS 2 FASES - FLUIDO) ====================
-- Tempo dividido igualmente entre subir e descer
local halfDuration = CONFIG.FLOAT_DURATION / 2

local tweenInfoUp = TweenInfo.new(
	halfDuration,
	CONFIG.EASING_STYLE,
	Enum.EasingDirection.InOut,
	-1,  -- RepeatCount: -1 = infinito
	true -- Reverses: true = vai e volta automaticamente
)

-- Criar apenas UM tween que faz o movimento completo
local tweenFloat = TweenService:Create(priceTag, tweenInfoUp, {Position = upPosition})

log("✅ Tween fluido criado", true)

-- ==================== FUNÇÃO DE LIMPEZA ====================
local function cleanup()
	running = false
	tweenFloat:Cancel()
	priceTag.Position = originalPosition -- Restaura posição original
	log("🛑 Animação parada para " .. gamepassButton.Name, true)
end

-- ==================== INICIAR FLUTUAÇÃO ====================
local function startFloating()
	log("🚀 Iniciando flutuação contínua...", true)

	-- Tween com repeat infinito e reverse = movimento fluido automático
	tweenFloat:Play()

	log("✅ Flutuação ativa (modo contínuo)", true)
end

-- ==================== EVENTOS DE LIMPEZA ====================
priceTag.AncestryChanged:Connect(function()
	if not priceTag.Parent then
		log("🗑️ PriceTag removido, limpando...", true)
		cleanup()
	end
end)

priceTag.Destroying:Connect(function()
	log("🗑️ PriceTag sendo destruído, limpando...", true)
	cleanup()
end)

gamepassButton.Destroying:Connect(function()
	log("🗑️ GamepassButton sendo destruído, limpando...", true)
	cleanup()
end)

-- ==================== DELAY ALEATÓRIO ====================
local randomDelay = math.random() * CONFIG.RANDOM_DELAY_MAX
log("⏳ Aguardando " .. string.format("%.2f", randomDelay) .. "s antes de iniciar...", true)
task.wait(randomDelay)

-- ==================== INICIAR ANIMAÇÃO ====================
log("✅ Iniciando animação!", true)
startFloating()

log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", true)
log("✅ FLOAT ANIMATION ATIVA!", true)
log("   🎯 Botão: " .. gamepassButton.Name, true)
log("   📦 PriceTag: " .. priceTag.Name, true)
log("   🎈 Distância: " .. CONFIG.FLOAT_DISTANCE .. "px", true)
log("   ⏱️ Velocidade: " .. CONFIG.FLOAT_DURATION .. "s/ciclo", true)
log("   🌊 Modo: CONTÍNUO (sem pausas)", true)
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", true)