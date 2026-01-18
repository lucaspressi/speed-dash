-- DIAGNOSE_ROLLING_BALLS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Checks if rolling ball objects exist

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== DIAGNOSE ROLLING BALLS ====================")
print("")

-- Check for required objects
local requiredObjects = {
    "sphere1",
    "sphere2",
    "BallRollPart1",
    "BallRollPart2"
}

print("📋 Checking for required objects...")
print("")

local allFound = true

for _, objectName in ipairs(requiredObjects) do
    local obj = workspace:FindFirstChild(objectName)
    
    if obj then
        print("✅ Found: " .. objectName)
        print("   ClassName: " .. obj.ClassName)
        print("   Position: " .. tostring(obj.Position))
        print("   Size: " .. tostring(obj.Size))
        print("   Anchored: " .. tostring(obj.Anchored))
        print("")
    else
        warn("❌ NOT FOUND: " .. objectName)
        allFound = false
        print("")
    end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

if allFound then
    print("✅ All required objects found!")
    print("")
    print("💡 RollingBallController can be ENABLED:")
    print("   1. Go to ServerScriptService")
    print("   2. Find RollingBallController")
    print("   3. Set Enabled = true")
    print("   4. Run the game")
    print("")
else
    warn("❌ Missing objects!")
    warn("")
    warn("💡 RollingBallController needs these objects to work:")
    warn("   - sphere1: The first rolling ball")
    warn("   - sphere2: The second rolling ball")
    warn("   - BallRollPart1: The first track/path")
    warn("   - BallRollPart2: The second track/path")
    warn("")
    warn("   Add these objects to Workspace or keep RollingBallController disabled")
    print("")
end

print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
