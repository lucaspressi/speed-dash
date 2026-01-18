-- CHECK_SPEEDGAMESERVER.lua
-- Run in Command Bar (SERVER with game RUNNING)
-- Checks if SpeedGameServer is working and creating leaderstats

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

print("🎮 ==================== SPEEDGAMESERVER CHECK ====================")
print("")

-- Check if SpeedGameServer exists
print("📜 Checking for SpeedGameServer script...")
local speedGameServer = ServerScriptService:FindFirstChild("SpeedGameServer", true)

if not speedGameServer then
    warn("❌ SpeedGameServer NOT FOUND in ServerScriptService!")
    warn("   This is the MAIN server script!")
    warn("   Check:")
    warn("   1. Is Rojo running and syncing?")
    warn("   2. Does src/server/SpeedGameServer.server.lua exist?")
    print("")
    return
end

print("   ✅ Found: " .. speedGameServer:GetFullName())
print("   Enabled: " .. tostring(speedGameServer.Enabled))
print("")

if not speedGameServer.Enabled then
    warn("   ❌ SpeedGameServer is DISABLED!")
    warn("   Enable it to make the game work.")
    print("")
    return
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check players
print("👤 Checking players...")
print("")

local players = Players:GetPlayers()
if #players == 0 then
    warn("   ⚠️ No players in game!")
    print("   Join the game to test if leaderstats are created.")
    print("")
    return
end

for _, player in ipairs(players) do
    print("   Player: " .. player.Name)
    print("      UserId: " .. player.UserId)

    -- Check leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        print("      ✅ Has leaderstats folder")

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
        warn("      ❌ NO LEADERSTATS FOLDER!")
        warn("         SpeedGameServer didn't create leaderstats!")
        warn("         Check Output window for errors in SpeedGameServer")
    end

    -- Check if player has TotalXP attribute
    local totalXP = player:GetAttribute("TotalXP")
    local currentLevel = player:GetAttribute("CurrentLevel")

    print("      Attributes:")
    print("         TotalXP: " .. tostring(totalXP))
    print("         CurrentLevel: " .. tostring(currentLevel))

    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 SUMMARY:")
print("")

if not speedGameServer then
    warn("❌ SpeedGameServer script not found! Game cannot work.")
elseif not speedGameServer.Enabled then
    warn("❌ SpeedGameServer is disabled! Enable it.")
else
    local allPlayersHaveLeaderstats = true
    for _, player in ipairs(players) do
        if not player:FindFirstChild("leaderstats") then
            allPlayersHaveLeaderstats = false
            break
        end
    end

    if #players == 0 then
        print("⚠️ No players to test. Join the game.")
    elseif allPlayersHaveLeaderstats then
        print("✅ All players have leaderstats!")
        print("   SpeedGameServer is working correctly.")
    else
        warn("❌ Some players don't have leaderstats!")
        warn("   SpeedGameServer may have errors.")
        warn("   Check the Output window for error messages.")
    end
end

print("")
print("🎮 ==================== END CHECK ====================")
-- ==================== COPY UNTIL HERE ====================
