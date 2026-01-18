-- FIX_ANCHORING_ISSUES.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Fixes unanchored floor parts and removes problematic scripts

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING ANCHORING ISSUES ====================")
print("")

local fixedParts = 0
local scriptsRemoved = 0

-- ==================== FIX 1: Anchor all floor and stage parts ====================
print("📌 Fixing anchoring for floor and stage parts...")
print("")

local floorPatterns = {
	"floor", "piso", "stage", "ground", "plataforma", "platform",
	"winblock", "spawn"
}

for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") then
		local name = obj.Name:lower()
		local shouldBeAnchored = false

		-- Check if matches any floor pattern
		for _, pattern in ipairs(floorPatterns) do
			if name:match(pattern) then
				shouldBeAnchored = true
				break
			end
		end

		-- Also check parent name
		if obj.Parent and obj.Parent:IsA("Model") then
			local parentName = obj.Parent.Name:lower()
			for _, pattern in ipairs(floorPatterns) do
				if parentName:match(pattern) then
					shouldBeAnchored = true
					break
				end
			end
		end

		-- Fix if needed
		if shouldBeAnchored and not obj.Anchored then
			obj.Anchored = true
			fixedParts = fixedParts + 1
			print("✅ Anchored: " .. obj:GetFullName())
		end
	end
end

if fixedParts > 0 then
	print("")
	print("✅ Fixed anchoring for " .. fixedParts .. " parts")
else
	print("✅ All floor parts already properly anchored")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== FIX 2: Remove scripts from floors/spawns ====================
print("🧹 Removing scripts from floor parts and spawn...")
print("")

local targetObjects = {}

-- Find all floor-like objects
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") or obj:IsA("Model") then
		local name = obj.Name:lower()
		for _, pattern in ipairs(floorPatterns) do
			if name:match(pattern) then
				table.insert(targetObjects, obj)
				break
			end
		end
	end
end

print("Found " .. #targetObjects .. " floor/stage/spawn objects to clean")
print("")

for _, obj in ipairs(targetObjects) do
	-- Check for scripts in this object and descendants
	for _, descendant in pairs(obj:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			-- Don't remove system scripts (from ServerScriptService)
			local fullName = descendant:GetFullName()
			if not fullName:match("ServerScriptService") and not fullName:match("ReplicatedStorage") then
				warn("⚠️ Removing script: " .. descendant:GetFullName())
				descendant.Enabled = false
				task.wait(0.1)
				descendant:Destroy()
				scriptsRemoved = scriptsRemoved + 1
			end
		end
	end
end

if scriptsRemoved > 0 then
	print("")
	print("✅ Removed " .. scriptsRemoved .. " problematic scripts")
else
	print("✅ No problematic scripts found")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== FIX 3: Ensure SpawnLocation is properly configured ====================
print("📍 Checking SpawnLocation configuration...")
print("")

local spawn = workspace:FindFirstChild("SpawnLocation", true)
if spawn and spawn:IsA("BasePart") then
	print("✅ Found SpawnLocation: " .. spawn:GetFullName())

	-- Fix properties
	local changed = false

	if not spawn.Anchored then
		spawn.Anchored = true
		changed = true
		print("   ✅ Set Anchored = true")
	end

	if not spawn.CanCollide then
		spawn.CanCollide = true
		changed = true
		print("   ✅ Set CanCollide = true")
	end

	if not changed then
		print("   ✅ SpawnLocation already properly configured")
	end
else
	warn("❌ SpawnLocation not found in Workspace!")
	warn("   You need to add a SpawnLocation part for players to spawn")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== SUMMARY ====================
print("✅ DONE!")
print("")
print("Summary:")
print("   Parts anchored: " .. fixedParts)
print("   Scripts removed: " .. scriptsRemoved)
print("")
print("💾 IMPORTANT: SAVE the file (Ctrl+S / Cmd+S) to persist changes!")
print("")
print("💡 Next steps:")
print("   1. Save the file")
print("   2. Run DIAGNOSE_MOVING_OBJECTS.lua to verify everything is stable")
print("   3. Test in-game to ensure floors don't fall and spawn doesn't move")
print("")
print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
