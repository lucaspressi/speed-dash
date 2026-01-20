print("==================== [CLIENT] LocalScript.lua STARTING ====================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
print("[CLIENT] LocalScript.lua loaded! Player: " .. player.Name)
print("[CLIENT] ✅ CHECKPOINT 1: Services and player loaded")
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PromptSpeedBoostEvent = Remotes:FindFirstChild("PromptSpeedBoost")

local MarketplaceService = game:GetService("MarketplaceService")
local TREADMILL_X3_PRODUCT_ID = 3510639799   -- 3x Speed Treadmill (dourada) - 59 Robux
local TREADMILL_X9_PRODUCT_ID = 3510662188   -- 9x Speed Treadmill (azul) - 149 Robux
local TREADMILL_X25_PRODUCT_ID = 3510662405  -- 25x Speed Treadmill (roxa) - 399 Robux

-- 🔄 PATCH 4: CACHE LOCAL de ownership (nil ao invés de false)
-- nil = não inicializado (aguardando snapshot do server)
-- true = possui
-- false = não possui (mas confirmado pelo server)
local treadmillOwnershipCache = {
	[3] = nil,   -- Aguardando snapshot
	[9] = nil,   -- Aguardando snapshot
	[25] = nil,  -- Aguardando snapshot
}

-- 🔄 NÃO inicializa com Attributes imediatamente - aguarda snapshot do server
print("[CLIENT] Ownership cache initialized as nil (awaiting server snapshot)...")

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

-- ✅ SIGNALS AGORA SÓ ATUALIZAM O CACHE (não leem de hasXxxAccess que usa o próprio cache)
-- Isso evita loop e garante que o servidor é a source of truth
player:GetAttributeChangedSignal("TreadmillX3Owned"):Connect(function()
	local newValue = player:GetAttribute("TreadmillX3Owned") == true
	print("[CLIENT] TreadmillX3Owned attribute changed to: " .. tostring(newValue))
	treadmillOwnershipCache[3] = newValue
end)

player:GetAttributeChangedSignal("TreadmillX9Owned"):Connect(function()
	local newValue = player:GetAttribute("TreadmillX9Owned") == true
	print("[CLIENT] TreadmillX9Owned attribute changed to: " .. tostring(newValue))
	treadmillOwnershipCache[9] = newValue
end)

player:GetAttributeChangedSignal("TreadmillX25Owned"):Connect(function()
	local newValue = player:GetAttribute("TreadmillX25Owned") == true
	print("[CLIENT] TreadmillX25Owned attribute changed to: " .. tostring(newValue))
	treadmillOwnershipCache[25] = newValue
end)

local UpdateSpeedEvent = Remotes:WaitForChild("UpdateSpeed")
local AddWinEvent = Remotes:WaitForChild("AddWin")
local EquipStepAwardEvent = Remotes:WaitForChild("EquipStepAward")
local UpdateUIEvent = Remotes:WaitForChild("UpdateUI")
local TreadmillOwnershipUpdated = Remotes:WaitForChild("TreadmillOwnershipUpdated")

-- 🔄 PATCH 4: Snapshot com timeout e aplicação ANTES da UI
local snapshotReceived = false

-- ✅ LISTENER: Atualiza ownership quando server notifica (após compra ou join)
-- Aceita dois formatos:
-- 1. Snapshot completo (table): {[3]=true, [9]=false, [25]=true}
-- 2. Update individual (multiplier, owned): (3, true)
TreadmillOwnershipUpdated.OnClientEvent:Connect(function(multiplierOrSnapshot, owned)
	-- Safe string conversion function
	local function safeStr(val)
		if type(val) == "table" then
			return "{table}"
		elseif val == nil then
			return "nil"
		else
			return tostring(val)
		end
	end

	if type(multiplierOrSnapshot) == "table" then
		-- Formato: snapshot completo (usado no join)
		print("[CLIENT] TreadmillOwnershipUpdated received SNAPSHOT:")
		for mult, isOwned in pairs(multiplierOrSnapshot) do
			-- Debug: show exact types received
			local multType = type(mult)
			local ownedType = type(isOwned)
			print("[CLIENT]   x" .. safeStr(mult) .. " = " .. safeStr(isOwned) .. " (types: " .. multType .. ", " .. ownedType .. ")")

			-- Convert string keys to numbers if needed (RemoteEvents might stringify keys)
			local multNum = tonumber(mult) or mult
			local ownedBool = (isOwned == true or isOwned == 1 or isOwned == "true")

			if type(multNum) == "number" then
				treadmillOwnershipCache[multNum] = ownedBool

				-- Atualiza atributo do player (sincronização)
				local key = "TreadmillX" .. tostring(multNum) .. "Owned"
				player:SetAttribute(key, ownedBool)
				print("[CLIENT]   ✅ Updated cache: x" .. multNum .. " = " .. tostring(ownedBool))
			else
				warn("[CLIENT] ⚠️ Could not convert mult to number: " .. safeStr(mult) .. " (type: " .. multType .. ")")
			end
		end
		print("[CLIENT] Ownership cache fully updated from snapshot!")
		snapshotReceived = true
	else
		-- Formato: update individual (usado após compra)
		local multiplier = multiplierOrSnapshot
		print("[CLIENT] TreadmillOwnershipUpdated received: x" .. safeStr(multiplier) .. " = " .. safeStr(owned))

		if type(multiplier) == "number" then
			treadmillOwnershipCache[multiplier] = (owned == true or owned == 1)

			-- Atualiza o atributo local também (redundante mas garante sincronização)
			local key = "TreadmillX" .. tostring(multiplier) .. "Owned"
			player:SetAttribute(key, (owned == true or owned == 1))

			print("[CLIENT] Ownership cache updated. Can now use x" .. safeStr(multiplier) .. " treadmill!")
		else
			warn("[CLIENT] Invalid ownership update: multiplier=" .. safeStr(multiplier) .. ", owned=" .. safeStr(owned))
		end
	end
end)

-- 🔄 AGUARDA SNAPSHOT DO SERVER (timeout: 5 segundos)
-- CRÍTICO: Aplica ANTES de inicializar qualquer UI ou lógica de gameplay
print("[CLIENT] Waiting for ownership snapshot from server (timeout: 5s)...")
local waitStartTime = tick()
local SNAPSHOT_TIMEOUT = 5

while not snapshotReceived and (tick() - waitStartTime) < SNAPSHOT_TIMEOUT do
	task.wait(0.1)
end

if snapshotReceived then
	print("[CLIENT] ✅ Snapshot received successfully!")
else
	warn("[CLIENT] ⚠️ Snapshot timeout! Falling back to player Attributes...")
	-- Fallback: lê de Attributes do player (se server setou antes)
	local attr3 = player:GetAttribute("TreadmillX3Owned")
	local attr9 = player:GetAttribute("TreadmillX9Owned")
	local attr25 = player:GetAttribute("TreadmillX25Owned")

	treadmillOwnershipCache[3] = (attr3 == true)
	treadmillOwnershipCache[9] = (attr9 == true)
	treadmillOwnershipCache[25] = (attr25 == true)

	-- Safe print with type checking
	local function safeStr(val)
		if type(val) == "table" then
			return "{table}"
		elseif val == nil then
			return "nil"
		else
			return tostring(val)
		end
	end

	print("[CLIENT] Fallback cache: x3=" .. safeStr(treadmillOwnershipCache[3]) .. " x9=" .. safeStr(treadmillOwnershipCache[9]) .. " x25=" .. safeStr(treadmillOwnershipCache[25]))
end

local lastPosition = nil
local stepAccumulator = 0
local STEP_DISTANCE = 3
local winDebounce = false
local stepAwardDebounce = false

local currentLevel = 1
local currentWins = 0  -- ✅ Wins do jogador (para Step Awards)
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

-- ✅ SET para deduplicate zonas (evita adicionar a mesma zone 2x)
local detectedZones = {}  -- [Instance] = true

local stepAwardParts = {}
local connectedStepAwards = {}  -- ✅ Rastreia quais StepAwards já foram conectados (evita duplicação)
local connectedWinBlocks = {}   -- ✅ Rastreia quais WinBlocks já foram conectados (evita duplicação)

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

print("[CLIENT] ✅ CHECKPOINT 2: Basic sounds created (levelUp, rebirth, collect)")

-- 🎵 MÚSICA DE FUNDO
local backgroundMusic = Instance.new("Sound")
backgroundMusic.Name = "BackgroundMusic"
backgroundMusic.SoundId = "rbxassetid://1837879082"  -- Música calma/chill lo-fi
backgroundMusic.Volume = 0.005  -- Volume muito baixo (quase ambiente)
backgroundMusic.Looped = true  -- Loop infinito
backgroundMusic.Parent = soundFolder
print("[CLIENT] 🎵 Background music created: " .. backgroundMusic.SoundId)

-- ✅ Aguarda carregar e depois toca
task.spawn(function()
	print("[CLIENT] ⏳ Waiting for background music to load...")

	local success, err = pcall(function()
		if not backgroundMusic.IsLoaded then
			backgroundMusic.Loaded:Wait()
		end
		backgroundMusic:Play()
	end)

	if success then
		print("[CLIENT] ✅ Background music playing!")
	else
		warn("[CLIENT] ❌ Failed to play music: " .. tostring(err))
	end
end)

-- 💀 SOM DE MORTE PELO NPC (MEME BRAINROT)
local npcKillSound = Instance.new("Sound")
npcKillSound.Name = "NpcKill"
npcKillSound.SoundId = "rbxassetid://12221967"  -- Skull emoji (tuntuntun) meme
npcKillSound.Volume = 1
npcKillSound.Parent = soundFolder
print("[CLIENT] 🔊 NPC kill sound created: " .. npcKillSound.SoundId)

-- 💀 OUTROS SONS DE MEME DISPONÍVEIS:
-- Skull emoji (tuntuntun): rbxassetid://12221967
-- Bruh: rbxassetid://4275842574
-- Metal Pipe: rbxassetid://8436226966
-- Windows Error: rbxassetid://160715357
-- Emotional Damage: rbxassetid://8578656799
-- Oof: rbxassetid://6955867

-- ✅ Aguarda o som carregar
task.spawn(function()
	print("[CLIENT] ⏳ Waiting for NPC kill sound to load...")
	local success, err = pcall(function()
		if not npcKillSound.IsLoaded then
			npcKillSound.Loaded:Wait()
		end
	end)

	if success then
		print("[CLIENT] ✅ NPC kill sound loaded successfully!")
	else
		warn("[CLIENT] ⚠️ NPC kill sound load warning: " .. tostring(err))
	end
end)

-- ✅ FUNÇÃO PARA CALCULAR MULTIPLICADOR
local function getSpeedBoostMultiplier(level)
	if level <= 0 then return 1 end
	return math.pow(2, level)
end

-- ⚠️ DEPRECATED: Substituído por GamepassButtonUpdater.client.lua
-- Este sistema antigo foi substituído por um novo script que atualiza dinamicamente
-- o multiplicador E o preço baseado no Attribute "SpeedBoostLevel" do jogador
--[[
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
--]]

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

				-- ⚠️ DEPRECATED: Atualização agora é feita por GamepassButtonUpdater.client.lua
				-- updateSpeedBoostButton()
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
	-- ✅ Função para formatar wins com vírgulas
	local function formatWins(num)
		local formatted = tostring(num)
		local k
		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
			if k == 0 then break end
		end
		return formatted
	end

	for _, data in pairs(stepAwardParts) do
		local part = data.part
		local bonus = data.bonus
		local requiredWins = data.requiredWins or 0
		local textPart = part:FindFirstChild("TextPart")

		if textPart then
			local gui = textPart:FindFirstChild("StepAwardGui")
			if gui then
				local frame = gui:FindFirstChild("Frame")
				if frame then
					-- ✅ Encontra o Frame interno
					local innerFrame = frame:FindFirstChild("Frame")
					if innerFrame then
						-- ✅ Atualiza as TextLabels (bonus e requisitos)
						local textLabels = {}
						for _, child in pairs(innerFrame:GetChildren()) do
							if child:IsA("TextLabel") then
								table.insert(textLabels, child)
							end
						end

						-- Primeira TextLabel: Mostra o bônus "+N/step"
						if textLabels[1] then
							textLabels[1].Text = "+" .. bonus .. "/step"
						end

						-- Segunda TextLabel: Mostra os requisitos "Requires N Wins" ou "FREE!"
						if textLabels[2] then
							if requiredWins == 0 then
								textLabels[2].Text = "FREE!"
								textLabels[2].TextColor3 = Color3.fromRGB(0, 255, 100)
							else
								textLabels[2].Text = "Requires " .. formatWins(requiredWins) .. " Wins"
								textLabels[2].TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						end
					end

					-- ✅ Mostra/esconde label "EQUIPPED"
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

UpdateUIEvent.OnClientEvent:Connect(function(data)
	local oldLevel = currentLevel
	currentLevel = data.Level

	-- ✅ Atualiza wins para Step Awards
	local oldWins = currentWins
	currentWins = data.Wins or 0

	if currentWins ~= oldWins then
		print("[CLIENT] 🏆 Wins updated: " .. oldWins .. " → " .. currentWins)
	end

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
		-- ⚠️ DEPRECATED: Atualização agora é feita por GamepassButtonUpdater.client.lua via Attribute
		-- updateSpeedBoostButton()
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

	-- ✅ Atualiza visuais dos Step Awards quando wins ou bonus mudarem
	if oldBonus ~= currentStepBonus or oldWins ~= currentWins then
		updateEquippedText()
	end
end)

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

-- 🔄 PATCH 4: DEPRECATED - Server-side detection via TreadmillService
--[[
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
--]]

-- 🔄 PATCH 4: Client simplificado - UX only
-- Server detecta zones, client apenas envia steps e mostra prompts
RunService.Heartbeat:Connect(function(dt)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end

	if humanoid.Health <= 0 then return end

	-- Lê estado do player (setado pelo TreadmillService no server)
	local serverOnTreadmill = player:GetAttribute("OnTreadmill") == true
	local serverMultiplier = player:GetAttribute("CurrentTreadmillMultiplier") or 0

	-- Animação de corrida
	local wasOnTreadmill = onTreadmill
	onTreadmill = serverOnTreadmill

	-- 🏃 Animation control moved to server (TreadmillService) for replication
	-- This ensures all players can see the running animation, not just the local player
	-- if onTreadmill and not wasOnTreadmill then
	-- 	playRunAnimation()
	-- end

	-- if not onTreadmill and wasOnTreadmill then
	-- 	stopRunAnimation()
	-- end

	-- Se está em treadmill, envia steps regularmente
	if onTreadmill then
		xpTimer = xpTimer + dt
		if xpTimer >= 0.15 then
			xpTimer = 0

			-- 🔄 NOVO PROTOCOLO: Envia apenas steps (sem multiplier)
			-- Server determina multiplier pela posição do player
			UpdateSpeedEvent:FireServer(1)  -- Server-authoritative!

			-- Verifica se tem acesso (para mostrar prompt)
			local hasAccess = (serverMultiplier == 1 or treadmillOwnershipCache[serverMultiplier] == true)

			if not hasAccess and serverMultiplier > 1 then
				-- Não tem acesso - mostra prompt de compra
				if not purchasePromptDebounce then
					purchasePromptDebounce = true

					local productId = nil
					if serverMultiplier == 3 then
						productId = TREADMILL_X3_PRODUCT_ID
					elseif serverMultiplier == 9 then
						productId = TREADMILL_X9_PRODUCT_ID
					elseif serverMultiplier == 25 then
						productId = TREADMILL_X25_PRODUCT_ID
					end

					if productId then
						print("[CLIENT] Prompting purchase for Treadmill x" .. tostring(serverMultiplier))
						MarketplaceService:PromptProductPurchase(player, productId)
					end

					task.delay(5, function()
						purchasePromptDebounce = false
					end)
				end
			end
		end
		return
	end

	-- Walking (fora da treadmill)
	local currentPos = hrp.Position

	if lastPosition and humanoid.MoveDirection.Magnitude > 0 then
		local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude
		stepAccumulator = stepAccumulator + dist

		while stepAccumulator >= STEP_DISTANCE do
			stepAccumulator = stepAccumulator - STEP_DISTANCE
			UpdateSpeedEvent:FireServer(1)  -- 🔄 Server-authoritative (sem multiplier)
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
	-- ✅ Evita duplicação
	if connectedWinBlocks[obj] then return end
	connectedWinBlocks[obj] = true

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
	-- ✅ Evita duplicação
	if connectedStepAwards[obj] then return end
	connectedStepAwards[obj] = true

	local bonus = obj:GetAttribute("Bonus")
	local requiredWins = obj:GetAttribute("RequiredWins")

	-- ✅ Suporte para legacy (RequiredLevel) mas prioriza RequiredWins
	if not requiredWins then
		requiredWins = obj:GetAttribute("RequiredLevel") or 0
	end

	if not bonus then
		warn("[CLIENT] ⚠️ StepAward missing Bonus attribute: " .. obj:GetFullName())
		return
	end

	print("[CLIENT] ✅ Connected StepAward: " .. obj.Name .. " (Bonus=" .. bonus .. ", RequiredWins=" .. requiredWins .. ")")
	table.insert(stepAwardParts, {part = obj, bonus = bonus, requiredWins = requiredWins})

	obj.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) and not stepAwardDebounce then
			stepAwardDebounce = true
			print("[CLIENT] 🎯 Touched StepAward: " .. obj.Name .. " (Current Wins: " .. currentWins .. ", Required: " .. requiredWins .. ")")
			if currentWins >= requiredWins then
				EquipStepAwardEvent:FireServer(bonus)
				showMessage("EQUIPPED! +" .. bonus .. "/step", Color3.fromRGB(0, 255, 100))
				print("[CLIENT] ✅ Equipped bonus: " .. bonus)
			else
				-- ✅ Formata número de wins com vírgula
				local function formatWins(num)
					local formatted = tostring(num)
					while true do
						formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
						if k == 0 then break end
					end
					return formatted
				end
				showMessage("Need " .. formatWins(requiredWins) .. " Wins!", Color3.fromRGB(255, 100, 100))
			end
			task.delay(1, function() stepAwardDebounce = false end)
		end
	end)
