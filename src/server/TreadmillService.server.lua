-- TreadmillService.server.lua
-- Serviço centralizado para gerenciar treadmill zones
-- Server-authoritative: calcula multiplier pela posição do player

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- ==================== DEPENDÊNCIAS ====================
local TreadmillRegistry = require(script.Parent.Modules.TreadmillRegistry)

-- Opcional: TelemetryService (se existir)
local TelemetryService = nil
pcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	TelemetryService = require(ReplicatedStorage:FindFirstChild("TelemetryService"))
end)

-- ==================== CONFIGURAÇÃO ====================
local DEBUG = true
local UPDATE_INTERVAL = 0.15  -- Checa posição a cada 0.15s (não todo frame)
local VELOCITY_THRESHOLD = 1  -- Só checa players com velocidade > 1

-- ==================== ESTADO ====================
local playerStates = {}  -- [UserId] = {LastZone, LastCheck, CurrentMultiplier}
local playerAnimations = {}  -- [UserId] = AnimationTrack

-- ==================== LOGGING ====================
local function debugLog(message)
	if DEBUG then
		print("[TreadmillService] " .. message)
	end
end

local function telemetryLog(category, message, context)
	if TelemetryService then
		TelemetryService.debug(category, message, context)
	else
		debugLog(message)
	end
end

-- ==================== INICIALIZAÇÃO ====================
debugLog("==================== TREADMILL SERVICE STARTING ====================")

-- Escaneia zones no boot
local scanResults = TreadmillRegistry.scanAndRegister()

debugLog("Boot Summary:")
debugLog("  Zones scanned: " .. scanResults.scanned)
debugLog("  Valid zones: " .. scanResults.valid)
debugLog("  Invalid zones: " .. scanResults.invalid)

if scanResults.valid == 0 then
	warn("[TreadmillService] ⚠️ NO VALID ZONES FOUND!")
	warn("[TreadmillService] TreadmillSetup may need to run first.")
else
	debugLog("✅ TreadmillService initialized with " .. scanResults.valid .. " zones")
end

-- Lista zones (debug)
if DEBUG then
	TreadmillRegistry.listAll()
end

-- ==================== PLAYER STATE MANAGEMENT ====================
local function initializePlayerState(player)
	playerStates[player.UserId] = {
		LastZone = nil,
		LastCheck = 0,
		CurrentMultiplier = 0,  -- 0 = not on treadmill
		OnTreadmill = false
	}

	-- Attributes para sync com client
	player:SetAttribute("CurrentTreadmillMultiplier", 0)
	player:SetAttribute("OnTreadmill", false)

	debugLog("Initialized state for " .. player.Name)
end

local function cleanupPlayerState(player)
	playerStates[player.UserId] = nil
	playerAnimations[player.UserId] = nil
	debugLog("Cleaned up state for " .. player.Name)
end

