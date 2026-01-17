-- SpeedGameServer.server.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")

-- ==================== CONFIGURAÇÕES ====================
local ADMIN_USER_IDS = {
	[10286998085] = true,
	[10291926911] = true,
}

local WELCOME_BADGE_ID = 0
local REBIRTH_BADGE_ID = 0

local GROUP_ID = 0
local GIFT_REWARD = 15000

-- Dev Product IDs (speed packs)
local SPEED_100K_PRODUCT_ID = 3511569875 -- Nível 1: +100,000 speed (29 Robux)
local SPEED_1M_PRODUCT_ID = 3511570288   -- Nível 2: +1,000,000 speed (99 Robux)
local SPEED_10M_PRODUCT_ID = 3511570659  -- Nível 3: +10,000,000 speed (500 Robux)

-- ✅ SPEED BOOST EXP (x2 -> x4 -> x8 -> x16 ...)
local SPEEDBOOST_PRODUCT_BY_LEVEL = {
	[1] = 3510578826, -- x2 SPEED (3 Robux)
	[2] = 3510802965, -- x4 SPEED (29 Robux)
	[3] = 3510803353, -- x8 SPEED (81 Robux)
	[4] = 3510803870, -- x16 SPEED (599 Robux)
	-- [5] = 0, -- x32 SPEED
	-- [6] = 0, -- x64 SPEED
}

-- ✅ WIN BOOST EXP (x2 -> x4 -> x8 -> x16 ...)
local WINBOOST_PRODUCT_BY_LEVEL = {
	[1] = 3510580275, -- x2 WIN (6 Robux)
	[2] = 3511571771, -- x4 WIN (12 Robux)
	[3] = 3511572068, -- x8 WIN (59 Robux)
	[4] = 3511572744, -- x16 WIN (500 Robux)
	-- [5] = 0, -- x32 WIN
	-- [6] = 0, -- x64 WIN
}

-- Treadmills
local TREADMILL_X3_PRODUCT_ID  = 3510639799  -- 3x Speed Treadmill (dourada) - 59 Robux
local TREADMILL_X9_PRODUCT_ID  = 3510662188  -- 9x Speed Treadmill (azul) - 149 Robux
local TREADMILL_X25_PRODUCT_ID = 3510662405  -- 25x Speed Treadmill (roxa) - 399 Robux

local TREADMILL_PRODUCT_TO_MULT = {
	[TREADMILL_X3_PRODUCT_ID]  = 3,
	[TREADMILL_X9_PRODUCT_ID]  = 9,
	[TREADMILL_X25_PRODUCT_ID] = 25,
}

-- ✅ VALID MULTIPLIERS (para validação server-side)
-- Protege contra exploits que enviam multipliers inválidos
local VALID_MULTIPLIERS = {
	[1] = true,   -- FREE treadmill
	[3] = true,   -- GOLD treadmill
	[9] = true,   -- BLUE treadmill
	[25] = true,  -- PURPLE treadmill
}

-- ==================== MODULES ====================
-- ✅ PATCH: Progression system now uses centralized ProgressionMath
local ProgressionMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionMath"))

-- ==================== DATASTORE2 ====================
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

DataStore2.Combine(
	"SpeedGameData",
	"TotalXP", "Level", "XP", "Wins", "Rebirths",
	"Multiplier", "StepBonus", "GiftClaimed",
	"TreadmillX3Owned", "TreadmillX9Owned", "TreadmillX25Owned",
	"SpeedBoostLevel", "WinBoostLevel"
)

-- ==================== REMOTES ====================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function getOrCreateRemote(name, className)
	local remote = Remotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = Remotes
		print("✅ Created " .. className .. ": " .. name)
	end
	return remote
end

-- ✅ ALL REMOTES NOW USE getOrCreateRemote (no infinite yield)
local AdminAdjustStat = getOrCreateRemote("AdminAdjustStat", "RemoteEvent")
local UpdateSpeedEvent = getOrCreateRemote("UpdateSpeed", "RemoteEvent")
local UpdateUIEvent = getOrCreateRemote("UpdateUI", "RemoteEvent")
local RebirthEvent = getOrCreateRemote("Rebirth", "RemoteEvent")
local EquipStepAwardEvent = getOrCreateRemote("EquipStepAward", "RemoteEvent")
local VerifyGroupEvent = getOrCreateRemote("VerifyGroup", "RemoteFunction")
local ClaimGiftEvent = getOrCreateRemote("ClaimGift", "RemoteEvent")
local ShowWinEvent = getOrCreateRemote("ShowWin", "RemoteEvent")
local TreadmillOwnershipUpdated = getOrCreateRemote("TreadmillOwnershipUpdated", "RemoteEvent")
local PromptSpeedBoostEvent = getOrCreateRemote("PromptSpeedBoost", "RemoteEvent")
local PromptWinsBoostEvent = getOrCreateRemote("PromptWinsBoost", "RemoteEvent")
local Prompt100KSpeedEvent = getOrCreateRemote("Prompt100KSpeed", "RemoteEvent")
local Prompt1MSpeedEvent = getOrCreateRemote("Prompt1MSpeed", "RemoteEvent")
local Prompt10MSpeedEvent = getOrCreateRemote("Prompt10MSpeed", "RemoteEvent")
local RebirthSuccessEvent = getOrCreateRemote("RebirthSuccess", "RemoteEvent")
local AddWinEvent = getOrCreateRemote("AddWin", "RemoteEvent")

