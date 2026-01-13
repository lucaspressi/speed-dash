local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

-- NPC refs
local noob = workspace:WaitForChild("Buff Noob")
local humanoid = noob:WaitForChild("Humanoid")
local hrp = noob:WaitForChild("HumanoidRootPart")
local head = noob:WaitForChild("Head")

-- Stage2 bounds
local stage2Area = workspace:WaitForChild("Stage2NpcKill")

local minX, maxX = math.huge, -math.huge
local minZ, maxZ = math.huge, -math.huge

for _, part in pairs(stage2Area:GetChildren()) do
	if part:IsA("BasePart") then
		local pos = part.Position
		local size = part.Size
		minX = math.min(minX, pos.X - size.X / 2)
		maxX = math.max(maxX, pos.X + size.X / 2)
		minZ = math.min(minZ, pos.Z - size.Z / 2)
		maxZ = math.max(maxZ, pos.Z + size.Z / 2)
	end
end

local centerX = (minX + maxX) / 2
local centerZ = (minZ + maxZ) / 2
local centerPosition = Vector3.new(centerX, hrp.Position.Y, centerZ)

print("[NoobAI] Stage2 center:", centerPosition)

-- ==========================
-- CONFIG - MOVEMENT & AI
-- ==========================
local CHASE_SPEED = 28
local RETURN_SPEED = 16
local PATROL_SPEED = 14
local INVESTIGATE_SPEED = 18

local DETECTION_RANGE = 200
local ATTENTION_SPAN = 3.5          -- quanto tempo "lembra" do alvo após perder LOS
local SEARCH_DURATION = 5.0         -- tempo de busca após investigar
local DECISION_RATE = 0.15          -- intervalo das decisões

local FOV_DEGREES = 90              -- cone de visão (tune aqui para aumentar/diminuir campo de visão)
local FOV_COS = math.cos(math.rad(FOV_DEGREES / 2))

local REPATH_COOLDOWN = 0.5         -- frequência para recalcular path
local TARGET_MOVE_THRESHOLD = 10    -- recalcula path se alvo "andou muito"

local CLAMP_PADDING = 6             -- evita encostar na borda do bounds
local REACH_DIST = 6                -- considera "chegou" no ponto

-- ==========================
-- CONFIG - EYE LASER
-- ==========================
local LASER_ENABLED = true          -- ativar/desativar laser
local LASER_MIN_RANGE = 25          -- distância mínima para usar laser (studs)
local LASER_MAX_RANGE = 160         -- distância máxima do laser (studs)
local LASER_COOLDOWN_MIN = 6        -- cooldown mínimo (segundos)
local LASER_COOLDOWN_MAX = 10       -- cooldown máximo (segundos)
local LASER_WINDUP_TIME = 0.4       -- tempo de "carregamento" antes de disparar (telegraph)
local LASER_BEAM_DURATION = 0.2     -- tempo que o beam fica visível após disparar
local LASER_DAMAGE = 100            -- dano do laser (100 = insta-kill)

-- ==========================
-- ANIMAÇÃO (se quiser manter)
-- ==========================
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

-- ==========================
-- LASER SETUP
-- ==========================
-- Criar attachment no olho (Head) se não existir
local eyeAttachment = head:FindFirstChild("EyeLaserAttachment")
if not eyeAttachment then
	eyeAttachment = Instance.new("Attachment")
	eyeAttachment.Name = "EyeLaserAttachment"
	-- Ajuste a posição do olho aqui (X, Y, Z)
	eyeAttachment.Position = Vector3.new(0, 0.2, -0.6) -- Frente do rosto
	eyeAttachment.Parent = head
end

-- Criar anchor (invisível) para o laser endpoint
local laserAnchor = Instance.new("Part")
laserAnchor.Name = "LaserAnchor"
laserAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
laserAnchor.Transparency = 1
laserAnchor.CanCollide = false
laserAnchor.Anchored = true
laserAnchor.Parent = workspace

local laserAnchorAttachment = Instance.new("Attachment")
laserAnchorAttachment.Name = "LaserAnchorAttachment"
laserAnchorAttachment.Parent = laserAnchor

-- Criar Beam visual
local laserBeam = Instance.new("Beam")
laserBeam.Name = "EyeLaserBeam"
laserBeam.Attachment0 = eyeAttachment
laserBeam.Attachment1 = laserAnchorAttachment
laserBeam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Vermelho
laserBeam.Brightness = 3
laserBeam.Width0 = 0.3
laserBeam.Width1 = 0.3
laserBeam.FaceCamera = true
laserBeam.Transparency = NumberSequence.new(0)
laserBeam.Enabled = false
laserBeam.Parent = head

