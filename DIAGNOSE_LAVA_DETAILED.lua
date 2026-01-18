-- DIAGNOSE_LAVA_DETAILED.lua
-- Detailed inspection of lava parts to understand why Touched events aren't firing
-- PASTE THIS IN STUDIO SERVER CONSOLE (Command Bar)

print("==================== DETAILED LAVA DIAGNOSIS ====================")

local CollectionService = game:GetService("CollectionService")

local KILL_PART_NAMES = {
    "Lava", "lava", "LAVA", "KillBrick", "Killbrick", "killbrick", "Kill", "Toxic", "Acid"
}

local lavaParts = {}

-- Find all lava parts
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        for _, name in ipairs(KILL_PART_NAMES) do
            if obj.Name == name then
                table.insert(lavaParts, obj)
                break
            end
        end
    end
end

-- Also check tagged parts
local taggedParts = CollectionService:GetTagged("KillOnTouch")
for _, part in ipairs(taggedParts) do
    if not table.find(lavaParts, part) then
        table.insert(lavaParts, part)
    end
end

print("\nFound " .. #lavaParts .. " lava parts")
print("\n" .. string.rep("=", 70))

for i, part in ipairs(lavaParts) do
    print("\n🔥 PART #" .. i .. ": " .. part:GetFullName())
    print("   ClassName: " .. part.ClassName)
    print("   Name: " .. part.Name)

    -- Critical properties for Touched events
    print("\n   🔑 CRITICAL PROPERTIES:")
    print("      CanCollide: " .. tostring(part.CanCollide))
    print("      CanTouch: " .. tostring(part.CanTouch))
    print("      CanQuery: " .. tostring(part.CanQuery))

    -- Other relevant properties
    print("\n   📊 OTHER PROPERTIES:")
    print("      Anchored: " .. tostring(part.Anchored))
    print("      Transparency: " .. part.Transparency)
    print("      Size: " .. tostring(part.Size))
    print("      Position: " .. tostring(part.Position))
    print("      CollisionGroup: " .. part.CollisionGroup)

    -- Check if it has Touched connections
    local connections = 0
    local hasKillSetup = part:GetAttribute("KillSetup")
    print("\n   🔌 CONNECTIONS:")
    print("      Has KillSetup attribute: " .. tostring(hasKillSetup))

    -- Check parent
    print("\n   📁 HIERARCHY:")
    print("      Parent: " .. tostring(part.Parent))
    if part.Parent and part.Parent:IsA("Model") then
        print("      Parent is Model: true")
        print("      Model Name: " .. part.Parent.Name)
    end

    print("\n   " .. string.rep("-", 66))
end

print("\n" .. string.rep("=", 70))
print("\n🔧 RECOMMENDED FIXES:")

local needsFixing = false
for _, part in ipairs(lavaParts) do
    if not part.CanCollide or not part.CanTouch then
        needsFixing = true
        print("   ❌ " .. part.Name .. " needs CanCollide=" .. tostring(not part.CanCollide and "true" or "OK") ..
              ", CanTouch=" .. tostring(not part.CanTouch and "true" or "OK"))
    end
end

if not needsFixing then
    print("   ✅ All parts have correct CanCollide and CanTouch settings")
    print("\n   🤔 If Touched still doesn't work, possible issues:")
    print("      1. Player character parts might have CanCollide=false")
    print("      2. CollisionGroups might be preventing collisions")
    print("      3. Parts might be too small or positioned incorrectly")
    print("      4. Script might not be running or connections not made")
end

print("\n==================== END DIAGNOSIS ====================")
