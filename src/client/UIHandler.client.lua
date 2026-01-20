local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

-- ✅ Import ProgressionConfig for centralized rebirth tiers
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionConfig"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)

if not Remotes then
	warn("[UIHandler] ⚠️ Remotes folder not found! UI will not work.")
	return
end

print("[UIHandler] ✅ Remotes folder found")

local UpdateUIEvent = Remotes:WaitForChild("UpdateUI", 10)
local RebirthEvent = Remotes:WaitForChild("Rebirth", 10)
local VerifyGroupEvent = Remotes:WaitForChild("VerifyGroup", 10)
local ClaimGiftEvent = Remotes:WaitForChild("ClaimGift", 10)
local ShowWinEvent = Remotes:WaitForChild("ShowWin", 10)
local PromptSpeedBoostEvent = Remotes:WaitForChild("PromptSpeedBoost", 10)
local PromptWinsBoostEvent = Remotes:WaitForChild("PromptWinsBoost", 10)
local Prompt100KSpeedEvent = Remotes:WaitForChild("Prompt100KSpeed", 10)
local Prompt1MSpeedEvent = Remotes:WaitForChild("Prompt1MSpeed", 10)
local Prompt10MSpeedEvent = Remotes:WaitForChild("Prompt10MSpeed", 10)

if not UpdateUIEvent then
	warn("[UIHandler] ⚠️ UpdateUI RemoteEvent not found! UI updates will not work.")
	return
end

print("[UIHandler] ✅ All RemoteEvents found")

local GROUP_ID = 0 -- Replace with your group ID

-- Wait for UI (with timeout to prevent blocking)
local speedGameUI = playerGui:WaitForChild("SpeedGameUI", 10)

if not speedGameUI then
	warn("[UIHandler] ⚠️ SpeedGameUI not found in PlayerGui after 10 seconds!")
	warn("[UIHandler] ⚠️ UI Handler will not function. Please add SpeedGameUI to StarterGui.")
	warn("[UIHandler] ℹ️  Core gameplay (XP/levels) will still work, but UI won't update.")
	return  -- Exit gracefully - don't block other systems
end

print("[UIHandler] ✅ SpeedGameUI found!")

-- Try to find UI elements (non-blocking)
local winsFrame = speedGameUI:FindFirstChild("WinsFrame")
local winsLabel = winsFrame and winsFrame:FindFirstChild("WinsLabel")
local rebirthFrame = speedGameUI:FindFirstChild("RebirthFrame")
local rebirthLabel = rebirthFrame and rebirthFrame:FindFirstChild("RebirthLabel")
if rebirthLabel then
	print("[UIHandler] ✅ RebirthLabel found: " .. rebirthLabel:GetFullName())
else
	warn("[UIHandler] ⚠️ RebirthLabel not found - rebirth display will not work")
end

local levelFrame = speedGameUI:FindFirstChild("LevelFrame")
local speedDisplay = levelFrame and levelFrame:FindFirstChild("SpeedDisplay")
local speedValue = speedDisplay and speedDisplay:FindFirstChild("SpeedValue")

local progressBg = levelFrame and levelFrame:FindFirstChild("ProgressBg")
local progressFill = progressBg and progressBg:FindFirstChild("ProgressFill")
local levelText = progressBg and progressBg:FindFirstChild("LevelText")
local xpText = progressBg and progressBg:FindFirstChild("XPText")

-- Rebirth modal (optional)
local rebirthModal = speedGameUI:FindFirstChild("RebirthModal")
local rebirthCloseButton = rebirthModal and rebirthModal:FindFirstChild("CloseButton")
local topRow = rebirthModal and rebirthModal:FindFirstChild("TopRow")
local bottomRow = rebirthModal and rebirthModal:FindFirstChild("BottomRow")
local currentSpeedBox = topRow and topRow:FindFirstChild("CurrentSpeedBox")
local newSpeedBox = topRow and topRow:FindFirstChild("NewSpeedBox")
local currentLevelBox = bottomRow and bottomRow:FindFirstChild("CurrentLevelBox")
local newLevelBox = bottomRow and bottomRow:FindFirstChild("NewLevelBox")
local modalProgressBg = rebirthModal and rebirthModal:FindFirstChild("ProgressBg")
local modalProgressFill = modalProgressBg and modalProgressBg:FindFirstChild("ProgressFill")
local modalProgressText = modalProgressBg and modalProgressBg:FindFirstChild("ProgressText")
local rebirthBtn = rebirthModal and rebirthModal:FindFirstChild("RebirthBtn")

