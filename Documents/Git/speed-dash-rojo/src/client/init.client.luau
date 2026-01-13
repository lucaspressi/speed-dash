print("==================== [CLIENT] LocalScript.lua STARTING ====================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
print("[CLIENT] LocalScript.lua loaded! Player: " .. player.Name)
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PromptSpeedBoostEvent = Remotes:FindFirstChild("PromptSpeedBoost")

local MarketplaceService = game:GetService("MarketplaceService")
local TREADMILL_X3_PRODUCT_ID = 3510639799   -- 3x Speed Treadmill (dourada) - 59 Robux
local TREADMILL_X9_PRODUCT_ID = 3510662188   -- 9x Speed Treadmill (azul) - 149 Robux
local TREADMILL_X25_PRODUCT_ID = 3510662405  -- 25x Speed Treadmill (roxa) - 399 Robux

-- ✅ CACHE LOCAL de ownership (atualizado pelo server via RemoteEvent)
local treadmillOwnershipCache = {
	[3] = false,
	[9] = false,
	[25] = false,
}

-- Função para verificar se tem acesso à esteira por multiplier
local function hasTreadmillAccess(multiplier)
	-- Usa o cache local (mais rápido e confiável)
	return treadmillOwnershipCache[multiplier] == true
end

-- Mantém funções antigas para compatibilidade
local function hasGoldTreadmillAccess()
	return hasTreadmillAccess(3)
end

local function hasBlueTreadmillAccess()
	return hasTreadmillAccess(9)
end

local function hasPurpleTreadmillAccess()
	return hasTreadmillAccess(25)
end

-- Debounce para evitar múltiplos prompts
local purchasePromptDebounce = false

-- Debug: mostra quando os atributos mudam
player:GetAttributeChangedSignal("TreadmillX3Owned"):Connect(function()
	local hasAccess = hasGoldTreadmillAccess()
	print("[CLIENT] TreadmillX3Owned changed to: " .. tostring(hasAccess))
	treadmillOwnershipCache[3] = hasAccess
end)

player:GetAttributeChangedSignal("TreadmillX9Owned"):Connect(function()
	local hasAccess = hasBlueTreadmillAccess()
	print("[CLIENT] TreadmillX9Owned changed to: " .. tostring(hasAccess))
	treadmillOwnershipCache[9] = hasAccess
end)

player:GetAttributeChangedSignal("TreadmillX25Owned"):Connect(function()
	local hasAccess = hasPurpleTreadmillAccess()
	print("[CLIENT] TreadmillX25Owned changed to: " .. tostring(hasAccess))
	treadmillOwnershipCache[25] = hasAccess
end)

-- Checa o valor inicial
task.spawn(function()
	task.wait(1)
	print("[CLIENT] Initial TreadmillX3Owned: " .. tostring(hasGoldTreadmillAccess()))
	-- Inicializa cache com atributos do player
	treadmillOwnershipCache[3] = player:GetAttribute("TreadmillX3Owned") == true
	treadmillOwnershipCache[9] = player:GetAttribute("TreadmillX9Owned") == true
	treadmillOwnershipCache[25] = player:GetAttribute("TreadmillX25Owned") == true
end)

local UpdateSpeedEvent = Remotes:WaitForChild("UpdateSpeed")
local AddWinEvent = Remotes:WaitForChild("AddWin")
local EquipStepAwardEvent = Remotes:WaitForChild("EquipStepAward")
local UpdateUIEvent = Remotes:WaitForChild("UpdateUI")
local TreadmillOwnershipUpdated = Remotes:WaitForChild("TreadmillOwnershipUpdated")

-- ✅ LISTENER: Atualiza ownership quando server notifica após compra
TreadmillOwnershipUpdated.OnClientEvent:Connect(function(multiplier, owned)
	print("[CLIENT] TreadmillOwnershipUpdated received: x" .. multiplier .. " = " .. tostring(owned))
	treadmillOwnershipCache[multiplier] = owned

	-- Atualiza o atributo local também (redundante mas garante sincronização)
	local key = "TreadmillX" .. multiplier .. "Owned"
	player:SetAttribute(key, owned)

	print("[CLIENT] Ownership cache updated. Can now use x" .. multiplier .. " treadmill!")
end)

local lastPosition = nil
local stepAccumulator = 0
local STEP_DISTANCE = 3
local winDebounce = false
local stepAwardDebounce = false

local currentLevel = 1
local isFirstLoad = true
local currentStepBonus = 1
local currentMultiplier = 1
local hasSpeedBoost = false
local currentTreadmillMultiplier = 1
local currentSpeedBoostLevel = 0
local shouldShowVisual = true -- ✅ Controla se deve mostrar o visual +XP (atualizado pelo server)

local onTreadmill = false
local onGoldTreadmill = false
local onBlueTreadmill = false    -- Esteira azul x9
local onPurpleTreadmill = false  -- Esteira roxa x25
local xpTimer = 0
local treadmillParts = {}
local goldTreadmillParts = {}
local blueTreadmillParts = {}    -- Lista para esteiras azuis (x9)
local purpleTreadmillParts = {}  -- Lista para esteiras roxas (x25)
local runTrack = nil

local stepAwardParts = {}

local soundFolder = Instance.new("Folder")
soundFolder.Name = "GameSounds"
soundFolder.Parent = game:GetService("SoundService")

local levelUpSound = Instance.new("Sound")
levelUpSound.Name = "LevelUp"
levelUpSound.SoundId = "rbxassetid://367453005"
levelUpSound.Volume = 1
levelUpSound.Parent = soundFolder

local rebirthSound = Instance.new("Sound")
rebirthSound.Name = "Rebirth"
rebirthSound.SoundId = "rbxassetid://5159368909"
rebirthSound.Volume = 1
rebirthSound.Parent = soundFolder

local collectSound = Instance.new("Sound")
collectSound.Name = "Collect"
collectSound.SoundId = "rbxassetid://1289263994"
collectSound.Volume = 0.5
collectSound.Parent = soundFolder

-- ✅ FUNÇÃO PARA CALCULAR MULTIPLICADOR
local function getSpeedBoostMultiplier(level)
	if level <= 0 then return 1 end
	return math.pow(2, level)
end

-- ✅ ATUALIZA O BOTÃO DE SPEED BOOST
local function updateSpeedBoostButton()
	local screenGui = playerGui:FindFirstChild("SpeedGameUI")
	if not screenGui then return end

	local speedBoostButton = screenGui:FindFirstChild("SpeedBoostButton", true)
	if not speedBoostButton then return end

	-- Encontra o TextLabel dentro do botão
	local textLabel = speedBoostButton:FindFirstChildOfClass("TextLabel")
	if not textLabel then
		-- Se não existir, procura no próprio botão
		if speedBoostButton:IsA("TextButton") then
			textLabel = speedBoostButton
		end
	end

	if textLabel then
		local currentMult = getSpeedBoostMultiplier(currentSpeedBoostLevel)
		local nextMult = getSpeedBoostMultiplier(currentSpeedBoostLevel + 1)

		if currentSpeedBoostLevel == 0 then
			textLabel.Text = "🚀 GET " .. nextMult .. "X SPEED"
		else
			textLabel.Text = "⚡ " .. currentMult .. "X → " .. nextMult .. "X"
		end

		print("Speed Boost button updated: " .. textLabel.Text)
	end
end

-- ✅ CONECTA O BOTÃO 2X SPEED
task.spawn(function()
	local screenGui = playerGui:WaitForChild("SpeedGameUI", 10)
	if screenGui then
		local speedBoostButton = screenGui:FindFirstChild("SpeedBoostButton", true)
		if speedBoostButton and PromptSpeedBoostEvent then
			local button = speedBoostButton:FindFirstChildOfClass("TextButton") or speedBoostButton:FindFirstChildOfClass("ImageButton")
			if button then
				button.Activated:Connect(function()
					print("Speed Boost button clicked!")
					PromptSpeedBoostEvent:FireServer()
				end)
				print("Speed Boost button connected!")

				-- Atualiza o botão inicialmente
				updateSpeedBoostButton()
			else
				print("Warning: Speed Boost button not found (no TextButton/ImageButton)")
			end
		else
			print("Warning: SpeedBoostButton or PromptSpeedBoostEvent not found")
		end
	end
end)

local function showLevelUp(oldLevel, newLevel)
	local screenGui = playerGui:FindFirstChild("SpeedGameUI")
	if not screenGui then return end

	levelUpSound:Play()

	local container = Instance.new("Frame")
	container.Name = "LevelUpNotification"
	container.Size = UDim2.new(0, 400, 0, 150)
	container.Position = UDim2.new(0.5, -200, 0.4, -75)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local levelUpText = Instance.new("TextLabel")
	levelUpText.Size = UDim2.new(1, 0, 0.5, 0)
	levelUpText.Position = UDim2.new(0, 0, 0, 0)
	levelUpText.BackgroundTransparency = 1
	levelUpText.Text = "🎉 LEVEL UP! 🎉"
	levelUpText.TextColor3 = Color3.fromRGB(255, 215, 0)
	levelUpText.TextSize = 48
	levelUpText.Font = Enum.Font.GothamBlack
	levelUpText.Parent = container

	local stroke1 = Instance.new("UIStroke")
	stroke1.Color = Color3.fromRGB(0, 0, 0)
	stroke1.Thickness = 4
	stroke1.Parent = levelUpText

	local newLevelText = Instance.new("TextLabel")
	newLevelText.Size = UDim2.new(1, 0, 0.25, 0)
	newLevelText.Position = UDim2.new(0, 0, 0.5, 0)
	newLevelText.BackgroundTransparency = 1
	newLevelText.Text = "Level " .. newLevel
	newLevelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	newLevelText.TextSize = 36
	newLevelText.Font = Enum.Font.GothamBold
	newLevelText.Parent = container

	local stroke2 = Instance.new("UIStroke")
	stroke2.Color = Color3.fromRGB(0, 0, 0)
	stroke2.Thickness = 3
	stroke2.Parent = newLevelText

	local oldSpeed = 16 + oldLevel
	local newSpeed = 16 + newLevel

	local speedText = Instance.new("TextLabel")
	speedText.Size = UDim2.new(1, 0, 0.25, 0)
	speedText.Position = UDim2.new(0, 0, 0.75, 0)
	speedText.BackgroundTransparency = 1
	speedText.Text = "Walk Speed: " .. oldSpeed .. " → " .. newSpeed
	speedText.TextColor3 = Color3.fromRGB(100, 255, 100)
	speedText.TextSize = 28
	speedText.Font = Enum.Font.GothamBold
	speedText.Parent = container

	local stroke3 = Instance.new("UIStroke")
	stroke3.Color = Color3.fromRGB(0, 0, 0)
	stroke3.Thickness = 2
	stroke3.Parent = speedText

	container.Size = UDim2.new(0, 0, 0, 0)
	container.Position = UDim2.new(0.5, 0, 0.4, 0)

	local expandTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 400, 0, 150),
		Position = UDim2.new(0.5, -200, 0.4, -75)
	})
	expandTween:Play()

	task.delay(2.5, function()
		local fadeTween = TweenService:Create(container, TweenInfo.new(0.5), {
			Position = UDim2.new(0.5, -200, 0.3, -75)
		})
		fadeTween:Play()

		for _, child in pairs(container:GetDescendants()) do
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			end
		end

		task.delay(0.5, function()
			container:Destroy()
		end)
	end)
