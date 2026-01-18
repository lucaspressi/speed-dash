-- DIAGNOSE_FREE_REALTIME.lua
-- Run in Command Bar (SERVER with game RUNNING)
-- Real-time monitoring of FREE treadmill detection

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("🔍 ==================== FREE TREADMILL REAL-TIME DIAGNOSTICS ====================")
print("")

-- Find all FREE zones
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
    print("      Size: " .. tostring(zone.Size))
    print("      Multiplier: " .. tostring(zone:GetAttribute("Multiplier")))
    print("      IsFree: " .. tostring(zone:GetAttribute("IsFree")))
    print("      Transparency: " .. tostring(zone.Transparency))
    print("      CanCollide: " .. tostring(zone.CanCollide))
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check TreadmillService
local TreadmillService = _G.TreadmillService
if not TreadmillService then
    warn("❌ TreadmillService not found in _G!")
    print("   The treadmill system is not running.")
    print("   Check ServerScriptService for TreadmillService.server.lua")
    return
end

print("✅ TreadmillService is loaded")
local stats = TreadmillService.getStats()
print("   Registered zones: " .. stats.registeredZones)
print("   Active players: " .. stats.activePlayers)
print("")

-- Check if FREE zones are registered
print("Checking if FREE zones are in TreadmillService...")
for i, zone in ipairs(freeZones) do
    local zoneData, zoneInstance = TreadmillService.getPlayerZone({Character = {HumanoidRootPart = {Position = zone.Position + Vector3.new(0, 3, 0)}}})

    if zoneData then
        print("   ✅ Zone #" .. i .. " IS registered (Mult=" .. zoneData.Multiplier .. ")")
    else
        warn("   ❌ Zone #" .. i .. " NOT registered!")
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Monitor player position relative to FREE zones
local players = Players:GetPlayers()
if #players == 0 then
    warn("⚠️ No players in game! Join to test.")
    return
end

local player = players[1]
print("👤 Monitoring player: " .. player.Name)
print("")
print("Stand on a FREE treadmill and watch the output...")
print("Monitoring for 10 seconds...")
print("")

local startTime = tick()
local connection

connection = RunService.Heartbeat:Connect(function()
    if tick() - startTime > 10 then
        connection:Disconnect()
        print("")
        print("⏱️ Monitoring stopped after 10 seconds")
        return
    end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerPos = hrp.Position

    -- Check distance to each FREE zone
    for i, zone in ipairs(freeZones) do
        local zonePos = zone.Position
        local distance = (playerPos - zonePos).Magnitude

        -- Only print if close (within 20 studs)
        if distance < 20 then
            local dx = math.abs(playerPos.X - zonePos.X)
            local dy = playerPos.Y - zonePos.Y
            local dz = math.abs(playerPos.Z - zonePos.Z)

            local halfX = zone.Size.X / 2
            local halfZ = zone.Size.Z / 2

            local inBoundsX = dx < (halfX + 2)
            local inBoundsZ = dz < (halfZ + 2)
            local inBoundsY = dy > 0 and dy < 5

            print(string.format("Zone #%d | Dist=%.1f | dX=%.1f dY=%.1f dZ=%.1f | inX=%s inZ=%s inY=%s",
                i, distance, dx, dy, dz,
                tostring(inBoundsX), tostring(inBoundsZ), tostring(inBoundsY)))

            if inBoundsX and inBoundsZ and inBoundsY then
                print("   ✅ SHOULD BE DETECTED!")
            else
                print("   ❌ Not in detection range")
            end

            -- Check TreadmillService detection
            local zoneData, zoneInstance = TreadmillService.getPlayerZone(player)
            if zoneData then
                print("   TreadmillService DETECTED: Mult=" .. zoneData.Multiplier)
            else
                print("   TreadmillService: NOT detected")
            end

            -- Check player attributes
            local onTreadmill = player:GetAttribute("OnTreadmill")
            local currentMult = player:GetAttribute("CurrentTreadmillMultiplier")
            print("   Player.OnTreadmill: " .. tostring(onTreadmill))
            print("   Player.CurrentTreadmillMultiplier: " .. tostring(currentMult))

            wait(0.5) -- Print every 0.5s when near
        end
    end
end)

print("")
print("🔍 ==================== MONITORING STARTED ====================")
-- ==================== COPY UNTIL HERE ====================
