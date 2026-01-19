-- DIAGNOSE_ROJO_SYNC.lua
-- Comprehensive diagnostic script to identify Rojo sync failures
-- Run this in Roblox Studio Command Bar to diagnose the progression issue

print("\n" .. string.rep("=", 80))
print("🔍 ROJO SYNC DIAGNOSTIC - PROGRESSION SYSTEM")
print(string.rep("=", 80) .. "\n")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- ==================== TEST 1: MODULE EXISTENCE ====================
print("📦 TEST 1: Checking if modules exist...")
print(string.rep("-", 80))

local shared = ReplicatedStorage:FindFirstChild("Shared")
if not shared then
	warn("❌ CRITICAL: ReplicatedStorage.Shared NOT FOUND!")
	warn("   This means Rojo has not synced the 'src/shared' folder.")
	warn("   Solution: Run 'rojo serve' and click 'Sync In' in Studio")
	return
else
	print("✅ ReplicatedStorage.Shared exists")
end

local progressionConfig = shared:FindFirstChild("ProgressionConfig")
local progressionMath = shared:FindFirstChild("ProgressionMath")
local config = shared:FindFirstChild("Config")

if progressionConfig then
	print("✅ ProgressionConfig module found")
else
	warn("❌ ProgressionConfig module NOT FOUND")
end

if progressionMath then
	print("✅ ProgressionMath module found")
else
	warn("❌ ProgressionMath module NOT FOUND")
end

if config then
	print("⚠️  Config.lua found (this is an old config, should not be used for progression)")
end

print("")

-- ==================== TEST 2: MODULE LOADING ====================
print("📥 TEST 2: Loading modules...")
print(string.rep("-", 80))

local ProgressionConfig, ProgressionMath
local loadSuccess = true

local success, result = pcall(function()
	ProgressionConfig = require(shared:WaitForChild("ProgressionConfig"))
	return true
end)

if success then
	print("✅ ProgressionConfig loaded successfully")
else
	warn("❌ ProgressionConfig failed to load: " .. tostring(result))
	loadSuccess = false
end

success, result = pcall(function()
	ProgressionMath = require(shared:WaitForChild("ProgressionMath"))
	return true
end)

if success then
	print("✅ ProgressionMath loaded successfully")
else
	warn("❌ ProgressionMath failed to load: " .. tostring(result))
	loadSuccess = false
end

if not loadSuccess then
	warn("\n❌ CRITICAL: Modules failed to load. Cannot continue diagnostic.")
	return
end

print("")

-- ==================== TEST 3: FORMULA INSPECTION ====================
print("🔬 TEST 3: Inspecting formula parameters...")
print(string.rep("-", 80))

local formula = ProgressionConfig.FORMULA
print("Formula Type: " .. tostring(formula.type))
print("BASE:         " .. tostring(formula.BASE))
print("SCALE:        " .. tostring(formula.SCALE))
print("EXPONENT:     " .. tostring(formula.EXPONENT))

print("\n📊 Expected values:")
print("  BASE:     50")
print("  SCALE:    25")
print("  EXPONENT: 1.45")

print("\n🎯 Actual values match expected:")
if formula.BASE == 50 then
	print("  ✅ BASE is correct (50)")
else
	warn("  ❌ BASE is WRONG: " .. tostring(formula.BASE) .. " (expected 50)")
	warn("     This means the module in Studio is OUTDATED!")
	warn("     Solution: Rojo has NOT synced the latest changes.")
end

if formula.SCALE == 25 then
	print("  ✅ SCALE is correct (25)")
else
	warn("  ❌ SCALE is WRONG: " .. tostring(formula.SCALE) .. " (expected 25)")
	warn("     This means the module in Studio is OUTDATED!")
end

if formula.EXPONENT == 1.45 then
	print("  ✅ EXPONENT is correct (1.45)")
else
	warn("  ❌ EXPONENT is WRONG: " .. tostring(formula.EXPONENT) .. " (expected 1.45)")
	warn("     This means the module in Studio is OUTDATED!")
end

print("")

-- ==================== TEST 4: XP CALCULATIONS ====================
print("🧮 TEST 4: Testing XP calculations...")
print(string.rep("-", 80))

local testCases = {
	{level = 1, expectedMin = 70, expectedMax = 80, desc = "Level 1→2 (start)"},
	{level = 10, expectedMin = 380, expectedMax = 450, desc = "Level 10→11"},
	{level = 25, expectedMin = 1600, expectedMax = 1800, desc = "Level 25→26"},
	{level = 64, expectedMin = 10400, expectedMax = 10500, desc = "Level 64→65 (anchor)"},
}

local allTestsPassed = true

