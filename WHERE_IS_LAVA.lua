-- WHERE_IS_LAVA.lua
-- Paste in Studio SERVER console to find where lava parts are located

print("==================== FINDING ALL LAVA PARTS ====================")

local CollectionService = game:GetService("CollectionService")

local KILL_PART_NAMES = {
    "Lava", "lava", "LAVA", "KillBrick", "Killbrick", "killbrick", "Kill", "Toxic", "Acid"
}

local lavaParts = {}

-- Search by name
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

-- Search by tag
local taggedParts = CollectionService:GetTagged("KillOnTouch")
for _, part in ipairs(taggedParts) do
    if not table.find(lavaParts, part) then
        table.insert(lavaParts, part)
    end
end

print("\n📊 FOUND " .. #lavaParts .. " LAVA PARTS:\n")

if #lavaParts == 0 then
    warn("❌ NO LAVA PARTS FOUND!")
    warn("\nSearching all workspace for ANY part with these names:")
    for _, name in ipairs(KILL_PART_NAMES) do
        print("   - " .. name)
    end
else
    for i, part in ipairs(lavaParts) do
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("LAVA PART #" .. i .. "/" .. #lavaParts)
        print("   Name: " .. part.Name)
        print("   FullName: " .. part:GetFullName())
        print("   ClassName: " .. part.ClassName)
        print("   Parent: " .. tostring(part.Parent))

        -- Check critical properties
        print("\n   COLLISION PROPERTIES:")
        print("      CanCollide: " .. tostring(part.CanCollide))
        print("      CanTouch: " .. tostring(part.CanTouch))
        print("      CanQuery: " .. tostring(part.CanQuery))

        print("\n   PHYSICS:")
        print("      Anchored: " .. tostring(part.Anchored))
        print("      Transparency: " .. part.Transparency)
        print("      Size: " .. tostring(part.Size))
        print("      Position: " .. tostring(part.Position))

        -- Check parent hierarchy
        print("\n   HIERARCHY:")
        local current = part.Parent
        local depth = 1
        while current and current ~= game do
            local prefix = string.rep("      ", depth)
            print(prefix .. "↑ " .. current.Name .. " (" .. current.ClassName .. ")")
            current = current.Parent
            depth = depth + 1
            if depth > 10 then break end  -- Safety limit
        end

        print("")
    end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("\n✅ ALL " .. #lavaParts .. " PARTS LISTED ABOVE")
    print("\n💡 SOLUTION:")
    print("   These parts exist in the Studio file but are NOT in your Rojo project.")
    print("   You need to either:")
    print("   1. Add them to default.project.json (recommended)")
    print("   2. Create them in a separate .rbxm file and load it")
    print("   3. Create them via script")
end

print("\n==================== END ====================")
