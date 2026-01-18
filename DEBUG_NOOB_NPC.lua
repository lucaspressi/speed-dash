-- DEBUG_NOOB_NPC.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Forces debug output from NoobNpcAI to see where it's stuck

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

print("🐛 ==================== DEBUG NOOB NPC ====================")
print("")

-- Check if NoobNpcAI.server.lua exists
local noobAIScript = ServerScriptService:FindFirstChild("NoobNpcAI")
if not noobAIScript then
	warn("❌ NoobNpcAI.server.lua NOT FOUND in ServerScriptService!")
	warn("   The script needs to be in ServerScriptService to run")
	return
end

print("✅ Found NoobNpcAI script: " .. noobAIScript.Name)
print("   Enabled: " .. tostring(noobAIScript.Enabled))
print("   ClassName: " .. noobAIScript.ClassName)
print("")

if not noobAIScript.Enabled then
	warn("❌ NoobNpcAI script is DISABLED!")
	warn("   Enable it in ServerScriptService")
	return
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check NPC
local noob = workspace:FindFirstChild("Buff Noob")
if not noob then
	warn("❌ 'Buff Noob' NPC not found!")
	return
end

print("✅ NPC found: " .. noob.Name)
print("")

-- Check components
local humanoid = noob:FindFirstChild("Humanoid")
local hrp = noob:FindFirstChild("HumanoidRootPart")
local head = noob:FindFirstChild("Head")

print("NPC Status:")
if humanoid then
	print("   Humanoid Health: " .. humanoid.Health)
	print("   Humanoid WalkSpeed: " .. humanoid.WalkSpeed)
	print("   Humanoid MoveDirection: " .. tostring(humanoid.MoveDirection))
else
	warn("   ❌ No Humanoid!")
end

if hrp then
	print("   HRP Position: " .. tostring(hrp.Position))
	print("   HRP Anchored: " .. tostring(hrp.Anchored))
	print("   HRP AssemblyLinearVelocity: " .. tostring(hrp.AssemblyLinearVelocity))
else
	warn("   ❌ No HumanoidRootPart!")
end

if head then
	-- Check for NoobNpcAI components
	local laserBeam = head:FindFirstChild("Beam")
	local pointLight = head:FindFirstChildOfClass("PointLight")
	local eyeAttachment = head:FindFirstChild("EyeLaserAttachment")

	print("   Head components:")
	print("      Beam: " .. tostring(laserBeam ~= nil))
	print("      PointLight: " .. tostring(pointLight ~= nil))
	print("      EyeLaserAttachment: " .. tostring(eyeAttachment ~= nil))

	if not laserBeam and not pointLight and not eyeAttachment then
		warn("   ❌ NoobNpcAI components NOT FOUND!")
		warn("      The script may have failed to initialize!")
	end
else
	warn("   ❌ No Head!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check Stage2NpcKill area
local stage2Area = workspace:FindFirstChild("Stage2NpcKill")
if stage2Area then
	print("✅ Stage2NpcKill area found")

	local parts = {}
	for _, obj in pairs(stage2Area:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end
	print("   Parts in area: " .. #parts)
else
	warn("❌ Stage2NpcKill area NOT FOUND!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Manual movement test
print("🧪 TESTING MANUAL MOVEMENT...")
print("   Attempting to move NPC manually...")
print("")

if humanoid and hrp then
	-- Test 1: Set WalkSpeed
	humanoid.WalkSpeed = 28
	print("   ✅ Set WalkSpeed to 28")

	-- Test 2: Try MoveTo
	local testPos = hrp.Position + Vector3.new(10, 0, 0)
	humanoid:MoveTo(testPos)
	print("   ✅ Called MoveTo: " .. tostring(testPos))

	-- Wait and check if moved
	task.wait(2)

	local newPos = hrp.Position
	local distance = (newPos - hrp.Position).Magnitude

	if distance > 0.5 then
		print("   ✅ NPC MOVED! Distance: " .. string.format("%.2f", distance))
		print("      Old Pos: " .. tostring(hrp.Position))
		print("      New Pos: " .. tostring(newPos))
	else
		warn("   ❌ NPC DID NOT MOVE!")
		warn("      This indicates a physics or pathfinding issue")
		warn("")
		warn("   Possible causes:")
		warn("      1. HumanoidRootPart is still anchored")
		warn("      2. Humanoid is in wrong state (Dead, Physics, etc)")
		warn("      3. CollisionGroup preventing movement")
		warn("      4. Other scripts interfering")
	end
else
	warn("   ❌ Cannot test movement (missing Humanoid or HRP)")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 RECOMMENDATIONS:")
print("")

-- Check for common issues
if hrp and hrp.Anchored then
	warn("❌ HumanoidRootPart is ANCHORED - NPC cannot move!")
	print("   Run FIX_NOOB_NPC.lua with game STOPPED to fix")
end

if humanoid then
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Physics then
		warn("❌ Humanoid is in bad state: " .. tostring(state))
		print("   Reset the NPC or respawn it")
	end
end

-- Check if NoobNpcAI initialized
if head then
	local hasComponents = head:FindFirstChild("Beam") or head:FindFirstChildOfClass("PointLight")
	if not hasComponents then
		warn("❌ NoobNpcAI script did NOT initialize!")
		warn("")
		warn("   Check Output window for errors like:")
		warn("   - [NoobAI] 'Buff Noob' NPC not found")
		warn("   - [NoobAI] 'Stage2NpcKill' area not found")
		warn("   - Script errors preventing initialization")
		print("")
		print("   To fix:")
		print("   1. Check Output window for error messages")
		print("   2. Make sure NoobNpcAI.server.lua is ENABLED")
		print("   3. Restart the game after fixing issues")
	end
end

print("")
print("🐛 ==================== END DEBUG ====================")
-- ==================== COPY UNTIL HERE ====================
