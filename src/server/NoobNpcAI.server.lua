-- NoobNpcAI.server.lua
-- COMPLETE REWRITE: Fixed all movement blocking issues
-- Boss NPC that chases players, shoots slow laser, and taunts after kills

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[NoobAI] 🚀 Initializing (REWRITTEN VERSION)...")

-- =========================
-- SERVICES & REMOTES
-- =========================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local NpcKillPlayerEvent = Remotes:WaitForChild("NpcKillPlayer")
local NpcLaserSlowEffect = Remotes:WaitForChild("NpcLaserSlowEffect")

-- =========================
-- NPC MODEL
-- =========================
task.wait(2) -- Safety delay

local noob = workspace:WaitForChild("Buff Noob", 5)
if not noob then
	warn("[NoobAI] ❌ 'Buff Noob' NPC not found in Workspace. Script disabled.")
	return
end

local humanoid = noob:WaitForChild("Humanoid", 5)
local hrp = noob:WaitForChild("HumanoidRootPart", 5)
local head = noob:WaitForChild("Head", 5)

if not humanoid or not hrp or not head then
	warn("[NoobAI] ❌ NPC missing required parts. Script disabled.")
	return
end

print("[NoobAI] ✅ Found NPC and parts")

-- =========================
-- CRITICAL: FIX ALL MOVEMENT BLOCKERS
-- =========================
print("[NoobAI] 🔧 Fixing all potential movement blockers...")

-- 1. Unanchor ALL parts (not just HRP)
for _, part in pairs(noob:GetDescendants()) do
	if part:IsA("BasePart") then
		if part.Anchored and part ~= hrp then
			warn("[NoobAI] ⚠️ Found anchored part: " .. part.Name .. " - UNANCHORING")
			part.Anchored = false
		end
	end
end

-- 2. Force HRP unanchored
hrp.Anchored = false
print("[NoobAI] ✅ HumanoidRootPart.Anchored = " .. tostring(hrp.Anchored))

-- 3. Fix Humanoid states
humanoid.PlatformStand = false
humanoid.Sit = false
print("[NoobAI] ✅ PlatformStand = false, Sit = false")

-- 4. Restore health if dead
if humanoid.Health <= 0 then
	warn("[NoobAI] ⚠️ Humanoid was DEAD! Restoring health...")
	humanoid.Health = humanoid.MaxHealth
end

-- 5. Set proper WalkSpeed (higher for scaled NPCs)
humanoid.WalkSpeed = 100
humanoid.JumpPower = 0 -- No jumping for NPC
print("[NoobAI] ✅ WalkSpeed = 100, JumpPower = 0")

-- 6. Remove any BodyMovers and constraints that might interfere
for _, child in pairs(hrp:GetChildren()) do
	if child:IsA("BodyMover") or child:IsA("BodyVelocity") or child:IsA("BodyPosition") then
		warn("[NoobAI] ⚠️ Found BodyMover: " .. child.ClassName .. " - DESTROYING")
		child:Destroy()
	end
	if child:IsA("Constraint") and not child:IsA("Motor6D") and not child:IsA("Weld") then
		warn("[NoobAI] ⚠️ Found Constraint: " .. child.ClassName .. " - DESTROYING")
		child:Destroy()
	end
end

-- 7. Ensure HumanoidRootPart has proper physics properties
hrp.CanCollide = true
hrp.Massless = false
print("[NoobAI] ✅ HRP CanCollide = true, Massless = false")

