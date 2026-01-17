-- ProgressionValidator.server.lua
-- Script de validação para testar o sistema de progressão
-- Execute no Roblox Studio para ver os logs de validação

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== LOAD MODULES ====================
print("[PROGRESSION-TEST] ============================================")
print("[PROGRESSION-TEST] Loading ProgressionMath module...")

local ProgressionMath = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ProgressionMath"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ProgressionConfig"))

print("[PROGRESSION-TEST] ✅ Modules loaded successfully!")
print("[PROGRESSION-TEST] ============================================")

-- ==================== TEST CASES ====================

-- Test 1: Anchor Level 64 (jogo referência)
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] TEST 1: Anchor Level 64 (Reference Game)")
print("[PROGRESSION-TEST] ────────────────────────────────────────────")

local level64_xpRequired = ProgressionMath.XPRequired(64)
print(string.format("[PROGRESSION-TEST] XPRequired(64) = %s", ProgressionMath.formatComma(level64_xpRequired)))
print(string.format("[PROGRESSION-TEST] Expected: 666,750"))
print(string.format("[PROGRESSION-TEST] Error: %d (%.2f%%)",
	math.abs(level64_xpRequired - 666750),
	math.abs(level64_xpRequired - 666750) / 666750 * 100))

local level64_totalXPToReach = ProgressionMath.TotalXPToReachLevel(64)
local level64_totalXPAt535k = level64_totalXPToReach + 535080

print(string.format("[PROGRESSION-TEST] TotalXP to reach Level 64: %s", ProgressionMath.formatComma(level64_totalXPToReach)))
print(string.format("[PROGRESSION-TEST] TotalXP at Level 64 with 535,080 XP: %s", ProgressionMath.formatComma(level64_totalXPAt535k)))
print(string.format("[PROGRESSION-TEST] Expected: 4,779,693"))
print(string.format("[PROGRESSION-TEST] Error: %d (%.2f%%)",
	math.abs(level64_totalXPAt535k - 4779693),
	math.abs(level64_totalXPAt535k - 4779693) / 4779693 * 100))

local progress64 = 535080 / level64_xpRequired
print(string.format("[PROGRESSION-TEST] Progress bar: %.2f%% (expected: 80.22%%)", progress64 * 100))

if math.abs(level64_xpRequired - 666750) < 100 and math.abs(level64_totalXPAt535k - 4779693) < 10000 then
	print("[PROGRESSION-TEST] ✅ TEST 1 PASSED")
else
	warn("[PROGRESSION-TEST] ❌ TEST 1 FAILED")
end

-- Test 2: LevelFromTotalXP (reverse calculation)
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] TEST 2: LevelFromTotalXP (Reverse Calculation)")
print("[PROGRESSION-TEST] ────────────────────────────────────────────")

local calcLevel, calcXPInto, calcXPReq = ProgressionMath.LevelFromTotalXP(level64_totalXPAt535k)
print(string.format("[PROGRESSION-TEST] LevelFromTotalXP(%s) = Level %d",
	ProgressionMath.formatComma(level64_totalXPAt535k), calcLevel))
print(string.format("[PROGRESSION-TEST] XP into level: %s / %s",
	ProgressionMath.formatComma(calcXPInto), ProgressionMath.formatComma(calcXPReq)))
print(string.format("[PROGRESSION-TEST] Expected: Level 64, XP 535,080 / 666,750"))

if calcLevel == 64 and math.abs(calcXPInto - 535080) < 10 then
	print("[PROGRESSION-TEST] ✅ TEST 2 PASSED")
else
	warn("[PROGRESSION-TEST] ❌ TEST 2 FAILED")
end

-- Test 3: Sample of other levels
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] TEST 3: Sample Levels (XPRequired)")
print("[PROGRESSION-TEST] ────────────────────────────────────────────")
print("[PROGRESSION-TEST] Level | XPRequired    | TotalXP      | Speed Display")
print("[PROGRESSION-TEST] ─────────────────────────────────────────────────────")

