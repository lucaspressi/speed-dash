-- LIST_ALL_BUTTONS.lua
-- Paste in Roblox Studio COMMAND BAR to list ALL buttons and UI elements
-- This will help us find the correct button names and locations

-- ==================== COPY FROM HERE ====================
print("==================== LISTING ALL UI ELEMENTS ====================")

local StarterGui = game:GetService("StarterGui")

print("\n📂 ALL ScreenGuis in StarterGui:")
for _, child in pairs(StarterGui:GetChildren()) do
	if child:IsA("ScreenGui") then
		print("   • " .. child.Name .. " (" .. child.ClassName .. ")")
	end
end

print("\n🔘 ALL BUTTONS in StarterGui (recursive search):")
local buttonCount = 0
for _, descendant in pairs(StarterGui:GetDescendants()) do
	if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
		buttonCount = buttonCount + 1
		print("\n" .. buttonCount .. ". " .. descendant.Name .. " (" .. descendant.ClassName .. ")")
		print("   Path: " .. descendant:GetFullName())
		print("   Size: " .. tostring(descendant.Size))
		print("   Position: " .. tostring(descendant.Position))

		-- Check if it's visible
		print("   Visible: " .. tostring(descendant.Visible))

		-- Check text if it's a TextButton
		if descendant:IsA("TextButton") and descendant.Text then
			print("   Text: \"" .. descendant.Text .. "\"")
		end
	end
end

if buttonCount == 0 then
	print("   ❌ No buttons found!")
else
	print("\n✅ Found " .. buttonCount .. " total buttons")
end

print("\n📦 ALL FRAMES in StarterGui:")
local frameCount = 0
for _, descendant in pairs(StarterGui:GetDescendants()) do
	if descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
		frameCount = frameCount + 1
		print("   • " .. descendant:GetFullName())
	end
end
print("   Total frames: " .. frameCount)

print("\n📝 ALL TEXTLABELS in StarterGui:")
local labelCount = 0
for _, descendant in pairs(StarterGui:GetDescendants()) do
	if descendant:IsA("TextLabel") then
		labelCount = labelCount + 1
		if descendant.Text and descendant.Text ~= "" then
			print("   • " .. descendant.Name .. ": \"" .. descendant.Text .. "\"")
			print("     Path: " .. descendant:GetFullName())
		end
	end
end
print("   Total labels: " .. labelCount)

print("\n==================== LISTING COMPLETE ====================")
print("\n💡 TIP: Look for button names containing:")
print("   • 'Speed', 'Boost', 'Gamepass', 'x2', 'Win'")
print("   • Then use those exact names in the STANDARDIZE script!")

-- ==================== COPY UNTIL HERE ====================
