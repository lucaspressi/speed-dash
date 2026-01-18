-- CREATE_BUFF_NOOB_SCRIPT.lua
-- Run in Command Bar (SERVER) to automatically create Buff Noob NPC
-- This creates the NPC if it doesn't exist

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🤖 ==================== CREATING BUFF NOOB NPC ====================")
print("")

-- Check if already exists
local existing = workspace:FindFirstChild("Buff Noob")
if existing then
    print("✅ 'Buff Noob' already exists at: " .. existing:GetFullName())
    print("   Delete it first if you want to recreate it.")
    return
end

-- Create a simple humanoid NPC
print("Creating Buff Noob NPC...")

local npc = Instance.new("Model")
npc.Name = "Buff Noob"
npc.Parent = workspace

-- HumanoidRootPart (required)
local hrp = Instance.new("Part")
hrp.Name = "HumanoidRootPart"
hrp.Size = Vector3.new(2, 2, 1)
hrp.Position = Vector3.new(0, 5, 0)  -- Spawn above ground
hrp.Anchored = false
hrp.CanCollide = true
hrp.Transparency = 1  -- Invisible
hrp.Parent = npc

-- Head
local head = Instance.new("Part")
head.Name = "Head"
head.Size = Vector3.new(2, 1, 1)
head.Position = hrp.Position + Vector3.new(0, 2, 0)
head.BrickColor = BrickColor.new("Bright yellow")
head.TopSurface = Enum.SurfaceType.Smooth
head.BottomSurface = Enum.SurfaceType.Smooth
head.Parent = npc

-- Face
local face = Instance.new("Decal")
face.Name = "face"
face.Texture = "rbxasset://textures/face.png"
face.Parent = head

-- Torso
local torso = Instance.new("Part")
torso.Name = "Torso"
torso.Size = Vector3.new(2, 2, 1)
torso.Position = hrp.Position
torso.BrickColor = BrickColor.new("Bright blue")
torso.TopSurface = Enum.SurfaceType.Smooth
torso.BottomSurface = Enum.SurfaceType.Smooth
torso.Parent = npc

-- Left Arm
local leftArm = Instance.new("Part")
leftArm.Name = "Left Arm"
leftArm.Size = Vector3.new(1, 2, 1)
leftArm.Position = hrp.Position + Vector3.new(-1.5, 0, 0)
leftArm.BrickColor = BrickColor.new("Bright yellow")
leftArm.TopSurface = Enum.SurfaceType.Smooth
leftArm.BottomSurface = Enum.SurfaceType.Smooth
leftArm.Parent = npc

-- Right Arm
local rightArm = Instance.new("Part")
rightArm.Name = "Right Arm"
rightArm.Size = Vector3.new(1, 2, 1)
rightArm.Position = hrp.Position + Vector3.new(1.5, 0, 0)
rightArm.BrickColor = BrickColor.new("Bright yellow")
rightArm.TopSurface = Enum.SurfaceType.Smooth
rightArm.BottomSurface = Enum.SurfaceType.Smooth
rightArm.Parent = npc

-- Left Leg
local leftLeg = Instance.new("Part")
leftLeg.Name = "Left Leg"
leftLeg.Size = Vector3.new(1, 2, 1)
leftLeg.Position = hrp.Position + Vector3.new(-0.5, -2, 0)
leftLeg.BrickColor = BrickColor.new("Br. yellowish green")
leftLeg.TopSurface = Enum.SurfaceType.Smooth
leftLeg.BottomSurface = Enum.SurfaceType.Smooth
leftLeg.Parent = npc

-- Right Leg
local rightLeg = Instance.new("Part")
rightLeg.Name = "Right Leg"
rightLeg.Size = Vector3.new(1, 2, 1)
rightLeg.Position = hrp.Position + Vector3.new(0.5, -2, 0)
rightLeg.BrickColor = BrickColor.new("Br. yellowish green")
rightLeg.TopSurface = Enum.SurfaceType.Smooth
rightLeg.BottomSurface = Enum.SurfaceType.Smooth
rightLeg.Parent = npc

-- Humanoid (required)
local humanoid = Instance.new("Humanoid")
humanoid.Name = "Humanoid"
humanoid.Health = 100
humanoid.MaxHealth = 100
humanoid.WalkSpeed = 16
humanoid.Parent = npc

-- Body Colors
local bodyColors = Instance.new("BodyColors")
bodyColors.HeadColor = BrickColor.new("Bright yellow")
bodyColors.LeftArmColor = BrickColor.new("Bright yellow")
bodyColors.RightArmColor = BrickColor.new("Bright yellow")
bodyColors.TorsoColor = BrickColor.new("Bright blue")
bodyColors.LeftLegColor = BrickColor.new("Br. yellowish green")
bodyColors.RightLegColor = BrickColor.new("Br. yellowish green")
bodyColors.Parent = npc

-- Welds (to hold parts together)
local function weldTo(part1, part2)
    local weld = Instance.new("Motor6D")
    weld.Part0 = part1
    weld.Part1 = part2
    weld.C0 = part1.CFrame:Inverse() * part2.CFrame
    weld.Parent = part1
    return weld
end

-- Weld all parts to HRP
weldTo(hrp, torso)
weldTo(torso, head)
weldTo(torso, leftArm)
weldTo(torso, rightArm)
weldTo(torso, leftLeg)
weldTo(torso, rightLeg)

print("")
print("✅ 'Buff Noob' NPC created successfully!")
print("   Position: " .. tostring(hrp.Position))
print("   You can now customize:")
print("   - Move it to desired position")
print("   - Change colors")
print("   - Scale size")
print("   - Add accessories")
print("")
print("🤖 ==================== DONE ====================")
-- ==================== COPY UNTIL HERE ====================
