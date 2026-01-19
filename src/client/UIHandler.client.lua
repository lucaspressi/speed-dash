local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

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
print("[UIHandler] 📋 All descendants:")
for _, child in pairs(speedGameUI:GetDescendants()) do
	if child:IsA("TextButton") or child:IsA("ImageButton") then
		-- ✅ Added tostring() protection to prevent table concatenation errors
		print("[UIHandler]   → " .. tostring(child.Name) .. " (" .. tostring(child.ClassName) .. ") at " .. tostring(child:GetFullName()))
	end
end

-- Find BoostFrame first
local boostFrame = speedGameUI:FindFirstChild("BoostFrame")

for _, child in pairs(speedGameUI:GetDescendants()) do
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

-- Rebirth tiers
local rebirthTiers = {
	{level = 25, multiplier = 1.5},
	{level = 50, multiplier = 2.0},
	{level = 100, multiplier = 2.5},
	{level = 150, multiplier = 3.0},
	{level = 200, multiplier = 3.5},
	{level = 300, multiplier = 4.0},
	{level = 500, multiplier = 5.0}, -- ✅ OK
	{level = 750, multiplier = 6.0},
	{level = 1000, multiplier = 7.5},
	{level = 1500, multiplier = 10.0},
}

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
		levelText.Text = "Level " .. data.Level
	end

	if xpText then
		xpText.Text = formatNumber(data.XP) .. "/" .. formatNumber(data.XPRequired)
	end

	local progress = data.XP / data.XPRequired
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

local function openModal(modal)
	if not modal then return end

	modal.Visible = true
	modal.Size = UDim2.new(0, 0, 0, 0)

	-- ✅ PATCH 1: Tenta esconder ButtonsContainer inteiro (melhor para UIListLayout)
	-- Se não existir, usa fallback (esconde botões individuais)
	local buttonsContainer = speedGameUI:FindFirstChild("ButtonsContainer")
	if buttonsContainer then
		-- Se existe ButtonsContainer, esconde ele inteiro (respeita UIListLayout)
		buttonsContainer.Visible = false
		print("[UIHandler] Modal opened - ButtonsContainer hidden")
	else
		-- Fallback: comportamento antigo (para compatibilidade)
		if gamepassButton then gamepassButton.Visible = false end
		if gamepassButton2 then gamepassButton2.Visible = false end
		print("[UIHandler] Modal opened - Individual buttons hidden (fallback mode)")
	end

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

		-- ✅ PATCH 1: Tenta mostrar ButtonsContainer inteiro (melhor para UIListLayout)
		-- Se não existir, usa fallback (mostra botões individuais)
		local buttonsContainer = speedGameUI:FindFirstChild("ButtonsContainer")
		if buttonsContainer then
			-- Se existe ButtonsContainer, mostra ele inteiro (respeita UIListLayout)
			buttonsContainer.Visible = true
			print("[UIHandler] Modal closed - ButtonsContainer shown")
		else
			-- Fallback: comportamento antigo (para compatibilidade)
			if gamepassButton then gamepassButton.Visible = true end
			if gamepassButton2 then gamepassButton2.Visible = true end
			print("[UIHandler] Modal closed - Individual buttons shown (fallback mode)")
		end
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
	winsFrame.Active = false
	for _, child in pairs(winsFrame:GetDescendants()) do
		if child:IsA("GuiObject") then
			child.Active = false
		end
	end
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

-- Auto-scale para mobile
local function setupMobileUI()
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	local uiScale = speedGameUI:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = speedGameUI
	end

	if isMobile then
		uiScale.Scale = 1.4
		print("[UIHandler] Mobile detected - UI scaled to 1.4x")
	else
		uiScale.Scale = 1.0
		print("[UIHandler] Desktop detected - UI scale 1.0x")
	end

	-- ✅ PATCH 2: Se ButtonsContainer existir, aplica UIScale separado para não quebrar layout
	local buttonsContainer = speedGameUI:FindFirstChild("ButtonsContainer")
	if buttonsContainer then
		-- Verifica se ButtonsContainer tem UIListLayout (sistema de layout automático)
		local hasListLayout = buttonsContainer:FindFirstChildOfClass("UIListLayout") ~= nil

		if hasListLayout then
			-- Se tem UIListLayout, cria UIScale próprio que neutraliza o scale do parent
			local buttonScale = buttonsContainer:FindFirstChildOfClass("UIScale")
			if not buttonScale then
				buttonScale = Instance.new("UIScale")
				buttonScale.Parent = buttonsContainer
			end

			-- Neutraliza o scale do parent (1.4x / 1.4x = 1.0x efetivo)
			if isMobile then
				buttonScale.Scale = 1.0 / 1.4  -- ≈ 0.714 (neutraliza o 1.4x do parent)
				print("[UIHandler] ButtonsContainer scale adjusted for mobile (neutralized parent scale)")
			else
				buttonScale.Scale = 1.0
				print("[UIHandler] ButtonsContainer scale normal for desktop")
			end
		else
			print("[UIHandler] ButtonsContainer found but no UIListLayout - using default scaling")
		end
	end
end

-- Chama após tudo carregar
setupMobileUI()
