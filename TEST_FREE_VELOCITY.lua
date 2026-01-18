-- TEST_FREE_VELOCITY.lua
-- Run in Command Bar (SERVER with game RUNNING)
-- Tests if player velocity is too low on FREE treadmills

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("⚡ ==================== VELOCITY TEST ON FREE TREADMILLS ====================")
print("")

-- Find FREE zones
local workspace = game:GetService("Workspace")
local freeZones = {}

for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
        local multiplier = obj:GetAttribute("Multiplier")
        local isFree = obj:GetAttribute("IsFree")

        if multiplier == 1 or isFree == true then
            table.insert(freeZones, obj)
        end
    end
end

print("Found " .. #freeZones .. " FREE zones:")
for i, zone in ipairs(freeZones) do
    print("   #" .. i .. ": " .. zone:GetFullName())
    print("      Position: " .. tostring(zone.Position))
end

if #freeZones == 0 then
    warn("❌ No FREE zones found!")
    return
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check players
local players = Players:GetPlayers()
if #players == 0 then
    warn("⚠️ No players in game! Join to test.")
    return
end

local player = players[1]
print("👤 Monitoring player: " .. player.Name)
print("")
print("INSTRUCTIONS:")
print("1. Stand STILL on a FREE treadmill")
print("2. Watch the output for 10 seconds")
print("3. If velocity is < 1.0, that's the problem!")
print("")
print("Monitoring for 10 seconds...")
print("")

local startTime = tick()
local connection
local sampleCount = 0
local velocitiesOnFree = {}

connection = RunService.Heartbeat:Connect(function()
    if tick() - startTime > 10 then
        connection:Disconnect()

        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("⏱️ Monitoring stopped after 10 seconds")
        print("")

        if #velocitiesOnFree > 0 then
            local sum = 0
            local min = math.huge
            local max = 0

            for _, vel in ipairs(velocitiesOnFree) do
                sum = sum + vel
                min = math.min(min, vel)
                max = math.max(max, vel)
            end

            local avg = sum / #velocitiesOnFree

            print("📊 STATISTICS (when on FREE zone):")
            print("   Samples: " .. #velocitiesOnFree)
            print("   Average velocity: " .. string.format("%.2f", avg))
            print("   Min velocity: " .. string.format("%.2f", min))
            print("   Max velocity: " .. string.format("%.2f", max))
            print("")

            print("📊 ANALYSIS:")
            if avg < 1.0 then
                warn("❌ PROBLEM FOUND!")
                warn("   Average velocity (" .. string.format("%.2f", avg) .. ") is BELOW TreadmillService threshold (1.0)")
                warn("   This means TreadmillService is IGNORING you!")
                warn("")
                warn("💡 SOLUTION:")
                warn("   Edit src/server/TreadmillService.server.lua")
                warn("   Change line 22: VELOCITY_THRESHOLD = 1")
                warn("   To: VELOCITY_THRESHOLD = 0.1")
                warn("   This will detect slower players on treadmills.")
            else
                print("✅ Velocity is GOOD!")
                print("   Average (" .. string.format("%.2f", avg) .. ") is above threshold (1.0)")
                print("   TreadmillService SHOULD detect you.")
                print("   Problem may be elsewhere.")
            end
        else
            warn("⚠️ No velocity samples collected!")
            warn("   Did you stand on a FREE treadmill?")
        end

        print("")
        print("⚡ ==================== END TEST ====================")
        return
    end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerPos = hrp.Position
    local velocity = hrp.AssemblyLinearVelocity
    local velMag = velocity.Magnitude

    -- Check if on FREE zone
    for i, zone in ipairs(freeZones) do
        local zonePos = zone.Position
        local distance = (playerPos - zonePos).Magnitude

        -- Only check if close (within 20 studs)
        if distance < 20 then
            local dx = math.abs(playerPos.X - zonePos.X)
            local dy = playerPos.Y - zonePos.Y
            local dz = math.abs(playerPos.Z - zonePos.Z)

            local halfX = zone.Size.X / 2
            local halfZ = zone.Size.Z / 2

            local inBoundsX = dx < (halfX + 2)
            local inBoundsZ = dz < (halfZ + 2)
            local inBoundsY = dy > 0 and dy < 5

            if inBoundsX and inBoundsZ and inBoundsY then
                -- Player is ON FREE zone!
                sampleCount = sampleCount + 1
                table.insert(velocitiesOnFree, velMag)

                -- Print every 20 samples (about 0.6s at 30fps)
                if sampleCount % 20 == 0 then
                    local threshold = 1.0
                    local status = velMag >= threshold and "✅ ABOVE" or "❌ BELOW"

                    print(string.format("Zone #%d | Velocity: %.2f | %s threshold (%.1f)",
                        i, velMag, status, threshold))
                end
            end
        end
    end
end)

print("⚡ ==================== MONITORING STARTED ====================")
-- ==================== COPY UNTIL HERE ====================
