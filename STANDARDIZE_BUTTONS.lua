-- STANDARDIZE_BUTTONS.lua
-- Paste in Roblox Studio COMMAND BAR (not console) to standardize button sizes
-- This script will make GamepassButton (x2) and GamepassButton2 (2X WIN) consistent

print("==================== STANDARDIZING BUTTON SIZES ====================")

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- Find SpeedGameUI in StarterGui
local speedGameUI = StarterGui:FindFirstChild("SpeedGameUI")

if not speedGameUI then
	warn("❌ SpeedGameUI not found in StarterGui!")
	warn("Make sure you have SpeedGameUI in StarterGui")
	return
end

print("✅ Found SpeedGameUI")

-- Find buttons
local gamepassButton = nil
local gamepassButton2 = nil

-- Search for buttons by common names
local buttonNames = {"GamepassButton", "SpeedBoostButton", "SpeedBoost", "BoostSpeed"}
local buttonNames2 = {"GamepassButton2", "WinsBoostButton", "WinsBoost", "BoostWins"}

for _, child in pairs(speedGameUI:GetDescendants()) do
	if table.find(buttonNames, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton = child
		print("✅ Found Speed Boost Button: " .. child:GetFullName())
	elseif table.find(buttonNames2, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton2 = child
		print("✅ Found Wins Boost Button: " .. child:GetFullName())
	end
end

if not gamepassButton then
	warn("❌ Speed Boost Button (GamepassButton) not found!")
	return
end

if not gamepassButton2 then
	warn("❌ Wins Boost Button (GamepassButton2) not found!")
	return
end

print("\n==================== CURRENT SIZES ====================")
print("GamepassButton (x2):")
print("   Size: " .. tostring(gamepassButton.Size))
print("   Position: " .. tostring(gamepassButton.Position))

print("\nGamepassButton2 (2X WIN):")
print("   Size: " .. tostring(gamepassButton2.Size))
print("   Position: " .. tostring(gamepassButton2.Position))

-- ✅ STANDARDIZE BUTTON SIZES
print("\n==================== STANDARDIZING ====================")

-- Standard button size (you can adjust these values)
local STANDARD_SIZE = UDim2.new(0, 150, 0, 60)  -- 150px width, 60px height
local STANDARD_ICON_SIZE = UDim2.new(0, 40, 0, 40)  -- 40x40 px for icons
local STANDARD_TEXT_SIZE = 24  -- TextSize for labels

print("📏 Standard button size: " .. tostring(STANDARD_SIZE))
print("📏 Standard icon size: " .. tostring(STANDARD_ICON_SIZE))
print("📏 Standard text size: " .. STANDARD_TEXT_SIZE)

-- Apply standard size to both buttons
gamepassButton.Size = STANDARD_SIZE
gamepassButton2.Size = STANDARD_SIZE

print("✅ Button sizes standardized!")

-- ✅ STANDARDIZE INTERNAL ELEMENTS (icons and text)
print("\n==================== STANDARDIZING ICONS & TEXT ====================")

local function standardizeChildren(button, buttonName)
	print("\n🔍 Processing: " .. buttonName)

	for _, child in pairs(button:GetDescendants()) do
		if child:IsA("ImageLabel") then
			-- Standardize icon size
			print("   📷 Found ImageLabel: " .. child.Name)
			print("      Old Size: " .. tostring(child.Size))
			child.Size = STANDARD_ICON_SIZE
			print("      New Size: " .. tostring(child.Size))

			-- Center the icon if needed
			child.Position = UDim2.new(0.5, -20, 0.5, -20)  -- Center 40x40 icon

		elseif child:IsA("TextLabel") then
			-- Standardize text size
			print("   📝 Found TextLabel: " .. child.Name)
			print("      Old TextSize: " .. child.TextSize)
			child.TextSize = STANDARD_TEXT_SIZE
			print("      New TextSize: " .. child.TextSize)

			-- Ensure text is scaled properly
			child.TextScaled = false  -- Use fixed TextSize instead of TextScaled
		end
	end
end

standardizeChildren(gamepassButton, "GamepassButton (x2)")
standardizeChildren(gamepassButton2, "GamepassButton2 (2X WIN)")

print("\n==================== ✅ STANDARDIZATION COMPLETE ====================")
print("Both buttons now have:")
print("   • Same button size: " .. tostring(STANDARD_SIZE))
print("   • Same icon size: " .. tostring(STANDARD_ICON_SIZE))
print("   • Same text size: " .. STANDARD_TEXT_SIZE)
print("\n💡 If buttons look wrong, adjust STANDARD_SIZE values in the script!")
print("💾 Don't forget to SAVE your place in Roblox Studio!")