-- Free Gift modal (optional)
local freeGiftModal = speedGameUI:FindFirstChild("FreeGiftModal")
local freeGiftCloseButton = freeGiftModal and freeGiftModal:FindFirstChild("CloseButton")
local step1Frame = freeGiftModal and freeGiftModal:FindFirstChild("Step1Frame")
local step2Frame = freeGiftModal and freeGiftModal:FindFirstChild("Step2Frame")
local verifyButton = freeGiftModal and freeGiftModal:FindFirstChild("VerifyButton")
local step1Check = step1Frame and step1Frame:FindFirstChild("Checkmark")
local step2Check = step2Frame and step2Frame:FindFirstChild("Checkmark")

-- Find buttons
local rebirthButton = nil
local freeButton = nil
local gamepassButton = nil
local gamepassButton2 = nil
local boost1Button = nil
local boost2Button = nil
local boost3Button = nil

-- Lista de possíveis nomes para os botões de gamepass
local speedBoostButtonNames = {"GamepassButton", "SpeedBoostButton", "SpeedBoost", "BoostSpeed"}
local winsBoostButtonNames = {"GamepassButton2", "WinsBoostButton", "WinsBoost", "BoostWins"}

print("[UIHandler] 🔍 Searching for buttons in SpeedGameUI...")

-- Find BoostFrame first
local boostFrame = speedGameUI:FindFirstChild("BoostFrame")

