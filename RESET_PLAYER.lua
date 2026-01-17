-- RESET_PLAYER.lua
-- INSTRUCTIONS:
-- 1. Open Roblox Studio with your game
-- 2. Start Play Solo (F5)
-- 3. While game is running, open Command Bar: View → Command Bar (Ctrl/Cmd + Shift + X)
-- 4. Copy ONLY the code between the lines below and paste it into Command Bar
-- 5. Press Enter to execute

-- ==================== COPY FROM HERE ====================
local playerName = "Xxpress1xX"
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local player = Players:FindFirstChild(playerName)
if not player then
    warn("❌ Player not found: " .. playerName)
    warn("Available players:")
    for _, p in pairs(Players:GetPlayers()) do
        print("  - " .. p.Name)
    end
    return
end

-- Access SpeedGameServer directly (server-side)
local SpeedGameServer = ServerScriptService:FindFirstChild("SpeedGameServer")
if not SpeedGameServer then
    warn("❌ SpeedGameServer not found")
    return
end

-- Get player data (assuming it's stored in a global or module)
local PlayerData = _G.PlayerData or {}
local data = PlayerData[player.UserId]

if not data then
    warn("❌ Player data not found for: " .. playerName)
    return
end

-- Default values
local DEFAULT_DATA = {
    Level = 1,
    XP = 0,
    TotalXP = 0,
    Wins = 0,
    Rebirths = 0,
    Multiplier = 1,
    StepBonus = 1,
    GiftClaimed = false,
    TreadmillX3Owned = false,
    TreadmillX9Owned = false,
    TreadmillX25Owned = false,
    SpeedBoostLevel = 0,
    WinBoostLevel = 0,
}

-- Reset data
for key, value in pairs(DEFAULT_DATA) do
    data[key] = value
end

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
    if speedStat then speedStat.Value = 0 end
    if winsStat then winsStat.Value = 0 end
end

print("✅ Successfully reset " .. playerName .. " to default values!")
print("  Level: 1, XP: 0, Wins: 0, Rebirths: 0")
-- ==================== COPY UNTIL HERE ====================
