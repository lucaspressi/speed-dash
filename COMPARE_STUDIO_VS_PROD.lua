-- COMPARE_STUDIO_VS_PROD.lua
-- Run in Command Bar (SERVER) in BOTH Studio AND Production
-- Compares zone positions to find differences

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local isStudio = RunService:IsStudio()
local environment = isStudio and "STUDIO" or "PRODUCTION"

print("🔍 ==================== ENVIRONMENT: " .. environment .. " ====================")
print("")

-- Find all TreadmillZone parts
print("📦 Scanning for TreadmillZone parts...")
print("")

local zones = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
        local multiplier = obj:GetAttribute("Multiplier")
        local isFree = obj:GetAttribute("IsFree")

        table.insert(zones, {
            name = obj:GetFullName(),
            position = obj.Position,
            size = obj.Size,
            multiplier = multiplier,
            isFree = isFree,
            transparency = obj.Transparency,
            canCollide = obj.CanCollide
        })
    end
end

print("Found " .. #zones .. " TreadmillZone parts:")
print("")

-- Sort by multiplier for easy comparison
table.sort(zones, function(a, b)
    return (a.multiplier or 0) < (b.multiplier or 0)
end)

for i, zone in ipairs(zones) do
    local typeStr = zone.multiplier == 1 and "FREE" or
                    zone.multiplier == 3 and "GOLD" or
                    zone.multiplier == 9 and "BLUE" or
                    zone.multiplier == 25 and "PURPLE" or
                    "UNKNOWN"

    print(string.format("#%d: %s", i, typeStr))
    print("    Name: " .. zone.name)
    print(string.format("    Position: X=%.1f, Y=%.1f, Z=%.1f", zone.position.X, zone.position.Y, zone.position.Z))
    print(string.format("    Size: X=%.1f, Y=%.1f, Z=%.1f", zone.size.X, zone.size.Y, zone.size.Z))
    print("    Multiplier: " .. tostring(zone.multiplier))
    print("    IsFree: " .. tostring(zone.isFree))
    print("    Transparency: " .. tostring(zone.transparency))
    print("    CanCollide: " .. tostring(zone.canCollide))
    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Count by type
local freeCount = 0
local goldCount = 0
local blueCount = 0
local purpleCount = 0
local unknownCount = 0

for _, zone in ipairs(zones) do
    if zone.multiplier == 1 then
        freeCount = freeCount + 1
    elseif zone.multiplier == 3 then
        goldCount = goldCount + 1
    elseif zone.multiplier == 9 then
        blueCount = blueCount + 1
    elseif zone.multiplier == 25 then
        purpleCount = purpleCount + 1
    else
        unknownCount = unknownCount + 1
    end
end

print("📊 SUMMARY BY TYPE:")
print("   FREE (x1): " .. freeCount)
print("   GOLD (x3): " .. goldCount)
print("   BLUE (x9): " .. blueCount)
print("   PURPLE (x25): " .. purpleCount)
if unknownCount > 0 then
    warn("   UNKNOWN: " .. unknownCount)
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check FREE zones specifically (common problem)
print("🔍 FREE ZONE ANALYSIS:")
print("")

local freeZones = {}
for _, zone in ipairs(zones) do
    if zone.multiplier == 1 or zone.isFree == true then
        table.insert(freeZones, zone)
    end
end

if #freeZones == 0 then
    warn("❌ NO FREE ZONES FOUND!")
    warn("   This is a critical problem!")
else
    for i, zone in ipairs(freeZones) do
        print(string.format("FREE Zone #%d:", i))
        print("   Y position: " .. string.format("%.1f", zone.position.Y))

        -- Check if Y position is correct
        if zone.position.Y < 0.5 then
            warn("   ❌ Y position too low! Should be around 1.0")
        elseif zone.position.Y > 5 and zone.position.Y < 40 then
            warn("   ⚠️ Y position seems wrong (between 5-40)")
        else
            print("   ✅ Y position looks good")
        end
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 INSTRUCTIONS:")
print("")
print("1. Run this script in STUDIO (with fixed zones)")
print("2. Copy the output")
print("3. Run this script in PRODUCTION (after deploy)")
print("4. Compare the outputs")
print("")
print("If the Y positions are DIFFERENT, the fixes weren't published!")
print("")

print("🔍 ==================== END SCAN (" .. environment .. ") ====================")
-- ==================== COPY UNTIL HERE ====================