-- ⚡ OPTIMIZED: Combina dois loops GetDescendants() em um único
for _, child in pairs(speedGameUI:GetDescendants()) do
	-- Log todos os botões (diagnóstico)
	if child:IsA("TextButton") or child:IsA("ImageButton") then
		print("[UIHandler]   → " .. tostring(child.Name) .. " (" .. tostring(child.ClassName) .. ") at " .. tostring(child:GetFullName()))
	end

	-- Encontrar botões específicos (no mesmo loop)
	if child.Name == "RebirthButton" and child:IsA("TextButton") then
		rebirthButton = child
		print("[UIHandler] ✅ Found RebirthButton")
	elseif child.Name == "FreeButton" and child:IsA("TextButton") then
		freeButton = child
		print("[UIHandler] ✅ Found FreeButton")
	elseif table.find(speedBoostButtonNames, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton = child
		print("[UIHandler] ✅ Found Speed Boost Button: " .. child.Name .. " at " .. child:GetFullName())
		print("[UIHandler]   → Type: " .. child.ClassName)
		print("[UIHandler]   → Active: " .. tostring(child.Active))
		print("[UIHandler]   → Visible: " .. tostring(child.Visible))
	elseif table.find(winsBoostButtonNames, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton2 = child
		print("[UIHandler] ✅ Found Wins Boost Button: " .. child.Name .. " at " .. child:GetFullName())
		print("[UIHandler]   → Type: " .. child.ClassName)
		print("[UIHandler]   → Active: " .. tostring(child.Active))
		print("[UIHandler]   → Visible: " .. tostring(child.Visible))
	end
end

-- Get boost buttons directly from BoostFrame to avoid duplicates
if boostFrame then
	print("[UIHandler] 🔍 Searching for boost buttons in BoostFrame...")
	for _, child in pairs(boostFrame:GetChildren()) do
		if child.Name == "Boost1" and (child:IsA("TextButton") or child:IsA("ImageButton")) and not boost1Button then
			boost1Button = child
			print("[UIHandler] ✅ Found Boost1 at " .. child:GetFullName())
		elseif child.Name == "Boost2" and (child:IsA("TextButton") or child:IsA("ImageButton")) and not boost2Button then
			boost2Button = child
			print("[UIHandler] ✅ Found Boost2 at " .. child:GetFullName())
		elseif child.Name == "Boost3" and (child:IsA("TextButton") or child:IsA("ImageButton")) and not boost3Button then
			boost3Button = child
			print("[UIHandler] ✅ Found Boost3 at " .. child:GetFullName())
		end
	end
else
	warn("[UIHandler] ⚠️ BoostFrame not found! Boost buttons will not work.")
end

print("[UIHandler] ====== Button Detection Summary ======")
print("[UIHandler] Speed Boost Button (gamepassButton): " .. tostring(gamepassButton ~= nil))
print("[UIHandler] Wins Boost Button (gamepassButton2): " .. tostring(gamepassButton2 ~= nil))
print("[UIHandler] Boost1 (100K): " .. tostring(boost1Button ~= nil))
print("[UIHandler] Boost2 (1M): " .. tostring(boost2Button ~= nil))
print("[UIHandler] Boost3 (10M): " .. tostring(boost3Button ~= nil))
print("[UIHandler] =======================================")

local currentData = {Level = 1, XP = 0, XPRequired = 100, TotalXP = 0, Wins = 0, Rebirths = 0, Multiplier = 1}
local giftClaimed = false

-- ✅ Import rebirth tiers from ProgressionConfig (single source of truth)
local rebirthTiers = ProgressionConfig.REBIRTH_TIERS

-- Win sound
local winSound = Instance.new("Sound")
winSound.SoundId = "rbxassetid://367453005"
winSound.Volume = 1
winSound.Parent = SoundService

local function formatNumber(num)
	if num >= 1000000000 then
		return string.format("%.2fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.2fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.2fK", num / 1000)
	else
		return tostring(num)
	end
end

local function formatComma(num)
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

local function tweenProgress(targetSize)
	if progressFill then
		TweenService:Create(progressFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			Size = targetSize
		}):Play()
	end
end

local function showWinNotification(amount)
	amount = amount or 1
	winSound:Play()

	local container = Instance.new("Frame")
	container.Name = "WinNotification"
	container.Size = UDim2.new(0, 400, 0, 60)
	container.Position = UDim2.new(0.5, -200, 0.35, 0)
	container.BackgroundTransparency = 1
	container.Parent = playerGui:FindFirstChild("SpeedGameUI")

	local trophyIcon = Instance.new("ImageLabel")
	trophyIcon.Size = UDim2.new(0, 50, 0, 50)
	trophyIcon.Position = UDim2.new(0, 0, 0.5, -25)
	trophyIcon.BackgroundTransparency = 1
	trophyIcon.Image = "rbxassetid://15540211845"
	trophyIcon.Parent = container

	local winText = Instance.new("TextLabel")
	winText.Size = UDim2.new(0, 300, 0, 60)
	winText.Position = UDim2.new(0, 60, 0, 0)
	winText.BackgroundTransparency = 1
	winText.Text = "+" .. amount .. " Win" .. (amount > 1 and "s" or "") .. "!"
	winText.TextColor3 = Color3.fromRGB(255, 215, 0)
	winText.TextScaled = true
	winText.Font = Enum.Font.GothamBlack
	winText.Parent = container

	local winTextStroke = Instance.new("UIStroke")
	winTextStroke.Color = Color3.fromRGB(0, 0, 0)
	winTextStroke.Thickness = 4
	winTextStroke.Parent = winText

	container.Position = UDim2.new(0.5, -200, 0.4, 0)
	trophyIcon.ImageTransparency = 1
	winText.TextTransparency = 1

	TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -200, 0.35, 0)
	}):Play()

	TweenService:Create(trophyIcon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
	TweenService:Create(winText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

	task.delay(2, function()
		TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -200, 0.3, 0)
		}):Play()

		TweenService:Create(trophyIcon, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
		TweenService:Create(winText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()

		task.delay(0.4, function()
			container:Destroy()
		end)
	end)
end

ShowWinEvent.OnClientEvent:Connect(showWinNotification)

local function updateRebirthModal()
	if not rebirthModal then return end

	local nextTierIndex = currentData.Rebirths + 1
	local currentMultiplier = currentData.Multiplier or 1

	if nextTierIndex > #rebirthTiers then
		if currentSpeedBox then
			local speedText = currentSpeedBox:FindFirstChild("SpeedText")
			if speedText then speedText.Text = currentMultiplier .. "x Speed" end
		end
		if newSpeedBox then
			local speedText = newSpeedBox:FindFirstChild("SpeedText")
			if speedText then speedText.Text = "MAX!" end
		end
		if currentLevelBox then
			local levelText = currentLevelBox:FindFirstChild("LevelText")
			if levelText then levelText.Text = "Level " .. currentData.Level end
		end
		if newLevelBox then
			local levelText = newLevelBox:FindFirstChild("LevelText")
			if levelText then levelText.Text = "MAXED" end
		end
		if modalProgressFill then modalProgressFill.Size = UDim2.new(1, 0, 1, 0) end
		if modalProgressText then modalProgressText.Text = "MAX REBIRTH!" end
		if rebirthBtn then
			rebirthBtn.Text = "Maxed Out!"
			rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		end
		return
	end

	local nextTier = rebirthTiers[nextTierIndex]
	local requiredLevel = nextTier.level
	local newMultiplier = nextTier.multiplier

	if currentSpeedBox then
		local speedText = currentSpeedBox:FindFirstChild("SpeedText")
		if speedText then speedText.Text = currentMultiplier .. "x Speed" end
	end
	if newSpeedBox then
		local speedText = newSpeedBox:FindFirstChild("SpeedText")
		if speedText then speedText.Text = newMultiplier .. "x Speed" end
	end

	if currentLevelBox then
		local levelText = currentLevelBox:FindFirstChild("LevelText")
		if levelText then levelText.Text = "Level " .. requiredLevel end
	end

	if newLevelBox then
		local levelText = newLevelBox:FindFirstChild("LevelText")
		if levelText then
			if nextTierIndex + 1 <= #rebirthTiers then
				levelText.Text = "Level " .. rebirthTiers[nextTierIndex + 1].level
			else
				levelText.Text = "Final Tier!"
			end
		end
	end

	local progress = math.min(currentData.Level / requiredLevel, 1)
	if modalProgressFill then modalProgressFill.Size = UDim2.new(progress, 0, 1, 0) end
	if modalProgressText then modalProgressText.Text = "Level " .. currentData.Level .. "/" .. requiredLevel end

	if rebirthBtn then
		if currentData.Level >= requiredLevel then
			rebirthBtn.Text = "Rebirth!"
			rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
		else
			rebirthBtn.Text = "Need Level " .. requiredLevel
			rebirthBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
		end
	end
end

local function updateUI(data)
	currentData = data

	print("[UIHandler] Updating UI with Rebirths: " .. tostring(data.Rebirths))

	if winsLabel then
		winsLabel.Text = formatComma(data.Wins)
	end

	if rebirthLabel then
		rebirthLabel.Text = formatComma(data.Rebirths or 0)
		print("[UIHandler] RebirthLabel.Text set to: " .. rebirthLabel.Text)
	end

	if speedValue then
		speedValue.Text = formatNumber(data.TotalXP) .. " Speed"
	end

	if levelText then
		-- ✅ Mostra indicador de bloqueio se estiver no cap
		if data.AtRebirthCap then
			levelText.Text = "Level " .. data.Level .. " (CAPPED!)"
			levelText.TextColor3 = Color3.fromRGB(255, 100, 100)  -- Vermelho
		else
			levelText.Text = "Level " .. data.Level
			levelText.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Branco
		end
	end

	if xpText then
		-- ✅ Mostra mensagem de rebirth se estiver bloqueado
		if data.AtRebirthCap then
			local nextTier = rebirthTiers[data.Rebirths + 1]
			if nextTier then
				xpText.Text = "⚠️ REBIRTH TO CONTINUE! ⚠️"
				xpText.TextColor3 = Color3.fromRGB(255, 215, 0)  -- Dourado
				xpText.TextScaled = true

				-- ✅ Animação de pulsação para chamar atenção
				if xpText:FindFirstChild("PulseAnimation") then
					xpText.PulseAnimation:Destroy()
				end
				local pulseAnim = TweenService:Create(xpText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
					TextTransparency = 0.3
				})
				pulseAnim.Name = "PulseAnimation"
				pulseAnim:Play()
			end
		else
			xpText.Text = formatNumber(data.XP) .. "/" .. formatNumber(data.XPRequired)
			xpText.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Branco
			xpText.TextTransparency = 0  -- Remove transparência

			-- Remove animação se existir
			if xpText:FindFirstChild("PulseAnimation") then
				xpText.PulseAnimation:Destroy()
			end
		end
	end

	local progress = data.XP / data.XPRequired
	-- ✅ Se está no cap, barra de progresso fica em 100% e dourada
	if data.AtRebirthCap then
		progress = 1  -- 100%
		if progressFill then
			progressFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- Dourada
		end
	else
		if progressFill then
			progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  -- Azul normal
		end
	end
	tweenProgress(UDim2.new(progress, 0, 1, 0))

	if rebirthModal and rebirthModal.Visible then
		updateRebirthModal()
	end

	if data.GiftClaimed then
		giftClaimed = true
		if step1Check then step1Check.Visible = true end
		if step2Check then step2Check.Visible = true end
		if verifyButton then
			verifyButton.Text = "Claimed! ✓"
			verifyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
		end
	end