-- Efeito de telegraph (carregamento) - pequena luz vermelha
local telegraphLight = Instance.new("PointLight")
telegraphLight.Name = "LaserTelegraphLight"
telegraphLight.Color = Color3.fromRGB(255, 0, 0)
telegraphLight.Brightness = 0
telegraphLight.Range = 12
telegraphLight.Parent = head

-- Estado do laser
local lastLaserTime = 0
local isChargingLaser = false

-- ==========================
-- HELPERS
-- ==========================
local function isInBounds(position: Vector3)
	return position.X >= minX and position.X <= maxX and position.Z >= minZ and position.Z <= maxZ
end

local function clampToBounds(position: Vector3)
	local x = math.clamp(position.X, minX + CLAMP_PADDING, maxX - CLAMP_PADDING)
	local z = math.clamp(position.Z, minZ + CLAMP_PADDING, maxZ - CLAMP_PADDING)
	return Vector3.new(x, position.Y, z)
end

local function getCharacterHrp(player: Player)
	local char = player.Character
	if not char then return nil end
	local pHrp = char:FindFirstChild("HumanoidRootPart")
	local pHum = char:FindFirstChild("Humanoid")
	if not pHrp or not pHum or pHum.Health <= 0 then return nil end
	return pHrp
end

local function isPlayerInStage2(player: Player)
	local pHrp = getCharacterHrp(player)
	if not pHrp then return false end
	return isInBounds(pHrp.Position)
end

-- FOV check: target must be in front cone
local function inFOV(targetPos: Vector3)
	local forward = hrp.CFrame.LookVector
	local dir = (targetPos - hrp.Position)
	if dir.Magnitude < 0.001 then return true end
	dir = dir.Unit
	return forward:Dot(dir) >= FOV_COS
end

-- LOS: raycast, ignore NPC model
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { noob }
rayParams.IgnoreWater = true

local function hasLineOfSight(targetHrp: BasePart)
	local origin = hrp.Position + Vector3.new(0, 2.5, 0)
	local target = targetHrp.Position + Vector3.new(0, 2.0, 0)
	local direction = (target - origin)
	local result = workspace:Raycast(origin, direction, rayParams)

	-- Sem hit = livre
	if not result then return true end

	-- Se bateu no próprio character do player, considera LOS ok
	local hitInst = result.Instance
	if hitInst and hitInst:IsDescendantOf(targetHrp.Parent) then
		return true
	end

	return false
end

-- Random point inside bounds + raycast ground
local function randomPointInBounds()
	local x = math.random() * (maxX - minX) + minX
	local z = math.random() * (maxZ - minZ) + minZ
	local y = hrp.Position.Y + 50

	local origin = Vector3.new(x, y, z)
	local direction = Vector3.new(0, -200, 0)
	local result = workspace:Raycast(origin, direction, rayParams)

	if result then
		return clampToBounds(Vector3.new(x, result.Position.Y, z))
	end

	return clampToBounds(Vector3.new(x, hrp.Position.Y, z))
end

-- Local search point near lastSeen
local function randomNear(position: Vector3, radius: number)
	local angle = math.random() * math.pi * 2
	local r = math.random() * radius
	local x = position.X + math.cos(angle) * r
	local z = position.Z + math.sin(angle) * r
	local y = hrp.Position.Y + 50

	local origin = Vector3.new(x, y, z)
	local result = workspace:Raycast(origin, Vector3.new(0, -200, 0), rayParams)
	if result then
		return clampToBounds(Vector3.new(x, result.Position.Y, z))
	end
	return clampToBounds(Vector3.new(x, hrp.Position.Y, z))
end

-- ==========================
-- LASER FUNCTIONS
-- ==========================
-- Mira suave na direção do alvo (LookAt)
local function aimAtTarget(targetPos: Vector3, duration: number)
	local direction = (targetPos - hrp.Position) * Vector3.new(1, 0, 1) -- ignora Y
	if direction.Magnitude < 0.1 then return end

	local targetCFrame = CFrame.new(hrp.Position, hrp.Position + direction)

	-- Tween suave para "mirar"
	local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCFrame
	})
	tween:Play()
end

-- Telegraph (carregamento) visual
local function showLaserTelegraph()
	isChargingLaser = true
	telegraphLight.Brightness = 5

	-- Piscar a luz durante o carregamento
	task.spawn(function()
		local elapsed = 0
		while elapsed < LASER_WINDUP_TIME and isChargingLaser do
			telegraphLight.Brightness = 5 + math.sin(elapsed * 30) * 2
			task.wait(0.05)
			elapsed += 0.05
		end
		telegraphLight.Brightness = 0
	end)
