-- CleanupBadScripts.server.lua
-- ✅ Disables problematic scripts that aren't managed by Rojo
-- These scripts (from free models/plugins) cause errors and block core gameplay

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("[CleanupBadScripts] 🧹 STARTING CLEANUP...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local scriptsDisabled = 0
local objectsRemoved = 0

-- ==================== FIX 1: CoreTextureSystem ====================
-- Error: Workspace.Lighting.Extra.CoreTextureSystem:267: attempt to index nil with 'Value'
-- Location: Workspace.Lighting.Extra.CoreTextureSystem
-- Solution: Disable the script completely

local function cleanupCoreTextureSystem()
	print("[CleanupBadScripts] Searching for CoreTextureSystem...")

	-- Search in multiple possible locations
	local searchPaths = {
		workspace:FindFirstChild("Lighting"),
		game:GetService("Lighting"),
		workspace,
	}

	local found = false
	for _, parent in ipairs(searchPaths) do
		if parent then
			-- Search recursively in descendants
			for _, descendant in ipairs(parent:GetDescendants()) do
				if descendant.Name == "CoreTextureSystem" and (descendant:IsA("Script") or descendant:IsA("LocalScript")) then
					local path = descendant:GetFullName()
					descendant.Disabled = true
					task.wait(0.1)  -- Let it stop running
					descendant:Destroy()  -- Remove completely
					scriptsDisabled = scriptsDisabled + 1
					objectsRemoved = objectsRemoved + 1
					print("[CleanupBadScripts] ✅ Destroyed CoreTextureSystem at: " .. path)
					found = true
				end
			end
		end
	end

	if not found then
		print("[CleanupBadScripts] ℹ️ CoreTextureSystem not found (already removed or doesn't exist)")
	end
end

-- ==================== FIX 2: AuraHandler ====================
-- Error: Infinite yield on 'ReplicatedStorage.Auras.DefaultAura:WaitForChild("AuraAttachment")'
-- Location: Character.AuraHandler (cloned to each player)
-- Root Cause: ReplicatedStorage.Auras folder exists but DefaultAura is misconfigured
-- Solution: Either fix DefaultAura structure OR remove the Auras folder entirely

local function cleanupAuraSystem()
	local auras = ReplicatedStorage:FindFirstChild("Auras")

	if not auras then
		print("[CleanupBadScripts] ℹ️ No Auras folder found (already clean)")
		return
	end

	-- Option 1: Try to fix DefaultAura by adding missing AuraAttachment
	local defaultAura = auras:FindFirstChild("DefaultAura")
	if defaultAura then
		local auraAttachment = defaultAura:FindFirstChild("AuraAttachment")
		if not auraAttachment then
			-- Create the missing AuraAttachment to stop infinite yield
			auraAttachment = Instance.new("Attachment")
			auraAttachment.Name = "AuraAttachment"
			auraAttachment.Parent = defaultAura
			print("[CleanupBadScripts] ✅ Created missing AuraAttachment in DefaultAura")
		end

		-- Also add a ParticleEmitter if missing (auras usually need this)
		if not defaultAura:FindFirstChild("ParticleEmitter") then
			local particle = Instance.new("ParticleEmitter")
			particle.Name = "ParticleEmitter"
			particle.Enabled = false -- Disabled by default
			particle.Parent = auraAttachment
			print("[CleanupBadScripts] ✅ Created ParticleEmitter in AuraAttachment")
		end
	end

	-- Option 2: If auras are not needed, comment out below to remove entirely
	--[[
	auras:Destroy()
	objectsRemoved = objectsRemoved + 1
	print("[CleanupBadScripts] ✅ Removed Auras folder completely (not needed)")
	--]]
end

-- ==================== FIX 3: Disable AuraHandler in Characters ====================
-- The AuraHandler script gets cloned into each player's character
-- We need to disable it when players spawn

local function disableAuraHandlerForCharacter(character)
	task.spawn(function()
		-- Wait for AuraHandler to be added to character (usually happens on spawn)
		task.wait(1)

		local auraHandler = character:FindFirstChild("AuraHandler")
		if auraHandler and (auraHandler:IsA("Script") or auraHandler:IsA("LocalScript")) then
			auraHandler.Disabled = true
			scriptsDisabled = scriptsDisabled + 1
			print("[CleanupBadScripts] ✅ Disabled AuraHandler for " .. character.Name)
		end
	end)
end

-- Connect to all current and future players
local Players = game:GetService("Players")

for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		disableAuraHandlerForCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		disableAuraHandlerForCharacter(character)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		disableAuraHandlerForCharacter(character)
	end)
end)

-- ==================== FIX 3: Old TreadmillZone Scripts ====================
-- Error: TreadmillZone missing ProductId or Multiplier
-- Cause: Old TreadmillZone parts from previous versions still have scripts attached
-- Solution: Remove old TreadmillZoneHandler scripts from parts

local function cleanupOldTreadmillScripts()
	print("[CleanupBadScripts] Searching for old TreadmillZoneHandler scripts...")

	local found = 0
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant.Name == "TreadmillZoneHandler" and (descendant:IsA("Script") or descendant:IsA("LocalScript")) then
			local parent = descendant.Parent
			if parent and parent.Name == "TreadmillZone" then
				descendant:Destroy()
				scriptsDisabled = scriptsDisabled + 1
				found = found + 1
				print("[CleanupBadScripts] ✅ Removed old TreadmillZoneHandler from: " .. parent:GetFullName())
			end
		end
	end

	if found == 0 then
		print("[CleanupBadScripts] ℹ️ No old TreadmillZoneHandler scripts found")
	else
		print("[CleanupBadScripts] ✅ Removed " .. found .. " old TreadmillZoneHandler scripts")
	end
end

-- ==================== RUN CLEANUP ====================
cleanupCoreTextureSystem()
cleanupAuraSystem()
cleanupOldTreadmillScripts()

-- ==================== SUMMARY ====================
task.wait(2) -- Give scripts time to be disabled

print("[CleanupBadScripts] ============================================")
print("[CleanupBadScripts] ✅ Cleanup complete!")
print("[CleanupBadScripts] Scripts disabled: " .. scriptsDisabled)
print("[CleanupBadScripts] Objects removed: " .. objectsRemoved)
print("[CleanupBadScripts] ============================================")
print("[CleanupBadScripts] Core gameplay systems should now work:")
print("[CleanupBadScripts]   - XP increments ✅")
print("[CleanupBadScripts]   - Level progression ✅")
print("[CleanupBadScripts]   - Leaderboard updates ✅")
print("[CleanupBadScripts]   - UI buttons ✅")
print("[CleanupBadScripts] ============================================")
