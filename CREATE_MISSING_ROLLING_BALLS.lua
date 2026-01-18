-- CREATE_MISSING_ROLLING_BALLS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Creates missing sphere2 and BallRollPart2 based on existing objects

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== CREATING MISSING ROLLING BALLS ====================")
print("")

-- Check existing objects
local sphere1 = workspace:FindFirstChild("sphere1")
local ballRollPart1 = workspace:FindFirstChild("BallRollPart1")

if not sphere1 or not ballRollPart1 then
    warn("❌ Cannot create missing objects - sphere1 or BallRollPart1 not found!")
    warn("   Both must exist to clone them")
    return
end

print("✅ Found existing objects to clone from")
print("")

-- Create sphere2 (clone of sphere1)
local sphere2 = workspace:FindFirstChild("sphere2")
if not sphere2 then
    sphere2 = sphere1:Clone()
    sphere2.Name = "sphere2"
    
    -- Position it on opposite side (mirror across Z axis)
    local offset = 440  -- Distance between the two tracks
    sphere2.Position = sphere1.Position + Vector3.new(0, 0, offset)
    
    sphere2.Parent = workspace
    
    print("✅ Created sphere2")
    print("   Position: " .. tostring(sphere2.Position))
    print("   Size: " .. tostring(sphere2.Size))
    print("")
else
    print("ℹ️ sphere2 already exists")
    print("")
end

-- Create BallRollPart2 (clone of BallRollPart1)
local ballRollPart2 = workspace:FindFirstChild("BallRollPart2")
if not ballRollPart2 then
    ballRollPart2 = ballRollPart1:Clone()
    ballRollPart2.Name = "BallRollPart2"
    
    -- Position it parallel to BallRollPart1
    local offset = 440  -- Same offset as spheres
    ballRollPart2.Position = ballRollPart1.Position + Vector3.new(0, 0, offset)
    
    ballRollPart2.Parent = workspace
    
    print("✅ Created BallRollPart2")
    print("   Position: " .. tostring(ballRollPart2.Position))
    print("   Size: " .. tostring(ballRollPart2.Size))
    print("")
else
    print("ℹ️ BallRollPart2 already exists")
    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("✅ Rolling ball objects created!")
print("")
print("💾 IMPORTANT: SAVE the file now (Ctrl+S / Cmd+S)!")
print("")
print("🎮 Next steps:")
print("   1. Save the file")
print("   2. Go to ServerScriptService")
print("   3. Find RollingBallController")
print("   4. Set Enabled = true")
print("   5. Run the game and test!")
print("")
print("💡 The balls will roll back and forth on their tracks and KILL players on touch")
print("   Speed: 175 studs/second (very fast!)")
print("")
print("🔧 ==================== END CREATE ====================")
-- ==================== COPY UNTIL HERE ====================