end

-- Disparar laser
local function fireLaser(targetHrp: BasePart)
	if not LASER_ENABLED then return end
	if isChargingLaser then return end

	local now = os.clock()
	local dist = (targetHrp.Position - hrp.Position).Magnitude

	-- Verifica range
	if dist < LASER_MIN_RANGE or dist > LASER_MAX_RANGE then return end

	-- Verifica cooldown
	local nextLaserTime = lastLaserTime + math.random(LASER_COOLDOWN_MIN * 10, LASER_COOLDOWN_MAX * 10) / 10
	if now < nextLaserTime then return end

	-- Verifica LOS
	if not hasLineOfSight(targetHrp) then return end

	print("[NoobAI] Charging laser...")

	-- Marca como carregando ANTES de parar
	isChargingLaser = true

	-- Para de andar durante o laser
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	stopWalking()

	-- Mira no alvo
	aimAtTarget(targetHrp.Position, LASER_WINDUP_TIME * 0.5)

	-- Telegraph
	showLaserTelegraph()

	-- Aguarda windup
	task.wait(LASER_WINDUP_TIME)

	-- SEMPRE reseta flag e speed (mesmo se cancelar)
	local function cleanup()
		isChargingLaser = false
		humanoid.WalkSpeed = CHASE_SPEED
		print("[NoobAI] Laser cleanup - speed restored to", humanoid.WalkSpeed)
	end

	-- Verifica se ainda tem LOS após windup
	if not targetHrp.Parent or not hasLineOfSight(targetHrp) then
		print("[NoobAI] Laser cancelled - lost LOS during windup")
		cleanup()
		return
	end

	-- DISPARA O LASER
	local origin = eyeAttachment.WorldPosition
	local targetPos = targetHrp.Position + Vector3.new(0, 1.5, 0) -- Mira no torso
	local direction = (targetPos - origin)

	-- Raycast para encontrar o que acerta
	local laserRayParams = RaycastParams.new()
	laserRayParams.FilterType = Enum.RaycastFilterType.Exclude
	laserRayParams.FilterDescendantsInstances = { noob, laserAnchor }
	laserRayParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, laserRayParams)

	local hitPos = targetPos
	local hitHumanoid = nil

	if result then
		hitPos = result.Position

		-- Verifica se acertou um character
		local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
		if hitChar then
			hitHumanoid = hitChar:FindFirstChildOfClass("Humanoid")
		end
	end

	-- Posiciona o anchor no ponto de impacto
	laserAnchor.Position = hitPos

	-- Ativa o beam visual
	laserBeam.Enabled = true

	print("[NoobAI] Laser fired! Hit:", hitHumanoid and "Player" or "Terrain")

	-- Aplica dano se acertou
	if hitHumanoid and hitHumanoid.Health > 0 then
		hitHumanoid:TakeDamage(LASER_DAMAGE)
		print("[NoobAI] Laser hit player for", LASER_DAMAGE, "damage")
	end

	-- Desativa beam após curta duração
	task.delay(LASER_BEAM_DURATION, function()
		laserBeam.Enabled = false
	end)

	-- Atualiza cooldown
	lastLaserTime = now

	-- Volta a andar após um pequeno delay
	task.wait(0.2)
	cleanup()
end

-- ==========================
-- PATHFOLLOW (simples)
-- ==========================
local currentPath = nil
local currentWaypoints = nil
local waypointIndex = 0
local lastPathCompute = 0
local lastTargetForPath = nil

local function clearPath()
	currentPath = nil
	currentWaypoints = nil
	waypointIndex = 0
end

local function computePathTo(targetPos: Vector3)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 8,
		AgentMaxSlope = 35,
	})

	targetPos = clampToBounds(targetPos)
	path:ComputeAsync(hrp.Position, targetPos)

	if path.Status == Enum.PathStatus.Success then
		currentPath = path
		currentWaypoints = path:GetWaypoints()
		waypointIndex = 1
		return true
	end

	clearPath()
	return false
end

local function stepAlongPath()
	if not currentWaypoints or waypointIndex > #currentWaypoints then
		return false
	end

	local wp = currentWaypoints[waypointIndex]
	if wp.Action == Enum.PathWaypointAction.Jump then
		humanoid.Jump = true
	end

	humanoid:MoveTo(wp.Position)
	startWalking()

	-- avança waypoint quando estiver perto
	if (hrp.Position - wp.Position).Magnitude <= REACH_DIST then
		waypointIndex += 1
	end

	return true
