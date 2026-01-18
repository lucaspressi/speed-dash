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

    part.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if player then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                debugLog("Player " .. player.Name .. " touched " .. part:GetFullName() .. " - KILLING")
                humanoid.Health = 0
            end
        end
    end)

    debugLog("Setup kill touch on: " .. part:GetFullName())
end

-- ==================== SCAN WORKSPACE ====================
debugLog("==================== LAVA KILL SYSTEM STARTING ====================")

-- Wait for workspace to load
task.wait(2)

local killPartsFound = 0

-- Method 1: By name
debugLog("Scanning for kill parts by name...")
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        for _, name in ipairs(KILL_PART_NAMES) do
            if obj.Name == name then
                setupKillTouch(obj)
                killPartsFound = killPartsFound + 1
                break
            end
        end
    end
end

-- Method 2: By tag
debugLog("Scanning for kill parts by tag '" .. KILL_TAG .. "'...")
local taggedParts = CollectionService:GetTagged(KILL_TAG)
for _, part in ipairs(taggedParts) do
    setupKillTouch(part)
    killPartsFound = killPartsFound + 1
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

debugLog("==================== LAVA KILL SYSTEM READY ====================")
debugLog("Kill parts found: " .. killPartsFound)

if killPartsFound == 0 then
    warn("[LavaKill] ⚠️ NO KILL PARTS FOUND!")
    warn("[LavaKill] Make sure you have parts named: " .. table.concat(KILL_PART_NAMES, ", "))
    warn("[LavaKill] Or tag parts with '" .. KILL_TAG .. "' using CollectionService")
else
    debugLog("✅ " .. killPartsFound .. " kill parts activated!")
end
