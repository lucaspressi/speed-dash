-- FIX_STUD_PARTS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Finds and anchors all Stud Parts and their parent Models

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING STUD PARTS ====================")
print("")

-- Find all Stud Parts
local studParts = {}
for _, obj in pairs(workspace:GetDescendants()) do
	if obj.Name == "Stud Part" and obj:IsA("BasePart") then
		table.insert(studParts, obj)
	end
end

print("📋 Found " .. #studParts .. " Stud Parts")
print("")

local fixedParts = 0
local modelsProcessed = {}

for i, studPart in ipairs(studParts) do
	print("Stud Part #" .. i .. ":")
	print("   FullName: " .. studPart:GetFullName())
	print("   Anchored: " .. tostring(studPart.Anchored))
	print("   Parent: " .. (studPart.Parent and studPart.Parent.Name or "nil"))

	-- Anchor this part
	if not studPart.Anchored then
		studPart.Anchored = true
		fixedParts = fixedParts + 1
		print("   ✅ Anchored Stud Part")
	else
		print("   ℹ️ Already anchored")
	end

	-- Check if parent is a Model and anchor ALL parts in it
	if studPart.Parent and studPart.Parent:IsA("Model") then
		local model = studPart.Parent
		local modelName = model:GetFullName()

		if not modelsProcessed[modelName] then
			modelsProcessed[modelName] = true
			print("   📦 Parent Model: " .. modelName)

			-- Get all parts in the model
			local partsInModel = {}
			for _, obj in pairs(model:GetDescendants()) do
				if obj:IsA("BasePart") then
					table.insert(partsInModel, obj)
				end
			end

			print("      Found " .. #partsInModel .. " parts in this model")

			local modelFixed = 0
			for _, part in ipairs(partsInModel) do
				if not part.Anchored then
					part.Anchored = true
					modelFixed = modelFixed + 1
				end
			end

			if modelFixed > 0 then
				print("      ✅ Anchored " .. modelFixed .. " parts in model")
				fixedParts = fixedParts + modelFixed
			else
				print("      ℹ️ All parts already anchored")
			end
		end
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("📊 Summary:")
print("   Stud Parts found: " .. #studParts)
print("   Total parts anchored: " .. fixedParts)
print("   Models processed: " .. (function() local count = 0 for _ in pairs(modelsProcessed) do count = count + 1 end return count end)())
print("")

if fixedParts > 0 then
	print("✅ Fixed " .. fixedParts .. " unanchored parts!")
	print("💾 IMPORTANT: SAVE the file now (Ctrl+S / Cmd+S)!")
else
	print("✅ All Stud Parts and their models are already anchored")
end

print("")
print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
