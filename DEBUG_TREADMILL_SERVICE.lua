-- DEBUG_TREADMILL_SERVICE.lua
-- COMMAND BAR SCRIPT - Run on SERVER while game is running
-- Forces TreadmillService debug mode and checks player state

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")

print("🔍 ==================== TREADMILL SERVICE DEBUG ====================")

-- Check if TreadmillService global exists
if not _G.TreadmillService then
	warn("❌ _G.TreadmillService NOT FOUND!")
	warn("   This means TreadmillService.server.lua didn't load properly")
	return
end

print("✅ _G.TreadmillService found")

-- Enable debug mode
if _G.TreadmillService.setDebug then
	_G.TreadmillService.setDebug(true)
	print("✅ Debug mode ENABLED")
else
	warn("⚠️ setDebug function not found")
end

-- Check each player's state
print("")
print("📋 Current Player States:")

for _, player in ipairs(Players:GetPlayers()) do
	print("")
	print("👤 Player: " .. player.Name)

	-- Check attributes
	local onTreadmill = player:GetAttribute("OnTreadmill")
	local multiplier = player:GetAttribute("CurrentTreadmillMultiplier")
	print("   Attributes:")
	print("      OnTreadmill: " .. tostring(onTreadmill))
	print("      Multiplier: " .. tostring(multiplier))

	-- Query TreadmillService
	if _G.TreadmillService.isPlayerOnTreadmill then
		local isOn = _G.TreadmillService.isPlayerOnTreadmill(player)
		print("   TreadmillService.isPlayerOnTreadmill: " .. tostring(isOn))
	end

	if _G.TreadmillService.getPlayerMultiplier then
		local mult = _G.TreadmillService.getPlayerMultiplier(player)
		print("   TreadmillService.getPlayerMultiplier: " .. tostring(mult))
	end

	-- Get zone info
	if _G.TreadmillService.getPlayerZone then
		local zoneData, zoneInstance = _G.TreadmillService.getPlayerZone(player)
		if zoneData then
			print("   Current Zone:")
			print("      Instance: " .. zoneInstance:GetFullName())
			print("      Multiplier: " .. zoneData.Multiplier)
			print("      IsFree: " .. tostring(zoneData.IsFree))
		else
			print("   Current Zone: NONE")
		end
	end
end

-- Get service stats
print("")
if _G.TreadmillService.getStats then
	local stats = _G.TreadmillService.getStats()
	print("📊 TreadmillService Stats:")
	print("   Total zones registered: " .. stats.totalZones)
	print("   Free zones: " .. stats.freeZones)
	print("   Paid zones: " .. stats.paidZones)
end

print("")
print("💡 Now walk onto a treadmill and watch the Output for [TreadmillService] logs")
print("🔍 ==================== END DEBUG ====================")
-- ==================== COPY UNTIL HERE ====================
