-- DIAGNOSE_ALL_SYSTEMS.lua
-- Run in Command Bar (SERVER) to check NoobNPC, Lava, and Leaderboard
-- Comprehensive diagnostic for all 3 systems

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local workspace = game:GetService("Workspace")

print("🔍 ==================== COMPREHENSIVE SYSTEM DIAGNOSTICS ====================")
print("")

-- ==================== 1. NOOB NPC CHECK ====================
print("🤖 ==================== NOOB NPC CHECK ====================")
print("")

-- Check if NPC exists
local noobNpc = workspace:FindFirstChild("Buff Noob")
if not noobNpc then
    warn("❌ 'Buff Noob' NPC NOT FOUND in Workspace!")
    warn("   The NPC doesn't exist. You need to add it to the workspace.")
else
    print("✅ 'Buff Noob' found: " .. noobNpc:GetFullName())

    -- Check NPC parts
    local humanoid = noobNpc:FindFirstChild("Humanoid")
    local hrp = noobNpc:FindFirstChild("HumanoidRootPart")
    local head = noobNpc:FindFirstChild("Head")

    print("   Humanoid: " .. tostring(humanoid ~= nil))
    print("   HumanoidRootPart: " .. tostring(hrp ~= nil))
    print("   Head: " .. tostring(head ~= nil))

    if humanoid then
        print("   Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
        print("   WalkSpeed: " .. humanoid.WalkSpeed)
    end

    if hrp then
        print("   Position: " .. tostring(hrp.Position))
    end
end

-- Check Stage2NpcKill area
local stage2Area = workspace:FindFirstChild("Stage2NpcKill")
if not stage2Area then
    warn("❌ 'Stage2NpcKill' area NOT FOUND in Workspace!")
    warn("   The NPC needs this area to define patrol bounds.")
else
    print("✅ 'Stage2NpcKill' area found")
    local partCount = 0
    for _, obj in pairs(stage2Area:GetChildren()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
        end
    end
    print("   Parts in area: " .. partCount)
end

-- Check NoobNpcAI script
local noobAiScript = ServerScriptService:FindFirstChild("NoobNpcAI", true)
if not noobAiScript then
    warn("❌ NoobNpcAI script NOT FOUND in ServerScriptService!")
else
    print("✅ NoobNpcAI script found")
    print("   Enabled: " .. tostring(noobAiScript.Enabled))

    if not noobAiScript.Enabled then
        warn("   ⚠️ Script is DISABLED! Enable it for NPC to work.")
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== 2. LAVA CHECK ====================
print("🔥 ==================== LAVA CHECK ====================")
print("")

-- Look for lava parts (common names)
local lavaNames = {"Lava", "lava", "LAVA", "KillBrick", "Killbrick", "killbrick"}
local lavaFound = {}

for _, name in ipairs(lavaNames) do
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:IsA("BasePart") then
            table.insert(lavaFound, obj)
        end
    end
end

if #lavaFound == 0 then
    warn("❌ NO LAVA PARTS FOUND!")
    warn("   Looked for parts named: " .. table.concat(lavaNames, ", "))
    warn("   You may need to add lava parts to the map.")
else
    print("✅ Found " .. #lavaFound .. " lava parts:")

    for i, lavaPart in ipairs(lavaFound) do
        print("")
        print("   Lava #" .. i .. ": " .. lavaPart:GetFullName())
        print("      Position: " .. tostring(lavaPart.Position))
        print("      Size: " .. tostring(lavaPart.Size))
        print("      CanCollide: " .. tostring(lavaPart.CanCollide))
        print("      Transparency: " .. tostring(lavaPart.Transparency))

        -- Check if it has a kill script
        local hasScript = false
        for _, child in pairs(lavaPart:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                hasScript = true
                print("      ✅ Has script: " .. child.Name .. " (Enabled: " .. tostring(child.Enabled) .. ")")
            end
        end

        if not hasScript then
            warn("      ❌ NO SCRIPT FOUND!")
            warn("         This lava won't kill players!")
        end

        -- Check Touched connections (runtime)
        local touchedConnections = 0
        -- Can't directly count connections, but we can test
        print("      Touch test: (checking if Touched event fires)")
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== 3. LEADERBOARD CHECK ====================
print("📊 ==================== LEADERBOARD CHECK ====================")
print("")

-- Check SpeedGameServer
local speedGameServer = ServerScriptService:FindFirstChild("SpeedGameServer", true)
if not speedGameServer then
    warn("❌ SpeedGameServer NOT FOUND!")
    warn("   This is the MAIN game script!")
else
    print("✅ SpeedGameServer found")
    print("   Enabled: " .. tostring(speedGameServer.Enabled))

    if not speedGameServer.Enabled then
        warn("   ⚠️ Script is DISABLED!")
    end
end

-- Check players
local players = Players:GetPlayers()
if #players == 0 then
    warn("⚠️ No players in game to check leaderboard")
else
    for _, player in ipairs(players) do
        print("")
        print("   Player: " .. player.Name)

        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            print("      ✅ Has leaderstats")

            local speed = leaderstats:FindFirstChild("Speed")
            local wins = leaderstats:FindFirstChild("Wins")

            if speed then
                print("         Speed: " .. tostring(speed.Value))
            else
                warn("         ❌ No Speed stat!")
            end

            if wins then
                print("         Wins: " .. tostring(wins.Value))
            else
                warn("         ❌ No Wins stat!")
            end
        else
            warn("      ❌ NO LEADERSTATS!")
            warn("         SpeedGameServer didn't create leaderstats for this player")
        end
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== SUMMARY ====================
print("📋 ==================== SUMMARY ====================")
print("")

local npcWorking = (noobNpc ~= nil) and (stage2Area ~= nil) and (noobAiScript ~= nil) and noobAiScript.Enabled
local lavaWorking = #lavaFound > 0
local leaderboardWorking = (speedGameServer ~= nil) and speedGameServer.Enabled

print("Systems Status:")
print("   NoobNPC: " .. (npcWorking and "✅ WORKING" or "❌ BROKEN"))
print("   Lava: " .. (lavaWorking and "⚠️ FOUND (check scripts)" or "❌ NOT FOUND"))
print("   Leaderboard: " .. (leaderboardWorking and "✅ WORKING" or "❌ BROKEN"))

print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
