-- FIX_STEPAWARDS.lua
-- COMMAND BAR SCRIPT - Run this in Studio Command Bar (F5 running)
-- Deletes all StepAward attributes and lets AutoSetupStepAwards reconfigure them correctly

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 Scanning for StepAwards...")

local stepAwards = {}
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and string.match(obj.Name, "^StepAward") then
		table.insert(stepAwards, obj)
	end
end

print("✅ Found " .. #stepAwards .. " StepAwards")

for _, stepAward in ipairs(stepAwards) do
	local hadBonus = stepAward:GetAttribute("Bonus") ~= nil
	local hadRequired = stepAward:GetAttribute("RequiredWins") ~= nil

	-- Delete attributes
	stepAward:SetAttribute("Bonus", nil)
	stepAward:SetAttribute("RequiredWins", nil)

	if hadBonus or hadRequired then
		print("🗑️ Cleared attributes from: " .. stepAward.Name)
	end
end

print("")
print("✅ All StepAward attributes cleared!")
print("⏳ Waiting 1 second for AutoSetupStepAwards to run...")

task.wait(1)

print("")
print("📋 Current StepAward configuration:")
for _, stepAward in ipairs(stepAwards) do
	local bonus = stepAward:GetAttribute("Bonus")
	local required = stepAward:GetAttribute("RequiredWins")
	print("   " .. stepAward.Name .. " → Bonus=" .. tostring(bonus) .. ", RequiredWins=" .. tostring(required))
end

print("")
print("✅ Done! Now restart the game (F5) to test!")
-- ==================== COPY UNTIL HERE ====================
