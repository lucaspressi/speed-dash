-- EMERGENCY_FIX_BUTTONS.lua
-- EMERGENCY FIX: Makes all hidden buttons visible again
-- Paste in Roblox Studio COMMAND BAR to restore buttons

print("==================== EMERGENCY BUTTON FIX ====================")

local StarterGui = game:GetService("StarterGui")

-- Check if in Play Mode
local Players = game:GetService("Players")
local targetGui = StarterGui

if #Players:GetPlayers() > 0 then
	local player = Players:GetPlayers()[1]
	if player:FindFirstChild("PlayerGui") then
		targetGui = player.PlayerGui
		print("✅ Running in Play Mode - using PlayerGui")
	end
else
	print("✅ Running in Edit Mode - using StarterGui")
end

local speedGameUI = targetGui:FindFirstChild("SpeedGameUI")

if not speedGameUI then
	warn("❌ SpeedGameUI not found!")
	return
end

print("✅ Found SpeedGameUI")

-- FORCE MAKE ALL BUTTONS VISIBLE
local fixCount = 0
local buttonNames = {
	"GamepassButton", "GamepassButton2", "SpeedBoostButton", "WinsBoostButton",
	"RebirthButton", "FreeButton", "BoostSpeed", "BoostWins"
}

print("\n🔧 FORCING ALL BUTTONS TO VISIBLE...")

for _, descendant in pairs(speedGameUI:GetDescendants()) do
	if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) then
		-- Check if it matches our button names
		local isTargetButton = table.find(buttonNames, descendant.Name) ~= nil

		if isTargetButton or descendant.Name:match("Button") then
			if not descendant.Visible then
				print("   🔧 Fixing: " .. descendant.Name .. " (was hidden)")
				descendant.Visible = true
				fixCount = fixCount + 1
			else
				print("   ✅ OK: " .. descendant.Name .. " (already visible)")
			end
		end
	end
end

-- ALSO CHECK CONTAINERS
print("\n🔧 CHECKING CONTAINERS...")
local containers = {"ButtonsContainer", "BoostFrame"}

for _, containerName in pairs(containers) do
	local container = speedGameUI:FindFirstChild(containerName)
	if container then
		if not container.Visible then
			print("   🔧 Fixing: " .. containerName .. " (was hidden)")
			container.Visible = true
			fixCount = fixCount + 1
		else
			print("   ✅ OK: " .. containerName .. " (already visible)")
		end
	end
end

print("\n==================== FIX COMPLETE ====================")
if fixCount > 0 then
	print("✅ Fixed " .. fixCount .. " hidden elements!")
	print("💾 SAVE YOUR PLACE NOW (Ctrl+S)!")
else
	print("✅ All buttons already visible - no fix needed")
end

print("\n💡 If buttons still missing, run FIND_SPEEDGAMEUI.lua to diagnose")