end

local function updateEquippedText()
	for _, data in pairs(stepAwardParts) do
		local part = data.part
		local bonus = data.bonus
		local textPart = part:FindFirstChild("TextPart")

		if textPart then
			local gui = textPart:FindFirstChild("StepAwardGui")
			if gui then
				local frame = gui:FindFirstChild("Frame")
				if frame then
					local equippedLabel = frame:FindFirstChild("EquippedLabel")

					if bonus == currentStepBonus then
						if not equippedLabel then
							equippedLabel = Instance.new("TextLabel")
							equippedLabel.Name = "EquippedLabel"
							equippedLabel.Size = UDim2.new(1, 0, 0.25, 0)
							equippedLabel.Position = UDim2.new(0, 0, 0.75, 0)
							equippedLabel.BackgroundTransparency = 1
							equippedLabel.Text = "✓ EQUIPPED"
							equippedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
							equippedLabel.TextSize = 35
							equippedLabel.Font = Enum.Font.GothamBlack
							equippedLabel.Parent = frame

							local stroke = Instance.new("UIStroke")
							stroke.Color = Color3.fromRGB(0, 0, 0)
							stroke.Thickness = 3
							stroke.Parent = equippedLabel
						else
							equippedLabel.Visible = true
						end
					else
						if equippedLabel then
							equippedLabel.Visible = false
						end
					end
				end
			end
		end
	end