-- ==================== VARIÁVEIS GLOBAIS ====================
local PlayerData = {}
local PlayerDataDirty = {} -- 🔧 DEBOUNCE: Track which players need DataStore save
local TreadmillCooldowns = {} -- Per-player cooldown tracking (UserId -> timestamp)
local VisualEffectCooldowns = {} -- Per-player cooldown for +XP visual effect (UserId -> timestamp)

local spawnLocation = workspace:FindFirstChild("SpawnLocation", true)
local spawnPosition = spawnLocation and spawnLocation.Position or Vector3.new(0, 10, 0)

local rebirthTiers = {
	{level = 25, multiplier = 1.5},
	{level = 50, multiplier = 2.0},
	{level = 100, multiplier = 2.5},
	{level = 150, multiplier = 3.0},
	{level = 200, multiplier = 3.5},
	{level = 300, multiplier = 4.0},
	{level = 500, multiplier = 5.0},
	{level = 750, multiplier = 6.0},
	{level = 1000, multiplier = 7.5},
	{level = 1500, multiplier = 10.0},
}

-- ==================== FUNÇÕES UTILITÁRIAS ====================
local function debugPrint(category, message)
	print("[" .. category .. "] " .. message)
end

-- ✅ PATCH: Now uses ProgressionMath (centralized formula)
local function getXPForLevel(level)
	return ProgressionMath.XPRequired(level)
end

-- Level 0 = 1x, 1=2x, 2=4x, 3=8x...
local function getSpeedBoostMultiplier(boostLevel)
	if (boostLevel or 0) <= 0 then return 1 end
	return math.pow(2, boostLevel)
end

local function getNextSpeedBoostProductId(currentLevel)
	local nextLevel = (currentLevel or 0) + 1
	return SPEEDBOOST_PRODUCT_BY_LEVEL[nextLevel], nextLevel
end

-- Level 0 = 1x, 1=2x, 2=4x, 3=8x...
local function getWinBoostMultiplier(boostLevel)
	if (boostLevel or 0) <= 0 then return 1 end
	return math.pow(2, boostLevel)
end

local function getNextWinBoostProductId(currentLevel)
	local nextLevel = (currentLevel or 0) + 1
	return WINBOOST_PRODUCT_BY_LEVEL[nextLevel], nextLevel
end

-- ==================== DATA MANAGEMENT ====================
local DEFAULT_DATA = {
	TotalXP = 0,
	Level = 1,
	XP = 0,
	Wins = 0,
	Rebirths = 0,
	Multiplier = 1,
	StepBonus = 1,
	GiftClaimed = false,
	TreadmillX3Owned = false,
	TreadmillX9Owned = false,
	TreadmillX25Owned = false,
	SpeedBoostLevel = 0,
	WinBoostLevel = 0,
}

local function getStores(player)
	return {
		TotalXP = DataStore2("TotalXP", player),
		Level = DataStore2("Level", player),
		XP = DataStore2("XP", player),
		Wins = DataStore2("Wins", player),
		Rebirths = DataStore2("Rebirths", player),
		Multiplier = DataStore2("Multiplier", player),
		StepBonus = DataStore2("StepBonus", player),
		GiftClaimed = DataStore2("GiftClaimed", player),
		TreadmillX3Owned = DataStore2("TreadmillX3Owned", player),
		TreadmillX9Owned = DataStore2("TreadmillX9Owned", player),
		TreadmillX25Owned = DataStore2("TreadmillX25Owned", player),
		SpeedBoostLevel = DataStore2("SpeedBoostLevel", player),
		WinBoostLevel = DataStore2("WinBoostLevel", player),
	}
end

local function getPlayerData(player)
	local stores = getStores(player)

	local data = {}
	for key, store in pairs(stores) do
		data[key] = store:Get(DEFAULT_DATA[key])
	end

	data.XPRequired = getXPForLevel(data.Level)
	data.SpeedBoostActive = (data.SpeedBoostLevel or 0) > 0
	data.CurrentSpeedBoostMultiplier = getSpeedBoostMultiplier(data.SpeedBoostLevel or 0)
	data.WinBoostActive = (data.WinBoostLevel or 0) > 0
	data.CurrentWinBoostMultiplier = getWinBoostMultiplier(data.WinBoostLevel or 0)

	return data
end

local function savePlayerData(player, data)
	local stores = getStores(player)

	for key, store in pairs(stores) do
		if data[key] ~= nil then
			store:Set(data[key])
		end
	end
