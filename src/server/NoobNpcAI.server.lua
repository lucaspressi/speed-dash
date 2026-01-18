-- NoobNpcAI.server.lua
-- Refactored with simple state machine and arena-based movement
-- Boss NPC that chases players, shoots slow laser, and taunts after kills

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[NoobAI] 🚀 Initializing...")

-- =========================
-- SERVICES & REMOTES
-- =========================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local NpcKillPlayerEvent = Remotes:WaitForChild("NpcKillPlayer")
local NpcLaserSlowEffect = Remotes:WaitForChild("NpcLaserSlowEffect")

-- =========================
-- NPC MODEL
-- =========================
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
-- DEBUG: Check NPC Configuration (kept from HEAD)
-- =========================
print("[NoobAI] 🔍 NPC Configuration:")
print("[NoobAI]   Humanoid.Health = " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
print("[NoobAI]   Humanoid.WalkSpeed = " .. humanoid.WalkSpeed)
print("[NoobAI]   HumanoidRootPart.Anchored = " .. tostring(hrp.Anchored))
print("[NoobAI]   HumanoidRootPart.Position = " .. tostring(hrp.Position))

-- ⚠️ CRITICAL: HumanoidRootPart CANNOT be anchored or NPC won't move!
if hrp.Anchored then
	warn("[NoobAI] ⚠️ WARNING: HumanoidRootPart is ANCHORED! Unanchoring...")
	hrp.Anchored = false
end

-- Ensure humanoid is alive
if humanoid.Health <= 0 then
	warn("[NoobAI] ❌ Humanoid is DEAD! Restoring health...")
	humanoid.Health = humanoid.MaxHealth
end

-- =========================
-- ARENA PART
-- =========================
-- NoobArena is a Model containing ArenaBounds (Part)
-- ⚠️ IMPORTANT: This is managed by Rojo (default.project.json)
-- Do NOT rename in Studio - changes must be made in the repo!
local arenaModel = workspace:WaitForChild("NoobArena", 5)
if not arenaModel then
	warn("[NoobAI] ❌ 'NoobArena' Model not found in Workspace!")
	warn("[NoobAI] This should be managed by Rojo in default.project.json")
	warn("[NoobAI] Do NOT create manually in Studio - edit the project file instead")
	return
end

print("[NoobAI] ✅ Found NoobArena model (ClassName: " .. arenaModel.ClassName .. ")")

-- Find ArenaBounds Part inside the model (wait to avoid Rojo timing issues)
local arena = arenaModel:WaitForChild("ArenaBounds", 5)

if not arena or not arena:IsA("BasePart") then
	warn("[NoobAI] ❌ 'ArenaBounds' Part not found inside NoobArena Model!")
	warn("[NoobAI] NoobArena ClassName: " .. arenaModel.ClassName)
	warn("[NoobAI] Children found in NoobArena:")
	for _, child in ipairs(arenaModel:GetChildren()) do
		warn("[NoobAI]   - " .. child.Name .. " (" .. child.ClassName .. ")")
	end
	warn("[NoobAI] Edit default.project.json (or source files) to add ArenaBounds Part inside NoobArena Model")
	return
end

local arenaCenter = arena.Position
local arenaSize = arena.Size

print("[NoobAI] ✅ Arena bounds found at: " .. tostring(arenaCenter))
print("[NoobAI] ✅ Arena size: " .. tostring(arenaSize))

-- Set diagnostic attributes (for DiagnosticClient)
workspace:SetAttribute("NoobNpcAI_Running", true)
workspace:SetAttribute("NoobNpcAI_ArenaPart", arena:GetFullName())

-- =========================
-- CONFIGURATION
-- =========================
-- Movement
local CHASE_SPEED = 28
local DETECTION_RANGE = 200
local CHASE_UPDATE_RATE = 0.2

-- Laser
local LASER_ENABLED = true
local LASER_MIN_RANGE = 25
local LASER_MAX_RANGE = 160
local LASER_COOLDOWN_MIN = 6
local LASER_COOLDOWN_MAX = 10
local LASER_WINDUP_TIME = 0.4
local LASER_BEAM_DURATION = 0.2
local LASER_SLOW_DURATION = 0.5
local LASER_SLOW_MULTIPLIER = 0.2  -- 20% speed
local LASER_CHANCE_PER_TICK = 0.22

-- Taunt
local TAUNT_DURATION = 1.5

-- =========================
-- STATE MACHINE
-- =========================
local State = {
	IDLE = "IDLE",        -- Meditating at center
	CHASING = "CHASING",  -- Chasing player
	TAUNTING = "TAUNTING" -- Dancing after kill
}

local currentState = nil  -- Start as nil so first enterState() actually executes
local currentTarget = nil
local chaseCoroutine = nil

-- forward declaration (fix: used before definition)
local enterState

-- =========================
-- ANIMATIONS
-- =========================
local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

-- Walk
local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://180426354"
local walkTrack = nil
local okWalk, errWalk = pcall(function()
	walkTrack = animator:LoadAnimation(walkAnim)
	walkTrack.Looped = true
	walkTrack.Priority = Enum.AnimationPriority.Movement
end)
if not okWalk then
	warn("[NoobAI] ❌ Failed to load walk animation: " .. tostring(errWalk))
else
	print("[NoobAI] ✅ Walk animation loaded successfully")
end

-- Meditation
local meditateAnim = Instance.new("Animation")
meditateAnim.AnimationId = "rbxassetid://2510196951"
local meditateTrack = nil
local okMed, errMed = pcall(function()
	meditateTrack = animator:LoadAnimation(meditateAnim)
	meditateTrack.Looped = true
	meditateTrack.Priority = Enum.AnimationPriority.Idle
end)
if not okMed then
	warn("[NoobAI] ❌ Failed to load meditation animation: " .. tostring(errMed))
else
	print("[NoobAI] ✅ Meditation animation loaded successfully")
end

-- Dance animations
local DANCE_ANIMATIONS = {
	"rbxassetid://3333499508",  -- Tidy
	"rbxassetid://3333136415",  -- Floss
	"rbxassetid://3333432454",  -- Hype
	"rbxassetid://4265725525",  -- Shuffle
	"rbxassetid://3695333486",  -- Laughing
	"rbxassetid://3333331310",  -- Salute
	"rbxassetid://3333387824",  -- Point
	"rbxassetid://4102315500",  -- Tilt
}
local currentDanceTrack = nil

-- =========================
-- LASER SETUP
-- =========================
local eyeAttachment = head:FindFirstChild("EyeLaserAttachment")
if not eyeAttachment then
	eyeAttachment = Instance.new("Attachment")
	eyeAttachment.Name = "EyeLaserAttachment"
	eyeAttachment.Position = Vector3.new(0, 0.2, -0.6)
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
	local relativePos = arena.CFrame:PointToObjectSpace(position)
	local halfSize = arenaSize / 2

	return math.abs(relativePos.X) <= halfSize.X
		and math.abs(relativePos.Y) <= halfSize.Y
		and math.abs(relativePos.Z) <= halfSize.Z
end

local function isPlayerInArena(player)
	local character = player.Character
	if not character then return false end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return false end

	return isPositionInArena(playerHrp.Position)
end

local function clampToArena(position)
	local relativePos = arena.CFrame:PointToObjectSpace(position)
	local halfSize = arenaSize / 2
	local margin = Vector3.new(5, 0, 5)

	local clampedRelative = Vector3.new(
		math.clamp(relativePos.X, -halfSize.X + margin.X, halfSize.X - margin.X),
		relativePos.Y,
		math.clamp(relativePos.Z, -halfSize.Z + margin.Z, halfSize.Z - margin.Z)
	)

	return arena.CFrame:PointToWorldSpace(clampedRelative)
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
-- LASER FUNCTIONS
-- =========================
local function refreshLaserCooldown()
	laserCooldown = math.random(LASER_COOLDOWN_MIN * 10, LASER_COOLDOWN_MAX * 10) / 10
end

local function canFireLaser()
	return LASER_ENABLED and not isChargingLaser and (os.clock() - lastLaserFiredAt) >= laserCooldown
end

local function aimAtTarget(targetPos, duration)
	local flat = (targetPos - hrp.Position) * Vector3.new(1, 0, 1)
	if flat.Magnitude < 0.1 then return end
	local targetCFrame = CFrame.new(hrp.Position, hrp.Position + flat)

	TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	}):Play()