end

UpdateUIEvent.OnClientEvent:Connect(function(data)
	local oldLevel = currentLevel
	currentLevel = data.Level

	local oldBonus = currentStepBonus
	currentStepBonus = data.StepBonus or 1

	currentMultiplier = data.Multiplier or 1
	hasSpeedBoost = data.SpeedBoostActive or false
	currentTreadmillMultiplier = data.TreadmillMultiplier or 1

	-- ✅ ATUALIZA O SPEED BOOST LEVEL
	local oldSpeedBoostLevel = currentSpeedBoostLevel
	currentSpeedBoostLevel = data.SpeedBoostLevel or 0

	if currentSpeedBoostLevel ~= oldSpeedBoostLevel then
		print("Speed Boost Level changed: " .. oldSpeedBoostLevel .. " → " .. currentSpeedBoostLevel)
		updateSpeedBoostButton()
	end

	-- ✅ COOLDOWN DE VISUAL: Server controla quando mostrar o efeito +XP
	if data.ShowVisual ~= nil then
		shouldShowVisual = data.ShowVisual
		print("[CLIENT_VISUAL] ShowVisual=" .. tostring(shouldShowVisual))
		if shouldShowVisual then
			print("[CLIENT_VISUAL] Calling showPlusOne()")
			showPlusOne()
		end
	end

	if currentLevel > oldLevel and not isFirstLoad then
		showLevelUp(oldLevel, currentLevel)
	end

	isFirstLoad = false

	if oldBonus ~= currentStepBonus then
		updateEquippedText()
	end
end)