end

-- ✅ Força persistência (mais confiável pra debug)
local function saveAll(player, data, reason)
	reason = reason or "unknown"
	local ok, err = pcall(function()
		savePlayerData(player, data)

		local stores = getStores(player)
		for _, store in pairs(stores) do
			store:Save()
		end
	end)

	if ok then
		debugPrint("DATA", player.Name .. " SaveAll OK (" .. reason .. ")")
		-- Log treadmill ownership após save
		if string.match(reason, "treadmill") then
			debugPrint("DATA", "  Treadmill x3: " .. tostring(data.TreadmillX3Owned))
			debugPrint("DATA", "  Treadmill x9: " .. tostring(data.TreadmillX9Owned))
			debugPrint("DATA", "  Treadmill x25: " .. tostring(data.TreadmillX25Owned))
		end
	else
		warn("[DATA] SaveAll FAILED (" .. reason .. "): " .. tostring(err))
	end
end

-- ==================== UI UPDATES ====================
local function updateLeaderstats(player, data)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local speedStat = leaderstats:FindFirstChild("Speed")
	if speedStat then speedStat.Value = data.TotalXP end

	local winsStat = leaderstats:FindFirstChild("Wins")
	if winsStat then winsStat.Value = data.Wins end
end

local function checkLevelUp(data)
	while data.XP >= data.XPRequired do
		data.XP -= data.XPRequired
		data.Level += 1
		data.XPRequired = getXPForLevel(data.Level)
	end
end

local function updateWalkSpeed(player, data)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid.WalkSpeed = 16 + math.min(data.Level, 500)
end

-- ==================== PLAYER MANAGEMENT ====================
local function onPlayerAdded(player)
	debugPrint("PLAYER JOIN", player.Name .. " joining...")

	local data = getPlayerData(player)
	PlayerData[player.UserId] = data

	-- ✅ ALWAYS set treadmill ownership attributes (even if false, so client can check)
	player:SetAttribute("TreadmillX3Owned", data.TreadmillX3Owned == true)
	player:SetAttribute("TreadmillX9Owned", data.TreadmillX9Owned == true)
	player:SetAttribute("TreadmillX25Owned", data.TreadmillX25Owned == true)

	debugPrint("TREADMILL", player.Name .. " ownership attributes set:")
	debugPrint("TREADMILL", "  x3: " .. tostring(data.TreadmillX3Owned == true))
	debugPrint("TREADMILL", "  x9: " .. tostring(data.TreadmillX9Owned == true))
	debugPrint("TREADMILL", "  x25: " .. tostring(data.TreadmillX25Owned == true))

	-- ✅ ENVIA SNAPSHOT COMPLETO DE OWNERSHIP AO CLIENT (evita race condition)
	local ownershipSnapshot = {
		[3] = data.TreadmillX3Owned or false,
		[9] = data.TreadmillX9Owned or false,
		[25] = data.TreadmillX25Owned or false,
	}
	debugPrint("TREADMILL", "Sending ownership snapshot to " .. player.Name .. ":")
	debugPrint("TREADMILL", "  x3: " .. tostring(ownershipSnapshot[3]))
	debugPrint("TREADMILL", "  x9: " .. tostring(ownershipSnapshot[9]))
	debugPrint("TREADMILL", "  x25: " .. tostring(ownershipSnapshot[25]))

	-- Envia após um pequeno delay para garantir que o client já conectou o listener
	task.delay(0.5, function()
		TreadmillOwnershipUpdated:FireClient(player, ownershipSnapshot)
		debugPrint("TREADMILL", "Ownership snapshot sent to " .. player.Name)
	end)

	player:SetAttribute("OnTreadmill", false)
	player:SetAttribute("TreadmillMultiplier", 1)

	debugPrint("DATA", player.Name .. " loaded:")
	debugPrint("DATA", "  Level: " .. data.Level)
	debugPrint("DATA", "  TotalXP: " .. data.TotalXP)
	debugPrint("DATA", "  Wins: " .. data.Wins)
	debugPrint("DATA", "  SpeedBoostLevel: " .. (data.SpeedBoostLevel or 0) .. " (" .. getSpeedBoostMultiplier(data.SpeedBoostLevel or 0) .. "x)")
	debugPrint("DATA", "  WinBoostLevel: " .. (data.WinBoostLevel or 0) .. " (" .. getWinBoostMultiplier(data.WinBoostLevel or 0) .. "x)")
	debugPrint("DATA", "  Treadmill x3: " .. tostring(data.TreadmillX3Owned))
	debugPrint("DATA", "  Treadmill x9: " .. tostring(data.TreadmillX9Owned))
	debugPrint("DATA", "  Treadmill x25: " .. tostring(data.TreadmillX25Owned))

	-- Award welcome badge (não tenta se id=0)
	if WELCOME_BADGE_ID and WELCOME_BADGE_ID ~= 0 then
		task.spawn(function()
			pcall(function()
				BadgeService:AwardBadge(player.UserId, WELCOME_BADGE_ID)
			end)
		end)
	end

	-- Create leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local speedStat = Instance.new("IntValue")
	speedStat.Name = "Speed"
	speedStat.Value = data.TotalXP
	speedStat.Parent = leaderstats

	local winsStat = Instance.new("IntValue")
	winsStat.Name = "Wins"
	winsStat.Value = data.Wins
	winsStat.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local pData = PlayerData[player.UserId]
		if pData then
			humanoid.WalkSpeed = 16 + math.min(pData.Level, 500)
			task.wait(0.5)
			UpdateUIEvent:FireClient(player, pData)
		end
	end)

	-- 🔥 opcional: salva logo ao entrar (ajuda a “fixar” user key em testes)
	saveAll(player, data, "player_join")

	debugPrint("PLAYER JOIN", player.Name .. " setup complete!")