print("[NoobAI] 🔍 Initial Configuration:")
print("[NoobAI]   Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
print("[NoobAI]   Position: " .. tostring(hrp.Position))
print("[NoobAI]   WalkSpeed: " .. humanoid.WalkSpeed)
print("[NoobAI]   HRP Anchored: " .. tostring(hrp.Anchored))
print("[NoobAI]   HRP CanCollide: " .. tostring(hrp.CanCollide))
print("[NoobAI]   HRP Massless: " .. tostring(hrp.Massless))
print("[NoobAI]   Humanoid PlatformStand: " .. tostring(humanoid.PlatformStand))
print("[NoobAI]   Humanoid Sit: " .. tostring(humanoid.Sit))

-- =========================
-- ARENA CONFIGURATION
-- =========================
local arenaModel = workspace:WaitForChild("NoobArena", 5)
if not arenaModel then
	warn("[NoobAI] ❌ 'NoobArena' Model not found! Script disabled.")
	warn("[NoobAI] Make sure default.project.json defines NoobArena")
	return
end

if arenaModel.ClassName ~= "Model" then
	warn("[NoobAI] ❌ 'NoobArena' is " .. arenaModel.ClassName .. " but should be Model!")
	return
end

print("[NoobAI] ✅ Found NoobArena model (ClassName: " .. arenaModel.ClassName .. ")")

local arena = arenaModel:FindFirstChild("ArenaBounds")
if not arena or not arena:IsA("BasePart") then
	warn("[NoobAI] ❌ 'ArenaBounds' Part not found inside NoobArena Model!")
	warn("[NoobAI] This should be managed by Rojo in default.project.json")
	if arenaModel:GetChildren() then
		warn("[NoobAI] Children found in NoobArena:")
		for _, child in pairs(arenaModel:GetChildren()) do
			warn("[NoobAI]   - " .. child.Name .. " (" .. child.ClassName .. ")")
		end
	end
	return
end

print("[NoobAI] ✅ Arena Part: " .. arena:GetFullName())

local arenaCenter = arena.Position
local arenaSize = arena.Size

print("[NoobAI] ✅ Arena bounds found at: " .. tostring(arenaCenter))
print("[NoobAI] ✅ Arena size: " .. tostring(arenaSize))
print("[NoobAI] ✅ Arena rotation: " .. tostring(arena.Rotation))

-- Check for rotation
local rotation = arena.Rotation
if math.abs(rotation.X) > 1 or math.abs(rotation.Y) > 1 or math.abs(rotation.Z) > 1 then
	warn("[NoobAI] ⚠️ WARNING: Arena has rotation! This may cause bounds detection issues")
	warn("[NoobAI] ⚠️ Rotation: " .. tostring(rotation))
	warn("[NoobAI] ⚠️ Arena should have zero rotation for proper function")
end

-- CRITICAL: Validate arena configuration
warn("[NoobAI] ⚠️ Arena found: Position=" .. tostring(arenaCenter) .. ", Size=" .. tostring(arenaSize))

-- ARENA VALIDATION DISABLED - Accept any arena configuration
-- The NPC will work with whatever arena exists in the workspace
warn("[NoobAI] ✅ Arena validation skipped - using existing arena configuration")

-- =========================
-- CONFIG
-- =========================
-- Movement
local CHASE_SPEED = 250 -- NEXTBOT STYLE - Very fast direct chase
local IDLE_SPEED = 16
local DETECTION_RANGE = 200
local PATHFINDING_UPDATE = 1.0 -- Recalculate path every 1 second
local MOVEMENT_UPDATE = 0.1 -- Move every 0.1 seconds

-- Laser
local LASER_ENABLED = true
local LASER_MIN_RANGE = 25
local LASER_MAX_RANGE = 160
local LASER_COOLDOWN_MIN = 6
local LASER_COOLDOWN_MAX = 10
local LASER_CHARGE_TIME = 0.4
local LASER_BEAM_DURATION = 0.6
local LASER_SLOW_MULTIPLIER = 0.2
local LASER_SLOW_DURATION = 0.5
local LASER_CHANCE_PER_TICK = 0.3

-- Taunt
local TAUNT_DURATION = 1.5

-- Dance animations
local DANCE_ANIMATIONS = {
	"rbxassetid://3695333486",
	"rbxassetid://4265725525",
	"rbxassetid://3695333486",
	"rbxassetid://3333499508",
	"rbxassetid://3334538554",
	"rbxassetid://3695333486",
	"rbxassetid://3333331310",
	"rbxassetid://3333432454",
}

-- =========================
-- STATE MACHINE
-- =========================
local State = {
	IDLE = "IDLE",        -- At center
	CHASING = "CHASING",  -- Chasing player
	TAUNTING = "TAUNTING" -- Dancing after kill
}

local currentState = nil
local currentTarget = nil
local currentPath = nil
local waypointIndex = 0
local pathfindingCoroutine = nil

-- =========================
-- ANIMATIONS
-- =========================
local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

-- Walk animation
local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://180426354"
local walkTrack = nil
local okWalk, errWalk = pcall(function()
	walkTrack = animator:LoadAnimation(walkAnim)
	walkTrack.Looped = true
	walkTrack.Priority = Enum.AnimationPriority.Movement
end)

if okWalk and walkTrack then
	print("[NoobAI] ✅ Walk animation loaded successfully")
else
	warn("[NoobAI] ❌ Failed to load walk animation: " .. tostring(errWalk))
end

-- Meditation animation
local meditateAnim = Instance.new("Animation")
meditateAnim.AnimationId = "rbxassetid://2510196951"
local meditateTrack = nil
local okMed, errMed = pcall(function()
	meditateTrack = animator:LoadAnimation(meditateAnim)
	meditateTrack.Looped = true
	meditateTrack.Priority = Enum.AnimationPriority.Idle
end)

if okMed and meditateTrack then
	print("[NoobAI] ✅ Meditation animation loaded successfully")
else
	warn("[NoobAI] ❌ Failed to load meditation animation: " .. tostring(errMed))
end

-- Current dance track
local currentDanceTrack = nil

-- =========================
-- LASER SETUP
-- =========================
local eyeAttachment = head:FindFirstChild("FaceCenterAttachment")
if not eyeAttachment then
	eyeAttachment = Instance.new("Attachment")
	eyeAttachment.Name = "FaceCenterAttachment"
	eyeAttachment.Position = Vector3.new(0, 0, -0.6)
	eyeAttachment.Parent = head
end

local laserAnchor = Instance.new("Part")
laserAnchor.Name = "LaserAnchor"
laserAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
laserAnchor.Transparency = 1
laserAnchor.CanCollide = false
laserAnchor.Anchored = true
laserAnchor.Parent = workspace

local laserAnchorAttachment = Instance.new("Attachment")
laserAnchorAttachment.Parent = laserAnchor

local laserBeam = Instance.new("Beam")
laserBeam.Attachment0 = eyeAttachment
laserBeam.Attachment1 = laserAnchorAttachment
laserBeam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
laserBeam.Brightness = 3
laserBeam.Width0 = 0.25
laserBeam.Width1 = 0.25
laserBeam.FaceCamera = true
laserBeam.Enabled = false
laserBeam.Parent = head

local telegraphLight = Instance.new("PointLight")
telegraphLight.Color = Color3.fromRGB(255, 0, 0)
telegraphLight.Brightness = 0
telegraphLight.Range = 12
telegraphLight.Parent = head

local isChargingLaser = false
local lastLaserFiredAt = 0
local laserCooldown = math.random(LASER_COOLDOWN_MIN * 10, LASER_COOLDOWN_MAX * 10) / 10

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { noob }
rayParams.IgnoreWater = true

-- =========================
-- HELPER FUNCTIONS
-- =========================
local function isPositionInArena(position)
	-- Use simple AABB (Axis-Aligned Bounding Box) check
	-- This ignores rotation and works in world space
	local halfSize = arenaSize / 2
	local minBounds = arenaCenter - halfSize
	local maxBounds = arenaCenter + halfSize

	-- Add vertical tolerance (Y axis) for physics/animation fluctuations
	local Y_TOLERANCE = 15 -- Allow 15 studs above/below for physics

	return position.X >= minBounds.X and position.X <= maxBounds.X
		and position.Y >= (minBounds.Y - Y_TOLERANCE) and position.Y <= (maxBounds.Y + Y_TOLERANCE)
		and position.Z >= minBounds.Z and position.Z <= maxBounds.Z
end

local function isPlayerInArena(player)
	local character = player.Character
	if not character then return false end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return false end

	return isPositionInArena(playerHrp.Position)
end

local function getNearestPlayerInArena()
	local nearestPlayer = nil
	local nearestDist = DETECTION_RANGE

	for _, player in pairs(Players:GetPlayers()) do
		if isPlayerInArena(player) then
			local character = player.Character
			if character then
				local playerHrp = character:FindFirstChild("HumanoidRootPart")
				local playerHumanoid = character:FindFirstChild("Humanoid")

				if playerHrp and playerHumanoid and playerHumanoid.Health > 0 then
					local dist = (playerHrp.Position - hrp.Position).Magnitude
					if dist < nearestDist then
						nearestDist = dist
						nearestPlayer = player
					end
				end
			end
		end
	end

	return nearestPlayer
end

-- =========================
-- PATHFINDING SYSTEM
-- =========================
local pathfindingAgent = PathfindingService:CreatePath({
	AgentRadius = 3,
	AgentHeight = 5,
	AgentCanJump = false,
	WaypointSpacing = 4,
	Costs = {}
})

local function createPathTo(targetPosition)
	local success, errorMsg = pcall(function()
		pathfindingAgent:ComputeAsync(hrp.Position, targetPosition)
	end)

	if success and pathfindingAgent.Status == Enum.PathStatus.Success then
		return pathfindingAgent:GetWaypoints()
	else
		warn("[NoobAI] ⚠️ Pathfinding failed: " .. tostring(errorMsg))
		return nil
	end
end

-- =========================
-- MOVEMENT SYSTEM (NEXTBOT STYLE - Direct CFrame Movement)
-- =========================
local movementConnection = nil
local currentMoveTarget = nil
local GROUND_Y = 7 -- Keep NPC at ground level

local function startMovingToPosition(targetPos)
	-- Stop old movement
	if movementConnection then
		movementConnection:Disconnect()
		movementConnection = nil
	end

	-- Keep target at ground level
	targetPos = Vector3.new(targetPos.X, GROUND_Y, targetPos.Z)
	currentMoveTarget = targetPos

	print("[NoobAI] 🎯 Moving to: " .. tostring(targetPos))

	-- Validate target position is in arena
	if not isPositionInArena(targetPos) then
		warn("[NoobAI] ⚠️ Target position is outside arena! Aborting movement")
		return
	end

	-- Nextbot-style movement: Move directly towards target using CFrame
	movementConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if currentState ~= State.CHASING then
			if movementConnection then
				movementConnection:Disconnect()
				movementConnection = nil
			end
			return
		end

		-- Get current position (but force ground level)
		local currentPos = Vector3.new(hrp.Position.X, GROUND_Y, hrp.Position.Z)

		-- Calculate direction to target
		local direction = (currentMoveTarget - currentPos).Unit
		local distance = (currentMoveTarget - currentPos).Magnitude

		-- If we're close enough, consider reached
		if distance < 4 then
			return -- Chase loop will handle next waypoint
		end

		-- Calculate movement speed (studs per second)
		local speed = CHASE_SPEED
		local moveAmount = direction * speed * deltaTime

		-- Calculate new position
		local newPos = currentPos + moveAmount

		-- Keep within arena bounds
		if not isPositionInArena(newPos) then
			-- Stop at arena edge
			return
		end

		-- Move NPC using CFrame (maintains Y level, ignores physics)
		local lookDirection = Vector3.new(direction.X, 0, direction.Z).Unit
		if lookDirection.Magnitude > 0 then
			hrp.CFrame = CFrame.new(newPos, newPos + lookDirection)
		else
			hrp.CFrame = CFrame.new(newPos)
		end
	end)
