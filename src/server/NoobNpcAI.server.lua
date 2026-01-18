local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[NoobAI] Initializing...")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local NpcKillPlayerEvent = Remotes:WaitForChild("NpcKillPlayer")
local NpcLaserSlowEffect = Remotes:WaitForChild("NpcLaserSlowEffect")

print("[NoobAI] Remotes found, searching for 'Buff Noob' NPC...")

-- Try to find NPC with timeout
local noob = workspace:WaitForChild("Buff Noob", 5)
if not noob then
	warn("[NoobAI] ❌ 'Buff Noob' NPC not found in Workspace. Script disabled.")
	warn("[NoobAI] Please add 'Buff Noob' NPC model to Workspace.")
	return
end

print("[NoobAI] ✅ Found 'Buff Noob' at: " .. noob:GetFullName())

local humanoid = noob:WaitForChild("Humanoid", 5)
local hrp = noob:WaitForChild("HumanoidRootPart", 5)
local head = noob:WaitForChild("Head", 5)

if not humanoid or not hrp or not head then
	warn("[NoobAI] ❌ NPC missing required parts (Humanoid, HumanoidRootPart, or Head). Script disabled.")
	return
end

print("[NoobAI] ✅ NPC parts found (Humanoid, HumanoidRootPart, Head)")

-- =========================
-- BOUNDS (do BKP - simples!)
-- =========================
print("[NoobAI] Searching for 'Stage2NpcKill' area...")
local stage2Area = workspace:WaitForChild("Stage2NpcKill", 5)
if not stage2Area then
	warn("[NoobAI] ❌ 'Stage2NpcKill' area not found in Workspace. Script disabled.")
	warn("[NoobAI] Please add 'Stage2NpcKill' folder with parts to Workspace.")
	return
end

print("[NoobAI] ✅ Found 'Stage2NpcKill' at: " .. stage2Area:GetFullName())

local minX, maxX = math.huge, -math.huge
local minZ, maxZ = math.huge, -math.huge

for _, part in pairs(stage2Area:GetChildren()) do
	if part:IsA("BasePart") then
		local pos = part.Position
		local size = part.Size

		minX = math.min(minX, pos.X - size.X/2)
		maxX = math.max(maxX, pos.X + size.X/2)
		minZ = math.min(minZ, pos.Z - size.Z/2)
		maxZ = math.max(maxZ, pos.Z + size.Z/2)
	end
end

local centerX = (minX + maxX) / 2
local centerZ = (minZ + maxZ) / 2
local centerPosition = Vector3.new(centerX, hrp.Position.Y, centerZ)

print("[NoobAI] Stage2 center:", centerPosition)

-- =========================
-- CONFIG
-- =========================
local CHASE_SPEED = 28
local RETURN_SPEED = 16
local DETECTION_RANGE = 200
local CHASE_UPDATE_RATE = 0.15

-- LASER
local LASER_ENABLED = true
local LASER_MIN_RANGE = 25
local LASER_MAX_RANGE = 160
local LASER_COOLDOWN_MIN = 6
local LASER_COOLDOWN_MAX = 10
local LASER_WINDUP_TIME = 0.4
local LASER_BEAM_DURATION = 0.2
local LASER_SLOW_DURATION = 0.5
local LASER_SLOW_MULTIPLIER = 0.2  -- 20% da velocidade (BEM LENTO)
local LASER_CHANCE_PER_TICK = 0.22

-- TAUNT
local TAUNT_DURATION = 1.5

-- =========================
-- ANIMATIONS
-- =========================
humanoid.WalkSpeed = CHASE_SPEED

local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

-- Walk
local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://180426354"
local walkTrack = animator:LoadAnimation(walkAnim)
walkTrack.Looped = true
walkTrack.Priority = Enum.AnimationPriority.Movement

-- 💃 Dance (random após kill)
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

-- 🧘 Meditation (idle)
local meditateAnim = Instance.new("Animation")
meditateAnim.AnimationId = "rbxassetid://2510196951"
local meditateTrack = animator:LoadAnimation(meditateAnim)
meditateTrack.Looped = true
meditateTrack.Priority = Enum.AnimationPriority.Idle

local isWalking = false
local isTaunting = false
local isMeditating = false

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
-- HELPER FUNCTIONS (do BKP)
-- =========================
local function isInBounds(position)
	return position.X >= minX and position.X <= maxX and position.Z >= minZ and position.Z <= maxZ
end

local function clampToBounds(position)
	local x = math.clamp(position.X, minX + 5, maxX - 5)
	local z = math.clamp(position.Z, minZ + 5, maxZ - 5)
	return Vector3.new(x, position.Y, z)
end

local function isPlayerInStage2(player)
	local character = player.Character
	if not character then return false end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return false end

	return isInBounds(playerHrp.Position)
end

local function getNearestPlayer()
	local nearestPlayer = nil
	local nearestDist = DETECTION_RANGE

	for _, player in pairs(Players:GetPlayers()) do
		if isPlayerInStage2(player) then
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
-- ANIMATION CONTROL
-- =========================
local function startWalking()
	if not isWalking and not isTaunting and not isMeditating then
		walkTrack:Play()
		isWalking = true
	end
end

local function stopWalking()
	if isWalking then
		walkTrack:Stop()
		isWalking = false
	end
end

local function startMeditating()
	if not isMeditating and not isTaunting and not isWalking then
		print("[NoobAI] 🧘 Starting meditation...")
		if meditateTrack and meditateTrack.Length > 0 then
			meditateTrack:Play()
		end
		isMeditating = true
		humanoid:MoveTo(hrp.Position)
	elseif isMeditating and meditateTrack and not meditateTrack.IsPlaying then
		-- Fix: Se meditation track parou mas flag ainda está true, reinicia
		print("[NoobAI] 🔄 Meditation track stopped, restarting...")
		meditateTrack:Play()
	end
