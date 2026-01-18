-- DIAGNOSE_MOVING_OBJECTS.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Monitors spawn and Stage 3 floor for unexpected movement

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== OBJECT MOVEMENT DIAGNOSTICS ====================")
print("")

-- Find SpawnLocation
local spawn = workspace:FindFirstChild("SpawnLocation", true)
if spawn then
	print("✅ Found SpawnLocation: " .. spawn:GetFullName())
	print("   Position: " .. tostring(spawn.Position))
	print("   Anchored: " .. tostring(spawn.Anchored))
	print("   CanCollide: " .. tostring(spawn.CanCollide))

	-- Check for scripts attached to spawn
	local spawnScripts = {}
	for _, obj in pairs(spawn:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			table.insert(spawnScripts, obj)
		end
	end

	if #spawnScripts > 0 then
		warn("⚠️ SCRIPTS FOUND IN SpawnLocation:")
		for _, script in ipairs(spawnScripts) do
			warn("   - " .. script:GetFullName() .. " (Enabled: " .. tostring(script.Enabled) .. ")")
		end
	else
		print("   ✅ No scripts attached to SpawnLocation")
	end
else
	warn("❌ SpawnLocation NOT FOUND!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Find Stage 3 floors/parts
local stage3Parts = {}
for _, obj in pairs(workspace:GetDescendants()) do
	local name = obj.Name:lower()
	if (name:match("stage") and name:match("3")) or name:match("stage3") or name:match("piso") then
		if obj:IsA("BasePart") then
			table.insert(stage3Parts, obj)
		end
	end
end

if #stage3Parts > 0 then
	print("✅ Found " .. #stage3Parts .. " Stage 3 parts:")
	for i, part in ipairs(stage3Parts) do
		print("")
		print("Part #" .. i .. ": " .. part.Name)
		print("   FullName: " .. part:GetFullName())
		print("   Position: " .. tostring(part.Position))
		print("   Anchored: " .. tostring(part.Anchored))
		print("   CanCollide: " .. tostring(part.CanCollide))

		-- Check parent if it's a Model
		if part.Parent:IsA("Model") then
			print("   Parent Model: " .. part.Parent.Name)

			-- Check if parent has PrimaryPart
			if part.Parent.PrimaryPart then
				print("   PrimaryPart: " .. part.Parent.PrimaryPart.Name)
			end
		end

		-- Check for scripts
		local scripts = {}
		for _, obj in pairs(part:GetDescendants()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") then
				table.insert(scripts, obj)
			end
		end

		-- Also check parent for scripts
		if part.Parent:IsA("Model") then
			for _, obj in pairs(part.Parent:GetDescendants()) do
				if obj:IsA("Script") or obj:IsA("LocalScript") then
					table.insert(scripts, obj)
				end
			end
		end

		if #scripts > 0 then
			warn("   ⚠️ SCRIPTS FOUND:")
			for _, script in ipairs(scripts) do
				warn("      - " .. script:GetFullName() .. " (Enabled: " .. tostring(script.Enabled) .. ")")
			end
		else
			print("   ✅ No scripts attached")
		end

		-- Check if Anchored = false (this would cause falling)
		if not part.Anchored then
			warn("   ❌ WARNING: Part is NOT anchored! This will cause it to fall!")
		end
	end
else
	warn("❌ No Stage 3 parts found!")
	print("   Searched for parts with names containing: 'stage 3', 'stage3', 'piso'")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Search for any scripts in Workspace that might be moving objects
print("🔍 Searching for suspicious scripts in Workspace...")
local suspiciousScripts = {}

for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Script") or obj:IsA("LocalScript") then
		-- Check script name for suspicious patterns
		local name = obj.Name:lower()
		if name:match("move") or name:match("animate") or name:match("tween") or
		   name:match("physics") or name:match("position") or name:match("cframe") then
			table.insert(suspiciousScripts, obj)
		end
	end
end

if #suspiciousScripts > 0 then
	warn("⚠️ Found " .. #suspiciousScripts .. " potentially suspicious scripts:")
	for _, script in ipairs(suspiciousScripts) do
		warn("   - " .. script:GetFullName() .. " (Enabled: " .. tostring(script.Enabled) .. ")")
	end
	print("")
	print("💡 These scripts might be moving objects. Inspect them to verify.")
else
	print("✅ No obviously suspicious scripts found in Workspace")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Monitor for position changes (run for 5 seconds)
print("⏱️ Monitoring for position changes (5 seconds)...")
print("   (Move around the game to see if objects move unexpectedly)")
print("")

if spawn then
	local initialSpawnPos = spawn.Position
	task.wait(5)
	local finalSpawnPos = spawn.Position

	if (initialSpawnPos - finalSpawnPos).Magnitude > 0.1 then
		warn("❌ SPAWN MOVED! Initial: " .. tostring(initialSpawnPos) .. " → Final: " .. tostring(finalSpawnPos))
	else
		print("✅ Spawn position remained stable")
	end
end

for i, part in ipairs(stage3Parts) do
	if part and part.Parent then
		local initialPos = part.Position
		task.wait(0.5)
		local finalPos = part.Position

		if (initialPos - finalPos).Magnitude > 0.1 then
			warn("❌ Stage 3 Part #" .. i .. " MOVED! Initial: " .. tostring(initialPos) .. " → Final: " .. tostring(finalPos))
		else
			print("✅ Stage 3 Part #" .. i .. " position remained stable")
		end
	end
end

print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