end

local function onPlayerRemoving(player)
	local data = PlayerData[player.UserId]
	if data then
		saveAll(player, data, "player_removing")
	end

	PlayerData[player.UserId] = nil
	TreadmillCooldowns[player.UserId] = nil -- Cleanup cooldown data
	VisualEffectCooldowns[player.UserId] = nil -- Cleanup visual cooldown data

	player:SetAttribute("OnTreadmill", false)
	player:SetAttribute("TreadmillMultiplier", nil)
	player:SetAttribute("TreadmillX3Owned", nil)
	player:SetAttribute("TreadmillX9Owned", nil)
	player:SetAttribute("TreadmillX25Owned", nil)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- ==================== AUTO-SAVE (DEBOUNCED) ====================
-- 🔧 REFACTOR: Only save players marked as dirty (reduces DataStore queue spam)
task.spawn(function()
	while true do
		task.wait(60)  -- Every 60 seconds
		local savedCount = 0
		for userId, isDirty in pairs(PlayerDataDirty) do
			if isDirty then
				local player = Players:GetPlayerByUserId(userId)
				if player and PlayerData[userId] then
					saveAll(player, PlayerData[userId], "autosave")
					PlayerDataDirty[userId] = false  -- Clear dirty flag
					savedCount = savedCount + 1
				end
			end
		end
		if savedCount > 0 then
			debugPrint("AUTOSAVE", savedCount .. " player(s) saved (others clean)")
		end
	end
end)

game:BindToClose(function()
	-- dá um tempo pro DataStore flushar
	local start = os.clock()

	for userId, data in pairs(PlayerData) do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			saveAll(player, data, "bind_to_close")
		end
	end

	-- espera um pouco (até 5s) pra garantir as requisições
	while os.clock() - start < 5 do
		task.wait(0.1)
	end

	debugPrint("SHUTDOWN", "All data saved on shutdown")
end)

-- ==================== DEV PRODUCTS ====================

-- Botão de boost: compra o PRÓXIMO nível
PromptSpeedBoostEvent.OnServerEvent:Connect(function(player)
	local data = PlayerData[player.UserId]
	if not data then
		debugPrint("PURCHASE", player.Name .. " clicked SpeedBoost but no data found!")
		return
	end

	local currentLevel = data.SpeedBoostLevel or 0
	local currentMult = getSpeedBoostMultiplier(currentLevel)
	local productId, nextLevel = getNextSpeedBoostProductId(currentLevel)

	if not productId or productId == 0 then
		debugPrint("PURCHASE", "No more SpeedBoost levels configured. CurrentLevel=" .. currentLevel .. " NextLevel=" .. tostring(nextLevel))
		return
	end

	local nextMult = getSpeedBoostMultiplier(nextLevel)
	debugPrint("PURCHASE", player.Name .. " clicked SpeedBoost!")
	debugPrint("PURCHASE", "  Current: Level " .. currentLevel .. " = " .. currentMult .. "x")
	debugPrint("PURCHASE", "  Next: Level " .. nextLevel .. " = " .. nextMult .. "x")
	debugPrint("PURCHASE", "  ProductId: " .. productId)

	MarketplaceService:PromptProductPurchase(player, productId)
end)

-- Botão Win Boost: compra o PRÓXIMO nível
PromptWinsBoostEvent.OnServerEvent:Connect(function(player)
	local data = PlayerData[player.UserId]
	if not data then
		debugPrint("PURCHASE", player.Name .. " clicked WinBoost but no data found!")
		return
	end

	local currentLevel = data.WinBoostLevel or 0
	local productId, nextLevel = getNextWinBoostProductId(currentLevel)

	if not productId or productId == 0 then
		debugPrint("PURCHASE", "No more WinBoost levels configured. CurrentLevel=" .. currentLevel)
		return
	end

	debugPrint("PURCHASE", player.Name .. " clicked WinBoost! ProductId: " .. productId)
	MarketplaceService:PromptProductPurchase(player, productId)
end)

