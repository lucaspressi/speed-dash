-- DIAGNOSE_NOOB_NPC.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Diagnoses why NoobNPC might not be working

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== NOOB NPC DIAGNOSTICS ====================")
print("")

-- Check for "Buff Noob" NPC
local noob = workspace:FindFirstChild("Buff Noob")
if not noob then
	warn("❌ 'Buff Noob' NPC NOT FOUND in Workspace!")
	warn("   The NoobNpcAI script cannot run without this NPC")
	print("")
	print("💡 Solution:")
	print("   1. Add a 'Buff Noob' NPC to Workspace")
	print("   2. Make sure it's named exactly 'Buff Noob' (case sensitive)")
	print("")
else
	print("✅ Found 'Buff Noob' NPC")
	print("   FullName: " .. noob:GetFullName())
	print("   ClassName: " .. noob.ClassName)
	print("")

	-- Check required parts
	local humanoid = noob:FindFirstChild("Humanoid")
	local hrp = noob:FindFirstChild("HumanoidRootPart")
	local head = noob:FindFirstChild("Head")

	print("   Required Parts:")
	if humanoid then
		print("      ✅ Humanoid found")
		print("         Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
		print("         WalkSpeed: " .. humanoid.WalkSpeed)
	else
		warn("      ❌ Humanoid NOT FOUND!")
	end

	if hrp then
		print("      ✅ HumanoidRootPart found")
		print("         Position: " .. tostring(hrp.Position))
		print("         Anchored: " .. tostring(hrp.Anchored))
	else
		warn("      ❌ HumanoidRootPart NOT FOUND!")
	end

	if head then
		print("      ✅ Head found")
	else
		warn("      ❌ Head NOT FOUND!")
	end

	print("")

	-- Check for scripts in the NPC
	local scripts = {}
	for _, obj in pairs(noob:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			table.insert(scripts, obj)
		end
	end

	if #scripts > 0 then
		print("   Scripts in NPC:")
		for _, script in ipairs(scripts) do
			print("      - " .. script.Name .. " (Enabled: " .. tostring(script.Enabled) .. ")")
		end
	else
		print("   ℹ️ No scripts found in NPC (controlled by NoobNpcAI.server.lua)")
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check for "Stage2NpcKill" area
local stage2Area = workspace:FindFirstChild("Stage2NpcKill")
if not stage2Area then
	warn("❌ 'Stage2NpcKill' area NOT FOUND in Workspace!")
	warn("   The NoobNpcAI script cannot calculate bounds without this folder")
	print("")
	print("💡 Solution:")
	print("   1. Create a folder named 'Stage2NpcKill' in Workspace")
	print("   2. Add BaseParts inside it to define the Stage 2 area")
	print("   3. The NPC will patrol within these bounds")
	print("")
else
	print("✅ Found 'Stage2NpcKill' area")
	print("   FullName: " .. stage2Area:GetFullName())
	print("")

	-- Count parts in area
	local parts = {}
	for _, obj in pairs(stage2Area:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end

	if #parts > 0 then
		print("   ✅ Found " .. #parts .. " parts defining the area")

		-- Calculate bounds
		local minX, maxX = math.huge, -math.huge
		local minZ, maxZ = math.huge, -math.huge

		for _, part in pairs(parts) do
			local pos = part.Position
			local size = part.Size

			minX = math.min(minX, pos.X - size.X/2)
			maxX = math.max(maxX, pos.X + size.X/2)
			minZ = math.min(minZ, pos.Z - size.Z/2)
			maxZ = math.max(maxZ, pos.Z + size.Z/2)
		end

		local centerX = (minX + maxX) / 2
		local centerZ = (minZ + maxZ) / 2

		print("   Calculated Bounds:")
		print("      X: " .. string.format("%.1f", minX) .. " to " .. string.format("%.1f", maxX))
		print("      Z: " .. string.format("%.1f", minZ) .. " to " .. string.format("%.1f", maxZ))
		print("      Center: " .. string.format("%.1f, %.1f", centerX, centerZ))
	else
		warn("   ❌ No BaseParts found in Stage2NpcKill!")
		warn("      Add BaseParts to define the patrol area")
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check if NoobNpcAI.server.lua is loaded
print("🔍 Checking if NoobNpcAI script is running...")
print("")

-- Look for evidence of the script running
if noob and noob:FindFirstChild("Head") then
	local head = noob:FindFirstChild("Head")

	-- Check for laser components
	local laserBeam = head:FindFirstChild("Beam")
	local pointLight = head:FindFirstChildOfClass("PointLight")
	local eyeAttachment = head:FindFirstChild("EyeLaserAttachment")

	if laserBeam or pointLight or eyeAttachment then
		print("✅ NoobNpcAI script IS RUNNING")
		print("   Evidence: Laser components found in NPC head")
		if laserBeam then
			print("      - Beam: " .. tostring(laserBeam.Enabled))
		end
		if pointLight then
			print("      - PointLight: Brightness=" .. pointLight.Brightness)
		end
		if eyeAttachment then
			print("      - EyeLaserAttachment found")
		end
	else
		warn("⚠️ NoobNpcAI script might NOT be running")
		warn("   No laser components found in NPC head")
		print("")
		print("💡 Possible causes:")
		print("   1. NoobNpcAI.server.lua is disabled in ServerScriptService")
		print("   2. Script failed to initialize (check Output for errors)")
		print("   3. Script was stopped due to missing requirements")
	end
else
	warn("⚠️ Cannot check if script is running (NPC or Head missing)")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("📊 SUMMARY:")
print("")

local hasNoob = workspace:FindFirstChild("Buff Noob") ~= nil
local hasStage2 = workspace:FindFirstChild("Stage2NpcKill") ~= nil

if hasNoob and hasStage2 then
	print("✅ Both requirements met!")
	print("   If NPC still doesn't work, check Output window for script errors")
elseif not hasNoob then
	warn("❌ Missing: Buff Noob NPC")
elseif not hasStage2 then
	warn("❌ Missing: Stage2NpcKill area")
end

print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
