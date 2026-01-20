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
-- ⚠️ IMPORTANTE: Buscar GamepassText E ValueText separadamente!
-- GamepassText = multiplicador ("2X SPEED")
-- ValueText = preço em Robux ("3", "29", "81", "599")
local priceTag = button:FindFirstChild("PriceTag", true)
local gamepassText = priceTag and priceTag:FindFirstChild("GamepassText")
local valueText = priceTag and priceTag:FindFirstChild("ValueText")
local onlyLabel = priceTag and priceTag:FindFirstChild("OnlyLabel")

-- Fallback: buscar no botão diretamente se não achar no PriceTag
if not gamepassText then
	gamepassText = button:FindFirstChild("GamepassText", true)
end
if not valueText then
	valueText = button:FindFirstChild("ValueText", true)
end
if not onlyLabel then
	onlyLabel = button:FindFirstChild("OnlyLabel", true)
end

-- Validar elementos críticos
if not gamepassText and not valueText then
	warn("[GamepassUpdater] ⚠️ Nenhum elemento de texto encontrado (GamepassText ou ValueText)!")
	return
end

print("[GamepassUpdater] 🎯 GamepassText encontrado:", gamepassText and gamepassText:GetFullName() or "NÃO ENCONTRADO")
print("[GamepassUpdater] 🎯 ValueText encontrado:", valueText and valueText:GetFullName() or "NÃO ENCONTRADO")
print("[GamepassUpdater] 🎯 OnlyLabel encontrado:", onlyLabel and onlyLabel:GetFullName() or "NENHUM")

-- ==================== LIMPAR ELEMENTOS HARDCODED ====================

-- Deletar PriceLabel antigo se existir
local oldPriceLabel = button:FindFirstChild("PriceLabel")
if oldPriceLabel then
	oldPriceLabel:Destroy()
	print("[GamepassUpdater] 🗑️ PriceLabel antigo removido")
end

-- Verificar se PriceTag tem conteúdo hardcoded "3"
local priceTag = button:FindFirstChild("PriceTag")
if priceTag then
	local hasHardcodedThree = false

	-- Procurar por TextLabels dentro do PriceTag que contenham "3"
	for _, child in ipairs(priceTag:GetDescendants()) do
		if child:IsA("TextLabel") and child.Text then
			local text = tostring(child.Text):lower()
			if text:match("3") and (text:match("robux") or text:match("only")) then
				hasHardcodedThree = true
				break
			end
		end
	end

	if hasHardcodedThree then
		priceTag.Visible = false
		print("[GamepassUpdater] 🗑️ PriceTag escondido (tinha '3' hardcoded detectado)")
	else
		print("[GamepassUpdater] ✅ PriceTag mantido visível (sem hardcode detectado)")
	end
end

-- Limpar texto do OnlyLabel se tiver hardcoded
if onlyLabel and onlyLabel:IsA("TextLabel") then
	if onlyLabel.Text == "ONLY 3" or onlyLabel.Text:find("3") or onlyLabel.Text:find("ROBUX") then
		onlyLabel.Text = "ONLY"
		print("[GamepassUpdater] 🧹 OnlyLabel texto limpo")
	end
end

print("[GamepassUpdater] ✅ Elementos hardcoded limpos")

-- Função de atualização do botão
local function updateButton(level)
	local data = SPEED_BOOST_DATA[level]
	if not data then
		warn("[GamepassUpdater] ⚠️ Nível inválido:", level)
		return
	end

	print("[GamepassUpdater] 🔄 Jogador está no nível:", level)

	if level >= 4 then
		-- Jogador já tem o boost máximo (16x)
		button.Visible = false  -- Esconder botão quando MAX
		print("[GamepassUpdater] ✅ Botão escondido (jogador já tem boost máximo)")
	else
		-- Jogador pode comprar o próximo boost
		button.Visible = true

		-- ✅ Atualizar GamepassText com o MULTIPLICADOR
		if gamepassText then
			gamepassText.Text = data.nextMult .. "X SPEED"
			print("[GamepassUpdater] ✅ GamepassText atualizado:", gamepassText.Text)
		end

		-- ✅ Atualizar ValueText com o PREÇO
		if valueText then
			valueText.Text = tostring(data.price)
			print("[GamepassUpdater] ✅ ValueText atualizado:", valueText.Text, "R$")
		end

		-- OnlyLabel deve mostrar apenas para os primeiros boosts (não para 16x)
		if onlyLabel then
			onlyLabel.Text = "ONLY"  -- Garantir que está sem números hardcoded
			onlyLabel.Visible = (data.nextMult < 16)
		end

		-- NÃO forçar PriceTag invisível aqui
		-- A validação inicial já determinou se deve ou não estar visível

		print("[GamepassUpdater] ✅ Botão configurado para nível:", level, "→ Próximo:", data.nextMult .. "X por", data.price, "R$")
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
