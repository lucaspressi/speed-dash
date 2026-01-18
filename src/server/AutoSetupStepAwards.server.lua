-- AutoSetupStepAwards.server.lua
-- 🔧 Automatically configures StepAward attributes based on their names
-- This ensures StepAwards work properly with the win requirement system

local workspace = game:GetService("Workspace")

print("[AutoSetup StepAwards] ==================== AUTO-CONFIGURING STEP AWARDS ====================")

-- StepAward configuration: {bonus, requiredWins}
local stepAwardConfigs = {
	["StepAward2"] = {bonus = 2, requiredWins = 3},         -- Requires 3 wins
	["StepAward5"] = {bonus = 5, requiredWins = 15},        -- Requires 15 wins
	["StepAward10"] = {bonus = 10, requiredWins = 100},     -- Requires 100 wins
	["StepAward25"] = {bonus = 25, requiredWins = 500},     -- Requires 500 wins
	["StepAward50"] = {bonus = 50, requiredWins = 2500},    -- Requires 2,500 wins
	["StepAward100"] = {bonus = 100, requiredWins = 15000}, -- Requires 15,000 wins
	["StepAward250"] = {bonus = 250, requiredWins = 50000}, -- Requires 50,000 wins
	["StepAward500"] = {bonus = 500, requiredWins = 250000}, -- Requires 250,000 wins
}

local function configureStepAward(obj)
	local config = stepAwardConfigs[obj.Name]

	if not config then
		warn("[AutoSetup StepAwards] ⚠️ Unknown StepAward: " .. obj.Name)
		return
	end

	-- Set attributes
	obj:SetAttribute("Bonus", config.bonus)
	obj:SetAttribute("RequiredWins", config.requiredWins)

	print("[AutoSetup StepAwards] ✅ Configured: " .. obj.Name .. " (Bonus=" .. config.bonus .. ", RequiredWins=" .. config.requiredWins .. ")")
end

-- Scan workspace for StepAwards
local configuredCount = 0
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and string.match(obj.Name, "^StepAward") then
		configureStepAward(obj)
		configuredCount = configuredCount + 1
	end
end

print("[AutoSetup StepAwards] ✅ Auto-setup complete: " .. configuredCount .. " StepAwards configured")
print("[AutoSetup StepAwards] ========================================================================")

-- Listen for dynamically added StepAwards
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and string.match(obj.Name, "^StepAward") then
		task.wait(0.1) -- Wait for it to fully load
		configureStepAward(obj)
	end
end)
