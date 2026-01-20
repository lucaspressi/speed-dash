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

-- ==================== DESIGN ORIGINAL ====================
-- NÃO criar PriceLabel - usar design original do botão
-- ValueText já tem "16x", "32x", etc definido no design

-- Deletar PriceLabel antigo se existir
local oldPriceLabel = button:FindFirstChild("PriceLabel")
if oldPriceLabel then
	oldPriceLabel:Destroy()
	print("[GamepassUpdater] 🗑️ PriceLabel antigo removido")
end

print("[GamepassUpdater] ✅ Usando design original (ValueText permanece como está)")

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

		-- Atualizar ValueText dinamicamente com o multiplicador que pode comprar
		ValueText.Text = data.nextMult .. "x"

		-- Esconder OnlyLabel se for o último boost (16x)
		if OnlyLabel then
			OnlyLabel.Visible = (data.nextMult ~= 16)
		end

		print("[GamepassUpdater] ✅ Botão mostra:", ValueText.Text)
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
