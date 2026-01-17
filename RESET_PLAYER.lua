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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players:FindFirstChild(playerName)
if not player then
    warn("❌ Player not found: " .. playerName)
    warn("Available players:")
    for _, p in pairs(Players:GetPlayers()) do
        print("  - " .. p.Name)
    end
    return
end

-- Get RemoteEvent
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
    warn("❌ Remotes folder not found!")
    warn("Make sure the game is running (F5)")
    return
end

local AdminAdjustStat = Remotes:FindFirstChild("AdminAdjustStat")
if not AdminAdjustStat then
    warn("❌ AdminAdjustStat RemoteEvent not found!")
    return
end

-- Send reset command from player's client
-- This will trigger the server-side reset logic
AdminAdjustStat:FireServer({
    action = "reset_player"
})

print("✅ Reset command sent for: " .. playerName)
print("⏳ Waiting for server to process...")
task.wait(1)
print("✅ Player should now be reset to default values!")
print("   Level: 1, XP: 0, Wins: 0, Rebirths: 0")
print("")
print("💡 TIP: If nothing happens, make sure you're an admin!")
print("   Admin User IDs are defined in SpeedGameServer.server.lua")
-- ==================== COPY UNTIL HERE ====================