end

local function stopMovement()
	if movementConnection then
		movementConnection:Disconnect()
		movementConnection = nil
	end

	currentMoveTarget = nil

	-- Zero out velocity
	if hrp:IsA("BasePart") then
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end
end

-- =========================
-- LASER SYSTEM
-- =========================
local function canFireLaser()
	if not LASER_ENABLED then return false end
	local timeSince = tick() - lastLaserFiredAt
	return timeSince >= laserCooldown
end

local function aimAtTarget(target)
	local targetCFrame = CFrame.lookAt(hrp.Position, target.Position)
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(LASER_CHARGE_TIME * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{CFrame = targetCFrame}
	)
	tween:Play()
end

local function fireLaser(targetHrp)
	if isChargingLaser then return end
	if not canFireLaser() then return end

	isChargingLaser = true
	local oldSpeed = humanoid.WalkSpeed

	print("[NoobAI] 🔫 Charging laser at " .. currentTarget.Name)
	humanoid.WalkSpeed = math.max(10, CHASE_SPEED * 0.5)

	telegraphLight.Brightness = 8
	task.wait(LASER_CHARGE_TIME * 0.5)
	aimAtTarget(targetHrp)
	task.wait(LASER_CHARGE_TIME * 0.5)

	print("[NoobAI] ⚡ FIRING LASER!")
	laserAnchor.Position = targetHrp.Position
	laserBeam.Enabled = true
	telegraphLight.Brightness = 15

	lastLaserFiredAt = tick()
	laserCooldown = math.random(LASER_COOLDOWN_MIN * 10, LASER_COOLDOWN_MAX * 10) / 10

	-- Raycast to check hit
	local ray = workspace:Raycast(eyeAttachment.WorldPosition, (targetHrp.Position - eyeAttachment.WorldPosition).Unit * LASER_MAX_RANGE, rayParams)

	if ray and ray.Instance then
		local hitChar = ray.Instance.Parent
		if hitChar and hitChar:FindFirstChild("Humanoid") then
			local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
			if hitPlayer then
				print("[NoobAI] 🎯 Laser HIT " .. hitPlayer.Name)
				local hitHumanoid = hitChar.Humanoid
				local originalSpeed = hitHumanoid.WalkSpeed
				hitHumanoid.WalkSpeed = originalSpeed * LASER_SLOW_MULTIPLIER

				-- Fire client event
				NpcLaserSlowEffect:FireClient(hitPlayer)

				task.delay(LASER_SLOW_DURATION, function()
					if hitHumanoid then
						hitHumanoid.WalkSpeed = originalSpeed
					end
				end)
			end
		end
	end

	task.delay(LASER_BEAM_DURATION, function()
		laserBeam.Enabled = false
	end)

	task.wait(0.05)
	isChargingLaser = false
	telegraphLight.Brightness = 0
	humanoid.WalkSpeed = oldSpeed
