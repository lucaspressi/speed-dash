-- DIAGNOSE_LEADERBOARD.lua
-- Run in Command Bar (SERVER with game RUNNING and a player in game)
-- Diagnoses leaderboard system

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("📊 ==================== LEADERBOARD DIAGNOSTICS ====================")
print("")

-- Check for leaderboard-related scripts
print("🔍 Checking for leaderboard scripts...")
print("")

local leaderboardScripts = {}
for _, service in ipairs({ServerScriptService, ReplicatedStorage}) do
    for _, obj in ipairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("ModuleScript") then
            if string.match(string.lower(obj.Name), "leader") or
               string.match(string.lower(obj.Name), "stats") or
               string.match(string.lower(obj.Name), "data") then
                table.insert(leaderboardScripts, obj)
                print("   Found: " .. obj:GetFullName())
                if obj:IsA("Script") then
                    print("      Enabled: " .. tostring(obj.Enabled))
                end
            end
        end
    end
end

if #leaderboardScripts == 0 then
    warn("   ❌ No leaderboard scripts found!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check players
print("👤 Checking players...")
print("")

local players = Players:GetPlayers()
if #players == 0 then
    warn("   ⚠️ No players in game! Join the game to test.")
    print("")
else
    for _, player in ipairs(players) do
        print("   Player: " .. player.Name)
        print("      UserId: " .. player.UserId)

        -- Check leaderstats
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            print("      ✅ Has leaderstats folder")
            for _, stat in ipairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    print("         - " .. stat.Name .. ": " .. tostring(stat.Value))
                end
            end
        else
            warn("      ❌ No leaderstats folder!")
        end

        -- Check attributes
        print("      Attributes:")
        local attrs = player:GetAttributes()
        local hasAttrs = false
        for name, value in pairs(attrs) do
            hasAttrs = true
            print("         - " .. name .. ": " .. tostring(value))
        end
        if not hasAttrs then
            print("         (none)")
        end

        -- Check PlayerGui
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            print("      PlayerGui scripts:")
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("LocalScript") then
                    print("         - " .. obj:GetFullName())
                end
            end
        end

        print("")
    end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check for DataStore scripts
print("💾 Checking for DataStore/Stats scripts...")
print("")

for _, obj in ipairs(ServerScriptService:GetDescendants()) do
    if obj:IsA("Script") then
        local success, source = pcall(function()
            return obj.Source
        end)

        if success and source then
            if string.match(source, "DataStoreService") or
               string.match(source, "leaderstats") or
               string.match(source, "PlayerAdded") then
                print("   Found: " .. obj:GetFullName())
                print("      Enabled: " .. tostring(obj.Enabled))
            end
        end
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 RECOMMENDATIONS:")
print("")

if #players == 0 then
    print("   ⚠️ No players in game - join to test leaderboard")
else
    local player = players[1]
    if not player:FindFirstChild("leaderstats") then
        warn("   ❌ Player has no leaderstats folder!")
        print("   This means:")
        print("   1. No script is creating leaderstats on PlayerAdded")
        print("   2. Or the script is disabled")
        print("   3. Or the script has an error")
        print("")
        print("   Look for a script that does:")
        print("   Players.PlayerAdded:Connect(function(player)")
        print("       local leaderstats = Instance.new('Folder')")
        print("       leaderstats.Name = 'leaderstats'")
        print("       leaderstats.Parent = player")
    else
        print("   ✅ Leaderstats folder exists")
        local speedStat = player.leaderstats:FindFirstChild("Speed") or
                         player.leaderstats:FindFirstChild("Velocidade")
        if not speedStat then
            warn("   ❌ No Speed/Velocidade stat found!")
            print("   The leaderboard might be missing the main stat display")
        end
    end
end

print("")
print("📊 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
