-- FIX_LEADERBOARD_UISTROKE.lua
-- Fixes the warning: "TextStrokeColor3/TextStrokeTransparency is invalid when UIStroke exists"
--
-- INSTRUCTIONS:
-- 1. Run this in Roblox Studio Command Bar (View > Command Bar)
-- 2. This will scan all leaderboard TextLabels (Name1..Name10, Score1..Score10)
-- 3. For each TextLabel with UIStroke, it clears the deprecated TextStroke properties
-- 4. Safe to run multiple times

print("==================== FIXING LEADERBOARD UISTROKE ====================")

local workspace = game:GetService("Workspace")
local fixed = 0
local skipped = 0

-- Find leaderboard models
local leaderboards = {
    workspace:FindFirstChild("SpeedLeaderboard"),
    workspace:FindFirstChild("WinsLeaderboard")
}

for _, leaderboard in ipairs(leaderboards) do
    if not leaderboard then continue end

    print("\n📊 Checking: " .. leaderboard.Name)

    -- Find SurfaceGui
    local surfaceGui = leaderboard:FindFirstChild("ScoreBlock")
    if surfaceGui then
        surfaceGui = surfaceGui:FindFirstChild("Leaderboard")
    end

    if not surfaceGui then
        warn("   ⚠️ No Leaderboard SurfaceGui found")
        continue
    end

    -- Find Names and Score folders
    local namesFolder = surfaceGui:FindFirstChild("Names")
    local scoreFolder = surfaceGui:FindFirstChild("Score")

    if not namesFolder and not scoreFolder then
        warn("   ⚠️ No Names or Score folders found")
        continue
    end

    -- Process all Name labels
    if namesFolder then
        for i = 1, 10 do
            local label = namesFolder:FindFirstChild("Name" .. i)
            if label and label:IsA("TextLabel") then
                local uiStroke = label:FindFirstChildOfClass("UIStroke")

                if uiStroke then
                    -- UIStroke exists - clear TextStroke properties to prevent warning
                    if label.TextStrokeTransparency ~= 1 or label.TextStrokeColor3 ~= Color3.fromRGB(0, 0, 0) then
                        print("   🔧 Fixing Name" .. i .. " (has UIStroke)")
                        label.TextStrokeTransparency = 1  -- Make it invisible
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  -- Reset to default
                        fixed = fixed + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    -- No UIStroke - TextStroke properties are valid
                    print("   ✅ Name" .. i .. " (no UIStroke, TextStroke OK)")
                    skipped = skipped + 1
                end
            end
        end
    end

    -- Process all Score labels
    if scoreFolder then
        for i = 1, 10 do
            local label = scoreFolder:FindFirstChild("Score" .. i)
            if label and label:IsA("TextLabel") then
                local uiStroke = label:FindFirstChildOfClass("UIStroke")

                if uiStroke then
                    -- UIStroke exists - clear TextStroke properties to prevent warning
                    if label.TextStrokeTransparency ~= 1 or label.TextStrokeColor3 ~= Color3.fromRGB(0, 0, 0) then
                        print("   🔧 Fixing Score" .. i .. " (has UIStroke)")
                        label.TextStrokeTransparency = 1  -- Make it invisible
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  -- Reset to default
                        fixed = fixed + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    -- No UIStroke - TextStroke properties are valid
                    print("   ✅ Score" .. i .. " (no UIStroke, TextStroke OK)")
                    skipped = skipped + 1
                end
            end
        end
    end
end

print("\n==================== FIX COMPLETE ====================")
print("✅ Fixed: " .. fixed .. " labels")
print("⏭️  Skipped: " .. skipped .. " labels (already correct)")
print("\n💡 The warnings should now be gone!")
print("   If you still see warnings, make sure to:")
print("   1. Save the place (Ctrl+S)")
print("   2. Stop and restart the game")
