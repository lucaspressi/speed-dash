-- CREATE_LAVA_PARTS.lua
-- Paste in Studio SERVER console to create lava parts programmatically
-- This ensures lava exists even if .rbxl file doesn't have it

print("==================== CREATING LAVA PARTS ====================")

-- Configuration
local LAVA_CONFIGS = {
    {
        name = "Lava1",
        position = Vector3.new(50, 0.5, 20),
        size = Vector3.new(10, 1, 10),
        color = Color3.fromRGB(255, 68, 51),  -- Red-orange lava
    },
    {
        name = "Lava2",
        position = Vector3.new(70, 0.5, 20),
        size = Vector3.new(10, 1, 10),
        color = Color3.fromRGB(255, 68, 51),
    },
    {
        name = "Lava3",
        position = Vector3.new(90, 0.5, 20),
        size = Vector3.new(10, 1, 10),
        color = Color3.fromRGB(255, 68, 51),
    },
}

local createdParts = {}

for i, config in ipairs(LAVA_CONFIGS) do
    -- Check if already exists
    local existing = workspace:FindFirstChild(config.name)
    if existing then
        print("⚠️ " .. config.name .. " already exists, skipping...")
        table.insert(createdParts, existing)
    else
        -- Create new lava part
        local lava = Instance.new("Part")
        lava.Name = config.name
        lava.Size = config.size
        lava.Position = config.position
        lava.Anchored = true
        lava.CanCollide = true
        lava.CanTouch = true
        lava.CanQuery = true
        lava.Color = config.color
        lava.Material = Enum.Material.Neon
        lava.Transparency = 0.2
        lava.Parent = workspace

        print("✅ Created: " .. config.name)
        print("   Position: " .. tostring(config.position))
        print("   Size: " .. tostring(config.size))

        table.insert(createdParts, lava)
    end
end

print("\n📊 TOTAL: " .. #createdParts .. " lava parts")
print("\n⚠️ IMPORTANT: These parts will disappear when you reload Studio!")
print("   To make them permanent, you need to:")
print("   1. Save the place (File → Publish/Save)")
print("   2. OR add them to default.project.json (better for Rojo workflow)")

print("\n🔧 The LavaKill script should automatically detect and setup these parts.")
print("   Wait 2 seconds, then check for '[LavaKill]' messages in console.")

print("\n==================== DONE ====================")
