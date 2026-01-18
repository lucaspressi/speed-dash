-- DEBUG_ANIMATION.lua
-- COMMAND BAR SCRIPT - Run while game is running (F5)
-- Checks animation state for your character

-- ==================== COPY FROM HERE ====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔍 ==================== ANIMATION DEBUG ====================")

if not player then
	warn("❌ LocalPlayer not found!")
	return
end

print("✅ Player: " .. player.Name)

local character = player.Character
if not character then
	warn("❌ Character not found!")
	return
end

print("✅ Character found")

local humanoid = character:FindFirstChild("Humanoid")
if not humanoid then
	warn("❌ Humanoid not found!")
	return
end

print("✅ Humanoid found")

-- Check attributes
local onTreadmill = player:GetAttribute("OnTreadmill")
local multiplier = player:GetAttribute("CurrentTreadmillMultiplier")

print("")
print("📋 Treadmill State:")
print("   OnTreadmill: " .. tostring(onTreadmill))
print("   Multiplier: " .. tostring(multiplier))

-- Check playing animations
print("")
print("🎬 Currently Playing Animations:")
local animTracks = humanoid:GetPlayingAnimationTracks()
if #animTracks == 0 then
	print("   ❌ NO ANIMATIONS PLAYING")
else
	for _, track in ipairs(animTracks) do
		print("   ▶️ " .. track.Animation.AnimationId)
		print("      Priority: " .. tostring(track.Priority))
		print("      Looped: " .. tostring(track.Looped))
		print("      IsPlaying: " .. tostring(track.IsPlaying))
	end
end

-- Check Animate script
print("")
print("🎭 Animate Script:")
local animate = character:FindFirstChild("Animate")
if animate then
	print("   ✅ Animate script found")
	local run = animate:FindFirstChild("run")
	if run then
		print("   ✅ Run folder found")
		local runAnim = run:FindFirstChildOfClass("Animation")
		if runAnim then
			print("   ✅ Run animation found: " .. runAnim.AnimationId)
		else
			print("   ❌ Run animation not found")
		end
	else
		print("   ❌ Run folder not found")
	end
else
	print("   ❌ Animate script not found")
end

print("🔍 ==================== END DEBUG ====================")
-- ==================== COPY UNTIL HERE ====================
