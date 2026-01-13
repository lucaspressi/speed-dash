local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateUIEvent = Remotes:WaitForChild("UpdateUI")
local RebirthEvent = Remotes:WaitForChild("Rebirth")
local VerifyGroupEvent = Remotes:WaitForChild("VerifyGroup")
local ClaimGiftEvent = Remotes:WaitForChild("ClaimGift")
local ShowWinEvent = Remotes:WaitForChild("ShowWin")
local PromptSpeedBoostEvent = Remotes:WaitForChild("PromptSpeedBoost")
local PromptWinsBoostEvent = Remotes:WaitForChild("PromptWinsBoost")
local Prompt100KSpeedEvent = Remotes:WaitForChild("Prompt100KSpeed") -- ✅ CORRIGIDO
local Prompt1MSpeedEvent = Remotes:WaitForChild("Prompt1MSpeed")
local Prompt10MSpeedEvent = Remotes:WaitForChild("Prompt10MSpeed")

local GROUP_ID = 0 -- Replace with your group ID

-- Wait for UI
local speedGameUI = playerGui:WaitForChild("SpeedGameUI")
local winsFrame = speedGameUI:WaitForChild("WinsFrame")
local winsLabel = winsFrame:WaitForChild("WinsLabel")
local levelFrame = speedGameUI:WaitForChild("LevelFrame")

local speedDisplay = levelFrame:WaitForChild("SpeedDisplay")
local speedValue = speedDisplay:WaitForChild("SpeedValue")

local progressBg = levelFrame:WaitForChild("ProgressBg")
local progressFill = progressBg:WaitForChild("ProgressFill")
local levelText = progressBg:WaitForChild("LevelText")
local xpText = progressBg:WaitForChild("XPText")

-- Rebirth modal
local rebirthModal = speedGameUI:WaitForChild("RebirthModal")
local rebirthCloseButton = rebirthModal:WaitForChild("CloseButton")
local topRow = rebirthModal:WaitForChild("TopRow")
local bottomRow = rebirthModal:WaitForChild("BottomRow")
local currentSpeedBox = topRow:WaitForChild("CurrentSpeedBox")
local newSpeedBox = topRow:WaitForChild("NewSpeedBox")
local currentLevelBox = bottomRow:WaitForChild("CurrentLevelBox")
local newLevelBox = bottomRow:WaitForChild("NewLevelBox")
local modalProgressBg = rebirthModal:WaitForChild("ProgressBg")
local modalProgressFill = modalProgressBg:WaitForChild("ProgressFill")
local modalProgressText = modalProgressBg:WaitForChild("ProgressText")
local rebirthBtn = rebirthModal:WaitForChild("RebirthBtn")

-- Free Gift modal
local freeGiftModal = speedGameUI:WaitForChild("FreeGiftModal")
local freeGiftCloseButton = freeGiftModal:WaitForChild("CloseButton")
local step1Frame = freeGiftModal:WaitForChild("Step1Frame")
local step2Frame = freeGiftModal:WaitForChild("Step2Frame")
local verifyButton = freeGiftModal:WaitForChild("VerifyButton")
local step1Check = step1Frame:WaitForChild("Checkmark")
local step2Check = step2Frame:WaitForChild("Checkmark")

-- Find buttons
local rebirthButton = nil
local freeButton = nil
local gamepassButton = nil
local gamepassButton2 = nil
local boost1Button = nil
local boost2Button = nil
local boost3Button = nil

for _, child in pairs(speedGameUI:GetDescendants()) do
	if child.Name == "RebirthButton" and child:IsA("TextButton") then
		rebirthButton = child
	elseif child.Name == "FreeButton" and child:IsA("TextButton") then
		freeButton = child
	elseif child.Name == "GamepassButton" and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton = child
	elseif child.Name == "GamepassButton2" and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton2 = child
	elseif child.Name == "Boost1" and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		boost1Button = child
	elseif child.Name == "Boost2" and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		boost2Button = child
	elseif child.Name == "Boost3" and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		boost3Button = child
	end
