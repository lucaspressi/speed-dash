-- FIX_RADIOACTIVE_PUDDLES.lua
-- Replace the broken "Kill script" and "Script" that try to access Model.Touched / Model.Color
--
-- INSTRUCTIONS:
-- 1. In Roblox Studio, find Workspace.Radioactive_Puddles
-- 2. Delete any existing "Kill script" or "Script" inside it that have errors
-- 3. Create a new Script inside Radioactive_Puddles (NOT a LocalScript)
-- 4. Copy this entire code into that new Script
-- 5. Name it "RadioactiveKillScript"
-- 6. Save and test

-- ==================== CONFIGURATION ====================
local DAMAGE_AMOUNT = 100  -- Instant kill
local COOLDOWN_TIME = 1    -- Seconds between damage ticks per player
local PUDDLE_COLOR = Color3.fromRGB(0, 255, 0)  -- Radioactive green
local PUDDLE_MATERIAL = Enum.Material.Neon

-- ==================== SETUP ====================
local model = script.Parent
if not model or not model:IsA("Model") then
    warn("[RadioactiveKill] Script must be inside the Radioactive_Puddles Model!")
    return
end

local Players = game:GetService("Players")
local debounceTable = {}  -- Track cooldowns per player

print("[RadioactiveKill] Starting setup for: " .. model.Name)

-- ==================== KILL FUNCTION ====================
local function damagePlayer(player, part)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Check cooldown
    local cooldownKey = player.UserId
    local lastDamage = debounceTable[cooldownKey] or 0

    if os.clock() - lastDamage < COOLDOWN_TIME then
        return  -- Still in cooldown
    end

    -- Apply damage
    print("[RadioactiveKill] 💀 Damaging " .. player.Name .. " - " .. DAMAGE_AMOUNT .. " damage")
    humanoid:TakeDamage(DAMAGE_AMOUNT)
    debounceTable[cooldownKey] = os.clock()
end

-- ==================== SETUP PARTS ====================
local function setupPart(part)
    if not part:IsA("BasePart") then return end

    -- Apply visual effects (if not already set)
    if part.Material ~= PUDDLE_MATERIAL then
        part.Material = PUDDLE_MATERIAL
    end

    if part.Color ~= PUDDLE_COLOR then
        part.Color = PUDDLE_COLOR
    end

    -- Ensure collision is enabled
    part.CanCollide = false  -- Players can walk through
    part.CanTouch = true
    part.CanQuery = true
    part.Anchored = true

    -- Connect Touched event
    local connection = part.Touched:Connect(function(hit)
        if not hit or not hit.Parent then return end

        -- Check if hit is part of a character
        local character = hit.Parent
        if not character:FindFirstChild("Humanoid") then
            -- Maybe it's an accessory/tool, check parent.Parent
            character = hit.Parent.Parent
            if not character or not character:FindFirstChild("Humanoid") then
                return
            end
        end

        -- Get player
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            damagePlayer(player, part)
        end
    end)

    print("[RadioactiveKill] ✅ Setup part: " .. part.Name)

    -- Cleanup connection when part is destroyed
    part.Destroying:Connect(function()
        connection:Disconnect()
    end)
end

-- ==================== SCAN ALL PARTS ====================
local partsSetup = 0

-- Setup existing parts
for _, descendant in pairs(model:GetDescendants()) do
    if descendant:IsA("BasePart") then
        setupPart(descendant)
        partsSetup = partsSetup + 1
    end
end

-- Setup future parts that get added
model.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)  -- Small delay to ensure it's fully loaded
    if descendant:IsA("BasePart") then
        setupPart(descendant)
        print("[RadioactiveKill] 🆕 Dynamically added part: " .. descendant.Name)
    end
end)

-- ==================== CLEANUP ====================
-- Clean up debounce table periodically
task.spawn(function()
    while true do
        task.wait(60)  -- Every minute
        local currentTime = os.clock()
        for userId, lastTime in pairs(debounceTable) do
            if currentTime - lastTime > 60 then
                debounceTable[userId] = nil
            end
        end
    end
end)

print("[RadioactiveKill] ==================== READY ====================")
print("[RadioactiveKill] Model: " .. model.Name)
print("[RadioactiveKill] Parts setup: " .. partsSetup)
print("[RadioactiveKill] Damage: " .. DAMAGE_AMOUNT .. " HP per touch")
print("[RadioactiveKill] Cooldown: " .. COOLDOWN_TIME .. " seconds")
print("[RadioactiveKill] ✅ System active!")