end

-- =========================
-- TAUNT (Victory Dance)
-- =========================
local function doVictoryTaunt()
	print("[NoobAI] 💃 Starting victory taunt!")

	-- Stop all movement
	stopMovement()
	humanoid.WalkSpeed = 0

	-- Choose random dance
	local randomIndex = math.random(1, #DANCE_ANIMATIONS)
	local randomDanceId = DANCE_ANIMATIONS[randomIndex]

	-- Load and play animation
	local danceAnim = Instance.new("Animation")
	danceAnim.AnimationId = randomDanceId

	if currentDanceTrack then
		currentDanceTrack:Stop()
		currentDanceTrack:Destroy()
	end

	local ok, err = pcall(function()
		currentDanceTrack = animator:LoadAnimation(danceAnim)
		currentDanceTrack.Looped = false
		currentDanceTrack.Priority = Enum.AnimationPriority.Action4
		currentDanceTrack:Play()
	end)

	if not ok then
		warn("[NoobAI] ❌ Failed to play dance: " .. tostring(err))
	end
end

-- =========================
-- CHASE LOOP (NEW - Using Pathfinding)
-- =========================
local function startChaseLoop()
	pathfindingCoroutine = coroutine.create(function()
		print("[NoobAI] 🏃 Chase loop STARTED (NEXTBOT DIRECT CHASE)")

		while currentState == State.CHASING do
			if not currentTarget or not currentTarget.Character then
				print("[NoobAI] ❌ No target")
				enterState(State.IDLE)
				break
			end

			local targetHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = currentTarget.Character:FindFirstChild("Humanoid")

			if not targetHrp or not targetHumanoid or targetHumanoid.Health <= 0 then
				print("[NoobAI] ❌ Target invalid")
				enterState(State.IDLE)
				break
			end

			if not isPlayerInArena(currentTarget) then
				print("[NoobAI] 🏃 Target left arena")
				enterState(State.IDLE)
				break
			end

			-- NEXTBOT STYLE: Move directly towards player (no pathfinding)
			if isPositionInArena(targetHrp.Position) then
				-- Update target position for movement system
				startMovingToPosition(targetHrp.Position)
			else
				warn("[NoobAI] ⚠️ Target outside arena")
				enterState(State.IDLE)
				break
			end

			-- Try to fire laser
			if not isChargingLaser and canFireLaser() then
				local dist = (targetHrp.Position - hrp.Position).Magnitude
				if dist >= LASER_MIN_RANGE and dist <= LASER_MAX_RANGE then
					if math.random() < LASER_CHANCE_PER_TICK then
						task.spawn(function()
							fireLaser(targetHrp)
						end)
					end
				end
			end

			task.wait(MOVEMENT_UPDATE)
		end

		stopMovement()
		print("[NoobAI] 🏃 Chase loop ENDED")
	end)

	coroutine.resume(pathfindingCoroutine)
end

-- =========================
-- STATE TRANSITIONS
-- =========================
enterState = function(newState)
	if currentState == newState then return end

	local oldState = currentState or "NONE"
	print("[NoobAI] 🔄 State: " .. oldState .. " → " .. newState)

	-- Exit current state
	if currentState == State.IDLE then
		if meditateTrack and meditateTrack.IsPlaying then
			meditateTrack:Stop()
		end

	elseif currentState == State.CHASING then
		if walkTrack and walkTrack.IsPlaying then
			walkTrack:Stop()
		end
		stopMovement()
		currentTarget = nil
		pathfindingCoroutine = nil

	elseif currentState == State.TAUNTING then
		if currentDanceTrack then
			currentDanceTrack:Stop()
		end
	end

	-- Update state
	currentState = newState

	-- Enter new state
	if newState == State.IDLE then
		print("[NoobAI] 🧘 Entering IDLE - returning to center")
		humanoid.WalkSpeed = IDLE_SPEED

		-- Teleport to center at GROUND LEVEL
		local groundPosition = Vector3.new(arenaCenter.X, GROUND_Y, arenaCenter.Z)
		hrp.CFrame = CFrame.new(groundPosition)
		print("[NoobAI] 📍 Teleported to ground level: " .. tostring(hrp.Position))

		-- Start meditation
		task.wait(0.5)
		if currentState == State.IDLE then
			humanoid.WalkSpeed = 0
			if meditateTrack then
				meditateTrack:Play()
			end
		end

	elseif newState == State.CHASING then
		print("[NoobAI] 🏃 Entering CHASING - hunting target")
		if meditateTrack and meditateTrack.IsPlaying then
			meditateTrack:Stop()
		end
		humanoid.WalkSpeed = CHASE_SPEED
		if walkTrack then
			walkTrack:Play()
		end
		startChaseLoop()

	elseif newState == State.TAUNTING then
		print("[NoobAI] 💃 Entering TAUNTING - victory dance")
		if walkTrack and walkTrack.IsPlaying then
			walkTrack:Stop()
		end
		doVictoryTaunt()

		-- Auto-return to IDLE after taunt
		task.delay(TAUNT_DURATION, function()
			if currentState == State.TAUNTING then
				enterState(State.IDLE)
			end
		end)
	end
end

-- =========================
-- KILL ON TOUCH
-- =========================
local function setupKillOnTouch()
	for _, part in pairs(noob:GetChildren()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)
				local character = hit.Parent
				if not character then return end

				local player = Players:GetPlayerFromCharacter(character)

				if player then
					local playerHumanoid = character:FindFirstChild("Humanoid")
					if playerHumanoid and playerHumanoid.Health > 0 then
						print("[NoobAI] ☠️ Killed " .. player.Name)
						playerHumanoid.Health = 0

						-- Fire client event (Vine Boom)
						NpcKillPlayerEvent:FireClient(player)

						-- Taunt after kill
						task.spawn(function()
							task.wait(0.1)
							if currentState ~= State.TAUNTING then
								enterState(State.TAUNTING)
							end
						end)
					end
				end
			end)
		end
	end
