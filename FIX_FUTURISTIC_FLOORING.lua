-- FIX_FUTURISTIC_FLOORING.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Anchors all Procedual Futuristic Flooring parts (the hexagonal floor)

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING FUTURISTIC FLOORING ====================")
print("")

local fixedParts = 0
local alreadyAnchored = 0

-- Find all "Procedual Futuristic Flooring" models
local flooringModels = {}
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name == "Procedual Futuristic Flooring" and obj:IsA("Model") then
		table.insert(flooringModels, obj)
	end
end

print("📋 Found " .. #flooringModels .. " Procedual Futuristic Flooring models")
print("")

for modelIndex, model in ipairs(flooringModels) do
	print("Model #" .. modelIndex .. ": " .. model:GetFullName())

	-- Get all parts in this model
	local parts = {}
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end

	print("   Found " .. #parts .. " parts in this model")

	-- Anchor all parts
	for _, part in ipairs(parts) do
		if not part.Anchored then
			part.Anchored = true
			fixedParts = fixedParts + 1
			print("   ✅ Anchored: " .. part.Name .. " at " .. tostring(part.Position))
		else
			alreadyAnchored = alreadyAnchored + 1
		end
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("📊 Summary:")
print("   Total flooring models: " .. #flooringModels)
print("   Parts that needed anchoring: " .. fixedParts)
print("   Parts already anchored: " .. alreadyAnchored)
print("")

if fixedParts > 0 then
	print("✅ Fixed " .. fixedParts .. " unanchored parts!")
	print("💾 IMPORTANT: SAVE the file now (Ctrl+S / Cmd+S)!")
else
	print("✅ All parts were already properly anchored")
end

print("")
print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
