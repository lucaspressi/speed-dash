-- FIND_UI_LOCATION.lua
-- Paste in Roblox Studio COMMAND BAR to find where SpeedGameUI is located
-- ==================== COPY FROM HERE ====================

print("==================== SEARCHING FOR SpeedGameUI ====================")

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

-- Search in StarterGui (template location)
print("\n🔍 Searching in StarterGui...")
local speedGameUI = StarterGui:FindFirstChild("SpeedGameUI", true)

if speedGameUI then
    print("✅ FOUND in StarterGui!")
    print("   Full path: " .. speedGameUI:GetFullName())
    print("   ClassName: " .. speedGameUI.ClassName)
else
    print("❌ NOT FOUND in StarterGui")
end

-- List all descendants to help locate it
print("\n📂 All UI objects in StarterGui:")
for _, child in pairs(StarterGui:GetDescendants()) do
    if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ScrollingFrame") then
        print("   • " .. child:GetFullName() .. " (" .. child.ClassName .. ")")
    end
end

-- If in play mode, check PlayerGui too
if game:GetService("RunService"):IsClient() then
    print("\n🔍 Searching in PlayerGui (client mode)...")
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:WaitForChild("PlayerGui", 5)
        if playerGui then
            local ui = playerGui:FindFirstChild("SpeedGameUI", true)
            if ui then
                print("✅ FOUND in PlayerGui!")
                print("   Full path: " .. ui:GetFullName())
            else
                print("❌ NOT FOUND in PlayerGui")
            end
        end
    end
end

print("\n==================== SEARCH COMPLETE ====================")

-- ==================== COPY UNTIL HERE ====================