-- Botão +100K Speed
Prompt100KSpeedEvent.OnServerEvent:Connect(function(player)
	debugPrint("PURCHASE", player.Name .. " clicked +100K Speed button")
	MarketplaceService:PromptProductPurchase(player, SPEED_100K_PRODUCT_ID)
end)

-- Botão +1M Speed
Prompt1MSpeedEvent.OnServerEvent:Connect(function(player)
	debugPrint("PURCHASE", player.Name .. " clicked +1M Speed button")
	MarketplaceService:PromptProductPurchase(player, SPEED_1M_PRODUCT_ID)
end)

-- Botão +10M Speed
Prompt10MSpeedEvent.OnServerEvent:Connect(function(player)
	debugPrint("PURCHASE", player.Name .. " clicked +10M Speed button")
	MarketplaceService:PromptProductPurchase(player, SPEED_10M_PRODUCT_ID)
end)

-- ⚠️ IMPORTANTE: só pode existir UM ProcessReceipt no jogo todo
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = PlayerData[player.UserId]
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- ✅ SPEED BOOST EXP (só aceita o ProductId do próximo nível)
	do
		local currentLevel = data.SpeedBoostLevel or 0
		local expectedProductId, nextLevel = getNextSpeedBoostProductId(currentLevel)

		debugPrint("PURCHASE", "Checking Speed Boost: ProductId=" .. receiptInfo.ProductId .. " Current=" .. currentLevel .. " Expected=" .. tostring(expectedProductId))

		if expectedProductId and expectedProductId ~= 0 and receiptInfo.ProductId == expectedProductId then
			data.SpeedBoostLevel = nextLevel
			local newMultiplier = getSpeedBoostMultiplier(data.SpeedBoostLevel)

			debugPrint("PURCHASE", player.Name .. " purchased Speed Boost!")
			debugPrint("PURCHASE", "  New Level: " .. data.SpeedBoostLevel)
			debugPrint("PURCHASE", "  New Multiplier: " .. newMultiplier .. "x")

			data.SpeedBoostActive = true
			data.CurrentSpeedBoostMultiplier = newMultiplier

			UpdateUIEvent:FireClient(player, data)
			saveAll(player, data, "purchase_speedboost")

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	-- ✅ WIN BOOST EXP (só aceita o ProductId do próximo nível)
	do
		local currentLevel = data.WinBoostLevel or 0
		local expectedProductId, nextLevel = getNextWinBoostProductId(currentLevel)

		debugPrint("PURCHASE", "Checking Win Boost: ProductId=" .. receiptInfo.ProductId .. " Current=" .. currentLevel .. " Expected=" .. tostring(expectedProductId))

		if expectedProductId and expectedProductId ~= 0 and receiptInfo.ProductId == expectedProductId then
			data.WinBoostLevel = nextLevel
			local newMultiplier = getWinBoostMultiplier(data.WinBoostLevel)

			debugPrint("PURCHASE", player.Name .. " purchased Win Boost!")
			debugPrint("PURCHASE", "  New Level: " .. data.WinBoostLevel)
			debugPrint("PURCHASE", "  New Multiplier: " .. newMultiplier .. "x")

			data.WinBoostActive = true
			data.CurrentWinBoostMultiplier = newMultiplier

			UpdateUIEvent:FireClient(player, data)
			saveAll(player, data, "purchase_winboost")

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	-- Speed XP Products (Pacotes de Velocidade)
	if receiptInfo.ProductId == SPEED_100K_PRODUCT_ID then
		data.TotalXP += 100000
		data.XP += 100000
		checkLevelUp(data)
		updateWalkSpeed(player, data)
		UpdateUIEvent:FireClient(player, data)
		updateLeaderstats(player, data)
		saveAll(player, data, "purchase_100k")
		debugPrint("PURCHASE", player.Name .. " purchased +100,000 Speed Pack (Nível 1)!")
		return Enum.ProductPurchaseDecision.PurchaseGranted

	elseif receiptInfo.ProductId == SPEED_1M_PRODUCT_ID then
		data.TotalXP += 1000000
		data.XP += 1000000
		checkLevelUp(data)
		updateWalkSpeed(player, data)
		UpdateUIEvent:FireClient(player, data)
		updateLeaderstats(player, data)
		saveAll(player, data, "purchase_1m")
		debugPrint("PURCHASE", player.Name .. " purchased +1,000,000 Speed Pack (Nível 2)!")
		return Enum.ProductPurchaseDecision.PurchaseGranted

	elseif receiptInfo.ProductId == SPEED_10M_PRODUCT_ID then
		data.TotalXP += 10000000
		data.XP += 10000000
		checkLevelUp(data)
		updateWalkSpeed(player, data)
		UpdateUIEvent:FireClient(player, data)
		updateLeaderstats(player, data)
		saveAll(player, data, "purchase_10m")
		debugPrint("PURCHASE", player.Name .. " purchased +10,000,000 Speed Pack (Nível 3)!")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Treadmill Products
	local treadmillMult = TREADMILL_PRODUCT_TO_MULT[receiptInfo.ProductId]
	if treadmillMult then
		local key = "TreadmillX" .. treadmillMult .. "Owned"

		debugPrint("PURCHASE", player.Name .. " attempting to purchase Treadmill x" .. treadmillMult)
		debugPrint("PURCHASE", "  Current ownership: " .. tostring(data[key]))

		-- Verifica se já comprou (para evitar compras duplicadas)
		if data[key] == true then
			debugPrint("PURCHASE", player.Name .. " already owns Treadmill x" .. treadmillMult .. " - granting anyway but not charging again")
			-- Notifica o client mesmo se já possuir (caso tenha desconectado durante compra anterior)
			TreadmillOwnershipUpdated:FireClient(player, treadmillMult, true)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		-- Marca como comprado
		data[key] = true
		player:SetAttribute(key, true)
		debugPrint("PURCHASE", player.Name .. " successfully purchased Treadmill x" .. treadmillMult .. "!")
		debugPrint("PURCHASE", "  Ownership is now: " .. tostring(data[key]))

		-- ✅ NOTIFICA O CLIENT IMEDIATAMENTE
		TreadmillOwnershipUpdated:FireClient(player, treadmillMult, true)
		debugPrint("PURCHASE", "  Notified client of ownership for x" .. treadmillMult)

		saveAll(player, data, "purchase_treadmill_x" .. treadmillMult)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- ==================== GAMEPLAY ====================