local sampleLevels = {1, 10, 25, 50, 64, 100, 150, 200}

for _, lv in ipairs(sampleLevels) do
	local xpReq = ProgressionMath.XPRequired(lv)
	local totalXP = ProgressionMath.TotalXPToReachLevel(lv)
	local speedDisplay = ProgressionMath.SpeedFromTotalXP(totalXP)

	print(string.format("[PROGRESSION-TEST] %-5d | %-13s | %-12s | %s",
		lv,
		ProgressionMath.formatComma(xpReq),
		ProgressionMath.formatNumber(totalXP),
		ProgressionMath.formatNumber(speedDisplay)))
end

print("[PROGRESSION-TEST] ✅ TEST 3 COMPLETED")

-- Test 4: Edge cases
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] TEST 4: Edge Cases")
print("[PROGRESSION-TEST] ────────────────────────────────────────────")

local edge1_level, edge1_xp, edge1_req = ProgressionMath.LevelFromTotalXP(0)
print(string.format("[PROGRESSION-TEST] LevelFromTotalXP(0) = Level %d, XP %d/%d",
	edge1_level, edge1_xp, edge1_req))

if edge1_level == 1 and edge1_xp == 0 then
	print("[PROGRESSION-TEST] ✅ Edge case 1 PASSED (TotalXP=0)")
else
	warn("[PROGRESSION-TEST] ❌ Edge case 1 FAILED")
end

local edge2_level, edge2_xp, edge2_req = ProgressionMath.LevelFromTotalXP(1000000)
print(string.format("[PROGRESSION-TEST] LevelFromTotalXP(1,000,000) = Level %d, XP %s/%s",
	edge2_level, ProgressionMath.formatComma(edge2_xp), ProgressionMath.formatComma(edge2_req)))

if edge2_level > 1 and edge2_level < 10000 then
	print("[PROGRESSION-TEST] ✅ Edge case 2 PASSED (TotalXP=1M)")
else
	warn("[PROGRESSION-TEST] ❌ Edge case 2 FAILED")
end

print("[PROGRESSION-TEST] ✅ TEST 4 COMPLETED")

-- Test 5: WalkSpeed calculation
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] TEST 5: WalkSpeed Calculation")
print("[PROGRESSION-TEST] ────────────────────────────────────────────")

local walkSpeed1 = ProgressionMath.WalkSpeedFromLevel(1)
local walkSpeed64 = ProgressionMath.WalkSpeedFromLevel(64)
local walkSpeed500 = ProgressionMath.WalkSpeedFromLevel(500)
local walkSpeed1000 = ProgressionMath.WalkSpeedFromLevel(1000)

print(string.format("[PROGRESSION-TEST] WalkSpeed(Level 1) = %.1f (expected: 17)", walkSpeed1))
print(string.format("[PROGRESSION-TEST] WalkSpeed(Level 64) = %.1f (expected: 80)", walkSpeed64))
print(string.format("[PROGRESSION-TEST] WalkSpeed(Level 500) = %.1f (expected: 516)", walkSpeed500))
print(string.format("[PROGRESSION-TEST] WalkSpeed(Level 1000) = %.1f (expected: 516 - capped)", walkSpeed1000))

if walkSpeed1 == 17 and walkSpeed64 == 80 and walkSpeed500 == 516 and walkSpeed1000 == 516 then
	print("[PROGRESSION-TEST] ✅ TEST 5 PASSED")
else
	warn("[PROGRESSION-TEST] ❌ TEST 5 FAILED")
end

-- Final summary
print("[PROGRESSION-TEST]")
print("[PROGRESSION-TEST] ============================================")
print("[PROGRESSION-TEST] VALIDATION COMPLETE!")
print("[PROGRESSION-TEST] Check logs above for any ❌ FAILED tests")
print("[PROGRESSION-TEST] ============================================")
