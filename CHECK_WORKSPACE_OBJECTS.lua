-- CHECK_WORKSPACE_OBJECTS.lua
-- Run in Command Bar (SERVER or CLIENT) to verify required objects exist
-- Checks all objects needed by the game scripts

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== WORKSPACE OBJECTS CHECK ====================")
print("")

local missingObjects = {}
local foundObjects = {}

-- Define all required objects
local requiredObjects = {
    -- NoobNPC system
    {name = "Buff Noob", type = "Model", reason = "NoobNpcAI.server.lua needs this"},
    {name = "Stage2NpcKill", type = "Folder", reason = "NoobNpcAI.server.lua needs this (patrol area)"},

    -- Rolling Balls
    {name = "sphere1", type = "Part", reason = "RollingBallController.server.lua needs this"},
    {name = "sphere2", type = "Part", reason = "RollingBallController.server.lua needs this"},
    {name = "BallRollPart1", type = "Part", reason = "RollingBallController.server.lua needs this"},
    {name = "BallRollPart2", type = "Part", reason = "RollingBallController.server.lua needs this"},

    -- Leaderboard displays
    {name = "SpeedLeaderboard", type = "Model", reason = "LeaderboardUpdater.server.lua needs this", optional = true},
    {name = "WinsLeaderboard", type = "Model", reason = "LeaderboardUpdater.server.lua needs this", optional = true},
}

-- Check each object
for _, objInfo in ipairs(requiredObjects) do
    local obj = workspace:FindFirstChild(objInfo.name)

    if obj then
        table.insert(foundObjects, objInfo)
        print("✅ FOUND: " .. objInfo.name)
        print("   Type: " .. obj.ClassName)

        if obj:IsA("Model") then
            local childCount = #obj:GetChildren()
            print("   Children: " .. childCount)

            -- Special checks
            if objInfo.name == "Buff Noob" then
                local humanoid = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local head = obj:FindFirstChild("Head")

                if not humanoid then
                    warn("   ⚠️ Missing Humanoid!")
                end
                if not hrp then
                    warn("   ⚠️ Missing HumanoidRootPart!")
                end
                if not head then
                    warn("   ⚠️ Missing Head!")
                end
            elseif objInfo.name == "Stage2NpcKill" then
                local partCount = 0
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then
                        partCount = partCount + 1
                    end
                end
                print("   Parts inside: " .. partCount)

                if partCount == 0 then
                    warn("   ⚠️ No Parts inside! Add Parts to define patrol area.")
                end
            end
        end
    else
        table.insert(missingObjects, objInfo)

        if objInfo.optional then
            print("⚠️ MISSING (optional): " .. objInfo.name)
        else
            warn("❌ MISSING (required): " .. objInfo.name)
        end
        print("   Reason: " .. objInfo.reason)
    end

    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Summary
print("📊 SUMMARY:")
print("   Found: " .. #foundObjects .. "/" .. #requiredObjects)
print("   Missing: " .. #missingObjects)
print("")

if #missingObjects == 0 then
    print("✅ All required objects exist in Workspace!")
    print("   Your game should work correctly.")
else
    warn("❌ Missing " .. #missingObjects .. " objects!")
    print("")
    print("💡 ACTIONS NEEDED:")
    print("")

    for _, objInfo in ipairs(missingObjects) do
        if not objInfo.optional then
            print("❌ CREATE: " .. objInfo.name .. " (" .. objInfo.type .. ")")

            if objInfo.name == "Buff Noob" then
                print("   1. Insert > Rig > R15 (or R6)")
                print("   2. Rename to 'Buff Noob'")
                print("   3. Customize appearance if desired")

            elseif objInfo.name == "Stage2NpcKill" then
                print("   1. Insert > Folder")
                print("   2. Rename to 'Stage2NpcKill'")
                print("   3. Add Parts inside to define patrol area")

            elseif objInfo.name:match("sphere") or objInfo.name:match("BallRoll") then
                print("   1. Run: CREATE_MISSING_ROLLING_BALLS.lua")
                print("   OR create manually:")
                print("   2. Insert > Part")
                print("   3. Rename to '" .. objInfo.name .. "'")

            elseif objInfo.name:match("Leaderboard") then
                print("   1. Insert > Model")
                print("   2. Rename to '" .. objInfo.name .. "'")
                print("   3. Add SurfaceGui with leaderboard layout")
                print("   (or disable LeaderboardUpdater.server.lua)")
            end

            print("")
        end
    end
end

print("🔍 ==================== END CHECK ====================")
-- ==================== COPY UNTIL HERE ====================
