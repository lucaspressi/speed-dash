-- ButtonStandardizer.client.lua
-- Auto-standardizes button sizes for GamepassButton and GamepassButton2
-- Ensures consistent UI appearance across different screen sizes

print("[ButtonStandardizer] 🎨 Initializing button standardization...")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for SpeedGameUI to load
local speedGameUI = playerGui:WaitForChild("SpeedGameUI", 10)

if not speedGameUI then
	warn("[ButtonStandardizer] ⚠️ SpeedGameUI not found!")
	return
end

-- Configuration: Adjust these values to change button appearance
local CONFIG = {
	-- Button sizes
	BUTTON_SIZE = UDim2.new(0, 150, 0, 60),  -- 150px width, 60px height

	-- Icon sizes (ImageLabel inside buttons)
	ICON_SIZE = UDim2.new(0, 40, 0, 40),  -- 40x40 px

	-- Text sizes
	TEXT_SIZE = 24,  -- Fixed text size (not scaled)

	-- Enable/disable features
	STANDARDIZE_BUTTONS = true,  -- Standardize button Size
	STANDARDIZE_ICONS = true,    -- Standardize icon Size
	STANDARDIZE_TEXT = true,     -- Standardize text TextSize
	CENTER_ICONS = true,         -- Center icons within buttons
}

-- Find buttons
local gamepassButton = nil
local gamepassButton2 = nil

local buttonNames = {"GamepassButton", "SpeedBoostButton", "SpeedBoost", "BoostSpeed"}
local buttonNames2 = {"GamepassButton2", "WinsBoostButton", "WinsBoost", "BoostWins"}

for _, child in pairs(speedGameUI:GetDescendants()) do
	if table.find(buttonNames, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton = child
		print("[ButtonStandardizer] ✅ Found Speed Boost Button: " .. child.Name)
	elseif table.find(buttonNames2, child.Name) and (child:IsA("TextButton") or child:IsA("ImageButton")) then
		gamepassButton2 = child
		print("[ButtonStandardizer] ✅ Found Wins Boost Button: " .. child.Name)
	end
end

if not gamepassButton or not gamepassButton2 then
	warn("[ButtonStandardizer] ⚠️ Buttons not found - standardization skipped")
	return
end

-- Function to standardize a button
local function standardizeButton(button, buttonName)
	print("[ButtonStandardizer] 🔧 Standardizing: " .. buttonName)

	-- Standardize button size
	if CONFIG.STANDARDIZE_BUTTONS then
		local oldSize = button.Size
		button.Size = CONFIG.BUTTON_SIZE
		print("[ButtonStandardizer]    Button Size: " .. tostring(oldSize) .. " → " .. tostring(CONFIG.BUTTON_SIZE))
	end

	-- Standardize children (icons and text)
	for _, child in pairs(button:GetDescendants()) do
		if child:IsA("ImageLabel") and CONFIG.STANDARDIZE_ICONS then
			-- Standardize icon size
			local oldSize = child.Size
			child.Size = CONFIG.ICON_SIZE
			print("[ButtonStandardizer]    Icon Size: " .. tostring(oldSize) .. " → " .. tostring(CONFIG.ICON_SIZE))

			-- Center icon if enabled
			if CONFIG.CENTER_ICONS then
				-- Calculate center position based on icon size
				local halfWidth = CONFIG.ICON_SIZE.X.Offset / 2
				local halfHeight = CONFIG.ICON_SIZE.Y.Offset / 2
				child.Position = UDim2.new(0.5, -halfWidth, 0.5, -halfHeight)
			end

		elseif child:IsA("TextLabel") and CONFIG.STANDARDIZE_TEXT then
			-- Standardize text size
			local oldTextSize = child.TextSize
			child.TextSize = CONFIG.TEXT_SIZE
			child.TextScaled = false  -- Use fixed size instead of scaling
			print("[ButtonStandardizer]    Text Size: " .. oldTextSize .. " → " .. CONFIG.TEXT_SIZE)
		end
	end
end

-- Apply standardization
standardizeButton(gamepassButton, "Speed Boost (x2)")
standardizeButton(gamepassButton2, "Wins Boost (2X WIN)")

print("[ButtonStandardizer] ✅ Button standardization complete!")
print("[ButtonStandardizer] 📏 All buttons now use consistent sizes:")
print("[ButtonStandardizer]    • Button: " .. tostring(CONFIG.BUTTON_SIZE))
print("[ButtonStandardizer]    • Icons: " .. tostring(CONFIG.ICON_SIZE))
print("[ButtonStandardizer]    • Text: " .. CONFIG.TEXT_SIZE .. "px")