end

-- ✅ FUNÇÃO HELPER: Adiciona zone à lista apropriada (com deduplicação)
local function addZoneToList(zone, multiplier)
	-- Deduplica: verifica se já foi adicionada
	if detectedZones[zone] then
		print("[CLIENT]   → Already detected, skipping duplicate")
		return
	end

	detectedZones[zone] = true

	-- Adiciona à lista apropriada
	if multiplier == 25 then
		table.insert(purpleTreadmillParts, zone)
		print("[CLIENT]   → ✓ Added to PURPLE treadmills (x25)")
	elseif multiplier == 9 then
		table.insert(blueTreadmillParts, zone)
		print("[CLIENT]   → ✓ Added to BLUE treadmills (x9)")
	elseif multiplier == 3 then
		table.insert(goldTreadmillParts, zone)
		print("[CLIENT]   → ✓ Added to GOLD treadmills (x3)")
	elseif multiplier == 1 then
		table.insert(treadmillParts, zone)
		print("[CLIENT]   → ✓ Added to FREE treadmills (x1)")
	else
		warn("[CLIENT]   → Unknown multiplier: " .. tostring(multiplier))
	end
end

-- 🔄 PATCH 4: DEPRECATED - Server-side detection via TreadmillService
-- Mantido comentado para rollback se necessário
--[[
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
		end
	end
	print("[CLIENT] Total objects with 'Treadmill' in name: " .. treadmillRelatedObjects)

	-- Agora procura especificamente por TreadmillZone usando ATTRIBUTES (novo sistema)
	print("[CLIENT] Starting TreadmillZone detection (using Attributes)...")
	local treadmillZonesFound = 0
	local validZonesDetected = 0
	local invalidZonesSkipped = 0

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
			treadmillZonesFound = treadmillZonesFound + 1
			print("[CLIENT] Found TreadmillZone #" .. treadmillZonesFound)
			print("[CLIENT]   FullName: " .. obj:GetFullName())

			-- ✅ LÊ ATTRIBUTES (novo sistema - mais confiável que nome do parent)
			local multiplier = obj:GetAttribute("Multiplier")
			local isFree = obj:GetAttribute("IsFree")
			local productId = obj:GetAttribute("ProductId")

			print("[CLIENT]   Attributes:")
			print("[CLIENT]     Multiplier: " .. tostring(multiplier))
			print("[CLIENT]     IsFree: " .. tostring(isFree))
			print("[CLIENT]     ProductId: " .. tostring(productId))

			-- Validação: deve ter pelo menos Multiplier
			if multiplier then
				-- Adiciona à lista apropriada (com deduplicação)
				addZoneToList(obj, multiplier)
				validZonesDetected = validZonesDetected + 1
			else
				warn("[CLIENT]   → ✗ SKIPPED: Zone missing Multiplier attribute!")
				warn("[CLIENT]      This zone will NOT work. Check TreadmillSetup output on server.")
				invalidZonesSkipped = invalidZonesSkipped + 1
			end
		end
	end

	print("[CLIENT] ========== SEARCH COMPLETE ==========")
	print("[CLIENT] Total TreadmillZones found: " .. treadmillZonesFound)
	print("[CLIENT] Valid zones detected: " .. validZonesDetected)
	print("[CLIENT] Invalid zones skipped: " .. invalidZonesSkipped)
	print("[CLIENT] ")
	print("[CLIENT] Detected by multiplier:")
	print("[CLIENT]   FREE treadmills (x1): " .. #treadmillParts)
	print("[CLIENT]   GOLD treadmills (x3): " .. #goldTreadmillParts)
	print("[CLIENT]   BLUE treadmills (x9): " .. #blueTreadmillParts)
	print("[CLIENT]   PURPLE treadmills (x25): " .. #purpleTreadmillParts)

	if #treadmillParts == 0 and #goldTreadmillParts == 0 and #blueTreadmillParts == 0 and #purpleTreadmillParts == 0 then
		warn("[CLIENT] ⚠️ NO VALID TREADMILLS DETECTED!")
		warn("[CLIENT] Possible causes:")
		warn("[CLIENT]   1. TreadmillSetup.server.lua didn't run on server")
		warn("[CLIENT]   2. Zones don't have Multiplier attribute")
		warn("[CLIENT]   3. Workspace structure is different than expected")
	else
		print("[CLIENT] ✅ Treadmill detection successful!")
	end
end
--]]

-- 🔄 PATCH 4: Detection desabilitada - Server-side via TreadmillService
-- task.spawn(setupTreadmills)  -- DEPRECATED
print("[CLIENT] 🔄 PATCH 4: Zone detection delegated to server (TreadmillService)")

-- ✅ Varredura inicial para WinBlocks e StepAwards (evita perder objetos que já existem)
task.spawn(function()
	task.wait(2)  -- Espera o workspace carregar
	print("[CLIENT] Scanning for WinBlocks and StepAwards...")

	local winBlocksFound = 0
	local stepAwardsFound = 0

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			if string.match(obj.Name, "WinBlock") then
				connectWinBlock(obj)
				winBlocksFound = winBlocksFound + 1
			elseif string.match(obj.Name, "StepAward") then
				connectStepAward(obj)
				stepAwardsFound = stepAwardsFound + 1
			end
		end
	end

	print("[CLIENT] ✅ Found " .. winBlocksFound .. " WinBlocks")
	print("[CLIENT] ✅ Found " .. stepAwardsFound .. " StepAwards")
end)

workspace.DescendantAdded:Connect(function(obj)
	task.wait(0.1)
	if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
		print("[CLIENT] Dynamically added TreadmillZone: " .. obj:GetFullName())

		-- ✅ LÊ ATTRIBUTES (novo sistema)
		local multiplier = obj:GetAttribute("Multiplier")
		print("[CLIENT]   Multiplier attribute: " .. tostring(multiplier))

		if multiplier then
			-- Adiciona à lista apropriada (com deduplicação)
			addZoneToList(obj, multiplier)
			print("[CLIENT]   → Added dynamically")
		else
			warn("[CLIENT]   → SKIPPED: Dynamic zone missing Multiplier attribute!")
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

-- 💀 SOM QUANDO NPC MATA O PLAYER
local NpcKillPlayerEvent = Remotes:WaitForChild("NpcKillPlayer")
NpcKillPlayerEvent.OnClientEvent:Connect(function()
	print("[CLIENT] 💀 NPC KILLED PLAYER EVENT RECEIVED!")

	local soundSuccess, soundErr = pcall(function()
		npcKillSound:Play()
	end)

	if soundSuccess then
		print("[CLIENT] ✅ Vine Boom played!")
	else
		warn("[CLIENT] ❌ Failed to play Vine Boom: " .. tostring(soundErr))
	end
end)

-- 🎨 EFEITO VISUAL QUANDO LASER DEIXA PLAYER LENTO
local NpcLaserSlowEffect = Remotes:WaitForChild("NpcLaserSlowEffect")
NpcLaserSlowEffect.OnClientEvent:Connect(function(duration)
	print("[CLIENT] Laser slow effect triggered! Duration: " .. tostring(duration) .. "s")

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- 📢 Mensagem na tela "YOU ARE SLOWED!"
	local playerGui = player:WaitForChild("PlayerGui")
	local slowGui = Instance.new("ScreenGui")
	slowGui.Name = "SlowEffectGui"
	slowGui.ResetOnSpawn = false
	slowGui.Parent = playerGui

	local slowLabel = Instance.new("TextLabel")
	slowLabel.Name = "SlowLabel"
	slowLabel.Size = UDim2.new(0, 400, 0, 80)
	slowLabel.Position = UDim2.new(0.5, -200, 0.3, 0)
	slowLabel.BackgroundTransparency = 0.5
	slowLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	slowLabel.BorderSizePixel = 0
	slowLabel.Text = "⚠️ YOU ARE SLOWED! ⚠️"
	slowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	slowLabel.TextSize = 32
	slowLabel.Font = Enum.Font.GothamBold
	slowLabel.Parent = slowGui

	-- 🔧 Apply stroke: use UIStroke if exists, otherwise fallback to TextStroke properties
	local existingStroke = slowLabel:FindFirstChildOfClass("UIStroke")
	if existingStroke then
		-- Use existing UIStroke
		existingStroke.Color = Color3.fromRGB(0, 0, 0)
		existingStroke.Transparency = 0.5
	else
		-- Fallback to TextStroke properties if no UIStroke
		slowLabel.TextStrokeTransparency = 0.5
		slowLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	end

	-- Adiciona canto arredondado
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = slowLabel

	print("[CLIENT] 📢 Slow message displayed!")

	-- 🔴 Cria partículas vermelhas ao redor do player
	local particles = Instance.new("ParticleEmitter")
	particles.Name = "LaserSlowParticles"
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	particles.Size = NumberSequence.new(1, 0)
	particles.Transparency = NumberSequence.new(0.3, 1)
	particles.Lifetime = NumberRange.new(0.5, 0.8)
	particles.Rate = 50
	particles.Speed = NumberRange.new(2, 4)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = hrp

	-- 🔴 Efeito de brilho vermelho
	local redLight = Instance.new("PointLight")
	redLight.Name = "LaserSlowLight"
	redLight.Color = Color3.fromRGB(255, 0, 0)
	redLight.Brightness = 3
	redLight.Range = 10
	redLight.Parent = hrp

	-- 🔴 Muda cor das partes do character temporariamente
	local originalColors = {}
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			originalColors[part] = {
				Color = part.Color,
				Material = part.Material
			}
			part.Color = Color3.fromRGB(255, 100, 100)  -- Vermelho claro
			part.Material = Enum.Material.Neon
		end
	end

	-- 🎵 Som de slow (opcional - descomente se quiser)
	-- local slowSound = Instance.new("Sound")
	-- slowSound.SoundId = "rbxassetid://9125402735"  -- Som de slow
	-- slowSound.Volume = 0.5
	-- slowSound.Parent = hrp
	-- slowSound:Play()

	-- ⏱️ Remove efeitos após a duração
	task.delay(duration or 0.5, function()
		-- Remove mensagem da tela
		if slowGui and slowGui.Parent then
			slowGui:Destroy()
			print("[CLIENT] 📢 Slow message removed!")
		end

		if particles and particles.Parent then
			particles.Enabled = false
			task.delay(1, function() particles:Destroy() end)
		end

		if redLight and redLight.Parent then
			redLight:Destroy()
		end

		-- Restaura cores originais
		for part, data in pairs(originalColors) do
			if part and part.Parent then
				part.Color = data.Color
				part.Material = data.Material
			end
		end

		print("[CLIENT] Laser slow effect ended!")
	end)
end)

print("Client ready - sounds fixed for respawn")