end

local function showLaserTelegraph()
	telegraphLight.Brightness = 6
	task.spawn(function()
		local elapsed = 0
		while elapsed < LASER_WINDUP_TIME and isChargingLaser do
			telegraphLight.Brightness = 6 + math.sin(elapsed * 30) * 2
			task.wait(0.05)
			elapsed += 0.05
		end
		if not isChargingLaser then
			telegraphLight.Brightness = 0
		end
	end)
end

local function fireLaser(targetHrp)
	if not canFireLaser() then return end
	if not targetHrp or not targetHrp.Parent then return end
	if not isPositionInArena(targetHrp.Position) then return end

	local dist = (targetHrp.Position - hrp.Position).Magnitude
	if dist < LASER_MIN_RANGE or dist > LASER_MAX_RANGE then return end

	isChargingLaser = true
	lastLaserFiredAt = os.clock()
	refreshLaserCooldown()

	local oldSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = math.max(10, CHASE_SPEED * 0.5)

	aimAtTarget(targetHrp.Position, LASER_WINDUP_TIME * 0.6)
	showLaserTelegraph()

	task.wait(LASER_WINDUP_TIME)

	if not targetHrp.Parent then
		isChargingLaser = false
		telegraphLight.Brightness = 0
		humanoid.WalkSpeed = oldSpeed
		return
	end

	local origin = eyeAttachment.WorldPosition
	local targetPos = targetHrp.Position + Vector3.new(0, 1.5, 0)
	local direction = targetPos - origin

	local result = workspace:Raycast(origin, direction, rayParams)

	local hitPos = targetPos
	local hitHumanoid = nil

	if result then
		hitPos = result.Position
		local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
		if hitChar then
			hitHumanoid = hitChar:FindFirstChildOfClass("Humanoid")
		end
	end

	laserAnchor.Position = clampToArena(hitPos)
	laserBeam.Enabled = true

	-- Slow player (doesn't kill)
	if hitHumanoid and hitHumanoid.Health > 0 then
		local originalSpeed = hitHumanoid.WalkSpeed
		hitHumanoid.WalkSpeed = originalSpeed * LASER_SLOW_MULTIPLIER

		print("[NoobAI] 🎯 Laser hit! Slowing player for " .. LASER_SLOW_DURATION .. "s")

		-- Fire client effect
		local player = Players:GetPlayerFromCharacter(hitHumanoid.Parent)
		if player then
			NpcLaserSlowEffect:FireClient(player, LASER_SLOW_DURATION)
		end

		-- Restore speed
		task.delay(LASER_SLOW_DURATION, function()
			if hitHumanoid and hitHumanoid.Health > 0 then
				hitHumanoid.WalkSpeed = originalSpeed
			end
		end)
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
	humanoid:MoveTo(hrp.Position)
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
-- CHASE LOOP (Coroutine)
-- =========================
local function startChaseLoop()
	chaseCoroutine = coroutine.create(function()
		while currentState == State.CHASING do
			if not currentTarget or not currentTarget.Character then
				enterState(State.IDLE)
				break
			end

			local targetHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = currentTarget.Character:FindFirstChild("Humanoid")

			if not targetHrp or not targetHumanoid or targetHumanoid.Health <= 0 then
				enterState(State.IDLE)
				break
			end

			if not isPlayerInArena(currentTarget) then
				print("[NoobAI] 🏃 Target left arena")
				enterState(State.IDLE)
				break
			end

			-- Chase target
			local targetPos = clampToArena(targetHrp.Position)
			humanoid:MoveTo(targetPos)

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

			task.wait(CHASE_UPDATE_RATE)
		end
	end)

	coroutine.resume(chaseCoroutine)
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
		if meditateTrack then meditateTrack:Stop() end

	elseif currentState == State.CHASING then
		if walkTrack then walkTrack:Stop() end
		currentTarget = nil
		chaseCoroutine = nil

	elseif currentState == State.TAUNTING then
		if currentDanceTrack then
			currentDanceTrack:Stop()
		end
	end

	-- Update state
	currentState = newState

	-- Enter new state
	if newState == State.IDLE then
		print("[NoobAI] 🧘 Entering IDLE - walking to center")
		humanoid.WalkSpeed = 16
		humanoid:MoveTo(arenaCenter)

		-- Wait for NPC to actually reach center
		local connection
		connection = humanoid.MoveToFinished:Connect(function(reached)
			if connection then connection:Disconnect() end
			if currentState == State.IDLE then
				print("[NoobAI] ✅ Reached center, starting meditation")
				humanoid.WalkSpeed = 0
				humanoid:MoveTo(hrp.Position)
				if meditateTrack then meditateTrack:Play() end
			end
		end)

		-- Timeout fallback (30s)
		task.delay(30, function()
			if connection then connection:Disconnect() end
			if currentState == State.IDLE then
				print("[NoobAI] ⚠️ MoveTo timeout, starting meditation anyway")
				humanoid.WalkSpeed = 0
				if meditateTrack then meditateTrack:Play() end
			end
		end)

	elseif newState == State.CHASING then
		print("[NoobAI] 🏃 Entering CHASING - hunting target")
		if meditateTrack then meditateTrack:Stop() end
		humanoid.WalkSpeed = CHASE_SPEED
		if walkTrack then walkTrack:Play() end
		startChaseLoop()

	elseif newState == State.TAUNTING then
		print("[NoobAI] 💃 Entering TAUNTING - victory dance")
		if walkTrack then walkTrack:Stop() end
		doVictoryTaunt()

		-- Return to IDLE after taunt duration
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
for _, part in pairs(noob:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
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

-- =========================
-- KEEP IN BOUNDS
-- =========================
RunService.Heartbeat:Connect(function()
	if not isPositionInArena(hrp.Position) then
		local clampedPos = clampToArena(hrp.Position)
		hrp.CFrame = CFrame.new(clampedPos.X, hrp.Position.Y, clampedPos.Z)
	end
end)

-- =========================
-- MAIN DETECTION LOOP
-- =========================
RunService.Heartbeat:Connect(function()
	-- Only detect players when IDLE (not chasing or taunting)
	if currentState == State.IDLE then
		local target = getNearestPlayerInArena()
		if target then
			currentTarget = target
			enterState(State.CHASING)
		end
	end
end)

-- =========================
-- INITIALIZATION
-- =========================
print("[NoobAI] ✅ Initialized successfully!")
print("[NoobAI] 📍 Arena center: " .. tostring(arenaCenter))
print("[NoobAI] 📏 Arena size: " .. tostring(arenaSize))
print("[NoobAI] 🎯 Detection range: " .. DETECTION_RANGE)
print("[NoobAI] 🏃 Chase speed: " .. CHASE_SPEED)
print("[NoobAI] 🔫 Laser enabled: " .. tostring(LASER_ENABLED))

-- Start in IDLE state
enterState(State.IDLE)
