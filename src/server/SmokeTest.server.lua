-- SmokeTest.server.lua
-- Script de validação para confirmar que todos os sistemas estão funcionando
-- Execute no Studio após corrigir os bugs para validar
-- PODE SER DELETADO após validação

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("==================== SMOKE TEST STARTING ====================")

-- Wait for game to initialize
task.wait(2)

local passed = 0
local failed = 0

local function test(name, condition, errorMsg)
	if condition then
		print("✅ PASS: " .. name)
		passed = passed + 1
	else
		warn("❌ FAIL: " .. name)
		if errorMsg then
			warn("   Details: " .. errorMsg)
		end
		failed = failed + 1
	end
end

-- ==================== TEST 1: REMOTES EXIST ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("TEST CATEGORY: Remotes")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
test("Remotes folder exists", remotes ~= nil, "ReplicatedStorage.Remotes not found")

if remotes then
	test("UpdateSpeed RemoteEvent exists", remotes:FindFirstChild("UpdateSpeed") ~= nil)
	test("UpdateUI RemoteEvent exists", remotes:FindFirstChild("UpdateUI") ~= nil)
	test("TreadmillOwnershipUpdated RemoteEvent exists", remotes:FindFirstChild("TreadmillOwnershipUpdated") ~= nil)
	test("AddWin RemoteEvent exists", remotes:FindFirstChild("AddWin") ~= nil)
	test("EquipStepAward RemoteFunction exists", remotes:FindFirstChild("EquipStepAward") ~= nil)
end

-- ==================== TEST 2: TREADMILL SERVICE ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("TEST CATEGORY: TreadmillService")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

test("_G.TreadmillService exists", _G.TreadmillService ~= nil)

if _G.TreadmillService then
	test("TreadmillService.getPlayerMultiplier exists", _G.TreadmillService.getPlayerMultiplier ~= nil)
	test("TreadmillService.isPlayerOnTreadmill exists", _G.TreadmillService.isPlayerOnTreadmill ~= nil)
	test("TreadmillService.getPlayerZone exists", _G.TreadmillService.getPlayerZone ~= nil)

	-- Test with first player if available
	local firstPlayer = Players:GetPlayers()[1]
	if firstPlayer then
		local success, result = pcall(function()
			return _G.TreadmillService.getPlayerMultiplier(firstPlayer)
		end)
		test("TreadmillService.getPlayerMultiplier(player) works", success, result)
	end
end

-- ==================== TEST 3: TREADMILL REGISTRY ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("TEST CATEGORY: TreadmillRegistry")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local ServerScriptService = game:GetService("ServerScriptService")
local TreadmillRegistry = nil
pcall(function()
	TreadmillRegistry = require(ServerScriptService:WaitForChild("TreadmillRegistry", 1))
end)

test("TreadmillRegistry module exists", TreadmillRegistry ~= nil)

if TreadmillRegistry then
	local stats = TreadmillRegistry.getStats()
	print("  Registry stats: " .. stats.totalZones .. " zones registered")
	test("TreadmillRegistry has zones", stats.totalZones > 0, "No zones found - check zone configuration")
end

-- ==================== TEST 4: PLAYER DATA ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("TEST CATEGORY: Player Data")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local firstPlayer = Players:GetPlayers()[1]
if firstPlayer then
	print("Testing with player: " .. firstPlayer.Name)

	-- Check if player has basic attributes
	local hasOnTreadmill = firstPlayer:GetAttribute("OnTreadmill") ~= nil
	local hasMultiplier = firstPlayer:GetAttribute("CurrentTreadmillMultiplier") ~= nil

	test("Player has OnTreadmill attribute", hasOnTreadmill)
	test("Player has CurrentTreadmillMultiplier attribute", hasMultiplier)

	-- Check ownership attributes
	local hasX3 = firstPlayer:GetAttribute("TreadmillX3Owned") ~= nil
	local hasX9 = firstPlayer:GetAttribute("TreadmillX9Owned") ~= nil
	local hasX25 = firstPlayer:GetAttribute("TreadmillX25Owned") ~= nil

	test("Player has TreadmillX3Owned attribute", hasX3)
	test("Player has TreadmillX9Owned attribute", hasX9)
	test("Player has TreadmillX25Owned attribute", hasX25)

	-- Check leaderstats
	local leaderstats = firstPlayer:FindFirstChild("leaderstats")
	test("Player has leaderstats", leaderstats ~= nil)

	if leaderstats then
		test("Leaderstats has Speed stat", leaderstats:FindFirstChild("Speed") ~= nil)
		test("Leaderstats has Wins stat", leaderstats:FindFirstChild("Wins") ~= nil)
	end
else
	warn("⚠️ No players in game - some tests skipped")
end

-- ==================== TEST 5: MODULES ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("TEST CATEGORY: Modules")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local ProgressionMath = nil
pcall(function()
	ProgressionMath = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ProgressionMath"))
end)
test("ProgressionMath module exists", ProgressionMath ~= nil)

local TreadmillConfig = nil
pcall(function()
	TreadmillConfig = require(ServerScriptService:WaitForChild("TreadmillConfig", 1))
end)
test("TreadmillConfig module exists", TreadmillConfig ~= nil)

-- ==================== SUMMARY ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("SMOKE TEST SUMMARY")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Passed: " .. passed)
print("❌ Failed: " .. failed)
print("")

if failed == 0 then
	print("🎉 ALL TESTS PASSED! Game systems are operational.")
else
	warn("⚠️ " .. failed .. " TESTS FAILED. Review errors above.")
end

print("==================== SMOKE TEST COMPLETE ====================")

-- Auto-delete after running (opcional)
-- task.wait(5)
-- script:Destroy()