-- 🔄 PATCH 4: Server-authoritative treadmill detection
-- Aguarda TreadmillService estar disponível
local TreadmillService = nil
local maxWaitTime = 10
local waitedTime = 0
while not TreadmillService and waitedTime < maxWaitTime do
	TreadmillService = _G.TreadmillService
	if not TreadmillService then
		task.wait(0.5)
		waitedTime = waitedTime + 0.5
	end
end

if TreadmillService then
	debugPrint("INIT", "✅ TreadmillService connected")
else
	warn("[SpeedGameServer] ⚠️ TreadmillService not found! Treadmill detection will not work.")
end

UpdateSpeedEvent.OnServerEvent:Connect(function(player, steps, clientMultiplier)
	local data = PlayerData[player.UserId]
	if not data then return end

	steps = steps or 1
	clientMultiplier = clientMultiplier or nil  -- nil = novo protocolo, não enviou

	-- 🔄 SERVER-AUTHORITATIVE: Usa TreadmillService como fonte da verdade
	local treadmillMultiplier = 0
	if TreadmillService then
		treadmillMultiplier = TreadmillService.getPlayerMultiplier(player)
	else
		-- Fallback: usa multiplier do client (backward compatible)
		treadmillMultiplier = clientMultiplier or 0
		if clientMultiplier and clientMultiplier > 0 then
			-- Valida multiplier enviado pelo client (security)
			if not VALID_MULTIPLIERS[clientMultiplier] then
				warn("[SECURITY] Player " .. player.Name .. " sent invalid multiplier: " .. clientMultiplier)
				return
			end
		end
	end

	-- 🔍 DEBUG: Detecta se client enviou multiplier diferente do server
	if clientMultiplier and clientMultiplier > 0 and TreadmillService then
		if clientMultiplier ~= treadmillMultiplier then
			warn("[MISMATCH] Client sent multiplier=" .. clientMultiplier .. " but server detected=" .. treadmillMultiplier)
			warn("[MISMATCH]   Player: " .. player.Name .. " - Using server value (authoritative)")
			-- Continua com valor do server (não bloqueia)
		end
	end

	-- ✅ COOLDOWN: 0.4 segundos apenas para WALKING (fora da esteira)
	local WALKING_COOLDOWN = 0.4
	local currentTime = os.clock()
	local lastTrigger = TreadmillCooldowns[player.UserId] or 0

	if treadmillMultiplier == 0 then
		-- Aplica cooldown apenas para walking no chão (previne XP muito rápido)
		if currentTime - lastTrigger < WALKING_COOLDOWN then
			-- Ainda em cooldown, ignora este step
			return
		end
		-- Atualiza o timestamp do último trigger
		TreadmillCooldowns[player.UserId] = currentTime
	end

	debugPrint("XP_GAIN", player.Name .. " - steps=" .. steps .. " treadmillMult=" .. treadmillMultiplier)

	local xpGain, totalMultiplier

	if treadmillMultiplier > 0 then
		-- VERIFICA SE O PLAYER TEM ACESSO À ESTEIRA PAGA
		local hasAccess = false
		if treadmillMultiplier == 3 and data.TreadmillX3Owned then
			hasAccess = true
		elseif treadmillMultiplier == 9 and data.TreadmillX9Owned then
			hasAccess = true
		elseif treadmillMultiplier == 25 and data.TreadmillX25Owned then
			hasAccess = true
		elseif treadmillMultiplier == 1 then
			-- Esteira grátis - sempre tem acesso
			hasAccess = true
		end

		if not hasAccess then
			debugPrint("XP_GAIN", "  BLOCKED: Player doesn't own treadmill x" .. treadmillMultiplier)
			-- Não dá XP se não tiver acesso
			return
		end

		-- NA ESTEIRA: NÃO aplica SpeedBoost
		xpGain = steps * data.StepBonus * data.Multiplier * treadmillMultiplier
		totalMultiplier = data.StepBonus * data.Multiplier * treadmillMultiplier
		data.TreadmillMultiplier = treadmillMultiplier
		-- OnTreadmill attribute já é setado pelo TreadmillService
		debugPrint("XP_GAIN", "  ON TREADMILL: xpGain=" .. xpGain .. " totalMult=" .. totalMultiplier)
	else
		-- FORA DA ESTEIRA: aplica SpeedBoost EXPONENCIAL
		local speedBoostMultiplier = getSpeedBoostMultiplier(data.SpeedBoostLevel or 0)
		xpGain = steps * data.StepBonus * data.Multiplier * speedBoostMultiplier
		totalMultiplier = data.StepBonus * data.Multiplier * speedBoostMultiplier
		data.TreadmillMultiplier = 1
		-- OnTreadmill attribute já é setado pelo TreadmillService
		debugPrint("XP_GAIN", "  WALKING: xpGain=" .. xpGain .. " totalMult=" .. totalMultiplier)
	end

	data.XP += xpGain
	data.TotalXP += xpGain
	PlayerDataDirty[player.UserId] = true  -- 🔧 Mark as dirty for next autosave

	local oldLevel = data.Level
	checkLevelUp(data)

	if data.Level > oldLevel then
		updateWalkSpeed(player, data)
		debugPrint("LEVEL", player.Name .. " leveled up to " .. data.Level)
		saveAll(player, data, "level_up")
		PlayerDataDirty[player.UserId] = false  -- 🔧 Clear dirty flag (just saved)
	end

	data.SpeedBoostActive = (data.SpeedBoostLevel or 0) > 0
	data.TotalMultiplier = totalMultiplier
	data.CurrentSpeedBoostMultiplier = getSpeedBoostMultiplier(data.SpeedBoostLevel or 0)

	-- ✅ COOLDOWN DE VISUAL: Só mostra efeito +XP a cada 1.5 segundos
	local VISUAL_COOLDOWN = 1.5
	local currentTime = os.clock()
	local lastVisual = VisualEffectCooldowns[player.UserId] or 0
	local timeSinceLastVisual = currentTime - lastVisual

	-- ✅ Cria uma cópia temporária do data com ShowVisual
	local dataWithVisual = {}
	for k, v in pairs(data) do
		dataWithVisual[k] = v
	end

	if timeSinceLastVisual >= VISUAL_COOLDOWN then
		-- Passou do cooldown, pode mostrar visual
		dataWithVisual.ShowVisual = true
		VisualEffectCooldowns[player.UserId] = currentTime
		print("[VISUAL_COOLDOWN] " .. player.Name .. " - SHOW (elapsed: " .. string.format("%.2f", timeSinceLastVisual) .. "s)")
	else
		-- Ainda em cooldown, não mostra visual
		dataWithVisual.ShowVisual = false
		print("[VISUAL_COOLDOWN] " .. player.Name .. " - HIDE (elapsed: " .. string.format("%.2f", timeSinceLastVisual) .. "s, need: 1.5s)")
	end

	UpdateUIEvent:FireClient(player, dataWithVisual)
	updateLeaderstats(player, data)
end)