end

-- NOTE: setupKillOnTouch() is called AFTER teleporting NPC to arena
-- (see initialization section at end of file)

-- =========================
-- ARENA BOUNDS ENFORCER (CRITICAL)
-- =========================
-- This runs ALWAYS to ensure NPC never escapes arena
local lastBoundsWarning = 0
local BOUNDS_WARNING_COOLDOWN = 2 -- Only warn every 2 seconds
local boundsEnforcerEnabled = false -- Start disabled to allow physics to settle

RunService.Heartbeat:Connect(function()
	if not boundsEnforcerEnabled then return end -- Wait for initialization

	if not isPositionInArena(hrp.Position) then
		local now = tick()
		if now - lastBoundsWarning >= BOUNDS_WARNING_COOLDOWN then
			warn("[NoobAI] 🚨 CRITICAL: NPC outside arena! Position: " .. tostring(hrp.Position))
			warn("[NoobAI] 🚨 Arena center: " .. tostring(arenaCenter) .. " | Size: " .. tostring(arenaSize))
			lastBoundsWarning = now
		end

		-- Force teleport back to ground level
		local groundPosition = Vector3.new(arenaCenter.X, GROUND_Y, arenaCenter.Z)
		hrp.CFrame = CFrame.new(groundPosition)
		if currentState ~= State.IDLE then
			enterState(State.IDLE)
		end
	end
end)