for _, test in ipairs(testCases) do
	local xpReq = ProgressionMath.XPRequired(test.level)
	local passed = xpReq >= test.expectedMin and xpReq <= test.expectedMax

	if passed then
		print(string.format("✅ %-25s XP: %d", test.desc, xpReq))
	else
		warn(string.format("❌ %-25s XP: %d (expected %d-%d)",
			test.desc, xpReq, test.expectedMin, test.expectedMax))
		allTestsPassed = false
	end
end

print("")

-- ==================== TEST 5: OLD FORMULA DETECTION ====================
print("🕵️ TEST 5: Checking for old formula (100 + 50 * level^1.55)...")
print(string.rep("-", 80))

-- Old formula: 100 + 50 * level^1.55
local function oldFormula(level)
	return math.floor(100 + 50 * (level ^ 1.55))
end

local level10New = ProgressionMath.XPRequired(10)
local level10Old = oldFormula(10)

print(string.format("Level 10 XP (NEW formula): %d", level10New))
print(string.format("Level 10 XP (OLD formula): %d", level10Old))

if math.abs(level10New - level10Old) < 50 then
	warn("❌ CRITICAL: Studio is using OLD FORMULA!")
	warn("   Expected: ~400 XP (new formula)")
	warn("   Got:      ~" .. level10Old .. " XP (old formula)")
	warn("")
	warn("🔧 ROOT CAUSE: Rojo has NOT synced the latest ProgressionConfig.lua")
	warn("")
	warn("📋 SOLUTION:")
	warn("   1. Make sure Rojo is running: rojo serve default.project.json")
	warn("   2. In Studio: Plugins → Rojo → Connect")
	warn("   3. Click 'Sync In' button")
	warn("   4. File → Save (Ctrl+S)")
	warn("   5. Run this diagnostic again")
else
	print("✅ Studio is using NEW formula (correct!)")
end

print("")

-- ==================== TEST 6: MODULE SOURCE INSPECTION ====================
print("🔍 TEST 6: Checking module source code...")
print(string.rep("-", 80))

local configModule = shared:FindFirstChild("ProgressionConfig")
if configModule and configModule:IsA("ModuleScript") then
	local source = configModule.Source

	-- Check for key markers
	if string.find(source, "BASE = 50") then
		print("✅ ProgressionConfig source contains 'BASE = 50'")
	else
		warn("❌ ProgressionConfig source does NOT contain 'BASE = 50'")
		warn("   This confirms the module is OUTDATED in Studio!")
	end

	if string.find(source, "SCALE = 25") then
		print("✅ ProgressionConfig source contains 'SCALE = 25'")
	else
		warn("❌ ProgressionConfig source does NOT contain 'SCALE = 25'")
	end

	if string.find(source, "EXPONENT = 1.45") then
		print("✅ ProgressionConfig source contains 'EXPONENT = 1.45'")
	else
		warn("❌ ProgressionConfig source does NOT contain 'EXPONENT = 1.45'")
	end
end

print("")

-- ==================== FINAL VERDICT ====================
print(string.rep("=", 80))
print("📊 FINAL VERDICT")
print(string.rep("=", 80))

if formula.BASE == 50 and formula.SCALE == 25 and formula.EXPONENT == 1.45 and allTestsPassed then
	print("✅ ROJO SYNC SUCCESSFUL!")
	print("   All modules are up-to-date and working correctly.")
	print("   The game should load the correct progression values.")
else
	warn("❌ ROJO SYNC FAILED!")
	warn("")
	warn("🔥 CRITICAL ISSUE DETECTED:")
	warn("   Studio is loading CACHED/OLD modules from the .rbxl file.")
	warn("   Git shows correct values, but Studio loads wrong values.")
	warn("")
	warn("📋 STEP-BY-STEP FIX:")
	warn("   1. Close Roblox Studio completely")
	warn("   2. Open terminal in project folder")
	warn("   3. Run: rojo serve default.project.json")
	warn("   4. Wait for 'Server listening on port 34872'")
	warn("   5. Open Roblox Studio")
	warn("   6. Plugins → Rojo → Connect")
	warn("   7. Click 'Sync In' button (this OVERWRITES cached modules)")
	warn("   8. File → Save (Ctrl+S)")
	warn("   9. File → Publish to Roblox (if needed)")
	warn("   10. Run this diagnostic again")
	warn("")
	warn("🎯 ALTERNATIVE FIX:")
	warn("   If Rojo sync still doesn't work:")
	warn("   1. Delete the cached modules in Studio:")
	warn("      ReplicatedStorage > Shared > ProgressionConfig (delete)")
	warn("      ReplicatedStorage > Shared > ProgressionMath (delete)")
	warn("   2. Click 'Sync In' again in Rojo")
	warn("   3. This will force Rojo to recreate the modules from scratch")
end

print("")
print(string.rep("=", 80))
print("Diagnostic complete. Check output above for issues.")
print(string.rep("=", 80))
