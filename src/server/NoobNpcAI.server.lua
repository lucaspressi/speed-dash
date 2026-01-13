local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local noob = workspace:WaitForChild("Buff Noob")
local humanoid = noob:WaitForChild("Humanoid")
local hrp = noob:WaitForChild("HumanoidRootPart")
local head = noob:WaitForChild("Head")

-- Get Stage2NpcKill bounds
local stage2Area = workspace:WaitForChild("Stage2NpcKill")

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

-- Calculate center of Stage2
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

-- ✅ Margem interna pra NÃO encostar no divisor perto do limite
-- Aumente se ainda quebrar: 20 / 25 / 30
local EDGE_BUFFER = 25

-- LASER
local LASER_ENABLED = true
local LASER_MIN_RANGE = 25
local LASER_MAX_RANGE = 160
local LASER_COOLDOWN_MIN = 6
local LASER_COOLDOWN_MAX = 10
local LASER_WINDUP_TIME = 0.4
local LASER_BEAM_DURATION = 0.2
local LASER_DAMAGE = 100
local LASER_CHANCE_PER_TICK = 0.22

-- FOV/LOS (pro laser ficar “AI” e não atravessar parede)
local FOV_DEGREES = 90
local FOV_COS = math.cos(math.rad(FOV_DEGREES/2))

-- =========================
-- Animation
-- =========================
humanoid.WalkSpeed = CHASE_SPEED

local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://180426354"

local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

local walkTrack = animator:LoadAnimation(walkAnim)
walkTrack.Looped = true
walkTrack.Priority = Enum.AnimationPriority.Movement

local isWalking = false

local function startWalking()
	if not isWalking then
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

-- =========================
-- Bounds helpers
-- =========================
local function isInRealBounds(position: Vector3)
	return position.X >= minX and position.X <= maxX and position.Z >= minZ and position.Z <= maxZ
end

-- ✅ área permitida (com margem interna)
local function isInAllowedBounds(position: Vector3)
	return position.X >= (minX + EDGE_BUFFER) and position.X <= (maxX - EDGE_BUFFER)
	   and position.Z >= (minZ + EDGE_BUFFER) and position.Z <= (maxZ - EDGE_BUFFER)
end

local function clampToAllowedBounds(position: Vector3)
	local x = math.clamp(position.X, minX + EDGE_BUFFER, maxX - EDGE_BUFFER)
	local z = math.clamp(position.Z, minZ + EDGE_BUFFER, maxZ - EDGE_BUFFER)
	return Vector3.new(x, position.Y, z)
end

-- =========================
-- Perception helpers (FOV + LOS)
-- =========================
local function inFOV(targetPos: Vector3)
	local forward = hrp.CFrame.LookVector
	local dir = (targetPos - hrp.Position)
	if dir.Magnitude < 0.001 then return true end
	dir = dir.Unit
	return forward:Dot(dir) >= FOV_COS
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { noob }
rayParams.IgnoreWater = true

local function hasLineOfSight(targetHrp: BasePart)
	local origin = hrp.Position + Vector3.new(0, 2.5, 0)
	local target = targetHrp.Position + Vector3.new(0, 2.0, 0)
	local direction = (target - origin)
	local result = workspace:Raycast(origin, direction, rayParams)
	if not result then return true end
	local hitInst = result.Instance
	return hitInst and hitInst:IsDescendantOf(targetHrp.Parent)
end

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

local function refreshLaserCooldown()
	laserCooldown = math.random(LASER_COOLDOWN_MIN * 10, LASER_COOLDOWN_MAX * 10) / 10
end

local function aimAtTarget(targetPos: Vector3, duration: number)
	local flat = (targetPos - hrp.Position) * Vector3.new(1, 0, 1)
	if flat.Magnitude < 0.1 then return end
	local targetCFrame = CFrame.new(hrp.Position, hrp.Position + flat)

	TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	}):Play()
end

local function canFireLaser()
	return LASER_ENABLED and not isChargingLaser and (os.clock() - lastLaserFiredAt) >= laserCooldown
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

