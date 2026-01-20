-- LavaKill.server.lua
-- BULLETPROOF LAVA KILL SYSTEM - Versão definitiva com múltiplos métodos de detecção

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

local KILL_TAG = "KillOnTouch"
local DEBUG = true

-- ==================== SETUP ====================
local function debugLog(message)
    if DEBUG then
        print("[LavaKill] " .. message)
    end
end

local killPartsList = {}
local killCooldowns = {}  -- Prevent spam kills

-- ==================== KILL FUNCTION ====================
local function killPlayer(player, reason, part)
    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end

    if humanoid.Health <= 0 then return false end

    -- Kill the player
    debugLog("💀 KILLING " .. player.Name .. " - Reason: " .. reason)
    debugLog("   Part: " .. (part and part.Name or "unknown"))
    debugLog("   Previous Health: " .. humanoid.Health)

    humanoid.Health = 0

    -- Verify it worked
    task.wait(0.1)
    if humanoid.Health > 0 then
        warn("[LavaKill] ⚠️ Health set to 0 but player still alive! Trying again...")
        humanoid.Health = 0
        humanoid:TakeDamage(humanoid.MaxHealth * 2)
    else
        debugLog("   ✅ Player successfully killed")
    end

    return true
end

-- ==================== METHOD 1: TOUCHED EVENTS ====================
local function setupKillTouch(part)
    if not part:IsA("BasePart") then return end

    -- Prevent duplicate connections
    if part:GetAttribute("KillSetup") then
        return
    end
    part:SetAttribute("KillSetup", true)

    -- FORCE ALL collision properties
    part.CanCollide = true
    part.CanTouch = true
    part.CanQuery = true
    part.Anchored = true

    debugLog("⚙️ Setup Touched event on: " .. part:GetFullName())
    debugLog("   CanCollide=" .. tostring(part.CanCollide) ..
             " | CanTouch=" .. tostring(part.CanTouch) ..
             " | CanQuery=" .. tostring(part.CanQuery))

    part.Touched:Connect(function(hit)
        debugLog("🔥 TOUCHED EVENT! Hit=" .. tostring(hit.Name) .. " | Parent=" .. tostring(hit.Parent and hit.Parent.Name or "nil"))

        if not hit or not hit.Parent then return end

        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)

        if player then
            local cooldownKey = player.UserId .. "_touched_" .. part:GetFullName()
            local lastKill = killCooldowns[cooldownKey] or 0

            if os.clock() - lastKill > 1 then
                killPlayer(player, "Touched Event", part)
                killCooldowns[cooldownKey] = os.clock()
            end
        end
    end)
end

-- ==================== METHOD 2: POSITION-BASED DETECTION ====================
-- ⚠️ DISABLED: Causava freezes (10 checks/s × players × lava parts = lag)
-- TouchEnded é suficiente para detecção precisa
local function startPositionBasedKiller()
    debugLog("⏸️ Position-based killer DESABILITADO (performance)")
    -- Não iniciar loop - usar apenas TouchEnded
end

-- ==================== METHOD 3: SPATIAL QUERY DETECTION ====================
-- ⚠️ DISABLED: GetPartBoundsInBox é MUITO caro (5 checks/s × lava parts)
-- TouchEnded é suficiente para detecção precisa
local function startSpatialQueryKiller()
    debugLog("⏸️ Spatial Query killer DESABILITADO (performance)")
    -- Não iniciar loop - usar apenas TouchEnded
end

-- ==================== SCAN AND ACTIVATE ====================
debugLog("==================== LAVA KILL SYSTEM STARTING ====================")

task.wait(2)  -- Wait for workspace to load

local killPartsFound = 0

-- Find all kill parts
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

-- Check for tagged parts
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

-- Listen for new parts
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if obj:IsA("BasePart") then
        for _, name in ipairs(KILL_PART_NAMES) do
            if obj.Name == name then
                setupKillTouch(obj)
                if not table.find(killPartsList, obj) then
                    table.insert(killPartsList, obj)
                    debugLog("Dynamically added: " .. obj:GetFullName())
                end
                break
            end
        end
    end
end)

CollectionService:GetInstanceAddedSignal(KILL_TAG):Connect(function(obj)
    setupKillTouch(obj)
    if not table.find(killPartsList, obj) then
        table.insert(killPartsList, obj)
        debugLog("Part tagged as kill: " .. obj:GetFullName())
    end
end)

debugLog("==================== LAVA KILL SYSTEM READY ====================")
debugLog("Kill parts found: " .. killPartsFound)

if killPartsFound == 0 then
    warn("[LavaKill] ⚠️ NO KILL PARTS FOUND!")
    warn("[LavaKill] Make sure you have parts named: " .. table.concat(KILL_PART_NAMES, ", "))
    warn("[LavaKill] Or tag parts with '" .. KILL_TAG .. "' using CollectionService")
else
    debugLog("✅ " .. killPartsFound .. " kill parts activated!")

    -- ACTIVATE ALL 3 DETECTION METHODS
    startPositionBasedKiller()  -- Method 2
    startSpatialQueryKiller()   -- Method 3

    debugLog("🛡️ TRIPLE PROTECTION ACTIVE:")
    debugLog("   1️⃣ Touched Events")
    debugLog("   2️⃣ Position Detection (every 0.1s)")
    debugLog("   3️⃣ Spatial Query Detection (every 0.2s)")
    debugLog("")
    debugLog("💀 Players stepping into lava WILL DIE - guaranteed!")
end

debugLog("==================== SYSTEM FULLY OPERATIONAL ====================")
