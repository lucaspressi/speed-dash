-- GAMEPASS BUTTON UPDATER
-- Atualiza o visual do GamepassButton dinamicamente baseado no nível do jogador

task.wait(2)  -- Aguardar UI carregar

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Dados dos boosts (baseado em SpeedGameServer.server.lua)
local SPEED_BOOST_DATA = {
	[0] = {multiplier = 1,  price = 3,   nextMult = 2},    -- Level 0 → comprar 2x por 3 R$
	[1] = {multiplier = 2,  price = 29,  nextMult = 4},    -- Level 1 → comprar 4x por 29 R$
	[2] = {multiplier = 4,  price = 81,  nextMult = 8},    -- Level 2 → comprar 8x por 81 R$
	[3] = {multiplier = 8,  price = 599, nextMult = 16},   -- Level 3 → comprar 16x por 599 R$
	[4] = {multiplier = 16, price = nil, nextMult = nil},  -- Level 4 → MAX (já tem tudo)
}

-- Encontrar PlayerGui e botão
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("[GamepassUpdater] PlayerGui não encontrado!")
	return
end

-- Buscar o botão em todos os ScreenGuis possíveis
local button = nil
local searchNames = {"GamepassButton", "SpeedBoostButton", "BoostSpeed", "SpeedBoost"}

for _, screenGui in ipairs(playerGui:GetChildren()) do
	if screenGui:IsA("ScreenGui") then
		for _, name in ipairs(searchNames) do
			button = screenGui:FindFirstChild(name, true)
			if button then
				print("[GamepassUpdater] ✅ Botão encontrado:", button:GetFullName())
				break
			end
		end
		if button then break end
	end
end

if not button then
	warn("[GamepassUpdater] ⚠️ GamepassButton não encontrado! Buscou por:", table.concat(searchNames, ", "))
	return
end

-- Elementos do botão (alguns podem não existir, verificar antes de usar)
local ValueText = button:FindFirstChild("ValueText") or button:FindFirstChild("GamepassText")
local OnlyLabel = button:FindFirstChild("OnlyLabel")

if not ValueText then
	warn("[GamepassUpdater] ⚠️ ValueText/GamepassText não encontrado no botão!")
	return
end

print("[GamepassUpdater] 🎯 ValueText encontrado:", ValueText:GetFullName())
print("[GamepassUpdater] 🎯 OnlyLabel encontrado:", OnlyLabel and OnlyLabel:GetFullName() or "NENHUM")

-- Criar PriceLabel (texto do preço)
local PriceLabel = button:FindFirstChild("PriceLabel")
if not PriceLabel then
	PriceLabel = Instance.new("TextLabel")
	PriceLabel.Name = "PriceLabel"
	PriceLabel.Parent = button
	PriceLabel.Size = UDim2.new(0, 60, 0, 30)
	PriceLabel.Position = UDim2.new(0.68, 0, 0.55, 0)
	PriceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	PriceLabel.BackgroundTransparency = 1
	PriceLabel.Font = Enum.Font.LuckiestGuy
	PriceLabel.TextSize = 28
	PriceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	PriceLabel.TextStrokeTransparency = 0.3
	PriceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	PriceLabel.ZIndex = (button.ZIndex or 1) + 2
	print("[GamepassUpdater] ✅ PriceLabel criado")
end

-- Buscar RobuxIcon existente (não criar novo, pois já existe no botão)
local RobuxIcon = nil
for _, child in ipairs(button:GetDescendants()) do
	if child:IsA("ImageLabel") and string.match(child.Image:lower(), "robux") then
		RobuxIcon = child
		print("[GamepassUpdater] ✅ RobuxIcon existente encontrado:", child.Name)
		break
	end
end

if not RobuxIcon then
	warn("[GamepassUpdater] ⚠️ RobuxIcon não encontrado! O preço não mostrará o ícone R$")
end

-- Função de atualização do botão
local function updateButton(level)
	local data = SPEED_BOOST_DATA[level]
	if not data then
		warn("[GamepassUpdater] ⚠️ Nível inválido:", level)
		return
	end

	print("[GamepassUpdater] 🔄 Atualizando botão para nível:", level)

	if level >= 4 then
		-- Jogador já tem o boost máximo (16x)
		ValueText.Text = "16X SPEED"
		PriceLabel.Text = "MAX"
		PriceLabel.TextSize = 24
		if RobuxIcon then RobuxIcon.Visible = false end
		if OnlyLabel then OnlyLabel.Visible = false end
		print("[GamepassUpdater] ✅ Botão mostra MAX (nível 4)")
	else
		-- Jogador pode comprar o próximo boost
		ValueText.Text = data.nextMult .. "X SPEED"
		PriceLabel.Text = tostring(data.price)
		PriceLabel.TextSize = 28
		if RobuxIcon then RobuxIcon.Visible = true end
		if OnlyLabel then OnlyLabel.Visible = true end
		print("[GamepassUpdater] ✅ Botão mostra", data.nextMult .. "X por", data.price, "R$")
	end
end

-- Listener: atualizar quando o Attribute mudar
player:GetAttributeChangedSignal("SpeedBoostLevel"):Connect(function()
	local newLevel = player:GetAttribute("SpeedBoostLevel")
	print("[GamepassUpdater] 🔔 SpeedBoostLevel mudou para:", newLevel)
	updateButton(newLevel)
end)

-- Atualização inicial (aguardar 1 segundo para garantir que o servidor já setou o Attribute)
task.wait(1)
local initialLevel = player:GetAttribute("SpeedBoostLevel") or 0
print("[GamepassUpdater] 🎬 Nível inicial:", initialLevel)
updateButton(initialLevel)

print("[GamepassUpdater] ✅ Sistema de atualização dinâmica ativado!")