EquipStepAwardEvent.OnServerEvent:Connect(function(player, bonus)
	local data = PlayerData[player.UserId]
	if not data then return end
	data.StepBonus = bonus
	debugPrint("EQUIP", player.Name .. " equipped +" .. bonus .. " step bonus")
	UpdateUIEvent:FireClient(player, data)
	saveAll(player, data, "equip_step_award")
end)

RebirthEvent.OnServerEvent:Connect(function(player)
	local data = PlayerData[player.UserId]
	if not data then return end

	local nextTierIndex = data.Rebirths + 1
	if nextTierIndex > #rebirthTiers then return end

	local nextTier = rebirthTiers[nextTierIndex]
	if data.Level >= nextTier.level then
		data.Rebirths = nextTierIndex
		data.Multiplier = nextTier.multiplier
		data.Level = 1
		data.XP = 0
		data.TotalXP = 0
		data.XPRequired = getXPForLevel(data.Level)
		data.StepBonus = nextTier.multiplier

		updateWalkSpeed(player, data)

		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(spawnPosition + Vector3.new(0, 5, 0))
			end
		end

		local RebirthSuccessEvent = Remotes:FindFirstChild("RebirthSuccess")
		if RebirthSuccessEvent then
			RebirthSuccessEvent:FireClient(player)
		end

		UpdateUIEvent:FireClient(player, data)
		updateLeaderstats(player, data)
		debugPrint("REBIRTH", player.Name .. " rebirthed to tier " .. nextTierIndex .. " (" .. nextTier.multiplier .. "x)")

		saveAll(player, data, "rebirth")

		-- Award rebirth badge (não tenta se id=0)
		if REBIRTH_BADGE_ID and REBIRTH_BADGE_ID ~= 0 then
			task.spawn(function()
				pcall(function()
					BadgeService:AwardBadge(player.UserId, REBIRTH_BADGE_ID)
				end)
			end)
		end
	end
end)

