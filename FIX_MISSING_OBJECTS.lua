-- FIX_MISSING_OBJECTS.lua
-- Run in Command Bar (SERVER) to identify and fix missing objects
-- Tells you exactly what's missing and how to create it

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== MISSING OBJECTS FIXER ====================")
print("")

local missing = {}

-- Check Buff Noob
if not workspace:FindFirstChild("Buff Noob") then
    table.insert(missing, {
        name = "Buff Noob",
        type = "NPC Model",
        script = "CREATE_BUFF_NOOB_SCRIPT.lua",
        description = "The NPC that patrols and chases players"
    })
end

-- Check Stage2NpcKill
if not workspace:FindFirstChild("Stage2NpcKill") then
    table.insert(missing, {
        name = "Stage2NpcKill",
        type = "Folder with Parts",
        script = "CREATE_STAGE2_AREA.lua",
        description = "Defines where the NPC can patrol"
    })
else
    -- Check if it has parts inside
    local stage2 = workspace:FindFirstChild("Stage2NpcKill")
    local partCount = 0
    for _, child in pairs(stage2:GetChildren()) do
        if child:IsA("BasePart") then
            partCount = partCount + 1
        end
    end

    if partCount == 0 then
        table.insert(missing, {
            name = "Stage2NpcKill (has no Parts!)",
            type = "Needs Parts inside",
            script = "CREATE_STAGE2_AREA.lua",
            description = "Folder exists but needs Parts to define boundaries"
        })
    end
end

-- Check Rolling Balls
if not workspace:FindFirstChild("sphere1") then
    table.insert(missing, {
        name = "sphere1",
        type = "Rolling Ball Part",
        script = "CREATE_MISSING_ROLLING_BALLS.lua",
        description = "First rolling obstacle ball"
    })
end

if not workspace:FindFirstChild("sphere2") then
    table.insert(missing, {
        name = "sphere2",
        type = "Rolling Ball Part",
        script = "CREATE_MISSING_ROLLING_BALLS.lua",
        description = "Second rolling obstacle ball"
    })
end

if not workspace:FindFirstChild("BallRollPart1") then
    table.insert(missing, {
        name = "BallRollPart1",
        type = "Ball Track Part",
        script = "CREATE_MISSING_ROLLING_BALLS.lua",
        description = "Track for sphere1 to roll on"
    })
end

if not workspace:FindFirstChild("BallRollPart2") then
    table.insert(missing, {
        name = "BallRollPart2",
        type = "Ball Track Part",
        script = "CREATE_MISSING_ROLLING_BALLS.lua",
        description = "Track for sphere2 to roll on"
    })
end

-- Report
if #missing == 0 then
    print("✅ All required objects exist in Workspace!")
    print("   Your game should work correctly.")
    print("")
    print("If you still have issues:")
    print("   1. Check Output window for errors")
    print("   2. Run DIAGNOSE_ALL_SYSTEMS.lua")
    print("   3. Make sure all scripts are enabled")
else
    print("❌ MISSING " .. #missing .. " OBJECT(S):")
    print("")

    for i, obj in ipairs(missing) do
        print(i .. ". " .. obj.name)
        print("   Type: " .. obj.type)
        print("   Description: " .. obj.description)
        print("   📜 FIX: Run script → " .. obj.script)
        print("")
    end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("")
    print("🎯 QUICK FIX INSTRUCTIONS:")
    print("")

    -- Group by script
    local scripts = {}
    for _, obj in ipairs(missing) do
        if not scripts[obj.script] then
            scripts[obj.script] = {}
        end
        table.insert(scripts[obj.script], obj.name)
    end

    local scriptNum = 1
    for scriptName, objects in pairs(scripts) do
        print(scriptNum .. ". Copy and run: " .. scriptName)
        print("   This will create:")
        for _, objName in ipairs(objects) do
            print("   - " .. objName)
        end
        print("")
        scriptNum = scriptNum + 1
    end

    print("After running the scripts:")
    print("   1. Save (Ctrl+S)")
    print("   2. Publish (File > Publish to Roblox)")
    print("   3. Test in production")
end

print("")
print("🔧 ==================== END FIXER ====================")
-- ==================== COPY UNTIL HERE ====================