end

local function stopMeditating()
	if isMeditating then
		print("[NoobAI] 🧘 Stopping meditation...")
		meditateTrack:Stop()
		isMeditating = false
	end
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
	if not isInBounds(targetHrp.Position) then return end

	local dist = (targetHrp.Position - hrp.Position).Magnitude
	if dist < LASER_MIN_RANGE or dist > LASER_MAX_RANGE then return end

	isChargingLaser = true
	lastLaserFiredAt = os.clock()
	refreshLaserCooldown()

	local oldSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = math.max(10, RETURN_SPEED)

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

	laserAnchor.Position = clampToBounds(hitPos)
	laserBeam.Enabled = true

	-- 🐌 LASER DEIXA PLAYER LENTO (não mata)
	if hitHumanoid and hitHumanoid.Health > 0 then
		local originalSpeed = hitHumanoid.WalkSpeed
		hitHumanoid.WalkSpeed = originalSpeed * LASER_SLOW_MULTIPLIER

		print("[NoobAI] Laser hit! Slowing player for " .. LASER_SLOW_DURATION .. "s")

		-- 🎨 Dispara efeito visual no cliente
		local player = Players:GetPlayerFromCharacter(hitHumanoid.Parent)
		if player then
			NpcLaserSlowEffect:FireClient(player, LASER_SLOW_DURATION)
		end

		-- Restaura velocidade
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
-- DANCE (após kill)
-- =========================
local function doVictoryTaunt()
	if isTaunting then
		print("[NoobAI] ⚠️ Already taunting, skipping...")
		return
	end

	isTaunting = true
	print("[NoobAI] 💃 STARTING VICTORY TAUNT!")

	-- Para tudo primeiro
	stopWalking()
	stopMeditating()
	humanoid:MoveTo(hrp.Position)
	humanoid.WalkSpeed = 0  -- ✅ Congela completamente

	-- Escolhe dança aleatória
	local randomIndex = math.random(1, #DANCE_ANIMATIONS)
	local randomDanceId = DANCE_ANIMATIONS[randomIndex]
	print("[NoobAI] 💃 Dance #" .. randomIndex .. ": " .. randomDanceId)

	-- Cria e carrega animação
	local danceAnim = Instance.new("Animation")
	danceAnim.AnimationId = randomDanceId

	if currentDanceTrack then
		currentDanceTrack:Stop()
		currentDanceTrack:Destroy()
	end

	local success, err = pcall(function()
		currentDanceTrack = animator:LoadAnimation(danceAnim)
		currentDanceTrack.Looped = false
		currentDanceTrack.Priority = Enum.AnimationPriority.Action4
		currentDanceTrack:Play()
		print("[NoobAI] ✅ Dance animation playing!")
	end)

	if not success then
		warn("[NoobAI] ❌ Failed to play dance: " .. tostring(err))
	end

	-- Volta ao normal após duração
	task.delay(TAUNT_DURATION, function()
		print("[NoobAI] 💃 Taunt finished! Returning to normal...")

		if currentDanceTrack then
			currentDanceTrack:Stop()
		end

		humanoid.WalkSpeed = CHASE_SPEED  -- ✅ Restaura velocidade
		isTaunting = false
	end)
end

-- =========================
-- CHASE & RETURN (do BKP)
-- =========================
local function chasePlayer(player)
	local character = player.Character
	if not character then return end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return end

	stopMeditating()

	local targetPos = clampToBounds(playerHrp.Position)

	humanoid.WalkSpeed = CHASE_SPEED
	humanoid:MoveTo(targetPos)
	startWalking()

	-- Laser chance
	if not isChargingLaser and canFireLaser() then
		local d = (playerHrp.Position - hrp.Position).Magnitude
		if d >= LASER_MIN_RANGE and d <= LASER_MAX_RANGE then
			if math.random() < LASER_CHANCE_PER_TICK then
				task.spawn(function()
					fireLaser(playerHrp)
				end)
			end
		end
	end
end

local function returnToCenter()
	local dist = (hrp.Position - centerPosition).Magnitude

	if dist > 10 then  -- ✅ Aumentei de 5 para 10 (zona morta maior)
		stopMeditating()
		humanoid.WalkSpeed = RETURN_SPEED
		humanoid:MoveTo(centerPosition)
		startWalking()
	else
		-- ✅ Só para de andar se estava andando
		if isWalking then
			humanoid:MoveTo(hrp.Position)
			stopWalking()
		end

		-- ✅ Só inicia meditação se NÃO está meditando
		if not isMeditating then
			startMeditating()
		end
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
					playerHumanoid.Health = 0
					print("[NoobAI] Killed " .. player.Name .. "!")

					-- 🎵 Notifica cliente (Vine Boom)
					NpcKillPlayerEvent:FireClient(player)

					-- 💃 Dança após matar
					task.spawn(function()
						task.wait(0.1)
						doVictoryTaunt()
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
	if not isInBounds(hrp.Position) then
		local clampedPos = clampToBounds(hrp.Position)
		hrp.CFrame = CFrame.new(clampedPos.X, hrp.Position.Y, clampedPos.Z)
	end
end)

-- =========================
-- MAIN LOOP
-- =========================
while true do
	if not isTaunting then
		local target = getNearestPlayer()

		if target then
			chasePlayer(target)
		else
			returnToCenter()
		end
	end

	task.wait(CHASE_UPDATE_RATE)
end