end

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
	TweenService:Create(progressFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
		Size = targetSize
	}):Play()
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
	local nextTierIndex = currentData.Rebirths + 1
	local currentMultiplier = currentData.Multiplier or 1

	if nextTierIndex > #rebirthTiers then
		currentSpeedBox:FindFirstChild("SpeedText").Text = currentMultiplier .. "x Speed"
		newSpeedBox:FindFirstChild("SpeedText").Text = "MAX!"
		currentLevelBox:FindFirstChild("LevelText").Text = "Level " .. currentData.Level
		newLevelBox:FindFirstChild("LevelText").Text = "MAXED"
		modalProgressFill.Size = UDim2.new(1, 0, 1, 0)
		modalProgressText.Text = "MAX REBIRTH!"
		rebirthBtn.Text = "Maxed Out!"
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		return
	end

	local nextTier = rebirthTiers[nextTierIndex]
	local requiredLevel = nextTier.level
	local newMultiplier = nextTier.multiplier

	currentSpeedBox:FindFirstChild("SpeedText").Text = currentMultiplier .. "x Speed"
	newSpeedBox:FindFirstChild("SpeedText").Text = newMultiplier .. "x Speed"

	currentLevelBox:FindFirstChild("LevelText").Text = "Level " .. requiredLevel

	if nextTierIndex + 1 <= #rebirthTiers then
		newLevelBox:FindFirstChild("LevelText").Text = "Level " .. rebirthTiers[nextTierIndex + 1].level
	else
		newLevelBox:FindFirstChild("LevelText").Text = "Final Tier!"
	end

	local progress = math.min(currentData.Level / requiredLevel, 1)
	modalProgressFill.Size = UDim2.new(progress, 0, 1, 0)
	modalProgressText.Text = "Level " .. currentData.Level .. "/" .. requiredLevel

	if currentData.Level >= requiredLevel then
		rebirthBtn.Text = "Rebirth!"
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
	else
		rebirthBtn.Text = "Need Level " .. requiredLevel
		rebirthBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	end
end

local function updateUI(data)
	currentData = data

	winsLabel.Text = formatComma(data.Wins)
	speedValue.Text = formatNumber(data.TotalXP) .. " Speed"
	levelText.Text = "Level " .. data.Level
	xpText.Text = formatNumber(data.XP) .. "/" .. formatNumber(data.XPRequired)

	local progress = data.XP / data.XPRequired
	tweenProgress(UDim2.new(progress, 0, 1, 0))

	if rebirthModal.Visible then
		updateRebirthModal()
	end

	if data.GiftClaimed then
		giftClaimed = true
		step1Check.Visible = true
		step2Check.Visible = true
		verifyButton.Text = "Claimed! ✓"
		verifyButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
	end
end

UpdateUIEvent.OnClientEvent:Connect(updateUI)

local function openModal(modal)
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

rebirthCloseButton.MouseButton1Click:Connect(function()
	closeModal(rebirthModal)
end)

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

if freeButton then
	freeButton.MouseButton1Click:Connect(function()
		openModal(freeGiftModal)
		step1Check.Visible = true
	end)
end

freeGiftCloseButton.MouseButton1Click:Connect(function()
	closeModal(freeGiftModal)
end)

verifyButton.MouseButton1Click:Connect(function()
	if giftClaimed then return end

	verifyButton.Text = "Checking..."

	local isInGroup = VerifyGroupEvent:InvokeServer()

	if isInGroup then
		step2Check.Visible = true
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

winsFrame.Active = false
for _, child in pairs(winsFrame:GetDescendants()) do
	if child:IsA("GuiObject") then
		child.Active = false
	end
end

if gamepassButton then
	gamepassButton.MouseButton1Click:Connect(function()
		PromptSpeedBoostEvent:FireServer()
	end)
end

if gamepassButton2 then
	gamepassButton2.MouseButton1Click:Connect(function()
		PromptWinsBoostEvent:FireServer()
	end)
end

if boost1Button then
	boost1Button.MouseButton1Click:Connect(function()
		Prompt100KSpeedEvent:FireServer()
	end)
end

if boost2Button then
	boost2Button.MouseButton1Click:Connect(function()
		Prompt1MSpeedEvent:FireServer()
	end)
end

if boost3Button then
	boost3Button.MouseButton1Click:Connect(function()
		Prompt10MSpeedEvent:FireServer()
	end)
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
end

-- Chama após tudo carregar
setupMobileUI()