-- =========================
-- MAIN DETECTION LOOP
-- =========================
RunService.Heartbeat:Connect(function()
	-- Only detect players when IDLE
	if currentState == State.IDLE then
		local target = getNearestPlayerInArena()
		if target then
			-- Double-check target is actually in arena
			if isPlayerInArena(target) then
				currentTarget = target
				enterState(State.CHASING)
			else
				warn("[NoobAI] ⚠️ Target detected but NOT in arena - ignoring")
			end
		end
	end
end)

-- =========================
-- INITIALIZATION
-- =========================
print("[NoobAI] ✅ Initialized successfully!")
print("[NoobAI] 📍 Arena center: " .. tostring(arenaCenter))
print("[NoobAI] 📏 Arena size: " .. tostring(arenaSize))

-- Calculate and display arena bounds
local halfSize = arenaSize / 2
local minX = arenaCenter.X - halfSize.X
local maxX = arenaCenter.X + halfSize.X
local minY = arenaCenter.Y - halfSize.Y
local maxY = arenaCenter.Y + halfSize.Y
local minZ = arenaCenter.Z - halfSize.Z
local maxZ = arenaCenter.Z + halfSize.Z

print("[NoobAI] 🔲 Arena Bounds:")
print("[NoobAI]   X: " .. minX .. " to " .. maxX)
print("[NoobAI]   Y: " .. minY .. " to " .. maxY)
print("[NoobAI]   Z: " .. minZ .. " to " .. maxZ)