end

UpdateUIEvent.OnClientEvent:Connect(updateUI)

-- ==================== SISTEMA DE AVISO DE REBIRTH CAP ====================
local lastRebirthWarning = 0
local REBIRTH_WARNING_COOLDOWN = 180  -- 3 minutos entre avisos
local rebirthGlowTween = nil

-- Criar notificação sutil no topo da tela
local function showRebirthWarning()
	-- Criar notificação se não existir
	local notification = speedGameUI:FindFirstChild("RebirthCapNotification")
	if not notification then
		notification = Instance.new("Frame")
		notification.Name = "RebirthCapNotification"
		notification.Size = UDim2.new(0.5, 0, 0, 60)
		notification.Position = UDim2.new(0.25, 0, -0.1, 0)  -- Começa fora da tela (topo)
		notification.AnchorPoint = Vector2.new(0, 0)
		notification.BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- Dourado
		notification.BorderSizePixel = 0
		notification.ZIndex = 10
		notification.Parent = speedGameUI

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 12)
		uiCorner.Parent = notification

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Thickness = 2
		uiStroke.Transparency = 0.3
		uiStroke.Parent = notification

		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0, 10, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Text = "⭐"
		icon.TextSize = 32
		icon.Font = Enum.Font.GothamBold
		icon.TextColor3 = Color3.fromRGB(255, 255, 255)
		icon.ZIndex = 11
		icon.Parent = notification

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.Size = UDim2.new(1, -60, 1, 0)
		textLabel.Position = UDim2.new(0, 55, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Level Cap Reached! Click Rebirth to continue"
		textLabel.TextSize = 18
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.ZIndex = 11
		textLabel.Parent = notification
	end

	-- Animar entrada (desce do topo)
	notification.Position = UDim2.new(0.25, 0, -0.1, 0)
	notification.Visible = true

	local tweenIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.25, 0, 0.05, 0)  -- Desce para 5% da tela
	})
	tweenIn:Play()

	print("[UIHandler] 📢 Aviso de rebirth cap exibido")

	-- Aguardar 3 segundos e animar saída (sobe)
	task.delay(3, function()
		local tweenOut = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.25, 0, -0.1, 0)  -- Sobe para fora da tela
		})
		tweenOut:Play()

		tweenOut.Completed:Connect(function()
			notification.Visible = false
			print("[UIHandler] 📢 Aviso de rebirth cap ocultado")
		end)
	end)