end

-- ==========================
-- TARGET SELECTION (com FOV+LOS)
-- ==========================
local function getBestTarget()
	local bestPlayer = nil
	local bestDist = DETECTION_RANGE

	for _, player in pairs(Players:GetPlayers()) do
		if isPlayerInStage2(player) then
			local pHrp = getCharacterHrp(player)
			if pHrp then
				local dist = (pHrp.Position - hrp.Position).Magnitude
				if dist < bestDist then
					-- FOV first (mais real)
					if inFOV(pHrp.Position) then
						-- LOS
						if hasLineOfSight(pHrp) then
							bestDist = dist
							bestPlayer = player
						end
					end
				end
			end
		end
	end

	return bestPlayer, bestDist
end

-- ==========================
-- FSM
-- ==========================
local State = {
	IDLE = "IDLE",
	PATROL = "PATROL",
	CHASE = "CHASE",
	INVESTIGATE = "INVESTIGATE",
	SEARCH = "SEARCH",
	RETURN = "RETURN",
}

local state = State.PATROL
local stateUntil = 0

local targetPlayer: Player? = nil
local lastSeenPos: Vector3? = nil
local lastSeenTime = 0

local patrolGoal: Vector3? = nil
local searchGoal: Vector3? = nil

local function setState(newState: string, duration: number?)
	state = newState
	if duration then
		stateUntil = os.clock() + duration
	else
		stateUntil = 0
	end
	print("[NoobAI] State ->", state)
end

-- ==========================
-- MOVEMENT ACTIONS
-- ==========================
local function moveToSimple(pos: Vector3, speed: number)
	humanoid.WalkSpeed = speed
	pos = clampToBounds(pos)
	humanoid:MoveTo(pos)
	startWalking()
end

local function moveToWithPath(pos: Vector3, speed: number)
	humanoid.WalkSpeed = speed
	local now = os.clock()

	-- evita recalcular path toda hora
	local needRepath = false
	if (now - lastPathCompute) >= REPATH_COOLDOWN then
		needRepath = true
	end

	if lastTargetForPath and (pos - lastTargetForPath).Magnitude >= TARGET_MOVE_THRESHOLD then
		needRepath = true
	end

	if needRepath or not currentWaypoints then
		lastPathCompute = now
		lastTargetForPath = pos
		local ok = computePathTo(pos)
		if not ok then
			-- fallback
			moveToSimple(pos, speed)
			return
		end
	end

	-- segue path
	local ok = stepAlongPath()
	if not ok then
		-- fallback
		moveToSimple(pos, speed)
	end
end

-- ==========================
-- INSTAKILL TOUCH (mantido) + debounce
-- ==========================
local killDebounceByUserId = {}

