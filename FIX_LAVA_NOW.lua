-- FIX_LAVA_NOW.lua
-- Emergency lava fix script - paste in Studio SERVER console
-- This will force-fix all lava parts and setup Touched events immediately

print("==================== EMERGENCY LAVA FIX ====================")

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local KILL_PART_NAMES = {
    "Lava", "lava", "LAVA", "KillBrick", "Killbrick", "killbrick", "Kill", "Toxic", "Acid"
}

local function killPlayer(player, part)
    print("💀 KILLING: " .. player.Name .. " (touched " .. part.Name .. ")")
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
            return true
        end
    end
    return false
end

local function setupKillPart(part)
    print("\n🔧 FIXING: " .. part:GetFullName())

    -- Force ALL collision properties
    part.CanCollide = true
    part.CanTouch = true
    part.CanQuery = true
    part.Anchored = true

    print("   ✅ CanCollide: " .. tostring(part.CanCollide))
    print("   ✅ CanTouch: " .. tostring(part.CanTouch))
    print("   ✅ CanQuery: " .. tostring(part.CanQuery))
    print("   ✅ Anchored: " .. tostring(part.Anchored))

    -- Clear any existing connections
    local connections = part:GetConnections()
    for _, conn in ipairs(connections) do
        if conn.FunctionName == "Touched" then
            conn:Disconnect()
            print("   🗑️ Cleared old Touched connection")
        end
    end

    -- Create NEW Touched connection
    part.Touched:Connect(function(hit)
        print("🔥 TOUCHED! Part: " .. part.Name .. " | Hit: " .. tostring(hit))

        if not hit or not hit.Parent then
            print("   ⏭️ Invalid hit")
            return
        end

        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if player then
            print("   ✅ PLAYER DETECTED: " .. player.Name)
            killPlayer(player, part)
        else
            print("   ⏭️ Not a player (Parent: " .. tostring(hit.Parent.Name) .. ")")
        end
    end)

    print("   ✅ NEW Touched connection created!")
end

-- Find and fix all lava parts
local lavaParts = {}

print("\n🔍 SCANNING FOR LAVA PARTS...")

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

print("\n📊 FOUND " .. #lavaParts .. " LAVA PARTS\n")

if #lavaParts == 0 then
    warn("❌ NO LAVA PARTS FOUND!")
    warn("Make sure you have parts named: " .. table.concat(KILL_PART_NAMES, ", "))
else
    print("🔧 FIXING ALL LAVA PARTS...\n")

    for i, part in ipairs(lavaParts) do
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("PART " .. i .. "/" .. #lavaParts)
        setupKillPart(part)
    end

    print("\n" .. string.rep("━", 44))
    print("\n✅ ALL " .. #lavaParts .. " LAVA PARTS FIXED!")
    print("\n🧪 TEST: Walk into lava NOW - it should kill you instantly!")
    print("   If you see '🔥 TOUCHED!' messages, it's working!")
end

print("\n==================== FIX COMPLETE ====================")
