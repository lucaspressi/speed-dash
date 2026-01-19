-- FIND_SPEEDGAMEUI.lua
-- Comprehensive search for SpeedGameUI and buttons in ALL locations
-- Paste in Roblox Studio COMMAND BAR

print("==================== SEARCHING FOR SPEEDGAMEUI ====================")

local locations = {
	game:GetService("StarterGui"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerStorage"),
	workspace,
}

-- Also check PlayerGui if in Play Mode
local Players = game:GetService("Players")
if #Players:GetPlayers() > 0 then
	local player = Players:GetPlayers()[1]
	if player:FindFirstChild("PlayerGui") then
		table.insert(locations, player.PlayerGui)
		print("✅ Added PlayerGui to search (Play Mode detected)")
	end
end

print("\n🔍 SEARCHING IN " .. #locations .. " LOCATIONS:")
for _, location in pairs(locations) do
	print("   • " .. location:GetFullName())
end

local speedGameUIFound = false
local speedGameUILocation = nil

print("\n==================== SEARCHING FOR 'SpeedGameUI' ====================")

for _, location in pairs(locations) do
	for _, descendant in pairs(location:GetDescendants()) do
		if descendant.Name == "SpeedGameUI" or string.match(descendant.Name:lower(), "speedgame") then
			speedGameUIFound = true
			speedGameUILocation = descendant
			print("\n✅ FOUND: " .. descendant.Name)
			print("   Location: " .. descendant:GetFullName())
			print("   ClassName: " .. descendant.ClassName)
			print("   Parent: " .. tostring(descendant.Parent))

			-- List all children
			print("\n   📂 CHILDREN:")
			for _, child in pairs(descendant:GetChildren()) do
				print("      • " .. child.Name .. " (" .. child.ClassName .. ")")
			end

			-- Search for buttons inside SpeedGameUI
			print("\n   🔘 BUTTONS INSIDE:")
			local buttonCount = 0
			for _, button in pairs(descendant:GetDescendants()) do
				if button:IsA("TextButton") or button:IsA("ImageButton") then
					buttonCount = buttonCount + 1
					print("\n      " .. buttonCount .. ". " .. button.Name .. " (" .. button.ClassName .. ")")
					print("         Path: " .. button:GetFullName())
					print("         Size: " .. tostring(button.Size))
					print("         Position: " .. tostring(button.Position))
					print("         Visible: " .. tostring(button.Visible))

					-- List children of button (icons, text)
					print("         📦 CONTENTS:")
					for _, content in pairs(button:GetChildren()) do
						print("            • " .. content.Name .. " (" .. content.ClassName .. ")")
						if content:IsA("ImageLabel") then
							print("              Size: " .. tostring(content.Size))
							print("              Position: " .. tostring(content.Position))
						elseif content:IsA("TextLabel") then
							print("              Text: \"" .. content.Text .. "\"")
							print("              TextSize: " .. content.TextSize)
							print("              TextScaled: " .. tostring(content.TextScaled))
						end
					end
				end
			end

			if buttonCount == 0 then
				warn("      ❌ No buttons found inside SpeedGameUI!")
			else
				print("\n      ✅ Found " .. buttonCount .. " buttons inside SpeedGameUI")
			end
		end
	end
end

if not speedGameUIFound then
	warn("\n❌ SpeedGameUI NOT FOUND in any location!")
	warn("Possible reasons:")
	warn("   1. SpeedGameUI doesn't exist yet (needs to be created)")
	warn("   2. SpeedGameUI has a different name")
	warn("   3. You need to be in PLAY MODE (press F5) to see PlayerGui")

	print("\n🔍 ALTERNATIVE SEARCH: Looking for ANY GUI with 'Speed' in name...")
	for _, location in pairs(locations) do
		for _, descendant in pairs(location:GetDescendants()) do
			if string.match(descendant.Name:lower(), "speed") or string.match(descendant.Name:lower(), "game") then
				print("   • " .. descendant.Name .. " (" .. descendant.ClassName .. ") at " .. descendant:GetFullName())
			end
		end
	end
else
	print("\n==================== ✅ SEARCH COMPLETE ====================")
	print("SpeedGameUI found at: " .. speedGameUILocation:GetFullName())
	print("\n💡 NEXT STEPS:")
	print("1. If buttons exist: Use STANDARDIZE_BUTTONS.lua")
	print("2. If buttons missing: Create them in Roblox Studio")
	print("3. If button names different: Update script with correct names")
end

print("\n==================== ADDITIONAL INFO ====================")
print("All ScreenGuis in StarterGui:")
for _, child in pairs(game:GetService("StarterGui"):GetChildren()) do
	if child:IsA("ScreenGui") then
		print("   • " .. child.Name)
		for _, subchild in pairs(child:GetChildren()) do
			print("      └─ " .. subchild.Name .. " (" .. subchild.ClassName .. ")")
		end
	end
end