end

-- Adicionar efeito de brilho/reflexo no RebirthFrame
local function startRebirthGlow()
	if not rebirthFrame then return end

	-- Criar efeito de brilho se não existir
	local glow = rebirthFrame:FindFirstChild("CapGlow")
	if not glow then
		glow = Instance.new("ImageLabel")
		glow.Name = "CapGlow"
		glow.Size = UDim2.new(1.2, 0, 1.2, 0)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.BackgroundTransparency = 1
		glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"  -- Placeholder, pode substituir
		glow.ImageColor3 = Color3.fromRGB(255, 215, 0)  -- Dourado
		glow.ImageTransparency = 0.5
		glow.ZIndex = rebirthFrame.ZIndex - 1
		glow.Parent = rebirthFrame
	end

	-- Cancelar tween anterior se existir
	if rebirthGlowTween then
		rebirthGlowTween:Cancel()
	end

	-- Criar animação de pulso (brilho)
	glow.ImageTransparency = 0.5
	glow.Visible = true

	local tweenInfo = TweenInfo.new(
		1.5,  -- Duração de 1.5 segundos
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		-1,  -- Repetir infinitamente
		true,  -- Reverter (vai e volta)
		0
	)

	rebirthGlowTween = TweenService:Create(glow, tweenInfo, {
		ImageTransparency = 0.1  -- Fica mais visível
	})

	rebirthGlowTween:Play()

	print("[UIHandler] ✨ Efeito de brilho no RebirthFrame ativado")
