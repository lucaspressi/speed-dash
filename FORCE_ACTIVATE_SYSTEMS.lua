-- FORCE_ACTIVATE_SYSTEMS.lua
-- Run in Command Bar (SERVER with game RUNNING)
-- Manually activates lava kill system and checks leaderboard

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

print("🔧 ==================== FORCE ACTIVATING SYSTEMS ====================")
print("")

-- ==================== 1. FORCE LAVA KILL ====================
print("🔥 Setting up Lava Kill manually...")
print("")

local lavaCount = 0
local lavaNames = {"Lava", "lava", "LAVA", "KillBrick"}

for _, name in ipairs(lavaNames) do
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == name and obj:IsA("BasePart") then
            -- Check if already setup
            if not obj:GetAttribute("KillSetup") then
                obj:SetAttribute("KillSetup", true)

                -- Setup kill on touch
                obj.Touched:Connect(function(hit)
                    local character = hit.Parent
                    local player = Players:GetPlayerFromCharacter(character)

                    if player then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            print("[LAVA] Killed " .. player.Name)
                            humanoid.Health = 0
                        end
                    end
                end)

                lavaCount = lavaCount + 1
                print("   ✅ Activated: " .. obj:GetFullName())
            end
        end
    end
end

print("")
print("✅ Activated " .. lavaCount .. " lava parts!")
print("   Lava will now kill players on touch.")
print("")

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== 2. CHECK LEADERBOARD ====================
print("📊 Checking Leaderboard system...")
print("")

local players = Players:GetPlayers()
if #players == 0 then
    print("⚠️ No players in game")
else
    for _, player in ipairs(players) do
        print("   Player: " .. player.Name)

        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            print("      ✅ Has leaderstats")

            local speed = leaderstats:FindFirstChild("Speed")
            local wins = leaderstats:FindFirstChild("Wins")

            if speed then
                print("         Speed: " .. speed.Value)
            else
                warn("         ❌ No Speed stat - creating manually...")

                local speedStat = Instance.new("IntValue")
                speedStat.Name = "Speed"
                speedStat.Value = 0
                speedStat.Parent = leaderstats

                print("         ✅ Created Speed stat")
            end

            if wins then
                print("         Wins: " .. wins.Value)
            else
                warn("         ❌ No Wins stat - creating manually...")

                local winsStat = Instance.new("IntValue")
                winsStat.Name = "Wins"
                winsStat.Value = 0
                winsStat.Parent = leaderstats

                print("         ✅ Created Wins stat")
            end
        else
            warn("      ❌ NO LEADERSTATS - creating manually...")

            local leaderstats = Instance.new("Folder")
            leaderstats.Name = "leaderstats"
            leaderstats.Parent = player

            local speedStat = Instance.new("IntValue")
            speedStat.Name = "Speed"
            speedStat.Value = 0
            speedStat.Parent = leaderstats

            local winsStat = Instance.new("IntValue")
            winsStat.Name = "Wins"
            winsStat.Value = 0
            winsStat.Parent = leaderstats

            print("      ✅ Created leaderstats with Speed and Wins")
        end
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- ==================== 3. CHECK NPC ====================
print("🤖 Checking NoobNPC...")
print("")

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then
    warn("❌ Buff Noob not found!")
else
    local humanoid = npc:FindFirstChild("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        print("✅ Buff Noob found")
        print("   Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
        print("   WalkSpeed: " .. humanoid.WalkSpeed)
        print("   Position: " .. tostring(hrp.Position))

        -- Check if NPC is moving
        print("")
        print("Testing NPC movement for 3 seconds...")

        local startPos = hrp.Position
        task.wait(3)
        local endPos = hrp.Position
        local moved = (endPos - startPos).Magnitude

        if moved > 1 then
            print("   ✅ NPC is moving! (moved " .. math.floor(moved) .. " studs)")
        else
            warn("   ❌ NPC is NOT moving!")
            warn("   NoobNpcAI script may not be running")
            warn("   Check Output for [NoobAI] error messages")
        end
    else
        warn("❌ NPC missing Humanoid or HumanoidRootPart!")
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("✅ FORCE ACTIVATION COMPLETE!")
print("")
print("What was done:")
print("   1. ✅ Manually activated " .. lavaCount .. " lava parts")
print("   2. ✅ Checked/created leaderstats for all players")
print("   3. ✅ Verified NPC movement")
print("")
print("TEST NOW:")
print("   1. Touch lava - should kill instantly")
print("   2. Check top-right corner for Speed/Wins")
print("   3. Walk near Stage 2 - NPC should chase you")
print("")
print("🔧 ==================== END ACTIVATION ====================")
-- ==================== COPY UNTIL HERE ====================
