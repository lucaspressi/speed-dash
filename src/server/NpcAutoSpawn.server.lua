-- NpcAutoSpawn.server.lua
-- Automatically creates "Buff Noob" NPC if it doesn't exist
-- This ensures NoobNpcAI can always find the NPC

local InsertService = game:GetService("InsertService")

print("[NpcAutoSpawn] Checking if Buff Noob exists...")

local existingNpc = workspace:FindFirstChild("Buff Noob")
if existingNpc then
	print("[NpcAutoSpawn] ✅ Buff Noob already exists")
	return
end

print("[NpcAutoSpawn] 🔄 Buff Noob not found - creating NPC...")

-- Create a basic NPC using Roblox's default character
local npc = game:GetService("Players"):CreateHumanoidModelFromDescription(
	Instance.new("HumanoidDescription"),
	Enum.HumanoidRigType.R15
)

-- Configure NPC
npc.Name = "Buff Noob"
npc.Parent = workspace

-- Position at NoobArena spawn
local arena = workspace:FindFirstChild("NoobArena")
if arena then
	local arenaBounds = arena:FindFirstChild("ArenaBounds")
	if arenaBounds then
		local spawnPos = arenaBounds.Position + Vector3.new(0, 20, 0)
		npc:MoveTo(spawnPos)
		print("[NpcAutoSpawn] ✅ NPC spawned at arena: " .. tostring(spawnPos))
	else
		npc:MoveTo(Vector3.new(0, 30, 100))
		print("[NpcAutoSpawn] ⚠️ Arena bounds not found, spawned at default")
	end
else
	npc:MoveTo(Vector3.new(0, 30, 100))
	print("[NpcAutoSpawn] ⚠️ Arena not found, spawned at default")
end

-- Configure Humanoid
local humanoid = npc:FindFirstChildOfClass("Humanoid")
if humanoid then
	humanoid.MaxHealth = 1000
	humanoid.Health = 1000
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 0
	humanoid.DisplayName = "Buff Noob"
	print("[NpcAutoSpawn] ✅ Humanoid configured: Health=1000, WalkSpeed=16")
end

-- Make all parts indestructible
for _, part in pairs(npc:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Anchored = false
		part.CanCollide = true
	end
end

-- Ensure HumanoidRootPart exists and is configured
local hrp = npc:FindFirstChild("HumanoidRootPart")
if hrp then
	hrp.Anchored = false
	hrp.CanCollide = true
	print("[NpcAutoSpawn] ✅ HumanoidRootPart configured")
end

print("[NpcAutoSpawn] ✅ Buff Noob created successfully!")
print("[NpcAutoSpawn] NoobNpcAI should now initialize properly")
