-- LavaKill.server.lua
-- Universal lava/kill brick script
-- Kills any player that touches parts with specific names or tags

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- ==================== CONFIGURATION ====================
local KILL_PART_NAMES = {
    "Lava",
    "lava",
    "LAVA",
    "KillBrick",
    "Killbrick",
    "killbrick",
    "Kill",
    "Toxic",
    "Acid"
}

local KILL_TAG = "KillOnTouch"  -- Use CollectionService tag
local DEBUG = true

-- ==================== SETUP ====================
local function debugLog(message)
    if DEBUG then
        print("[LavaKill] " .. message)
    end
end

local function setupKillTouch(part)
    if not part:IsA("BasePart") then return end

    -- Prevent duplicate connections
    if part:GetAttribute("KillSetup") then
        return
    end
    part:SetAttribute("KillSetup", true)

    -- CRITICAL: Force ALL collision properties to ensure Touched events work
    -- ALWAYS set these, don't check first
    part.CanCollide = true
    part.CanTouch = true
    part.CanQuery = true

    debugLog("⚙️ Configured collision properties on: " .. part:GetFullName())
    debugLog("   CanCollide=" .. tostring(part.CanCollide) ..
             " | CanTouch=" .. tostring(part.CanTouch) ..
             " | CanQuery=" .. tostring(part.CanQuery))

    part.Touched:Connect(function(hit)
        debugLog("🔥 TOUCHED EVENT! Hit=" .. tostring(hit) .. " | Parent=" .. tostring(hit.Parent))

        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if player then
            debugLog("✅ Player detected: " .. player.Name)
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                debugLog("💀 KILLING " .. player.Name .. " (Health=" .. humanoid.Health .. ")")
                humanoid.Health = 0
            else
                debugLog("⚠️ Humanoid not found or already dead")
            end
        else
            debugLog("⏭️ Not a player (hit.Parent=" .. tostring(hit.Parent) .. ")")
        end
    end)

    debugLog("✅ Setup kill touch on: " .. part:GetFullName())
end

-- ==================== SCAN WORKSPACE ====================
debugLog("==================== LAVA KILL SYSTEM STARTING ====================")

-- Wait for workspace to load
task.wait(2)

local killPartsFound = 0
local killPartsList = {}  -- Track all parts we find

-- Method 1: By name
debugLog("Scanning for kill parts by name...")
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        for _, name in ipairs(KILL_PART_NAMES) do
            if obj.Name == name then
                setupKillTouch(obj)
                table.insert(killPartsList, obj)
                killPartsFound = killPartsFound + 1
                debugLog("   Found: " .. obj:GetFullName())
                break
            end
        end
    end
end

-- Method 2: By tag
debugLog("Scanning for kill parts by tag '" .. KILL_TAG .. "'...")
local taggedParts = CollectionService:GetTagged(KILL_TAG)
for _, part in ipairs(taggedParts) do
    if not table.find(killPartsList, part) then
        setupKillTouch(part)
        table.insert(killPartsList, part)
        killPartsFound = killPartsFound + 1
        debugLog("   Found tagged: " .. part:GetFullName())
    end
end

-- Listen for new parts added dynamically
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)

    if obj:IsA("BasePart") then
        -- Check name
        for _, name in ipairs(KILL_PART_NAMES) do
            if obj.Name == name then
                setupKillTouch(obj)
                debugLog("Dynamically added kill part: " .. obj:GetFullName())
                break
            end
        end

        -- Check tag
        if CollectionService:HasTag(obj, KILL_TAG) then
            setupKillTouch(obj)
            debugLog("Dynamically added tagged kill part: " .. obj:GetFullName())
        end
    end
end)

-- Listen for parts tagged dynamically
CollectionService:GetInstanceAddedSignal(KILL_TAG):Connect(function(obj)
    setupKillTouch(obj)
    debugLog("Part tagged as kill: " .. obj:GetFullName())
end)

-- 🧪 PLAYER COLLISION DIAGNOSTICS
-- Check if player characters can collide with kill parts
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)  -- Wait for character to fully load

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            debugLog("🧍 Player " .. player.Name .. " character loaded:")
            debugLog("   HRP CanCollide: " .. tostring(hrp.CanCollide))
            debugLog("   HRP CanTouch: " .. tostring(hrp.CanTouch))
            debugLog("   HRP CollisionGroup: " .. hrp.CollisionGroup)

            -- Check all character parts
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch == false then
                    debugLog("   ⚠️ Part has CanTouch=false: " .. part.Name)
                end
            end
        end
    end)
end)

-- 🔄 WATCHDOG: Continuously verify and enforce lava properties
-- Some scripts or Roblox itself might reset properties
if killPartsFound > 0 then
    task.spawn(function()
        while true do
            task.wait(5)  -- Check every 5 seconds

            local fixedCount = 0
            for _, part in ipairs(killPartsList) do
                if part and part.Parent then
                    local needsFix = false

                    if not part.CanCollide then
                        part.CanCollide = true
                        needsFix = true
                    end

                    if not part.CanTouch then
                        part.CanTouch = true
                        needsFix = true
                    end

                    if not part.CanQuery then
                        part.CanQuery = true
                        needsFix = true
                    end

                    if needsFix then
                        fixedCount = fixedCount + 1
                        debugLog("🔧 Watchdog fixed properties on: " .. part:GetFullName())
                    end
                end
            end

            if fixedCount > 0 then
                warn("[LavaKill] ⚠️ Watchdog had to fix " .. fixedCount .. " parts! Something is resetting their properties.")
            end
        end
    end)
    debugLog("🔄 Watchdog started - will monitor and enforce lava properties every 5 seconds")
end

debugLog("==================== LAVA KILL SYSTEM READY ====================")
debugLog("Kill parts found: " .. killPartsFound)

if killPartsFound == 0 then
    warn("[LavaKill] ⚠️ NO KILL PARTS FOUND!")
    warn("[LavaKill] Make sure you have parts named: " .. table.concat(KILL_PART_NAMES, ", "))
    warn("[LavaKill] Or tag parts with '" .. KILL_TAG .. "' using CollectionService")
else
    debugLog("✅ " .. killPartsFound .. " kill parts activated!")

    -- 🧪 SELF-TEST: Verify Touched events are working
    debugLog("🧪 Running self-test on first kill part...")
    if killPartsList[1] then
        local testPart = killPartsList[1]
        debugLog("   Testing: " .. testPart:GetFullName())
        debugLog("   Properties:")
        debugLog("      CanCollide: " .. tostring(testPart.CanCollide))
        debugLog("      CanTouch: " .. tostring(testPart.CanTouch))
        debugLog("      CanQuery: " .. tostring(testPart.CanQuery))
        debugLog("      Anchored: " .. tostring(testPart.Anchored))
        debugLog("      Size: " .. tostring(testPart.Size))
        debugLog("      Position: " .. tostring(testPart.Position))

        -- Test by firing Touched with a test part
        local testTouchPart = Instance.new("Part")
        testTouchPart.Name = "TestTouch"
        testTouchPart.Size = Vector3.new(1, 1, 1)
        testTouchPart.Position = testPart.Position + Vector3.new(0, 2, 0)
        testTouchPart.Anchored = false
        testTouchPart.CanCollide = true
        testTouchPart.Parent = workspace

        task.wait(0.5)

        debugLog("   Test part created and dropped. If you see '🔥 TOUCHED EVENT!' above, events work!")
        debugLog("   If not, there's a deeper issue with Roblox physics/events.")

        task.wait(2)
        testTouchPart:Destroy()
        debugLog("   Self-test complete. Test part destroyed.")
    end
end
