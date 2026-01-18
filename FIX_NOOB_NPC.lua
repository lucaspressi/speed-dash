-- FIX_NOOB_NPC.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Fixes Buff Noob NPC to work with NoobNpcAI.server.lua

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING BUFF NOOB NPC ====================")
print("")

local noob = workspace:FindFirstChild("Buff Noob")
if not noob then
	warn("❌ 'Buff Noob' NPC not found in Workspace!")
	return
end

print("✅ Found 'Buff Noob' NPC")
print("")

-- Fix 1: Unanchor HumanoidRootPart
local hrp = noob:FindFirstChild("HumanoidRootPart")
if hrp then
	if hrp.Anchored then
		hrp.Anchored = false
		print("✅ FIX 1: Unanchored HumanoidRootPart (was anchored, preventing movement)")
	else
		print("ℹ️ FIX 1: HumanoidRootPart already unanchored")
	end
else
	warn("❌ HumanoidRootPart not found!")
end

print("")

-- Fix 2: Disable conflicting scripts
local scriptsToDisable = {
	"Follow",       -- Conflicts with NoobNpcAI movement
	"Health",       -- Not needed
	"Respawn",      -- Not needed
	"Script",       -- Unknown scripts
}

local disabledCount = 0

print("🔧 FIX 2: Disabling conflicting scripts...")
for _, scriptName in ipairs(scriptsToDisable) do
	for _, obj in pairs(noob:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") then
			if obj.Name == scriptName then
				if obj.Enabled then
					obj.Enabled = false
					disabledCount = disabledCount + 1
					print("   ✅ Disabled: " .. obj:GetFullName())
				end
			end
		end
	end
end

if disabledCount > 0 then
	print("✅ Disabled " .. disabledCount .. " conflicting scripts")
else
	print("ℹ️ No conflicting scripts found to disable")
end

print("")

-- Fix 3: Keep only Animate script enabled
print("🔧 FIX 3: Ensuring Animate script is enabled...")
local animateScript = noob:FindFirstChild("Animate")
if animateScript and (animateScript:IsA("Script") or animateScript:IsA("LocalScript")) then
	if not animateScript.Enabled then
		animateScript.Enabled = true
		print("✅ Enabled Animate script")
	else
		print("ℹ️ Animate script already enabled")
	end
else
	print("ℹ️ Animate script not found (NoobNpcAI will handle animations)")
end

print("")

-- Fix 4: Verify Humanoid settings
local humanoid = noob:FindFirstChild("Humanoid")
if humanoid then
	print("🔧 FIX 4: Checking Humanoid settings...")
	print("   Health: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
	print("   WalkSpeed: " .. humanoid.WalkSpeed .. " (NoobNpcAI will set to 28)")

	-- Reset to default if needed
	if humanoid.MaxHealth < 1000 then
		humanoid.MaxHealth = 1000
		humanoid.Health = 1000
		print("   ✅ Set MaxHealth to 1000")
	end
else
	warn("❌ Humanoid not found!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("📊 SUMMARY:")
print("   ✅ HumanoidRootPart unanchored")
print("   ✅ Conflicting scripts disabled: " .. disabledCount)
print("   ✅ Humanoid configured")
print("")

print("💾 IMPORTANT: SAVE the file (Ctrl+S / Cmd+S)!")
print("")
print("🎮 Next steps:")
print("   1. Save the file")
print("   2. Check ServerScriptService for NoobNpcAI.server.lua")
print("   3. Make sure NoobNpcAI.server.lua is ENABLED")
print("   4. Run the game (F5) and test!")
print("")

print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