end

-- Parar efeito de brilho
local function stopRebirthGlow()
	if rebirthGlowTween then
		rebirthGlowTween:Cancel()
		rebirthGlowTween = nil
	end

	if rebirthFrame then
		local glow = rebirthFrame:FindFirstChild("CapGlow")
		if glow then
			glow.Visible = false
			print("[UIHandler] ✨ Efeito de brilho no RebirthFrame desativado")
		end
	end
end

-- Monitorar estado de rebirth cap
local isAtCap = false
UpdateUIEvent.OnClientEvent:Connect(function(data)
	local wasAtCap = isAtCap
	isAtCap = data.AtRebirthCap or false

	-- Jogador acabou de atingir o cap
	if isAtCap and not wasAtCap then
		print("[UIHandler] 🔒 Jogador atingiu rebirth cap")

		-- Mostrar aviso imediatamente
		showRebirthWarning()
		lastRebirthWarning = tick()

		-- Ativar efeito de brilho
		startRebirthGlow()

	-- Jogador não está mais no cap (fez rebirth)
	elseif not isAtCap and wasAtCap then
		print("[UIHandler] ✅ Jogador saiu do rebirth cap")

		-- Parar efeito de brilho
		stopRebirthGlow()

	-- Jogador continua no cap
	elseif isAtCap then
		-- Verificar cooldown para mostrar aviso novamente
		local timeSinceLastWarning = tick() - lastRebirthWarning

		if timeSinceLastWarning >= REBIRTH_WARNING_COOLDOWN then
			print("[UIHandler] ⏰ Cooldown de aviso passou, mostrando novamente")
			showRebirthWarning()
			lastRebirthWarning = tick()
		end
	end
end)

local function openModal(modal)
	if not modal then return end

	modal.Visible = true
	modal.Size = UDim2.new(0, 0, 0, 0)

	if gamepassButton then gamepassButton.Visible = false end
	if gamepassButton2 then gamepassButton2.Visible = false end

	TweenService:Create(modal, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.9, 0, 0, 350)
	}):Play()

	if modal.Name == "RebirthModal" then
		updateRebirthModal()
	end
end

local function closeModal(modal)
	if not modal then return end

	TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.delay(0.2, function()
		modal.Visible = false
		if gamepassButton then gamepassButton.Visible = true end
		if gamepassButton2 then gamepassButton2.Visible = true end
	end)
end

if rebirthButton then
	rebirthButton.MouseButton1Click:Connect(function()
		openModal(rebirthModal)
	end)
end

if rebirthCloseButton then
	rebirthCloseButton.MouseButton1Click:Connect(function()
		closeModal(rebirthModal)
	end)
end

if rebirthBtn then
	rebirthBtn.MouseButton1Click:Connect(function()
		local nextTierIndex = currentData.Rebirths + 1
		if nextTierIndex <= #rebirthTiers then
			local nextTier = rebirthTiers[nextTierIndex]
			if currentData.Level >= nextTier.level then
				RebirthEvent:FireServer()
				closeModal(rebirthModal)
			end
		end
	end)
end

if freeButton then
	freeButton.MouseButton1Click:Connect(function()
		openModal(freeGiftModal)
		if step1Check then step1Check.Visible = true end
	end)
end

if freeGiftCloseButton then
	freeGiftCloseButton.MouseButton1Click:Connect(function()
		closeModal(freeGiftModal)
	end)
