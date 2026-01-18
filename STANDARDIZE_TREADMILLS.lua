-- STANDARDIZE_TREADMILLS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Renames all treadmills to standard naming and configures TreadmillZones

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== TREADMILL STANDARDIZATION ====================")
print("")

-- Mapping from old names to standard names and configs
local treadmillMapping = {
	-- x1 (Free)
	{patterns = {"Esteira1x", "Esteira1X", "TreadmillFree"}, newName = "TreadmillX1", multiplier = 1, color = Color3.fromRGB(128, 128, 128), isFree = true},

	-- x3 (Gold)
	{patterns = {"TreadmillPaid", "Esteira3x", "Esteira3X", "TreadmillX3", "TreadmillGold"}, newName = "TreadmillX3", multiplier = 3, color = Color3.fromRGB(255, 215, 0), isFree = false},

	-- x9 (Blue/Purple)
	{patterns = {"TreadmillBlue", "Esteira9x", "Esteira9X", "TreadmillX9"}, newName = "TreadmillX9", multiplier = 9, color = Color3.fromRGB(51, 102, 255), isFree = false},

	-- x25 (Purple)
	{patterns = {"TreadmillPurple", "Esteira25x", "Esteira25X", "TreadmillX25"}, newName = "TreadmillX25", multiplier = 25, color = Color3.fromRGB(204, 51, 204), isFree = false},
}

local function matchesPattern(modelName, patterns)
	for _, pattern in ipairs(patterns) do
		if string.match(modelName, "^" .. pattern) then
			return true
		end
	end
	return false
end

local function findLargestPart(model)
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
	local zone = model:FindFirstChild("TreadmillZone")

	if not zone then
		zone = Instance.new("Part")
		zone.Name = "TreadmillZone"
		zone.Parent = model
		print("      ✅ Created TreadmillZone")
	else
		print("      🔄 Updated TreadmillZone")
	end

	-- Position under visual part
	local visualPart = findLargestPart(model)
	if visualPart then
		local baseY = visualPart.Position.Y - (visualPart.Size.Y / 2)
		zone.Position = Vector3.new(visualPart.Position.X, baseY, visualPart.Position.Z)
		zone.Size = Vector3.new(visualPart.Size.X, 1, visualPart.Size.Z)
	else
		zone.Position = Vector3.new(0, 0, 0)
		zone.Size = Vector3.new(10, 1, 10)
	end

	-- Configure properties
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 0.5
	zone.Material = Enum.Material.Neon
	zone.Color = config.color

	-- Set attributes
	zone:SetAttribute("Multiplier", config.multiplier)
	zone:SetAttribute("IsFree", config.isFree)

	-- ProductIds
	local productIds = {
		[3] = 3510662188,
		[9] = 3510662188,
		[25] = 3510662405,
	}
	zone:SetAttribute("ProductId", productIds[config.multiplier] or 0)

	return zone
end

-- Scan and rename
print("📋 Scanning Workspace for treadmills...")
print("")

local processed = 0
local renamed = 0
local alreadyStandard = 0

for _, model in pairs(workspace:GetChildren()) do
	if model:IsA("Model") then
		-- Check if matches any treadmill pattern
		for _, mapping in ipairs(treadmillMapping) do
			if matchesPattern(model.Name, mapping.patterns) then
				local oldName = model.Name
				local newName = mapping.newName

				-- Check if already has standard name
				local isAlreadyStandard = (oldName == newName)

				-- Generate unique name if multiple with same type
				local baseName = newName
				local counter = 1
				local finalName = baseName

				-- If already standard, keep original name
				if not isAlreadyStandard then
					while workspace:FindFirstChild(finalName) and workspace:FindFirstChild(finalName) ~= model do
						counter = counter + 1
						finalName = baseName .. counter
					end
				else
					finalName = oldName
					alreadyStandard = alreadyStandard + 1
				end

				print("🎯 Found: " .. oldName)

				if not isAlreadyStandard then
					model.Name = finalName
					print("   ✏️ Renamed to: " .. finalName)
					renamed = renamed + 1
				else
					print("   ✅ Already standard name")
				end

				print("   🎯 Multiplier: x" .. mapping.multiplier)
				print("   " .. (mapping.isFree and "🆓 FREE" or "💰 PAID"))

				createOrUpdateZone(model, mapping)

				processed = processed + 1
				print("")
				break
			end
		end
	end
end

print("✅ Done!")
print("   Total processed: " .. processed)
print("   Renamed: " .. renamed)
print("   Already standard: " .. alreadyStandard)
print("")
print("📋 Standard naming convention:")
print("   TreadmillX1  = x1 multiplier (free)")
print("   TreadmillX3  = x3 multiplier (gold)")
print("   TreadmillX9  = x9 multiplier (blue)")
print("   TreadmillX25 = x25 multiplier (purple)")
print("")
print("💾 IMPORTANT: SAVE the file (Ctrl+S / Cmd+S) to persist changes!")
print("🔧 ==================== END STANDARDIZATION ====================")
-- ==================== COPY UNTIL HERE ====================