local function showPlusOne()
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	collectSound:Play()

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlusOne"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
	billboard.AlwaysOnTop = true
	billboard.Adornee = hrp
	billboard.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 3)
	layout.Parent = frame

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 24, 0, 24)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://16408406294"
	icon.LayoutOrder = 1
	icon.Parent = frame

	local speedBoostMult = getSpeedBoostMultiplier(currentSpeedBoostLevel)
	local totalXPGain = currentStepBonus * currentMultiplier * speedBoostMult * currentTreadmillMultiplier

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 70, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = "x" .. math.floor(totalXPGain)
	label.TextColor3 = currentTreadmillMultiplier > 1 and Color3.fromRGB(255, 215, 0) or (speedBoostMult > 1 and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 0))
	label.TextSize = 24
	label.Font = Enum.Font.GothamBlack
	label.LayoutOrder = 2
	label.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 2
	stroke.Parent = label

	local startOffset = billboard.StudsOffset
	local endOffset = startOffset + Vector3.new(0, 3, 0)

	TweenService:Create(billboard, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = endOffset
	}):Play()
	TweenService:Create(label, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
	TweenService:Create(icon, TweenInfo.new(0.8), {ImageTransparency = 1}):Play()

	task.delay(0.8, function()
		billboard:Destroy()
	end)
end

local function showMessage(text, color)
	local screenGui = playerGui:FindFirstChild("SpeedGameUI")
	if not screenGui then return end

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Name = "Message"
	msgLabel.Size = UDim2.new(0, 400, 0, 50)
	msgLabel.Position = UDim2.new(0.5, -200, 0.3, 0)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = text
	msgLabel.TextColor3 = color
	msgLabel.TextSize = 32
	msgLabel.Font = Enum.Font.GothamBlack
	msgLabel.Parent = screenGui

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 3
	stroke.Parent = msgLabel

	TweenService:Create(msgLabel, TweenInfo.new(2), {TextTransparency = 1}):Play()
	task.delay(2, function() msgLabel:Destroy() end)
end

local function playRunAnimation()
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local animate = character:FindFirstChild("Animate")
	if animate then
		local run = animate:FindFirstChild("run")
		if run then
			local runAnim = run:FindFirstChildOfClass("Animation")
			if runAnim then
				runTrack = humanoid:LoadAnimation(runAnim)
				runTrack.Priority = Enum.AnimationPriority.Movement
				runTrack.Looped = true
				runTrack:Play()
				return
			end
		end
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://180426354"
	runTrack = humanoid:LoadAnimation(anim)
	runTrack.Priority = Enum.AnimationPriority.Movement
	runTrack.Looped = true
	runTrack:Play()
end

local function stopRunAnimation()
	if runTrack then
		runTrack:Stop()
		runTrack = nil
	end
end

local function isOnTreadmill()
	local character = player.Character
	if not character then return false, false, false, false end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false, false, false, false end

	local playerPos = hrp.Position

	-- Prioridade: Purple (x25) > Blue (x9) > Gold (x3) > Free (x1)

	-- Verifica esteira roxa (x25) primeiro (maior prioridade)
	for _, conveyor in pairs(purpleTreadmillParts) do
		if conveyor and conveyor.Parent then
			local conveyorPos = conveyor.Position
			local conveyorSize = conveyor.Size

			local dx = math.abs(playerPos.X - conveyorPos.X)
			local dz = math.abs(playerPos.Z - conveyorPos.Z)
			local dy = playerPos.Y - conveyorPos.Y

			if dx < conveyorSize.X/2 + 2 and dz < conveyorSize.Z/2 + 2 and dy > 0 and dy < 5 then
				return true, false, false, true  -- (onTreadmill, isGold, isBlue, isPurple)
			end
		end
	end

	-- Verifica esteira azul (x9)
	for _, conveyor in pairs(blueTreadmillParts) do
		if conveyor and conveyor.Parent then
			local conveyorPos = conveyor.Position
			local conveyorSize = conveyor.Size

			local dx = math.abs(playerPos.X - conveyorPos.X)
			local dz = math.abs(playerPos.Z - conveyorPos.Z)
			local dy = playerPos.Y - conveyorPos.Y

			if dx < conveyorSize.X/2 + 2 and dz < conveyorSize.Z/2 + 2 and dy > 0 and dy < 5 then
				return true, false, true, false  -- (onTreadmill, isGold, isBlue, isPurple)
			end
		end
	end

	-- Verifica esteira dourada (x3)
	for _, conveyor in pairs(goldTreadmillParts) do
		if conveyor and conveyor.Parent then
			local conveyorPos = conveyor.Position
			local conveyorSize = conveyor.Size

			local dx = math.abs(playerPos.X - conveyorPos.X)
			local dz = math.abs(playerPos.Z - conveyorPos.Z)
			local dy = playerPos.Y - conveyorPos.Y

			if dx < conveyorSize.X/2 + 2 and dz < conveyorSize.Z/2 + 2 and dy > 0 and dy < 5 then
				return true, true, false, false  -- (onTreadmill, isGold, isBlue, isPurple)
			end
		end
	end

	-- Verifica esteira grátis (x1)
	for _, conveyor in pairs(treadmillParts) do
		if conveyor and conveyor.Parent then
			local conveyorPos = conveyor.Position
			local conveyorSize = conveyor.Size

			local dx = math.abs(playerPos.X - conveyorPos.X)
			local dz = math.abs(playerPos.Z - conveyorPos.Z)
			local dy = playerPos.Y - conveyorPos.Y

			if dx < conveyorSize.X/2 + 2 and dz < conveyorSize.Z/2 + 2 and dy > 0 and dy < 5 then
				return true, false, false, false  -- (onTreadmill, isGold, isBlue, isPurple)
			end
		end
	end

	return false, false, false, false
end

RunService.Heartbeat:Connect(function(dt)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end

	if humanoid.Health <= 0 then return end

	local wasOnTreadmill = onTreadmill
	local isGold, isBlue, isPurple
	onTreadmill, isGold, isBlue, isPurple = isOnTreadmill()
	onGoldTreadmill = isGold
	onBlueTreadmill = isBlue
	onPurpleTreadmill = isPurple

	if onTreadmill and not wasOnTreadmill then
		playRunAnimation()
	end

	if not onTreadmill and wasOnTreadmill then
		stopRunAnimation()
	end

	if onTreadmill then
		xpTimer = xpTimer + dt
		if xpTimer >= 0.15 then
			xpTimer = 0

			-- Prioridade: Purple (x25) > Blue (x9) > Gold (x3) > Free (x1)

			-- Esteira roxa (x25) - maior prioridade
			if onPurpleTreadmill then
				local hasAccess = hasPurpleTreadmillAccess()
				print("[CLIENT] On PURPLE treadmill (x25)! hasAccess=" .. tostring(hasAccess))
				if hasAccess then
					UpdateSpeedEvent:FireServer(1, 25) -- steps, treadmillMultiplier = 25
				else
					-- Prompt para comprar a esteira x25 (uma vez a cada 5 segundos)
					if not purchasePromptDebounce then
						purchasePromptDebounce = true
						print("[CLIENT] Prompting purchase for Treadmill x25")
						MarketplaceService:PromptProductPurchase(player, TREADMILL_X25_PRODUCT_ID)
						task.delay(5, function()
							purchasePromptDebounce = false
						end)
					end
				end

			-- Esteira azul (x9)
			elseif onBlueTreadmill then
				local hasAccess = hasBlueTreadmillAccess()
				print("[CLIENT] On BLUE treadmill (x9)! hasAccess=" .. tostring(hasAccess))
				if hasAccess then
					UpdateSpeedEvent:FireServer(1, 9) -- steps, treadmillMultiplier = 9
				else
					-- Prompt para comprar a esteira x9 (uma vez a cada 5 segundos)
					if not purchasePromptDebounce then
						purchasePromptDebounce = true
						print("[CLIENT] Prompting purchase for Treadmill x9")
						MarketplaceService:PromptProductPurchase(player, TREADMILL_X9_PRODUCT_ID)
						task.delay(5, function()
							purchasePromptDebounce = false
						end)
					end
				end

			-- Esteira dourada (x3)
			elseif onGoldTreadmill then
				local hasAccess = hasGoldTreadmillAccess()
				print("[CLIENT] On GOLD treadmill (x3)! hasAccess=" .. tostring(hasAccess))
				if hasAccess then
					UpdateSpeedEvent:FireServer(1, 3) -- steps, treadmillMultiplier = 3
				else
					-- Prompt para comprar a esteira x3 (uma vez a cada 5 segundos)
					if not purchasePromptDebounce then
						purchasePromptDebounce = true
						print("[CLIENT] Prompting purchase for Treadmill x3")
						MarketplaceService:PromptProductPurchase(player, TREADMILL_X3_PRODUCT_ID)
						task.delay(5, function()
							purchasePromptDebounce = false
						end)
					end
				end

			-- Esteira grátis (x1)
			else
				print("[CLIENT] On FREE treadmill")
				UpdateSpeedEvent:FireServer(1, 1) -- steps, treadmillMultiplier = 1
			end
		end
		return
	end

	local currentPos = hrp.Position

	if lastPosition and humanoid.MoveDirection.Magnitude > 0 then
		local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude
		stepAccumulator = stepAccumulator + dist

		while stepAccumulator >= STEP_DISTANCE do
			stepAccumulator = stepAccumulator - STEP_DISTANCE
			UpdateSpeedEvent:FireServer(1) -- visual mostrado via UpdateUIEvent com cooldown
		end
	end

	lastPosition = currentPos
end)

player.CharacterAdded:Connect(function(character)
	lastPosition = nil
	stepAccumulator = 0
	onTreadmill = false
	runTrack = nil

	local humanoid = character:WaitForChild("Humanoid")
	task.wait(0.5)
end)

local function connectWinBlock(obj)
	obj.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) and not winDebounce then
			winDebounce = true
			AddWinEvent:FireServer()
			task.delay(1, function() winDebounce = false end)
		end
	end)
