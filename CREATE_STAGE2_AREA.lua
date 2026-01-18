-- CREATE_STAGE2_AREA.lua
-- Run in Command Bar (SERVER) to create Stage2NpcKill patrol area
-- Creates a rectangular patrol zone

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("📦 ==================== CREATING STAGE2 PATROL AREA ====================")
print("")

-- Check if already exists
local existing = workspace:FindFirstChild("Stage2NpcKill")
if existing then
    print("✅ 'Stage2NpcKill' already exists at: " .. existing:GetFullName())
    print("   Delete it first if you want to recreate it.")

    -- Count parts inside
    local partCount = 0
    for _, child in pairs(existing:GetChildren()) do
        if child:IsA("BasePart") then
            partCount = partCount + 1
        end
    end

    print("   Parts inside: " .. partCount)

    if partCount == 0 then
        warn("   ⚠️ Folder exists but has NO PARTS!")
        warn("   Add Parts to define the patrol area boundaries.")
    end

    return
end

-- Create the folder
print("Creating Stage2NpcKill folder...")

local stage2Folder = Instance.new("Folder")
stage2Folder.Name = "Stage2NpcKill"
stage2Folder.Parent = workspace

-- Configuration
local CENTER_X = 0  -- Change this to center on your Stage 2
local CENTER_Z = 0  -- Change this to center on your Stage 2
local AREA_WIDTH = 100  -- Width of patrol area (X axis)
local AREA_LENGTH = 100  -- Length of patrol area (Z axis)
local HEIGHT = 50  -- Height where NPC patrols

print("")
print("⚙️ CONFIGURATION:")
print("   Center: X=" .. CENTER_X .. " Z=" .. CENTER_Z)
print("   Size: " .. AREA_WIDTH .. "x" .. AREA_LENGTH .. " studs")
print("   Height: Y=" .. HEIGHT)
print("")
print("💡 TIP: Adjust CENTER_X, CENTER_Z, AREA_WIDTH, AREA_LENGTH in the script")
print("   to match your Stage 2 location and size!")
print("")

-- Create 4 corner markers (invisible)
local corners = {
    {X = CENTER_X - AREA_WIDTH/2, Z = CENTER_Z - AREA_LENGTH/2, name = "Corner_SW"},
    {X = CENTER_X + AREA_WIDTH/2, Z = CENTER_Z - AREA_LENGTH/2, name = "Corner_SE"},
    {X = CENTER_X - AREA_WIDTH/2, Z = CENTER_Z + AREA_LENGTH/2, name = "Corner_NW"},
    {X = CENTER_X + AREA_WIDTH/2, Z = CENTER_Z + AREA_LENGTH/2, name = "Corner_NE"},
}

for _, corner in ipairs(corners) do
    local part = Instance.new("Part")
    part.Name = corner.name
    part.Size = Vector3.new(2, 2, 2)
    part.Position = Vector3.new(corner.X, HEIGHT, corner.Z)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5  -- Semi-transparent for visibility
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Lime green")
    part.Parent = stage2Folder

    print("   Created: " .. part.Name .. " at " .. tostring(part.Position))
end

print("")
print("✅ 'Stage2NpcKill' created successfully!")
print("   Location: " .. stage2Folder:GetFullName())
print("   Parts: 4 corner markers")
print("")
print("📍 NEXT STEPS:")
print("   1. In Studio, select the 4 corner Parts")
print("   2. Move them to surround your Stage 2 area")
print("   3. The NPC will patrol within these boundaries")
print("   4. (Optional) Set Transparency = 1 to make them invisible")
print("")
print("📦 ==================== DONE ====================")
-- ==================== COPY UNTIL HERE ====================
