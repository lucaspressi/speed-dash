-- BUTTON ANIMATOR - Animações de hover e clique do GamepassButton
-- ⚠️ VERSÃO CORRIGIDA - Busca elementos dentro do PriceTag corretamente

local TweenService = game:GetService("TweenService")

local priceTag = script.Parent
if not priceTag or not priceTag:IsA("GuiObject") then
	warn("[ButtonAnimator] ⚠️ Script deve estar dentro do PriceTag")
	return
end

-- Buscar o botão raiz (parent do PriceTag)
local button = priceTag.Parent
if not button or not (button:IsA("ImageButton") or button:IsA("TextButton")) then
	warn("[ButtonAnimator] ⚠️ PriceTag deve estar dentro de um Button")
	return
end

print("[ButtonAnimator] ✅ Inicializando para botão:", button:GetFullName())

-- ==================== VALIDAÇÃO DE ESTRUTURA ====================

-- Buscar elementos DENTRO do PriceTag (não no botão raiz!)
local gamepassText = priceTag:FindFirstChild("GamepassText")
local valueText = priceTag:FindFirstChild("ValueText")
local onlyLabel = priceTag:FindFirstChild("OnlyLabel")

if not gamepassText then
	warn("[ButtonAnimator] ⚠️ GamepassText não encontrado dentro do PriceTag!")
end

if not valueText then
	warn("[ButtonAnimator] ⚠️ ValueText não encontrado dentro do PriceTag!")
end

print("[ButtonAnimator] 🎯 GamepassText:", gamepassText and gamepassText:GetFullName() or "NÃO ENCONTRADO")
print("[ButtonAnimator] 🎯 ValueText:", valueText and valueText:GetFullName() or "NÃO ENCONTRADO")
print("[ButtonAnimator] 🎯 OnlyLabel:", onlyLabel and onlyLabel:GetFullName() or "NÃO ENCONTRADO")

-- ==================== CRIAR UIScale NO BOTÃO RAIZ ====================

local uiScale = button:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Name = "ButtonAnimatorScale"
	uiScale.Scale = 1
	uiScale.Parent = button
	print("[ButtonAnimator] ✅ UIScale criado no botão raiz")
else
	print("[ButtonAnimator] ✅ UIScale existente encontrado:", uiScale.Name)
end

-- ==================== CONFIGURAÇÕES DE ANIMAÇÃO ====================

local HOVER_SCALE = 1.05      -- 5% maior ao passar o mouse
local CLICK_SCALE = 0.95      -- 5% menor ao clicar
local NORMAL_SCALE = 1.0      -- Tamanho normal

local HOVER_DURATION = 0.15   -- Duração da animação de hover (rápida)
local CLICK_DURATION = 0.1    -- Duração da animação de clique (muito rápida)

-- ==================== GERENCIAMENTO DE TWEENS ====================

local activeTweens = {}  -- Armazena tweens ativos para cancelamento

-- Cancela todos os tweens ativos antes de criar um novo
local function cancelActiveTweens()
	for _, tween in ipairs(activeTweens) do
		if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
			tween:Cancel()
		end
	end
	activeTweens = {}
end

-- Cria um tween e adiciona à lista de ativos
local function createTween(targetScale, duration)
	cancelActiveTweens()

	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)

	local tween = TweenService:Create(uiScale, tweenInfo, {Scale = targetScale})
	table.insert(activeTweens, tween)

	-- Remover da lista quando completar
	tween.Completed:Connect(function()
		local index = table.find(activeTweens, tween)
		if index then
			table.remove(activeTweens, index)
		end
	end)

	return tween
end

-- ==================== EVENTOS DO BOTÃO ====================

-- Quando o mouse entra no botão
button.MouseEnter:Connect(function()
	if not button.Visible or not button.Parent then return end

	local tween = createTween(HOVER_SCALE, HOVER_DURATION)
	tween:Play()

	print("[ButtonAnimator] 🔼 Hover ativado (scale:", HOVER_SCALE, ")")
end)

-- Quando o mouse sai do botão
button.MouseLeave:Connect(function()
	if not button.Visible or not button.Parent then return end

	local tween = createTween(NORMAL_SCALE, HOVER_DURATION)
	tween:Play()

	print("[ButtonAnimator] 🔽 Hover desativado (scale:", NORMAL_SCALE, ")")
end)

-- Quando o botão é clicado (MouseButton1Down)
button.MouseButton1Down:Connect(function()
	if not button.Visible or not button.Parent then return end

	local tween = createTween(CLICK_SCALE, CLICK_DURATION)
	tween:Play()

	print("[ButtonAnimator] 🖱️ Botão pressionado (scale:", CLICK_SCALE, ")")
end)

-- Quando o botão é solto (MouseButton1Up)
button.MouseButton1Up:Connect(function()
	if not button.Visible or not button.Parent then return end

	-- Verificar se o mouse ainda está sobre o botão
	local mouseOver = false
	local mousePos = game:GetService("UserInputService"):GetMouseLocation()

	-- Converter posição do mouse para espaço da tela
	local buttonPos = button.AbsolutePosition
	local buttonSize = button.AbsoluteSize

	if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
	   mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
		mouseOver = true
	end

	-- Se o mouse ainda está sobre o botão, voltar para hover scale
	-- Caso contrário, voltar para normal scale
	local targetScale = mouseOver and HOVER_SCALE or NORMAL_SCALE
	local tween = createTween(targetScale, CLICK_DURATION)
	tween:Play()

	print("[ButtonAnimator] 🖱️ Botão solto (scale:", targetScale, ")")
end)

-- ==================== CLEANUP ====================

-- Limpar tweens quando o botão for destruído
button.Destroying:Connect(function()
	print("[ButtonAnimator] 🗑️ Botão sendo destruído, cancelando tweens")
	cancelActiveTweens()
end)

-- Limpar tweens quando o botão sair da hierarquia
button.AncestryChanged:Connect(function(_, parent)
	if not parent then
		print("[ButtonAnimator] 📤 Botão removido da hierarquia, cancelando tweens")
		cancelActiveTweens()
	end
end)

-- ==================== NOTA IMPORTANTE ====================
--[[
	⚠️ ESTE SCRIPT NÃO MODIFICA OS TEXTOS DO BOTÃO!

	Os textos (GamepassText, ValueText, OnlyLabel) são atualizados por outro
	script do sistema de gamepasses (GamepassButtonUpdater.client.lua).

	Este script é APENAS responsável pelas animações visuais:
	- Hover (mouse sobre o botão)
	- Click (clique no botão)

	A estrutura correta é:
	GamepassButton (ImageButton)
	├── UIScale ← ESTE SCRIPT ANIMA ESTE ELEMENTO
	└── PriceTag (Frame)
	    ├── GamepassText (TextLabel) ← Atualizado por outro script
	    ├── ValueText (TextLabel) ← Atualizado por outro script
	    └── OnlyLabel (TextLabel) ← Atualizado por outro script
--]]

print("[ButtonAnimator] ✅ Sistema de animação do botão ativado com sucesso!")
print("[ButtonAnimator] 📝 Configurações:")
print("[ButtonAnimator]    - Hover Scale:", HOVER_SCALE)
print("[ButtonAnimator]    - Click Scale:", CLICK_SCALE)
print("[ButtonAnimator]    - Normal Scale:", NORMAL_SCALE)
