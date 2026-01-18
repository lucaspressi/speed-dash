-- ENABLE_ROLLING_BALLS.lua
-- Run in Command Bar (SERVER) to enable RollingBallController

-- ==================== COPY FROM HERE ====================
local ServerScriptService = game:GetService("ServerScriptService")

print("🎮 ==================== ENABLING ROLLING BALLS ====================")
print("")

-- Find the RollingBallController
local controller = ServerScriptService:FindFirstChild("RollingBallController", true)

if not controller then
    warn("❌ RollingBallController NOT FOUND in ServerScriptService!")
    warn("   Make sure Rojo is syncing the file from src/server/")
    print("")
    print("💡 Check:")
    print("   1. Is Rojo running? (rojo serve)")
    print("   2. Is Studio connected to Rojo?")
    print("   3. Does src/server/RollingBallController.server.lua exist?")
    return
end

print("📜 Found RollingBallController at: " .. controller:GetFullName())
print("   Current status: " .. (controller.Enabled and "ENABLED ✅" or "DISABLED ❌"))
print("")

if controller.Enabled then
    print("✅ RollingBallController is already ENABLED!")
    print("   Rolling balls should be working at SPEED 175")
else
    print("🔧 Enabling RollingBallController...")
    controller.Enabled = true
    wait(0.5)

    if controller.Enabled then
        print("✅ SUCCESS! RollingBallController is now ENABLED")
        print("")
        print("🎯 What to expect:")
        print("   - sphere1 and sphere2 will start rolling")
        print("   - They roll at 175 studs/second")
        print("   - They reset to start position when reaching the end")
        print("   - They kill players on touch (instant death)")
        print("")
        print("📍 Check the Output window for:")
        print("   'Rolling balls - SPEED 175!'")
    else
        warn("❌ Failed to enable RollingBallController")
        warn("   Try enabling manually in Studio")
    end
end

print("")
print("🎮 ==================== DONE ====================")
-- ==================== COPY UNTIL HERE ====================