local function fireLaser(targetHrp: BasePart)
	if not canFireLaser() then return end
	if not targetHrp or not targetHrp.Parent then return end

	-- ✅ Só usa laser se player estiver dentro da área permitida
	if not isInAllowedBounds(targetHrp.Position) then return end

	local dist = (targetHrp.Position - hrp.Position).Magnitude
	if dist < LASER_MIN_RANGE or dist > LASER_MAX_RANGE then return end
	if not inFOV(targetHrp.Position) then return end
	if not hasLineOfSight(targetHrp) then return end

	isChargingLaser = true
	lastLaserFiredAt = os.clock()
	refreshLaserCooldown()

	-- Não congela: só reduz um pouco
	local oldSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = math.max(10, RETURN_SPEED)

	aimAtTarget(targetHrp.Position, LASER_WINDUP_TIME * 0.6)
	showLaserTelegraph()

	task.wait(LASER_WINDUP_TIME)

	-- Revalida
	if not targetHrp.Parent or not hasLineOfSight(targetHrp) or not isInAllowedBounds(targetHrp.Position) then
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

	-- ✅ endpoint clamped pra não mirar na borda
	laserAnchor.Position = clampToAllowedBounds(hitPos)
	laserBeam.Enabled = true

	if hitHumanoid and hitHumanoid.Health > 0 then
		hitHumanoid:TakeDamage(LASER_DAMAGE)
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
-- Original functions (simple)
-- =========================
local function isPlayerInStage2(player)
	local character = player.Character
	if not character then return false end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return false end

	-- ✅ Agora o "pode atacar" é só dentro do allowed
	return isInAllowedBounds(playerHrp.Position)
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

local function chasePlayer(player)
	local character = player.Character
	if not character then return end

	local playerHrp = character:FindFirstChild("HumanoidRootPart")
	if not playerHrp then return end

	-- ✅ clamp sempre pro allowed (não encosta divisor)
	local targetPos = clampToAllowedBounds(playerHrp.Position)

	humanoid.WalkSpeed = CHASE_SPEED
	humanoid:MoveTo(targetPos)
	startWalking()

	-- Laser chance durante chase (sem travar o movimento)
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

	if dist > 5 then
		humanoid.WalkSpeed = RETURN_SPEED
		humanoid:MoveTo(clampToAllowedBounds(centerPosition))
		startWalking()
	else
		humanoid:MoveTo(hrp.Position)
		stopWalking()
	end
end

-- Kill player on touch (mantém simples)
for _, part in pairs(noob:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)

			if player then
				-- ✅ SAFE: se player está fora do allowed, não morre
				local cHrp = character and character:FindFirstChild("HumanoidRootPart")
				if cHrp and (not isInAllowedBounds(cHrp.Position)) then
					return
				end

				local playerHumanoid = character:FindFirstChild("Humanoid")
				if playerHumanoid and playerHumanoid.Health > 0 then
					playerHumanoid.Health = 0
				end
			end
		end)
	end
end

-- Keep NPC in bounds (agora empurra pra dentro do allowed sempre)
RunService.Heartbeat:Connect(function()
	-- se saiu do real bounds, traz pra dentro
	if not isInRealBounds(hrp.Position) then
		local clampedPos = clampToAllowedBounds(hrp.Position)
		hrp.CFrame = CFrame.new(clampedPos.X, hrp.Position.Y, clampedPos.Z)
		return
	end

	-- se chegou perto do limite (fora do allowed), empurra pra dentro também
	if not isInAllowedBounds(hrp.Position) then
		local clampedPos = clampToAllowedBounds(hrp.Position)
		hrp.CFrame = CFrame.new(clampedPos.X, hrp.Position.Y, clampedPos.Z)
	end
end)

-- Main chase loop
while true do
	local target = getNearestPlayer()

	if target then
		chasePlayer(target)
	else
		returnToCenter()
	end

	task.wait(CHASE_UPDATE_RATE)
end