end

if verifyButton then
	verifyButton.MouseButton1Click:Connect(function()
		if giftClaimed then return end

		verifyButton.Text = "Checking..."

		local isInGroup = VerifyGroupEvent:InvokeServer()

		if isInGroup then
			if step2Check then step2Check.Visible = true end
			ClaimGiftEvent:FireServer()
			giftClaimed = true
			verifyButton.Text = "Claimed! ✓"
			verifyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
			task.delay(1.5, function()
				closeModal(freeGiftModal)
			end)
		else
			verifyButton.Text = "Join Group First!"
			verifyButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
			task.delay(2, function()
				verifyButton.Text = "Verify & Claim!"
				verifyButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
			end)
		end
	end)
end

if winsFrame then
	-- ⚡ OPTIMIZED: Active = false herda para descendentes automaticamente
	-- Não precisa iterar GetDescendants() - economiza performance
	winsFrame.Active = false
end

if gamepassButton then
	print("[UIHandler] 🔗 Connecting Speed Boost Button click handler")
	gamepassButton.MouseButton1Click:Connect(function()
		print("[UIHandler] 🎯 Speed Boost Button clicked! Firing PromptSpeedBoostEvent...")
		PromptSpeedBoostEvent:FireServer()
	end)
	print("[UIHandler] ✅ Speed Boost Button handler connected successfully!")
else
	warn("[UIHandler] ❌ SPEED BOOST BUTTON NOT FOUND!")
	warn("[UIHandler] Expected button names: GamepassButton, SpeedBoostButton, SpeedBoost, or BoostSpeed")
	warn("[UIHandler] Please check Roblox Studio: PlayerGui > SpeedGameUI")
	warn("[UIHandler] Make sure the button exists and is a TextButton or ImageButton")
end

if gamepassButton2 then
	print("[UIHandler] 🔗 Connecting Wins Boost Button click handler")
	gamepassButton2.MouseButton1Click:Connect(function()
		print("[UIHandler] 🎯 Wins Boost Button clicked! Firing PromptWinsBoostEvent...")
		PromptWinsBoostEvent:FireServer()
	end)
	print("[UIHandler] ✅ Wins Boost Button handler connected successfully!")
else
	warn("[UIHandler] ❌ WINS BOOST BUTTON NOT FOUND!")
	warn("[UIHandler] Expected button names: GamepassButton2, WinsBoostButton, WinsBoost, or BoostWins")
	warn("[UIHandler] Please check Roblox Studio: PlayerGui > SpeedGameUI")
	warn("[UIHandler] Make sure the button exists and is a TextButton or ImageButton")
end

if boost1Button then
	boost1Button.MouseButton1Click:Connect(function()
		print("[UIHandler] 🎯 Boost1 (100K) clicked!")
		Prompt100KSpeedEvent:FireServer()
	end)
	print("[UIHandler] ✅ Boost1 (100K) handler connected")
else
	warn("[UIHandler] ❌ Boost1 (100K) button NOT FOUND in BoostFrame!")
end

if boost2Button then
	boost2Button.MouseButton1Click:Connect(function()
		print("[UIHandler] 🎯 Boost2 (1M) clicked!")
		Prompt1MSpeedEvent:FireServer()
	end)
	print("[UIHandler] ✅ Boost2 (1M) handler connected")
else
	warn("[UIHandler] ❌ Boost2 (1M) button NOT FOUND in BoostFrame!")
end

if boost3Button then
	boost3Button.MouseButton1Click:Connect(function()
		print("[UIHandler] 🎯 Boost3 (10M) clicked!")
		Prompt10MSpeedEvent:FireServer()
	end)
	print("[UIHandler] ✅ Boost3 (10M) handler connected")
else
	warn("[UIHandler] ❌ Boost3 (10M) button NOT FOUND in BoostFrame!")
end

print("UIHandler ready with win notifications!")

-- ==================== CONFIGURAÇÃO DE RESPONSIVIDADE ====================
-- 🔧 MUDE AQUI: true = ativo | false = desativado
local MOBILE_RESPONSIVE_ENABLED = false  -- ❌ DESATIVADO (estava afetando PC)
-- ========================================================================