local function tryKillFromHit(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	-- debounce por player (evita spam)
	local now = os.clock()
	local last = killDebounceByUserId[player.UserId]
	if last and (now - last) < 0.2 then return end
	killDebounceByUserId[player.UserId] = now

	hum.Health = 0
	print("[NoobAI] Touch kill:", player.Name)
end

for _, part in pairs(noob:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			if character and character:IsA("Model") then
				tryKillFromHit(character)
			end
		end)
	end
end

-- Keep NPC in bounds hard clamp (anti-bug) + safety checks
RunService.Heartbeat:Connect(function()
	-- Garante que HRP nunca está anchored (bug fix comum)
	if hrp.Anchored then
		hrp.Anchored = false
		warn("[NoobAI] HRP was anchored! Fixed.")
	end

	-- Garante que WalkSpeed nunca fica em 0 fora do laser
	if not isChargingLaser and humanoid.WalkSpeed == 0 then
		humanoid.WalkSpeed = PATROL_SPEED
		warn("[NoobAI] WalkSpeed was 0! Reset to", PATROL_SPEED)
	end

	-- Bounds clamp
	if not isInBounds(hrp.Position) then
		local clamped = clampToBounds(hrp.Position)
		hrp.CFrame = CFrame.new(clamped.X, hrp.Position.Y, clamped.Z)
		clearPath()
	end
end)

-- ==========================
-- MAIN BRAIN LOOP
-- ==========================
local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc < DECISION_RATE then
		-- continua andando no path mesmo entre decisões
		if state == State.CHASE and currentWaypoints then
			stepAlongPath()
		end
		return
	end
	acc = 0

	local now = os.clock()

	-- 1) tenta adquirir alvo
	local best, dist = getBestTarget()
	if best then
		targetPlayer = best
		local pHrp = getCharacterHrp(best)
		if pHrp then
			lastSeenPos = pHrp.Position
			lastSeenTime = now
		end
		if state ~= State.CHASE then
			setState(State.CHASE)
		end
	end

	-- 2) lógica por estado
	if state == State.CHASE then
		if not targetPlayer then
			-- sem alvo: investiga última visão se tiver
			if lastSeenPos and (now - lastSeenTime) <= ATTENTION_SPAN then
				setState(State.INVESTIGATE)
			else
				setState(State.PATROL)
			end
			clearPath()
			return
		end

		local pHrp = getCharacterHrp(targetPlayer)
		if not pHrp or not isInBounds(pHrp.Position) then
			-- perdeu o alvo ou saiu da área
			targetPlayer = nil
			clearPath()

			if lastSeenPos and (now - lastSeenTime) <= ATTENTION_SPAN then
				setState(State.INVESTIGATE)
			else
				setState(State.PATROL)
			end
			return
		end

		-- se ainda está em bounds: valida LOS/FOV, senão "perde" mas mantém memória
		if inFOV(pHrp.Position) and hasLineOfSight(pHrp) then
			lastSeenPos = pHrp.Position
			lastSeenTime = now

			-- TENTA USAR LASER (se estiver em range e cooldown ok)
			if not isChargingLaser then
				local distToTarget = (pHrp.Position - hrp.Position).Magnitude
				if distToTarget >= LASER_MIN_RANGE and distToTarget <= LASER_MAX_RANGE then
					-- Chance aleatória de usar laser (30% por decisão, aproximadamente)
					if math.random() < 0.3 then
						task.spawn(function()
							fireLaser(pHrp)
						end)
					end
				end
			end
		else
			-- mantém chase por um tempinho baseado em memória
			if (now - lastSeenTime) > ATTENTION_SPAN then
				targetPlayer = nil
				clearPath()
				setState(State.INVESTIGATE)
				return
			end
		end

		-- chase com pathfinding (só se não estiver carregando laser)
		if not isChargingLaser then
			-- Se o path está vazio ou bugou, tenta MoveTo direto
			if not currentWaypoints or #currentWaypoints == 0 then
				moveToSimple(pHrp.Position, CHASE_SPEED)
			else
				moveToWithPath(pHrp.Position, CHASE_SPEED)
			end
		end
		return
	end

	if state == State.INVESTIGATE then
		targetPlayer = nil

		if not lastSeenPos then
			setState(State.PATROL)
			return
		end

		local goal = clampToBounds(lastSeenPos)
		moveToWithPath(goal, INVESTIGATE_SPEED)

		-- chegou perto do lastSeenPos -> SEARCH por alguns segundos
		if (hrp.Position - goal).Magnitude <= REACH_DIST + 2 then
			searchGoal = nil
			setState(State.SEARCH, SEARCH_DURATION)
			clearPath()
		end
		return
	end

	if state == State.SEARCH then
		targetPlayer = nil

		-- se encontrou target durante search, o topo do loop já muda pra CHASE
		if stateUntil > 0 and now > stateUntil then
			lastSeenPos = nil
			searchGoal = nil
			setState(State.PATROL)
			clearPath()
			return
		end

		-- escolhe pontos perto do lastSeenPos pra "procurar"
		if not lastSeenPos then
			setState(State.PATROL)
			return
		end

		if not searchGoal or (hrp.Position - searchGoal).Magnitude <= REACH_DIST then
			searchGoal = randomNear(lastSeenPos, 35)
			clearPath()
		end

		moveToWithPath(searchGoal, PATROL_SPEED)
		return
	end

	if state == State.PATROL then
		targetPlayer = nil
		lastSeenPos = nil

		if not patrolGoal or (hrp.Position - patrolGoal).Magnitude <= REACH_DIST then
			patrolGoal = randomPointInBounds()
			clearPath()
			-- pequena pausa "humana"
			setState(State.IDLE, math.random(6, 14) / 10) -- 0.6 a 1.4s
			stopWalking()
			return
		end

		moveToWithPath(patrolGoal, PATROL_SPEED)
		return
	end

	if state == State.IDLE then
		targetPlayer = nil

		if stateUntil > 0 and now > stateUntil then
			setState(State.PATROL)
		else
			stopWalking()
		end
		return
	end

	if state == State.RETURN then
		targetPlayer = nil
		moveToWithPath(centerPosition, RETURN_SPEED)
		if (hrp.Position - centerPosition).Magnitude <= REACH_DIST then
			setState(State.PATROL)
		end
		return
	end
end)

print("[NoobAI] Buff Noob AI initialized with Eye Laser System!")
