-- FIX_ALL_SYSTEMS.lua
-- Run in Command Bar (SERVER) to auto-fix common issues
-- Fixes NoobNPC, Lava, and checks Leaderboard

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local workspace = game:GetService("Workspace")

print("🔧 ==================== AUTO-FIX ALL SYSTEMS ====================")
print("")

local fixesApplied = 0
local warnings = 0

-- ==================== FIX 1: NOOB NPC ====================
print("🤖 Checking NoobNPC...")
print("")

local noobNpc = workspace:FindFirstChild("Buff Noob")
if not noobNpc then
    warn("❌ 'Buff Noob' NPC not found in Workspace!")
    warn("   MANUAL FIX REQUIRED:")
    warn("   1. Insert a 'Rig' or character model into Workspace")
    warn("   2. Rename it to 'Buff Noob'")
    warn("   3. Make sure it has Humanoid, HumanoidRootPart, and Head")
    warnings = warnings + 1
else
    print("✅ 'Buff Noob' found")

    -- Check if script is enabled
    local noobAiScript = ServerScriptService:FindFirstChild("NoobNpcAI", true)
    if noobAiScript and not noobAiScript.Enabled then
        print("   Enabling NoobNpcAI script...")
        noobAiScript.Enabled = true
        fixesApplied = fixesApplied + 1
        print("   ✅ NoobNpcAI enabled!")
    end
end

-- Check Stage2NpcKill area
local stage2Area = workspace:FindFirstChild("Stage2NpcKill")
if not stage2Area then
    warn("❌ 'Stage2NpcKill' area not found!")
    warn("   MANUAL FIX REQUIRED:")
    warn("   1. Create a Folder in Workspace named 'Stage2NpcKill'")
    warn("   2. Add Parts to this folder to define NPC patrol area")
    warn("   3. The NPC will patrol within the bounds of these parts")
    warnings = warnings + 1
else
    print("✅ 'Stage2NpcKill' area found")

    local partCount = 0
    for _, obj in pairs(stage2Area:GetChildren()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
        end
    end

    if partCount == 0 then
        warn("   ⚠️ Stage2NpcKill has NO parts!")
        warn("   Add Parts to define the patrol area")
        warnings = warnings + 1
    else
        print("   ✅ " .. partCount .. " parts in patrol area")
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== FIX 2: LAVA ====================
print("🔥 Checking Lava system...")
print("")

-- Check if LavaKill script exists and is enabled
local lavaKillScript = ServerScriptService:FindFirstChild("LavaKill", true)
if not lavaKillScript then
    warn("❌ LavaKill script not found!")
    warn("   Make sure src/server/LavaKill.server.lua exists and Rojo is syncing")
    warnings = warnings + 1
else
    print("✅ LavaKill script found")

    if not lavaKillScript.Enabled then
        print("   Enabling LavaKill script...")
        lavaKillScript.Enabled = true
        fixesApplied = fixesApplied + 1
        print("   ✅ LavaKill enabled!")
    else
        print("   ✅ LavaKill already enabled")
    end
end

-- Check for lava parts
local lavaNames = {"Lava", "lava", "LAVA", "KillBrick"}
local lavaFound = 0

for _, name in ipairs(lavaNames) do
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:IsA("BasePart") then
            lavaFound = lavaFound + 1
        end
    end
end

if lavaFound == 0 then
    warn("⚠️ No lava parts found in workspace!")
    warn("   MANUAL FIX REQUIRED:")
    warn("   1. Create Parts in Workspace")
    warn("   2. Name them 'Lava' or 'KillBrick'")
    warn("   3. LavaKill script will automatically make them deadly")
    warnings = warnings + 1
else
    print("✅ Found " .. lavaFound .. " lava parts")
    print("   LavaKill script should handle them automatically")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== FIX 3: LEADERBOARD ====================
print("📊 Checking Leaderboard system...")
print("")

-- Check SpeedGameServer
local speedGameServer = ServerScriptService:FindFirstChild("SpeedGameServer", true)
if not speedGameServer then
    warn("❌ SpeedGameServer NOT FOUND!")
    warn("   This is CRITICAL - the entire game won't work!")
    warn("   Make sure Rojo is syncing src/server/SpeedGameServer.server.lua")
    warnings = warnings + 1
else
    print("✅ SpeedGameServer found")

    if not speedGameServer.Enabled then
        print("   Enabling SpeedGameServer...")
        speedGameServer.Enabled = true
        fixesApplied = fixesApplied + 1
        print("   ✅ SpeedGameServer enabled!")
    else
        print("   ✅ SpeedGameServer already enabled")
    end
end

-- Check if players have leaderstats
local players = Players:GetPlayers()
if #players > 0 then
    local allHaveLeaderstats = true

    for _, player in ipairs(players) do
        if not player:FindFirstChild("leaderstats") then
            allHaveLeaderstats = false
            warn("   ⚠️ Player " .. player.Name .. " has no leaderstats")
        end
    end

    if allHaveLeaderstats then
        print("   ✅ All players have leaderstats")
    else
        warn("   ⚠️ Some players missing leaderstats!")
        warn("   They may need to rejoin after fixes are applied")
        warnings = warnings + 1
    end
else
    print("   ℹ️ No players in game to check")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== SUMMARY ====================
print("📋 ==================== SUMMARY ====================")
print("")
print("Fixes applied: " .. fixesApplied)
print("Warnings: " .. warnings)
print("")

if fixesApplied > 0 then
    print("✅ Applied " .. fixesApplied .. " automatic fixes!")
    print("   Scripts have been enabled. Test the game now.")
end

if warnings > 0 then
    print("")
    warn("⚠️ " .. warnings .. " issues require MANUAL fixing")
    warn("Review the warnings above for instructions")
end

if fixesApplied == 0 and warnings == 0 then
    print("✅ All systems already working!")
    print("   If you still have issues, check:")
    print("   1. Did you publish the game? (File > Publish to Roblox)")
    print("   2. Are you testing in production or Studio?")
    print("   3. Check Output window for error messages")
end

print("")
print("🔧 ==================== END AUTO-FIX ====================")
-- ==================== COPY UNTIL HERE ====================
