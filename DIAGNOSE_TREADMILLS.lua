-- DIAGNOSE_TREADMILLS.lua
-- COMMAND BAR SCRIPT - Run to see all treadmill models in Workspace

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== TREADMILL DIAGNOSTIC ====================")
print("")

local allModels = {}
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("Model") then
		table.insert(allModels, obj)
	end
end

print("📋 Total models in Workspace: " .. #allModels)
print("")

-- Check for treadmill-like models
print("🎯 Models with 'Treadmill' in name:")
for _, model in pairs(allModels) do
	if string.match(string.lower(model.Name), "treadm") then
		print("   • " .. model.Name)

		-- Check for TreadmillZone
		local zone = model:FindFirstChild("TreadmillZone")
		if zone then
			print("      ✅ Has TreadmillZone")
			print("         Position: " .. tostring(zone.Position))
			print("         Size: " .. tostring(zone.Size))
			print("         Multiplier: " .. tostring(zone:GetAttribute("Multiplier")))
		else
			print("      ❌ NO TreadmillZone")
		end

		-- List all parts in model
		print("      Parts in model:")
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				print("         - " .. part.Name .. " (" .. part.ClassName .. ") Size: " .. tostring(part.Size))
			end
		end
		print("")
	end
end

print("🔍 ==================== END DIAGNOSTIC ====================")
-- ==================== COPY UNTIL HERE ====================