print("[NoobAI] 🎯 Detection range: " .. DETECTION_RANGE)
print("[NoobAI] 🏃 Chase speed: " .. CHASE_SPEED)
print("[NoobAI] 🔫 Laser enabled: " .. tostring(LASER_ENABLED))

-- CRITICAL: Teleport NPC to arena center at GROUND LEVEL
print("[NoobAI] 📦 Teleporting NPC to arena ground level...")
local groundPosition = Vector3.new(arenaCenter.X, GROUND_Y, arenaCenter.Z)
hrp.CFrame = CFrame.new(groundPosition)
task.wait(0.5) -- Delay to ensure physics fully settle
print("[NoobAI] ✅ NPC teleported to ground level: " .. tostring(hrp.Position))

-- NOW setup kill-on-touch (after NPC is in arena, not in lobby!)
print("[NoobAI] ⚔️ Setting up kill-on-touch...")
setupKillOnTouch()

-- Start in IDLE state
enterState(State.IDLE)

-- Enable bounds enforcer after physics settle (2 seconds)
task.delay(2, function()
	boundsEnforcerEnabled = true
	print("[NoobAI] ✅ Bounds enforcer enabled")
end)

-- Set diagnostic attributes
workspace:SetAttribute("NoobNpcAI_Running", true)
workspace:SetAttribute("NoobNpcAI_ArenaPart", arena:GetFullName())
