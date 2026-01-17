-- SystemValidator.server.lua
-- ✅ Automated test suite that validates all core gameplay systems
-- Runs checks and provides detailed diagnostics

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("[SystemValidator] 🧪 STARTING VALIDATION...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

task.wait(3) -- Wait for other systems to initialize

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local testsRun = 0
local testsPassed = 0
local testsFailed = 0
local testsSkipped = 0

-- ==================== TEST FRAMEWORK ====================

local function assert_true(condition, testName, message)
	testsRun = testsRun + 1
	if condition then
		testsPassed = testsPassed + 1
		print("[✅ PASS] " .. testName)
		return true
	else
		testsFailed = testsFailed + 1
		warn("[❌ FAIL] " .. testName)
		if message then
			warn("  → " .. message)
		end
		return false
	end
end

local function assert_exists(object, testName, path)
	testsRun = testsRun + 1
	if object then
		testsPassed = testsPassed + 1
		print("[✅ PASS] " .. testName .. " - Found at: " .. (path or "unknown"))
		return true
	else
		testsFailed = testsFailed + 1
		warn("[❌ FAIL] " .. testName)
		warn("  → Object not found" .. (path and (" at: " .. path) or ""))
		return false
	end
end

local function skip_test(testName, reason)
	testsRun = testsRun + 1
	testsSkipped = testsSkipped + 1
	print("[⏭️  SKIP] " .. testName .. " - " .. reason)
end

-- ==================== SYSTEM TESTS ====================

print("\n[SystemValidator] 📦 Testing Core Services...")

-- Test 1: ReplicatedStorage.Shared
assert_exists(
	ReplicatedStorage:FindFirstChild("Shared"),
	"ReplicatedStorage.Shared exists",
	"ReplicatedStorage.Shared"
)

-- Test 2: ProgressionMath module
local progressionMath = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("ProgressionMath")
if assert_exists(progressionMath, "ProgressionMath module exists", "ReplicatedStorage.Shared.ProgressionMath") then
	-- Test 3: ProgressionMath functions
	local success, result = pcall(function()
		return require(progressionMath)
	end)
	if assert_true(success, "ProgressionMath loads without error") then
		local ProgressionMath = result
		-- Test 4: XPRequired function
		local xp = ProgressionMath.XPRequired(10)
		assert_true(
			xp and xp > 0,
			"ProgressionMath.XPRequired(10) returns positive value",
			"Got: " .. tostring(xp)
		)
	end
end

-- Test 5: Remotes folder
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if assert_exists(remotes, "Remotes folder exists", "ReplicatedStorage.Remotes") then
	-- Test 6-10: Critical RemoteEvents
	assert_exists(remotes:FindFirstChild("UpdateSpeed"), "UpdateSpeed RemoteEvent", "Remotes.UpdateSpeed")
	assert_exists(remotes:FindFirstChild("UpdateUI"), "UpdateUI RemoteEvent", "Remotes.UpdateUI")
	assert_exists(remotes:FindFirstChild("TreadmillOwnershipUpdated"), "TreadmillOwnershipUpdated RemoteEvent", "Remotes.TreadmillOwnershipUpdated")
	assert_exists(remotes:FindFirstChild("AddWin"), "AddWin RemoteEvent", "Remotes.AddWin")
	assert_exists(remotes:FindFirstChild("Rebirth"), "Rebirth RemoteEvent", "Remotes.Rebirth")
end

print("\n[SystemValidator] 🎮 Testing Server Scripts...")

-- Test 11: DataStore2
local dataStore2 = ServerScriptService:FindFirstChild("DataStore2")
if assert_exists(dataStore2, "DataStore2 module exists", "ServerScriptService.DataStore2") then
	local success, result = pcall(function()
		return require(dataStore2)
	end)
	assert_true(success, "DataStore2 loads without error")
end

-- Test 12: SpeedGameServer
assert_exists(
	ServerScriptService:FindFirstChild("SpeedGameServer"),
	"SpeedGameServer exists",
	"ServerScriptService.SpeedGameServer"
)

-- Test 13: TreadmillService
assert_exists(
	ServerScriptService:FindFirstChild("TreadmillService"),
	"TreadmillService exists",
	"ServerScriptService.TreadmillService"
)

-- Test 14: LeaderboardUpdater
assert_exists(
	ServerScriptService:FindFirstChild("LeaderboardUpdater"),
	"LeaderboardUpdater exists",
	"ServerScriptService.LeaderboardUpdater"
)

-- Test 15: CleanupBadScripts
assert_exists(
	ServerScriptService:FindFirstChild("CleanupBadScripts"),
	"CleanupBadScripts exists",
	"ServerScriptService.CleanupBadScripts"
)

print("\n[SystemValidator] 🏃 Testing Treadmill Setup...")

-- Test 16-18: Treadmill models in Workspace
local treadmillFree = workspace:FindFirstChild("TreadmillFree")
local treadmillBlue = workspace:FindFirstChild("TreadmillBlue")
local treadmillPurple = workspace:FindFirstChild("TreadmillPurple")

assert_exists(treadmillFree, "TreadmillFree model exists", "Workspace.TreadmillFree")
assert_exists(treadmillBlue, "TreadmillBlue model exists", "Workspace.TreadmillBlue")
assert_exists(treadmillPurple, "TreadmillPurple model exists", "Workspace.TreadmillPurple")

-- Test 19-21: Treadmill zones
if treadmillFree then
	local zone = treadmillFree:FindFirstChild("TreadmillZone")
	if assert_exists(zone, "TreadmillFree has TreadmillZone", "TreadmillFree.TreadmillZone") then
		assert_true(
			zone:GetAttribute("Multiplier") ~= nil,
			"TreadmillFree zone has Multiplier attribute",
			"Multiplier=" .. tostring(zone:GetAttribute("Multiplier"))
		)
	end
end

if treadmillBlue then
	local zone = treadmillBlue:FindFirstChild("TreadmillZone")
	if assert_exists(zone, "TreadmillBlue has TreadmillZone", "TreadmillBlue.TreadmillZone") then
		local mult = zone:GetAttribute("Multiplier")
		assert_true(
			mult == 9,
			"TreadmillBlue zone has correct Multiplier (9)",
			"Got: " .. tostring(mult)
		)
	end
end

if treadmillPurple then
	local zone = treadmillPurple:FindFirstChild("TreadmillZone")
	if assert_exists(zone, "TreadmillPurple has TreadmillZone", "TreadmillPurple.TreadmillZone") then
		local mult = zone:GetAttribute("Multiplier")
		assert_true(
			mult == 25,
			"TreadmillPurple zone has correct Multiplier (25)",
			"Got: " .. tostring(mult)
		)
	end
end

print("\n[SystemValidator] 🔍 Testing for Known Issues...")

-- Test 22: Check for CoreTextureSystem (should be disabled or removed)
local foundCoreTexture = false
for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant.Name == "CoreTextureSystem" and (descendant:IsA("Script") or descendant:IsA("LocalScript")) then
		foundCoreTexture = true
		local isDisabled = descendant.Disabled
		assert_true(
			isDisabled,
			"CoreTextureSystem is disabled",
			"Found at: " .. descendant:GetFullName() .. " - Disabled: " .. tostring(isDisabled)
		)
		break
	end
end
if not foundCoreTexture then
	skip_test("CoreTextureSystem check", "Not found (already cleaned up)")
end

-- Test 23: Check for old TreadmillZoneHandler scripts
local foundOldScripts = 0
for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant.Name == "TreadmillZoneHandler" and descendant:IsA("Script") then
		local parent = descendant.Parent
		if parent and parent.Name == "TreadmillZone" then
			foundOldScripts = foundOldScripts + 1
		end
	end
end
assert_true(
	foundOldScripts == 0,
	"No old TreadmillZoneHandler scripts in TreadmillZone parts",
	"Found: " .. foundOldScripts .. " old scripts"
)

-- Test 24: Check for DefaultAura fix
local auras = ReplicatedStorage:FindFirstChild("Auras")
if auras then
	local defaultAura = auras:FindFirstChild("DefaultAura")
	if defaultAura then
		local auraAttachment = defaultAura:FindFirstChild("AuraAttachment")
		assert_exists(
			auraAttachment,
			"DefaultAura has AuraAttachment (prevents infinite yield)",
			"ReplicatedStorage.Auras.DefaultAura.AuraAttachment"
		)
	else
		skip_test("DefaultAura check", "DefaultAura not found")
	end
else
	skip_test("DefaultAura check", "Auras folder not found")
end

print("\n[SystemValidator] 👥 Testing Player System...")

-- Test 25: Player joining test (if players present)
local playerCount = #Players:GetPlayers()
if playerCount > 0 then
	print("[SystemValidator] Found " .. playerCount .. " player(s) to test...")

	for _, player in ipairs(Players:GetPlayers()) do
		-- Test 26: Leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if assert_exists(leaderstats, player.Name .. " has leaderstats") then
			-- Test 27-28: Speed and Wins stats
			assert_exists(leaderstats:FindFirstChild("Speed"), player.Name .. " has Speed stat")
			assert_exists(leaderstats:FindFirstChild("Wins"), player.Name .. " has Wins stat")
		end

		-- Test 29-31: Treadmill ownership attributes
		assert_true(
			player:GetAttribute("TreadmillX3Owned") ~= nil,
			player.Name .. " has TreadmillX3Owned attribute set",
			"Value: " .. tostring(player:GetAttribute("TreadmillX3Owned"))
		)
		assert_true(
			player:GetAttribute("TreadmillX9Owned") ~= nil,
			player.Name .. " has TreadmillX9Owned attribute set",
			"Value: " .. tostring(player:GetAttribute("TreadmillX9Owned"))
		)
		assert_true(
			player:GetAttribute("TreadmillX25Owned") ~= nil,
			player.Name .. " has TreadmillX25Owned attribute set",
			"Value: " .. tostring(player:GetAttribute("TreadmillX25Owned"))
		)

		-- Only test first player to avoid spam
		break
	end
else
	skip_test("Player system tests", "No players in game")
end

-- ==================== RESULTS ====================
task.wait(1)

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("[SystemValidator] 📊 TEST RESULTS:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("[SystemValidator] Total Tests:  " .. testsRun)
print("[SystemValidator] ✅ Passed:     " .. testsPassed .. " (" .. math.floor((testsPassed / testsRun) * 100) .. "%)")
print("[SystemValidator] ❌ Failed:     " .. testsFailed .. " (" .. math.floor((testsFailed / testsRun) * 100) .. "%)")
print("[SystemValidator] ⏭️  Skipped:    " .. testsSkipped .. " (" .. math.floor((testsSkipped / testsRun) * 100) .. "%)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if testsFailed == 0 then
	print("[SystemValidator] 🎉 ALL TESTS PASSED!")
	print("[SystemValidator] ✅ Core gameplay systems are functional!")
else
	warn("[SystemValidator] ⚠️ SOME TESTS FAILED!")
	warn("[SystemValidator] Review the logs above to identify issues.")
	warn("[SystemValidator] Common fixes:")
	warn("[SystemValidator]   - Ensure Rojo is synced to the latest code")
	warn("[SystemValidator]   - Check that all scripts loaded without errors")
	warn("[SystemValidator]   - Verify workspace has correct treadmill models")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
