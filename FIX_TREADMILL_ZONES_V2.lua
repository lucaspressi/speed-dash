-- FIX_TREADMILL_ZONES_V2.lua
-- COMMAND BAR SCRIPT - Run this in Studio Command Bar (with game STOPPED)
-- Creates/positions TreadmillZones and lets you configure multipliers

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== TREADMILL ZONE SETUP V2 ====================")
print("")

-- ⚠️ CONFIGURE MULTIPLIERS HERE:
-- Edit the multiplier value for each treadmill model name pattern
local treadmillMultipliers = {
	-- Free treadmills (x1)
	["TreadmillFree"] = 1,

	-- Gold treadmills (x3)
	["TreadmillX3"] = 3,
	["TreadmillPaid"] = 3,
	["TreadmillGold"] = 3,

	-- Blue treadmills (x9)
	["TreadmillBlue"] = 9,
	["TreadmillX9"] = 9,

	-- Purple treadmills (x25)
	["TreadmillPurple"] = 25,
	["TreadmillX25"] = 25,
}

-- Color mapping for visual identification
local multiplierColors = {
	[1] = Color3.fromRGB(128, 128, 128),   -- Gray (Free)
	[3] = Color3.fromRGB(255, 215, 0),     -- Gold
	[9] = Color3.fromRGB(51, 102, 255),    -- Blue
	[25] = Color3.fromRGB(204, 51, 204),   -- Purple
}

local function getMultiplierForModel(modelName)
	-- Check each pattern
	for pattern, multiplier in pairs(treadmillMultipliers) do
		if string.match(modelName, "^" .. pattern) then
			return multiplier
		end
	end
	return nil
end

local function findLargestPart(model)
	-- Find the largest part in the model (usually the platform)
	local largest = nil
	local largestVolume = 0

	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name ~= "TreadmillZone" then
			local volume = obj.Size.X * obj.Size.Y * obj.Size.Z
			if volume > largestVolume then
				largestVolume = volume
				largest = obj
			end
		end
	end

	return largest
end

local function createOrUpdateZone(model, multiplier)
	-- Find or create TreadmillZone
	local zone = model:FindFirstChild("TreadmillZone")

	if not zone then
		zone = Instance.new("Part")
		zone.Name = "TreadmillZone"
		zone.Parent = model
		print("   ✅ Created new TreadmillZone")
	else
		print("   🔄 Updating existing TreadmillZone")
	end

	-- Find the visual part to position zone under it
	local visualPart = findLargestPart(model)

	if visualPart then
		-- Position zone at the base of the visual part
		local baseY = visualPart.Position.Y - (visualPart.Size.Y / 2)
		zone.Position = Vector3.new(visualPart.Position.X, baseY, visualPart.Position.Z)
		zone.Size = Vector3.new(visualPart.Size.X, 1, visualPart.Size.Z)

		print("   📍 Position: " .. tostring(zone.Position))
		print("   📏 Size: " .. tostring(zone.Size))
	else
		warn("   ⚠️ No visual part found - using default position")
		zone.Position = Vector3.new(0, 0, 0)
		zone.Size = Vector3.new(10, 1, 10)
	end

	-- Configure properties
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 0.5
	zone.Material = Enum.Material.Neon
	zone.Color = multiplierColors[multiplier] or Color3.fromRGB(255, 255, 255)

	-- Set attributes
	zone:SetAttribute("Multiplier", multiplier)

	-- Determine if free or paid
	local isFree = (multiplier == 1)
	zone:SetAttribute("IsFree", isFree)

	-- Set ProductId based on multiplier
	local productIds = {
		[3] = 3510662188,   -- Gold
		[9] = 3510662188,   -- Blue (same as gold for now)
		[25] = 3510662405,  -- Purple
	}
	zone:SetAttribute("ProductId", productIds[multiplier] or 0)

	print("   🎯 Multiplier: x" .. multiplier)
	print("   " .. (isFree and "🆓 FREE" or "💰 PAID"))

	return zone
end

-- Scan workspace for treadmill models
print("📋 Scanning Workspace for treadmill models...")
print("")

local processedCount = 0
local skippedCount = 0

for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Model") then
		local multiplier = getMultiplierForModel(obj.Name)

		if multiplier then
			print("🎯 Found: " .. obj.Name)
			createOrUpdateZone(obj, multiplier)
			processedCount = processedCount + 1
			print("")
		elseif string.match(string.lower(obj.Name), "treadm") then
			warn("⚠️ Skipped: " .. obj.Name .. " (no multiplier configured)")
			warn("   Add it to the treadmillMultipliers table if needed")
			skippedCount = skippedCount + 1
			print("")
		end
	end
end

print("✅ Done! Processed: " .. processedCount .. " | Skipped: " .. skippedCount)
print("")
print("💾 IMPORTANT: SAVE the file (Ctrl+S / Cmd+S) to persist changes!")
print("🔧 ==================== END SETUP ====================")
-- ==================== COPY UNTIL HERE ====================