-- ✅ DETECÇÃO ROBUSTA DE MOBILE
local function isMobileDevice()
	local GuiService = game:GetService("GuiService")

	-- Método 1: Verificar plataforma via GuiService (mais confiável)
	local platform = GuiService:IsTenFootInterface() and "Console" or
	                 (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and "Mobile" or
	                 "Desktop"

	print("[UIHandler] 🖥️ Plataforma detectada:", platform)

	-- Método 2: Verificar tamanho da tela (mobile geralmente < 1024px)
	local screenSize = workspace.CurrentCamera.ViewportSize
	local isSmallScreen = screenSize.X < 1024 or screenSize.Y < 768

	print("[UIHandler] 📱 Tamanho da tela:", screenSize.X .. "x" .. screenSize.Y)
	print("[UIHandler] 📏 Tela pequena?", isSmallScreen)

	-- Método 3: Verificar touch sem teclado
	local hasTouchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	print("[UIHandler] 👆 Touch habilitado?", UserInputService.TouchEnabled)
	print("[UIHandler] ⌨️ Teclado habilitado?", UserInputService.KeyboardEnabled)
	print("[UIHandler] 📱 Touch apenas?", hasTouchOnly)

	-- É mobile se: plataforma = Mobile OU (touch sem teclado E tela pequena)
	local isMobile = platform == "Mobile" or (hasTouchOnly and isSmallScreen)

	print("[UIHandler] 🎯 RESULTADO FINAL: " .. (isMobile and "MOBILE" or "DESKTOP"))

	return isMobile
end

-- Auto-scale para mobile
local function setupMobileUI()
	if not MOBILE_RESPONSIVE_ENABLED then
		print("[UIHandler] ⚠️ Responsividade mobile DESABILITADA (MOBILE_RESPONSIVE_ENABLED = false)")

		-- ✅ FORÇAR REMOVER qualquer UIScale que possa ter sido criado antes
		local uiScale = speedGameUI:FindFirstChildOfClass("UIScale")
		if uiScale and uiScale.Name ~= "BuiltIn" then
			-- Se não é o UIScale padrão do Roblox, garantir que está em 1.0
			uiScale.Scale = 1.0
			print("[UIHandler] 🔧 UIScale forçado para 1.0 (removendo qualquer modificação anterior)")
		end

		return
	end

	print("[UIHandler] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("[UIHandler] 🔍 Detectando plataforma...")

	local isMobile = isMobileDevice()

	local uiScale = speedGameUI:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = speedGameUI
	end

	if isMobile then
		-- ✅ APLICAR AJUSTES MOBILE
		uiScale.Scale = 1.4
		print("[UIHandler] ✅ Mobile detectado - UI escalada para 1.4x")

		-- ✅ AJUSTE MOBILE: Reposiciona WinsFrame/RebirthFrame para não serem cobertos pelo chat
		if winsFrame then
			local originalPosition = winsFrame.Position
			winsFrame.Position = UDim2.new(
				originalPosition.X.Scale,
				originalPosition.X.Offset,
				0.12,  -- Move para Y = 12% da tela (abaixo do chat mobile)
				originalPosition.Y.Offset
			)
			print("[UIHandler] 📱 WinsFrame reposicionado para mobile (Y=0.12)")
		end

		if rebirthFrame then
			local originalPosition = rebirthFrame.Position
			rebirthFrame.Position = UDim2.new(
				originalPosition.X.Scale,
				originalPosition.X.Offset,
				0.12,  -- Mesma altura do WinsFrame
				originalPosition.Y.Offset
			)
			print("[UIHandler] 📱 RebirthFrame reposicionado para mobile (Y=0.12)")
		end

		print("[UIHandler] ✅ Ajustes mobile aplicados com sucesso!")
	else
		-- ✅ MANTER PADRÃO DESKTOP (sem mudanças)
		uiScale.Scale = 1.0
		print("[UIHandler] ✅ Desktop detectado - UI mantida em 1.0x (padrão)")
		print("[UIHandler] ℹ️ WinsFrame e RebirthFrame mantidos nas posições originais")
	end

	print("[UIHandler] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- Chama após tudo carregar
setupMobileUI()
