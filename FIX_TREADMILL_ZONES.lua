-- FIX_TREADMILL_ZONES.lua
-- COMMAND BAR SCRIPT - Run this in Studio Command Bar (with game STOPPED)
-- Creates/positions TreadmillZones under each treadmill model based on visual parts

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 Scanning for treadmill models...")

-- Configuration for each treadmill type
local treadmillConfig = {
	TreadmillFree = {color = Color3.fromRGB(128, 128, 128), multiplier = 1},
	TreadmillBlue = {color = Color3.fromRGB(51, 102, 255), multiplier = 9},
	TreadmillPurple = {color = Color3.fromRGB(204, 51, 204), multiplier = 25},
	TreadmillX3 = {color = Color3.fromRGB(255, 215, 0), multiplier = 3},  -- Gold
	TreadmillPaid = {color = Color3.fromRGB(255, 215, 0), multiplier = 3},  -- Gold (alias)
}

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

local function createOrUpdateZone(model, config)
	-- Find or create TreadmillZone
	local zone = model:FindFirstChild("TreadmillZone")

	if not zone then
		zone = Instance.new("Part")
		zone.Name = "TreadmillZone"
		zone.Parent = model
		print("   ✅ Created new TreadmillZone in " .. model.Name)
	else
		print("   🔄 Updating existing TreadmillZone in " .. model.Name)
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
		warn("   ⚠️ No visual part found in " .. model.Name .. " - using default position")
		zone.Position = Vector3.new(0, 0, 0)
		zone.Size = Vector3.new(10, 1, 10)
	end

	-- Configure properties
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 0.5
	zone.Color = config.color
	zone.Material = Enum.Material.Neon

	-- Set attributes
	zone:SetAttribute("Multiplier", config.multiplier)

	return zone
end

-- Scan workspace for treadmill models
local processedCount = 0
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Model") then
		-- Check if model name matches any treadmill type
		for typeName, config in pairs(treadmillConfig) do
			if string.match(obj.Name, "^" .. typeName) then
				print("\n🎯 Found: " .. obj.Name)
				createOrUpdateZone(obj, config)
				processedCount = processedCount + 1
				break
			end
		end
	end
end

print("\n✅ Done! Processed " .. processedCount .. " treadmill models")
print("💾 Remember to SAVE the file (Ctrl+S / Cmd+S) to persist changes!")
-- ==================== COPY UNTIL HERE ====================