end

local function connectStepAward(obj)
	local bonus = obj:GetAttribute("Bonus")
	local requiredLevel = obj:GetAttribute("RequiredLevel")
	if not bonus or not requiredLevel then return end

	table.insert(stepAwardParts, {part = obj, bonus = bonus})

	obj.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) and not stepAwardDebounce then
			stepAwardDebounce = true
			if currentLevel >= requiredLevel then
				EquipStepAwardEvent:FireServer(bonus)
				showMessage("EQUIPPED! +" .. bonus .. "/step", Color3.fromRGB(0, 255, 100))
			else
				showMessage("Need Level " .. requiredLevel .. "!", Color3.fromRGB(255, 100, 100))
			end
			task.delay(1, function() stepAwardDebounce = false end)
		end
	end)
end

-- Função para procurar esteiras (com delay para garantir que workspace carregou)
local function setupTreadmills()
	print("[CLIENT] ========== STARTING TREADMILL DETECTION ==========")
	print("[CLIENT] Waiting for workspace to load...")
	task.wait(2)  -- Espera 2 segundos para o workspace carregar

	-- Primeiro, vamos listar TODOS os objetos com "Treadmill" no nome
	print("[CLIENT] Searching for ALL objects with 'Treadmill' in name...")
	local treadmillRelatedObjects = 0
	for _, obj in pairs(workspace:GetDescendants()) do
		if string.match(obj.Name, "Treadmill") then
			treadmillRelatedObjects = treadmillRelatedObjects + 1
			local parent = obj.Parent
			print("[CLIENT]   Found: " .. obj.Name .. " (" .. obj.ClassName .. ") - Parent: " .. (parent and parent.Name or "nil") .. " - FullName: " .. obj:GetFullName())

			-- Se for um BasePart, mostra Position e Size
			if obj:IsA("BasePart") then
				print("[CLIENT]     → Is BasePart - Position: " .. tostring(obj.Position) .. " Size: " .. tostring(obj.Size))
			end

			-- Se for um Model, mostra se tem PrimaryPart
			if obj:IsA("Model") then
				print("[CLIENT]     → Is Model - PrimaryPart: " .. tostring(obj.PrimaryPart))
			end
		end
	end
	print("[CLIENT] Total objects with 'Treadmill' in name: " .. treadmillRelatedObjects)

	-- Agora procura especificamente por TreadmillZone
	print("[CLIENT] Starting TreadmillZone detection...")
	local treadmillZonesFound = 0

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "TreadmillZone" then
			treadmillZonesFound = treadmillZonesFound + 1
			local parent = obj.Parent
			print("[CLIENT] Found TreadmillZone #" .. treadmillZonesFound)
			print("[CLIENT]   Name: " .. obj.Name)
			print("[CLIENT]   Type: " .. obj.ClassName)
			print("[CLIENT]   Parent: " .. (parent and parent.Name or "nil"))
			print("[CLIENT]   FullName: " .. obj:GetFullName())

			-- Determina qual part usar para detecção
			local detectionPart = nil
			if obj:IsA("BasePart") then
				detectionPart = obj
				print("[CLIENT]   → Is BasePart, using directly")
			elseif obj:IsA("Model") and obj.PrimaryPart then
				detectionPart = obj.PrimaryPart
				print("[CLIENT]   → Is Model with PrimaryPart, using PrimaryPart")
			elseif obj:IsA("Model") then
				-- Procura por um BasePart dentro do Model
				for _, child in pairs(obj:GetDescendants()) do
					if child:IsA("BasePart") then
						detectionPart = child
						print("[CLIENT]   → Is Model, using first BasePart found: " .. child.Name)
						break
					end
				end
			end

			if not detectionPart then
				warn("[CLIENT]   → Could not find BasePart for detection!")
			else
				print("[CLIENT]   → Using detection part: " .. detectionPart.Name .. " (Position: " .. tostring(detectionPart.Position) .. ")")

				-- Adiciona à lista apropriada
				if parent and string.match(parent.Name, "TreadmillPurple") then
					table.insert(purpleTreadmillParts, detectionPart)
					print("[CLIENT]   → ✓ Added to PURPLE treadmills (x25)")
				elseif parent and string.match(parent.Name, "TreadmillBlue") then
					table.insert(blueTreadmillParts, detectionPart)
					print("[CLIENT]   → ✓ Added to BLUE treadmills (x9)")
				elseif parent and (string.match(parent.Name, "TreadmillGold") or string.match(parent.Name, "TreadmillPaid")) then
					table.insert(goldTreadmillParts, detectionPart)
					print("[CLIENT]   → ✓ Added to GOLD treadmills (x3)")
				elseif parent and string.match(parent.Name, "TreadmillFree") then
					table.insert(treadmillParts, detectionPart)
					print("[CLIENT]   → ✓ Added to FREE treadmills (x1)")
				else
					print("[CLIENT]   → ✗ Not added (parent doesn't match pattern)")
					if parent then
						print("[CLIENT]      Parent name: '" .. parent.Name .. "'")
					end
				end
			end
		end
	end

	print("[CLIENT] ========== SEARCH COMPLETE ==========")
	print("[CLIENT] Total TreadmillZones found: " .. treadmillZonesFound)
	print("[CLIENT] Total FREE treadmills (x1): " .. #treadmillParts)
	print("[CLIENT] Total GOLD treadmills (x3): " .. #goldTreadmillParts)
	print("[CLIENT] Total BLUE treadmills (x9): " .. #blueTreadmillParts)
	print("[CLIENT] Total PURPLE treadmills (x25): " .. #purpleTreadmillParts)

	-- Debug: lista todas as esteiras encontradas
	if #treadmillParts > 0 then
		print("[CLIENT] FREE treadmills list:")
		for i, conveyor in ipairs(treadmillParts) do
			print("[CLIENT]   #" .. i .. ": " .. conveyor:GetFullName())
		end
	end
	if #goldTreadmillParts > 0 then
		print("[CLIENT] GOLD treadmills list:")
		for i, conveyor in ipairs(goldTreadmillParts) do
			print("[CLIENT]   #" .. i .. ": " .. conveyor:GetFullName())
		end
	end
	if #blueTreadmillParts > 0 then
		print("[CLIENT] BLUE treadmills list:")
		for i, conveyor in ipairs(blueTreadmillParts) do
			print("[CLIENT]   #" .. i .. ": " .. conveyor:GetFullName())
		end
	end
	if #purpleTreadmillParts > 0 then
		print("[CLIENT] PURPLE treadmills list:")
		for i, conveyor in ipairs(purpleTreadmillParts) do
			print("[CLIENT]   #" .. i .. ": " .. conveyor:GetFullName())
		end
	end

	if #treadmillParts == 0 and #goldTreadmillParts == 0 and #blueTreadmillParts == 0 and #purpleTreadmillParts == 0 then
		warn("[CLIENT] ⚠️ NO TREADMILLS FOUND! This will prevent treadmill detection from working!")
	end
end

-- Chama a função de setup
task.spawn(setupTreadmills)

workspace.DescendantAdded:Connect(function(obj)
	task.wait(0.1)
	if obj.Name == "TreadmillZone" then
		local parent = obj.Parent
		print("[CLIENT] Dynamically added TreadmillZone: " .. obj:GetFullName())

		-- Determina qual part usar para detecção
		local detectionPart = nil
		if obj:IsA("BasePart") then
			detectionPart = obj
		elseif obj:IsA("Model") and obj.PrimaryPart then
			detectionPart = obj.PrimaryPart
		elseif obj:IsA("Model") then
			for _, child in pairs(obj:GetDescendants()) do
				if child:IsA("BasePart") then
					detectionPart = child
					break
				end
			end
		end

		if detectionPart then
			if parent and string.match(parent.Name, "TreadmillPurple") then
				table.insert(purpleTreadmillParts, detectionPart)
				print("[CLIENT] → Added to PURPLE treadmills (x25) dynamically")
			elseif parent and string.match(parent.Name, "TreadmillBlue") then
				table.insert(blueTreadmillParts, detectionPart)
				print("[CLIENT] → Added to BLUE treadmills (x9) dynamically")
			elseif parent and (string.match(parent.Name, "TreadmillGold") or string.match(parent.Name, "TreadmillPaid")) then
				table.insert(goldTreadmillParts, detectionPart)
				print("[CLIENT] → Added to GOLD treadmills (x3) dynamically")
			elseif parent and string.match(parent.Name, "TreadmillFree") then
				table.insert(treadmillParts, detectionPart)
				print("[CLIENT] → Added to FREE treadmills (x1) dynamically")
			end
		end
	elseif obj:IsA("BasePart") then
		if string.match(obj.Name, "WinBlock") then
			connectWinBlock(obj)
		elseif string.match(obj.Name, "StepAward") then
			connectStepAward(obj)
		end
	end
end)

task.delay(1, updateEquippedText)

local RebirthSuccessEvent = Remotes:WaitForChild("RebirthSuccess")
RebirthSuccessEvent.OnClientEvent:Connect(function()
	rebirthSound:Play()
end)

print("Client ready - sounds fixed for respawn")