-- ==================== ANIMATION CONTROL (SERVER-SIDE) ====================
local function playRunAnimationOnServer(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Check if already playing
	if playerAnimations[player.UserId] then
		return  -- Already running
	end

	-- Try to use existing run animation from Animate script
	local animate = character:FindFirstChild("Animate")
	local runAnim = nil

	if animate then
		local run = animate:FindFirstChild("run")
		if run then
			runAnim = run:FindFirstChildOfClass("Animation")
		end
	end

	-- Fallback to default run animation
	if not runAnim then
		runAnim = Instance.new("Animation")
		runAnim.AnimationId = "rbxassetid://180426354"  -- Default run
	end

	-- Load and play animation ON SERVER (this replicates to all clients!)
	local animTrack = humanoid:LoadAnimation(runAnim)
	animTrack.Priority = Enum.AnimationPriority.Movement
	animTrack.Looped = true
	animTrack:Play()

	playerAnimations[player.UserId] = animTrack
	debugLog("▶️ Started run animation for " .. player.Name .. " (SERVER-SIDE - visible to all)")
end

local function stopRunAnimationOnServer(player)
	local animTrack = playerAnimations[player.UserId]
	if not animTrack then return end

	animTrack:Stop()
	playerAnimations[player.UserId] = nil
	debugLog("⏹️ Stopped run animation for " .. player.Name)
end

Players.PlayerAdded:Connect(initializePlayerState)
Players.PlayerRemoving:Connect(cleanupPlayerState)

-- Inicializa players já no jogo
for _, player in ipairs(Players:GetPlayers()) do
	initializePlayerState(player)
end

-- ==================== ZONE DETECTION LOOP ====================
local timeSinceLastUpdate = 0

RunService.Heartbeat:Connect(function(deltaTime)
	timeSinceLastUpdate = timeSinceLastUpdate + deltaTime

	-- Update a cada UPDATE_INTERVAL segundos (não todo frame)
	if timeSinceLastUpdate < UPDATE_INTERVAL then
		return
	end

	local currentTime = os.clock()
	timeSinceLastUpdate = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then continue end

		local humanoid = character:FindFirstChild("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp or humanoid.Health <= 0 then continue end

		local state = playerStates[player.UserId]
		if not state then continue end

		-- Otimização: só checa se player está se movendo
		local velocity = hrp.AssemblyLinearVelocity
		if velocity.Magnitude < VELOCITY_THRESHOLD then
			-- Player parado - mantém última zone
			continue
		end

		-- Detecta zone na posição atual
		local position = hrp.Position
		local zoneData, zoneInstance = TreadmillRegistry.getZoneAtPosition(position)

		local oldMultiplier = state.CurrentMultiplier
		local newMultiplier = 0
		local onTreadmill = false

		if zoneData then
			newMultiplier = zoneData.Multiplier
			onTreadmill = true

			-- Log mudança de zone (evita spam)
			if state.LastZone ~= zoneInstance then
				state.LastZone = zoneInstance

				telemetryLog("TREADMILL", "Player entered zone", {
					Player = player.Name,
					Zone = zoneInstance:GetFullName(),
					Multiplier = newMultiplier,
					IsFree = zoneData.IsFree
				})
			end
		else
			-- Não está em nenhuma zone
			if state.OnTreadmill then
				-- Saiu de uma zone
				telemetryLog("TREADMILL", "Player left zone", {
					Player = player.Name
				})
			end

			state.LastZone = nil
			newMultiplier = 0
			onTreadmill = false
		end

		-- Atualiza estado se mudou
		if oldMultiplier ~= newMultiplier or state.OnTreadmill ~= onTreadmill then
			local wasOnTreadmill = state.OnTreadmill  -- Save old state

			state.CurrentMultiplier = newMultiplier
			state.OnTreadmill = onTreadmill

			-- Sync com client via Attributes
			player:SetAttribute("CurrentTreadmillMultiplier", newMultiplier)
			player:SetAttribute("OnTreadmill", onTreadmill)

			-- 🏃 Control run animation on server (visible to all players)
			if onTreadmill and not wasOnTreadmill then
				-- Just entered treadmill
				playRunAnimationOnServer(player)
			elseif not onTreadmill and wasOnTreadmill then
				-- Just left treadmill
				stopRunAnimationOnServer(player)
			end
		end

		state.LastCheck = currentTime
	end
end)

-- ==================== QUERY API ====================
local TreadmillService = {}

-- Retorna multiplier atual do player (usado por SpeedGameServer)
function TreadmillService.getPlayerMultiplier(player)
	local state = playerStates[player.UserId]
	if not state then
		return 0  -- Default: not on treadmill
	end

	return state.CurrentMultiplier
end

-- Retorna se player está em treadmill
function TreadmillService.isPlayerOnTreadmill(player)
	local state = playerStates[player.UserId]
	if not state then
		return false
	end

	return state.OnTreadmill
end

-- Retorna zone data se player está em uma
function TreadmillService.getPlayerZone(player)
	local character = player.Character
	if not character then return nil end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	return TreadmillRegistry.getZoneAtPosition(hrp.Position)
end

-- ==================== DEBUG ====================
function TreadmillService.setDebug(enabled)
	DEBUG = enabled
	TreadmillRegistry.setDebug(enabled)
	debugLog("Debug " .. (enabled and "enabled" or "disabled"))
end

function TreadmillService.getStats()
	local registryStats = TreadmillRegistry.getStats()

	return {
		registeredZones = registryStats.totalZones,
		spatialGridCells = registryStats.gridCells,
		activePlayers = #Players:GetPlayers(),
		trackedPlayers = 0  -- TODO: contar players com state
	}
end

-- Comando de debug para printar estado de um player
function TreadmillService.debugPlayer(playerName)
	local player = Players:FindFirstChild(playerName)
	if not player then
		warn("[TreadmillService] Player not found: " .. playerName)
		return
	end

	local state = playerStates[player.UserId]
	if not state then
		warn("[TreadmillService] No state for player: " .. playerName)
		return
	end

	debugLog("==================== PLAYER STATE: " .. playerName .. " ====================")
	debugLog("  CurrentMultiplier: " .. state.CurrentMultiplier)
	debugLog("  OnTreadmill: " .. tostring(state.OnTreadmill))
	debugLog("  LastZone: " .. (state.LastZone and state.LastZone:GetFullName() or "nil"))
	debugLog("  LastCheck: " .. state.LastCheck)

	local zoneData, zoneInstance = TreadmillService.getPlayerZone(player)
	if zoneData then
		debugLog("  Current Zone (live): " .. zoneInstance:GetFullName())
		debugLog("    Multiplier: " .. zoneData.Multiplier)
		debugLog("    IsFree: " .. tostring(zoneData.IsFree))
	else
		debugLog("  Current Zone (live): NONE")
	end

	debugLog("=================================================================")
end

-- ==================== EXPORT (para SpeedGameServer usar) ====================
debugLog("✅ TreadmillService ready")
debugLog("========================================================")

-- Expõe API globalmente para SpeedGameServer acessar
_G.TreadmillService = {
	getPlayerMultiplier = TreadmillService.getPlayerMultiplier,
	isPlayerOnTreadmill = TreadmillService.isPlayerOnTreadmill,
	getPlayerZone = TreadmillService.getPlayerZone,
	setDebug = TreadmillService.setDebug,
	getStats = TreadmillService.getStats,
	debugPlayer = TreadmillService.debugPlayer
}

return TreadmillService
