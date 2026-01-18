-- VERIFY_ROLLING_BALLS.lua
-- Run in Command Bar (SERVER) to check RollingBallController status

-- ==================== COPY FROM HERE ====================
local ServerScriptService = game:GetService("ServerScriptService")
local workspace = game:GetService("Workspace")

print("🔍 ==================== ROLLING BALLS VERIFICATION ====================")
print("")

-- Check for required objects in workspace
print("📦 Checking Workspace objects...")
print("")

local requiredObjects = {
    "sphere1",
    "sphere2",
    "BallRollPart1",
    "BallRollPart2"
}

local allObjectsExist = true
for _, objName in ipairs(requiredObjects) do
    local obj = workspace:FindFirstChild(objName)
    if obj then
        print("   ✅ " .. objName .. " exists")
        print("      Position: " .. tostring(obj.Position))
        print("      Size: " .. tostring(obj.Size))
    else
        warn("   ❌ " .. objName .. " NOT FOUND!")
        allObjectsExist = false
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check for RollingBallController script
print("📜 Checking RollingBallController script...")
print("")

local controller = ServerScriptService:FindFirstChild("RollingBallController", true)
if controller then
    print("   ✅ RollingBallController found")
    print("      Location: " .. controller:GetFullName())
    print("      Enabled: " .. tostring(controller.Enabled))
    print("      ClassName: " .. controller.ClassName)

    if not controller.Enabled then
        warn("   ⚠️ Script is DISABLED! Enable it to start rolling balls.")
    else
        print("   ✅ Script is ENABLED and should be running")
    end
else
    warn("   ❌ RollingBallController NOT FOUND in ServerScriptService!")
    warn("   Make sure Rojo is syncing the file from src/server/")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Summary
print("📋 SUMMARY:")
print("")

if allObjectsExist and controller and controller.Enabled then
    print("✅ Everything is ready! Rolling balls should be working.")
    print("   - All 4 objects exist in workspace")
    print("   - RollingBallController is enabled")
    print("   - Balls should be rolling at SPEED 175")
elseif allObjectsExist and controller and not controller.Enabled then
    print("⚠️ Almost ready!")
    print("   ✅ All 4 objects exist in workspace")
    print("   ❌ RollingBallController is DISABLED")
    print("")
    print("💡 TO FIX:")
    print("   1. Go to ServerScriptService")
    print("   2. Find RollingBallController")
    print("   3. Right-click > Properties")
    print("   4. Check 'Enabled'")
    print("   5. Or just set: ServerScriptService.RollingBallController.Enabled = true")
elseif not allObjectsExist then
    print("❌ Missing required objects!")
    print("   Run CREATE_MISSING_ROLLING_BALLS.lua first")
elseif not controller then
    print("❌ RollingBallController script not found!")
    print("   Make sure Rojo is running and syncing from src/server/")
end

print("")
print("🔍 ==================== END VERIFICATION ====================")
-- ==================== COPY UNTIL HERE ====================
