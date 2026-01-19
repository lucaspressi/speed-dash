-- ANALYZE_XP_PROGRESSION.lua
-- COMMAND BAR SCRIPT - Run on SERVER to analyze XP progression
-- Shows how much XP is required for each level

-- ==================== COPY FROM HERE ====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressionMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionMath"))

print("📊 ==================== XP PROGRESSION ANALYSIS ====================")
print("")

-- Analyze first 100 levels
print("🔍 XP Required per Level (first 20 levels):")
print("")

for level = 1, 20 do
	local xpRequired = ProgressionMath.XPRequired(level)
	local totalXPToReach = ProgressionMath.TotalXPToReachLevel(level)
	print(string.format("  Level %3d: %10s XP to next | Total: %12s XP",
		level,
		ProgressionMath.formatComma(xpRequired),
		ProgressionMath.formatComma(totalXPToReach)
	))
end

print("")
print("🔍 Sample of higher levels:")
print("")

local sampleLevels = {25, 30, 40, 50, 64, 75, 100, 150, 200}
for _, level in ipairs(sampleLevels) do
	local xpRequired = ProgressionMath.XPRequired(level)
	local totalXPToReach = ProgressionMath.TotalXPToReachLevel(level)
	print(string.format("  Level %3d: %10s XP to next | Total: %12s XP",
		level,
		ProgressionMath.formatComma(xpRequired),
		ProgressionMath.formatComma(totalXPToReach)
	))
end

print("")
print("💡 ==================== GAIN RATE ANALYSIS ====================")
print("")
print("Assuming base gain (no boosts):")
print("  - 1 XP per step")
print("  - Walking gives ~1-2 steps per second")
print("")

-- Calculate time to level up at different levels
local levelsToAnalyze = {1, 5, 10, 20, 30, 50, 64}
for _, level in ipairs(levelsToAnalyze) do
	local xpRequired = ProgressionMath.XPRequired(level)
	local stepsNeeded = xpRequired
	local timeInSeconds = stepsNeeded / 1.5  -- ~1.5 XP per second walking
	local timeInMinutes = timeInSeconds / 60

	print(string.format("  Level %2d → %2d: %s XP = ~%.1f minutes of walking",
		level,
		level + 1,
		ProgressionMath.formatComma(xpRequired),
		timeInMinutes
	))
end

print("")
print("⚠️  ISSUES DETECTED:")
print("")

-- Check if progression is too steep
local level10XP = ProgressionMath.XPRequired(10)
local level50XP = ProgressionMath.XPRequired(50)
local level100XP = ProgressionMath.XPRequired(100)

if level10XP > 50000 then
	print("  ❌ Level 10 requires " .. ProgressionMath.formatComma(level10XP) .. " XP (too high!)")
end

if level50XP > 500000 then
	print("  ❌ Level 50 requires " .. ProgressionMath.formatComma(level50XP) .. " XP (too high!)")
end

if level100XP > 2000000 then
	print("  ❌ Level 100 requires " .. ProgressionMath.formatComma(level100XP) .. " XP (too high!)")
end

local timeToLevel10 = ProgressionMath.TotalXPToReachLevel(10) / (1.5 * 60)  -- minutes
if timeToLevel10 > 30 then
	print("  ❌ Reaching Level 10 takes ~" .. string.format("%.1f", timeToLevel10) .. " minutes (too long!)")
end

print("")
print("💡 RECOMMENDATIONS:")
print("")
print("  To make progression feel better:")
print("  1. Reduce BASE from 20,000 to ~1,000-5,000")
print("  2. Reduce SCALE from 500 to ~100-200")
print("  3. Consider reducing EXPONENT from 1.65 to ~1.5")
print("")
print("  This will make early game more fun and progression feel smoother")
print("")
print("📊 ==================== END ANALYSIS ====================")
-- ==================== COPY UNTIL HERE ====================
