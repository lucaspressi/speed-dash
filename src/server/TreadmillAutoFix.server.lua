-- TreadmillAutoFix.server.lua
-- Automatically fixes FREE treadmill positions on server boot
-- This ensures FREE zones work even if deployed with wrong positions

local workspace = game:GetService("Workspace")

print("[TreadmillAutoFix] ==================== AUTO-FIX STARTING ====================")

-- Wait for workspace to fully load
task.wait(2)

-- Find SpawnLocation to determine correct floor height
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
local floorHeight = 1  -- Default

if spawnLocation then
    -- Calculate floor height from SpawnLocation
    floorHeight = spawnLocation.Position.Y + (spawnLocation.Size.Y / 2)
    print("[TreadmillAutoFix] Floor height detected: " .. floorHeight .. " (from SpawnLocation)")
else
    print("[TreadmillAutoFix] No SpawnLocation found, using default floor height: " .. floorHeight)
end

-- Find all FREE TreadmillZone parts
local freeZones = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
        local multiplier = obj:GetAttribute("Multiplier")
        local isFree = obj:GetAttribute("IsFree")

        if multiplier == 1 or isFree == true then
            table.insert(freeZones, obj)
        end
    end
end

print("[TreadmillAutoFix] Found " .. #freeZones .. " FREE zones")

if #freeZones == 0 then
    print("[TreadmillAutoFix] No FREE zones found - nothing to fix")
    return
end

-- Fix each FREE zone
local fixedCount = 0
local alreadyCorrectCount = 0

for i, zonePart in ipairs(freeZones) do
    local oldPos = zonePart.Position
    local oldY = oldPos.Y

    -- Calculate correct Y position (center of part should be at floor level)
    local correctY = floorHeight - (zonePart.Size.Y / 2)

    -- Only fix if Y is wrong (tolerance: 0.5 studs)
    if math.abs(oldY - correctY) > 0.5 then
        local newPos = Vector3.new(oldPos.X, correctY, oldPos.Z)
        zonePart.Position = newPos

        print(string.format("[TreadmillAutoFix] ✅ Fixed zone #%d: %s", i, zonePart:GetFullName()))
        print(string.format("[TreadmillAutoFix]    Y: %.1f → %.1f", oldY, correctY))

        fixedCount = fixedCount + 1
    else
        print(string.format("[TreadmillAutoFix] ✓ Zone #%d already correct: %s (Y=%.1f)", i, zonePart:GetFullName(), oldY))
        alreadyCorrectCount = alreadyCorrectCount + 1
    end
end

print("[TreadmillAutoFix] ==================== AUTO-FIX COMPLETE ====================")
print("[TreadmillAutoFix] Fixed: " .. fixedCount)
print("[TreadmillAutoFix] Already correct: " .. alreadyCorrectCount)
print("[TreadmillAutoFix] Total: " .. #freeZones)

if fixedCount > 0 then
    print("[TreadmillAutoFix] ✅ FREE zones have been auto-corrected and should now work!")
else
    print("[TreadmillAutoFix] ✅ All FREE zones were already at correct height")
end
