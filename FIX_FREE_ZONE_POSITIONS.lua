-- FIX_FREE_ZONE_POSITIONS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Fixes FREE zone positions to match the actual floor height

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING FREE ZONE POSITIONS ====================")
print("")

-- Find SpawnLocation to get the floor height
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
local floorHeight = 1  -- Default

if spawnLocation then
    floorHeight = spawnLocation.Position.Y + (spawnLocation.Size.Y / 2)
    print("✅ Found SpawnLocation")
    print("   Position Y: " .. spawnLocation.Position.Y)
    print("   Floor height: " .. floorHeight)
else
    warn("⚠️ SpawnLocation not found, using default floor height: " .. floorHeight)
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Find all TreadmillFree models
local freeModels = {}
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "TreadmillFree" and obj:IsA("Model") then
        table.insert(freeModels, obj)
    end
end

print("📋 Found " .. #freeModels .. " TreadmillFree models")
print("")

local fixedCount = 0

for i, model in ipairs(freeModels) do
    local zonePart = model:FindFirstChild("TreadmillZone")
    
    if zonePart then
        local oldPos = zonePart.Position
        local oldY = oldPos.Y
        
        -- Calculate new Y position (floor height - half of zone height)
        local newY = floorHeight - (zonePart.Size.Y / 2)
        
        if math.abs(oldY - newY) > 0.1 then
            -- Update position
            zonePart.Position = Vector3.new(oldPos.X, newY, oldPos.Z)
            fixedCount = fixedCount + 1
            
            print("✅ Fixed TreadmillFree #" .. i)
            print("   Old Y: " .. string.format("%.1f", oldY))
            print("   New Y: " .. string.format("%.1f", newY))
            print("   Position: " .. tostring(zonePart.Position))
            print("")
        else
            print("ℹ️ TreadmillFree #" .. i .. " already at correct height")
            print("")
        end
    end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

if fixedCount > 0 then
    print("✅ Fixed " .. fixedCount .. " FREE zones!")
    print("")
    print("💾 IMPORTANT: SAVE the file now (Ctrl+S / Cmd+S)!")
    print("")
    print("🎮 Next steps:")
    print("   1. Save the file")
    print("   2. Run the game and test FREE zones")
    print("   3. They should now give XP multiplier!")
    print("")
else
    print("✅ All FREE zones are already at correct height")
    print("")
end

print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