-- ==================== OTHER EVENTS ====================
VerifyGroupEvent.OnServerInvoke = function(player)
	return player:IsInGroup(GROUP_ID)
end

ClaimGiftEvent.OnServerEvent:Connect(function(player)
	local data = PlayerData[player.UserId]
	if not data or data.GiftClaimed then return end

	if player:IsInGroup(GROUP_ID) then
		data.TotalXP += GIFT_REWARD
		data.XP += GIFT_REWARD
		data.GiftClaimed = true

		checkLevelUp(data)
		updateWalkSpeed(player, data)
		UpdateUIEvent:FireClient(player, data)
		updateLeaderstats(player, data)

		saveAll(player, data, "claim_gift")

		debugPrint("GIFT", player.Name .. " claimed free gift!")
	end
end)

-- ==================== ADMIN PANEL ====================
AdminAdjustStat.OnServerEvent:Connect(function(player, payload)
	if not player or not payload or type(payload) ~= "table" then return end
	if not ADMIN_USER_IDS[player.UserId] then return end

	local data = PlayerData[player.UserId]
	if not data then return end

	local action = payload.action

	if action == "set_walk_speed" then
		local val = math.clamp(tonumber(payload.value) or 16, 16, 200)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = val
			end
		end

	elseif action == "set_step_bonus" then
		data.StepBonus = math.clamp(tonumber(payload.value) or 1, 1, 100)

	elseif action == "add_xp" then
		local amount = math.clamp(tonumber(payload.amount) or 0, 0, 100000000)
		data.XP += amount
		data.TotalXP += amount
		checkLevelUp(data)
		updateWalkSpeed(player, data)

	elseif action == "set_level" then
		data.Level = math.clamp(tonumber(payload.value) or 1, 1, 3000)
		data.XPRequired = getXPForLevel(data.Level)
		updateWalkSpeed(player, data)
	end

	UpdateUIEvent:FireClient(player, data)
	updateLeaderstats(player, data)
	saveAll(player, data, "admin_adjust")
end)

-- ==================== WIN BLOCKS ====================
local winDebounce = {}
local winAmounts = {
	WinBlock = 1,
	WinBlock2 = 3,
	WinBlock3 = 8,
	WinBlock4 = 29,
	WinBlock5 = 50,
	WinBlock6 = 200,
	WinBlock7 = 400,
	WinBlock8 = 1250
}

local winBlocks = {}
for _, obj in pairs(workspace:GetChildren()) do
	if string.match(obj.Name, "WinBlock") and obj:IsA("BasePart") then
		table.insert(winBlocks, obj)
	end
end

debugPrint("INIT", "Found " .. #winBlocks .. " WinBlocks")

for _, winBlock in ipairs(winBlocks) do
	winBlock.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player or winDebounce[player.UserId] then return end

		winDebounce[player.UserId] = true

		local humanoid = character:FindFirstChild("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")

		if humanoid and hrp and humanoid.Health > 0 then
			local d = PlayerData[player.UserId]
			if d then
				local winAmount = winAmounts[winBlock.Name] or 1

				-- ✅ Aplica Win Boost Multiplier (x2, x4, x8, x16...)
				local winBoostMultiplier = getWinBoostMultiplier(d.WinBoostLevel or 0)
				winAmount *= winBoostMultiplier

				d.Wins += winAmount
				UpdateUIEvent:FireClient(player, d)
				updateLeaderstats(player, d)
				saveAll(player, d, "win_block")

				debugPrint("WIN", player.Name .. " won +" .. winAmount .. "! (Base: " .. (winAmounts[winBlock.Name] or 1) .. " × WinBoost: " .. winBoostMultiplier .. "x)")

				-- ✅ Mostra notificação com o valor correto (DEPOIS de aplicar boost)
				ShowWinEvent:FireClient(player, winAmount)
				hrp.CFrame = CFrame.new(spawnPosition + Vector3.new(0, 5, 0))
			end
		end

		task.delay(2, function()
			winDebounce[player.UserId] = nil
		end)
	end)
end

-- ==================== INITIALIZE EXISTING PLAYERS ====================
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(player)
	end)
end

debugPrint("INIT", "✅ Server ready with DataStore2, Dev Products, Badges, and Speed Boost System!")
