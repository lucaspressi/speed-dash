-- RENAME_STEPAWARDS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Renames StepAward objects to match new progression

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== STEPAWARD RENAMING ====================")
print("")

-- Mapping: old bonus value -> new name
local renameMap = {
	-- These stay the same
	[2] = "StepAward2",    -- 3 wins
	[5] = "StepAward5",    -- 15 wins

	-- These need to be checked/renamed
	[10] = "StepAward10",  -- 100 wins (NEW - if you had StepAward25 at 100 wins, rename it)
	[25] = "StepAward25",  -- 500 wins
	[50] = "StepAward50",  -- 2,500 wins
	[100] = "StepAward100", -- 15,000 wins
	[250] = "StepAward250", -- 50,000 wins (NEW - if needed)
	[500] = "StepAward500", -- 250,000 wins
}

-- Expected configuration
local expectedConfig = {
	["StepAward2"] = {bonus = 2, wins = 3},
	["StepAward5"] = {bonus = 5, wins = 15},
	["StepAward10"] = {bonus = 10, wins = 100},
	["StepAward25"] = {bonus = 25, wins = 500},
	["StepAward50"] = {bonus = 50, wins = 2500},
	["StepAward100"] = {bonus = 100, wins = 15000},
	["StepAward250"] = {bonus = 250, wins = 50000},
	["StepAward500"] = {bonus = 500, wins = 250000},
}

print("📋 Expected StepAwards:")
for name, config in pairs(expectedConfig) do
	print("   " .. name .. " = +" .. config.bonus .. " steps (requires " .. config.wins .. " wins)")
end
print("")

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Find all StepAward objects
local stepAwards = {}
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and string.match(obj.Name, "^StepAward") then
		table.insert(stepAwards, obj)
	end
end

print("🔍 Found " .. #stepAwards .. " StepAward objects:")
print("")

local renamed = 0
local alreadyCorrect = 0
local needsManualCheck = {}

for i, obj in ipairs(stepAwards) do
	local currentName = obj.Name
	local currentBonus = obj:GetAttribute("Bonus")
	local currentWins = obj:GetAttribute("RequiredWins")

	print("StepAward #" .. i .. ": " .. currentName)
	print("   Current Bonus: " .. tostring(currentBonus))
	print("   Current RequiredWins: " .. tostring(currentWins))

	local expectedData = expectedConfig[currentName]

	if expectedData then
		-- Check if attributes match expected values
		if currentBonus == expectedData.bonus and currentWins == expectedData.wins then
			print("   ✅ Already correct!")
			alreadyCorrect = alreadyCorrect + 1
		else
			-- Attributes don't match name
			print("   ⚠️ Attributes don't match name!")
			print("      Expected Bonus: " .. expectedData.bonus .. ", Got: " .. tostring(currentBonus))
			print("      Expected Wins: " .. expectedData.wins .. ", Got: " .. tostring(currentWins))
			table.insert(needsManualCheck, {obj = obj, name = currentName, bonus = currentBonus, wins = currentWins})
		end
	else
		-- Unknown name
		warn("   ❌ Unknown StepAward name: " .. currentName)
		warn("      Check if this should be renamed to match one of the expected names")
		table.insert(needsManualCheck, {obj = obj, name = currentName, bonus = currentBonus, wins = currentWins})
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("📊 Summary:")
print("   Total StepAwards found: " .. #stepAwards)
print("   Already correct: " .. alreadyCorrect)
print("   Need manual check: " .. #needsManualCheck)
print("")

if #needsManualCheck > 0 then
	warn("⚠️ The following StepAwards need manual checking:")
	for _, item in ipairs(needsManualCheck) do
		warn("   " .. item.name .. " (Bonus=" .. tostring(item.bonus) .. ", Wins=" .. tostring(item.wins) .. ")")
	end
	print("")
	print("💡 To fix:")
	print("   1. Select each StepAward in the Explorer")
	print("   2. Check its current Bonus attribute")
	print("   3. Rename it to match: StepAward{Bonus}")
	print("      Example: If Bonus=10, rename to 'StepAward10'")
end

print("")
print("💡 Missing StepAwards:")
local found = {}
for _, obj in ipairs(stepAwards) do
	found[obj.Name] = true
end

for name, config in pairs(expectedConfig) do
	if not found[name] then
		warn("   ❌ " .. name .. " not found - you may need to create it or rename an existing one")
	end
end

print("")
print("💾 IMPORTANT: After making changes, SAVE the file (Ctrl+S / Cmd+S)!")
print("🔧 ==================== END RENAMING ====================")
-- ==================== COPY UNTIL HERE ====================
