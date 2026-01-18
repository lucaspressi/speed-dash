-- CHECK_XP_GAIN.lua
-- COMMAND BAR SCRIPT - Run on SERVER while on treadmill
-- Monitors XP changes in real-time

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")

local player = Players:FindFirstChild("Xxpress1xX")  -- ⚠️ Change this to your username!

if not player then
	warn("❌ Player not found!")
	return
end

print("🔍 ==================== XP GAIN MONITOR ====================")
print("👤 Monitoring: " .. player.Name)
print("")

-- Access player data from SpeedGameServer
if not _G.SpeedGame_PlayerData then
	warn("❌ _G.SpeedGame_PlayerData not found!")
	warn("   SpeedGameServer may not be loaded yet")
	return
end

local data = _G.SpeedGame_PlayerData[player.UserId]
if not data then
	warn("❌ Player data not found for " .. player.Name)
	return
end

print("📊 Current Player Data:")
print("   XP: " .. data.XP)
print("   Level: " .. data.Level)
print("   StepBonus: " .. data.StepBonus)
print("   Multiplier: " .. data.Multiplier)
print("   TreadmillX3Owned: " .. tostring(data.TreadmillX3Owned))
print("   TreadmillX9Owned: " .. tostring(data.TreadmillX9Owned))
print("   TreadmillX25Owned: " .. tostring(data.TreadmillX25Owned))
print("")

-- Monitor for 10 seconds
print("⏱️ Monitoring XP for 10 seconds...")
print("   (Stand on a treadmill and walk!)")
print("")

local startXP = data.XP
local startTime = tick()

task.wait(10)

local endXP = data.XP
local endTime = tick()
local elapsed = endTime - startTime
local xpGained = endXP - startXP

print("📈 Results after " .. string.format("%.1f", elapsed) .. " seconds:")
print("   Start XP: " .. startXP)
print("   End XP: " .. endXP)
print("   XP Gained: " .. xpGained)
print("   XP/sec: " .. string.format("%.1f", xpGained / elapsed))
print("")

if xpGained == 0 then
	warn("❌ NO XP GAINED!")
	warn("   Possible causes:")
	warn("   1. Not moving/walking")
	warn("   2. Not on a treadmill")
	warn("   3. Don't own the treadmill (check ownership above)")
else
	print("✅ XP is being gained!")
end

print("🔍 ==================== END MONITOR ====================")
-- ==================== COPY UNTIL HERE ====================
