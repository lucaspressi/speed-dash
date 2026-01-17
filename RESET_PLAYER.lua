-- RESET_PLAYER.lua
-- SERVER-SIDE COMMAND BAR SCRIPT
-- INSTRUCTIONS:
-- 1. Open Roblox Studio with your game
-- 2. Start Play Solo (F5)
-- 3. While game is running, open Command Bar: View → Command Bar (Ctrl/Cmd + Shift + X)
-- 4. Copy ONLY the code between the lines below and paste it into Command Bar
-- 5. Press Enter to execute

-- ==================== COPY FROM HERE ====================
local playerName = "Xxpress1xX"
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Find player
local player = Players:FindFirstChild(playerName)
if not player then
    warn("❌ Player not found: " .. playerName)
    warn("Available players:")
    for _, p in pairs(Players:GetPlayers()) do
        print("  - " .. p.Name)
    end
    return
end

print("🔍 Found player: " .. player.Name .. " (UserId: " .. player.UserId .. ")")

-- Wait for SpeedGameServer to load (with timeout)
print("⏳ Waiting for SpeedGameServer to load...")
local maxWaitTime = 10 -- seconds
local waitedTime = 0
local checkInterval = 0.5

while (not _G.SpeedGame_PlayerData or not _G.SpeedGame_DEFAULT_DATA) and waitedTime < maxWaitTime do
    task.wait(checkInterval)
    waitedTime = waitedTime + checkInterval
    print("   Still waiting... (" .. waitedTime .. "s)")
end

-- Access global PlayerData (exposed by SpeedGameServer)
local PlayerData = _G.SpeedGame_PlayerData
local DEFAULT_DATA = _G.SpeedGame_DEFAULT_DATA

if not PlayerData or not DEFAULT_DATA then
    warn("❌ SpeedGameServer not loaded after " .. maxWaitTime .. " seconds!")
    warn("❌ Make sure the game is running (F5) and try again.")
    return
end

print("✅ SpeedGameServer loaded!")

local data = PlayerData[player.UserId]
if not data then
    warn("❌ Player data not found for: " .. playerName)
    return
end

print("🔧 Resetting player data...")

-- Reset all data to defaults
for key, value in pairs(DEFAULT_DATA) do
    data[key] = value
end

-- Calculate XP required (basic formula)
data.XPRequired = 100 * (1.5 ^ (data.Level - 1))

-- Reset attributes
player:SetAttribute("TreadmillX3Owned", false)
player:SetAttribute("TreadmillX9Owned", false)
player:SetAttribute("TreadmillX25Owned", false)
player:SetAttribute("OnTreadmill", false)
player:SetAttribute("TreadmillMultiplier", 1)

-- Update leaderstats
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    local speedStat = leaderstats:FindFirstChild("Speed")
    local winsStat = leaderstats:FindFirstChild("Wins")
    if speedStat then speedStat.Value = 16 end
    if winsStat then winsStat.Value = 0 end
end

-- Update character walk speed
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
    end
end

-- Fire UpdateUI to client
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if Remotes then
    local UpdateUIEvent = Remotes:FindFirstChild("UpdateUI")
    if UpdateUIEvent then
        UpdateUIEvent:FireClient(player, data)
    end
end

print("✅ Successfully reset " .. playerName .. " to default values!")
print("   Level: 1, XP: 0, Wins: 0, Rebirths: 0, Speed: 16")
print("   All treadmill ownership reset")
print("   All attributes reset")
print("")
print("💡 Now you can test the win requirement warnings on StepAwards!")
-- ==================== COPY UNTIL HERE ====================
