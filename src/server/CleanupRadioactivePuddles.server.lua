-- CleanupRadioactivePuddles.server.lua
-- Removes old broken scripts from Radioactive_Puddles and applies the correct solution
--
-- PROBLEM: Old scripts try to access Model.Touched and Model.Color which cause errors:
--   "Touched is not a valid member of Model 'Workspace.Radioactive_Puddles'"
--   "Color is not a valid member of Model 'Workspace.Radioactive_Puddles'"
--
-- SOLUTION: Remove old scripts and install the correct RadioactiveKillScript

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("[CleanupRadioactivePuddles] 🧹 STARTING CLEANUP...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local scriptsRemoved = 0
local debounceTable = {}

-- ==================== CONFIGURATION ====================
local DAMAGE_AMOUNT = 100  -- Instant kill
local COOLDOWN_TIME = 1    -- Seconds between damage ticks per player
local PUDDLE_COLOR = Color3.fromRGB(0, 255, 0)  -- Radioactive green
local PUDDLE_MATERIAL = Enum.Material.Neon

-- ==================== STEP 1: FIND AND REMOVE OLD SCRIPTS ====================
local function cleanupOldScripts()
	print("[CleanupRadioactivePuddles] 🔍 Searching for Radioactive_Puddles...")

	local radioactivePuddles = workspace:FindFirstChild("Radioactive_Puddles")

	if not radioactivePuddles then
		warn("[CleanupRadioactivePuddles] ⚠️ Radioactive_Puddles model not found in Workspace!")
		warn("[CleanupRadioactivePuddles] Script will wait for it to be added...")
		return false
	end

	if not radioactivePuddles:IsA("Model") then
		warn("[CleanupRadioactivePuddles] ⚠️ Radioactive_Puddles exists but is not a Model!")
		return false
	end

	print("[CleanupRadioactivePuddles] ✅ Found Radioactive_Puddles at: " .. radioactivePuddles:GetFullName())
	print("[CleanupRadioactivePuddles] 🗑️ Removing old problematic scripts...")

	-- Find and remove all old scripts that cause errors
	local scriptsFound = {}
	for _, child in ipairs(radioactivePuddles:GetChildren()) do
		if child:IsA("Script") or child:IsA("LocalScript") then
			table.insert(scriptsFound, {
				name = child.Name,
				className = child.ClassName,
				path = child:GetFullName()
			})
		end
	end

	-- Also check descendants (scripts might be nested)
	for _, descendant in ipairs(radioactivePuddles:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			-- Skip if already in list
			local alreadyFound = false
			for _, scriptInfo in ipairs(scriptsFound) do
				if scriptInfo.path == descendant:GetFullName() then
					alreadyFound = true
					break
				end
			end

			if not alreadyFound then
				table.insert(scriptsFound, {
					name = descendant.Name,
					className = descendant.ClassName,
					path = descendant:GetFullName()
				})
			end
		end
	end

	if #scriptsFound == 0 then
		print("[CleanupRadioactivePuddles] ℹ️ No existing scripts found (clean slate)")
	else
		print("[CleanupRadioactivePuddles] 📋 Found " .. #scriptsFound .. " script(s) to remove:")
		for _, scriptInfo in ipairs(scriptsFound) do
			print("[CleanupRadioactivePuddles]    - " .. scriptInfo.name .. " (" .. scriptInfo.className .. ") at: " .. scriptInfo.path)
		end

		-- Remove all found scripts
		for _, child in ipairs(radioactivePuddles:GetChildren()) do
			if child:IsA("Script") or child:IsA("LocalScript") then
				child:Destroy()
				scriptsRemoved = scriptsRemoved + 1
				print("[CleanupRadioactivePuddles] ✅ Removed: " .. child.Name)
			end
		end

		for _, descendant in ipairs(radioactivePuddles:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") then
				descendant:Destroy()
				scriptsRemoved = scriptsRemoved + 1
				print("[CleanupRadioactivePuddles] ✅ Removed: " .. descendant:GetFullName())
			end
		end
	end

	return true, radioactivePuddles
end

-- ==================== STEP 2: APPLY CORRECT SOLUTION ====================
local function damagePlayer(player, part)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Check cooldown
	local cooldownKey = player.UserId
	local lastDamage = debounceTable[cooldownKey] or 0

	if os.clock() - lastDamage < COOLDOWN_TIME then
		return  -- Still in cooldown
	end

	-- Apply damage
	print("[CleanupRadioactivePuddles] 💀 Damaging " .. player.Name .. " - " .. DAMAGE_AMOUNT .. " damage")
	humanoid:TakeDamage(DAMAGE_AMOUNT)
	debounceTable[cooldownKey] = os.clock()
end

local function setupPart(part)
	if not part:IsA("BasePart") then return end

	-- Apply visual effects (if not already set)
	if part.Material ~= PUDDLE_MATERIAL then
		part.Material = PUDDLE_MATERIAL
	end

	if part.Color ~= PUDDLE_COLOR then
		part.Color = PUDDLE_COLOR
	end

	-- Ensure collision is enabled
	part.CanCollide = false  -- Players can walk through
	part.CanTouch = true
	part.CanQuery = true
	part.Anchored = true

	-- Connect Touched event
	local connection = part.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end

		-- Check if hit is part of a character
		local character = hit.Parent
		if not character:FindFirstChild("Humanoid") then
			-- Maybe it's an accessory/tool, check parent.Parent
			character = hit.Parent.Parent
			if not character or not character:FindFirstChild("Humanoid") then
				return
			end
		end

		-- Get player
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			damagePlayer(player, part)
		end
	end)

	print("[CleanupRadioactivePuddles] ✅ Setup part: " .. part.Name)

	-- Cleanup connection when part is destroyed
	part.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

local function applyCorrectSolution(model)
	print("[CleanupRadioactivePuddles] 🔧 Applying correct kill script solution...")

	local partsSetup = 0

	-- Setup existing parts
	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			setupPart(descendant)
			partsSetup = partsSetup + 1
		end
	end

	-- Setup future parts that get added
	model.DescendantAdded:Connect(function(descendant)
		task.wait(0.1)  -- Small delay to ensure it's fully loaded
		if descendant:IsA("BasePart") then
			setupPart(descendant)
			print("[CleanupRadioactivePuddles] 🆕 Dynamically added part: " .. descendant.Name)
		end
	end)

	print("[CleanupRadioactivePuddles] ✅ Setup " .. partsSetup .. " radioactive puddle parts")

	return partsSetup
end

-- ==================== STEP 3: PERIODIC DEBOUNCE CLEANUP ====================
local function startDebounceCleanup()
	task.spawn(function()
		while true do
			task.wait(60)  -- Every minute
			local currentTime = os.clock()
			local cleaned = 0
			for userId, lastTime in pairs(debounceTable) do
				if currentTime - lastTime > 60 then
					debounceTable[userId] = nil
					cleaned = cleaned + 1
				end
			end
			if cleaned > 0 then
				print("[CleanupRadioactivePuddles] 🧹 Cleaned " .. cleaned .. " old debounce entries")
			end
		end
	end)
end

-- ==================== EXECUTE CLEANUP ====================
task.wait(2)  -- Wait for workspace to load

local success, model = cleanupOldScripts()

if success and model then
	local partsSetup = applyCorrectSolution(model)
	startDebounceCleanup()

	-- Summary
	print("[CleanupRadioactivePuddles] ============================================")
	print("[CleanupRadioactivePuddles] ✅ CLEANUP COMPLETE!")
	print("[CleanupRadioactivePuddles] Scripts removed: " .. scriptsRemoved)
	print("[CleanupRadioactivePuddles] Parts configured: " .. partsSetup)
	print("[CleanupRadioactivePuddles] Damage per touch: " .. DAMAGE_AMOUNT .. " HP")
	print("[CleanupRadioactivePuddles] Cooldown: " .. COOLDOWN_TIME .. " seconds")
	print("[CleanupRadioactivePuddles] ============================================")
	print("[CleanupRadioactivePuddles] ✅ Radioactive_Puddles is now working correctly!")
	print("[CleanupRadioactivePuddles] No more 'Touched is not a valid member' errors!")
	print("[CleanupRadioactivePuddles] ============================================")
else
	-- If Radioactive_Puddles doesn't exist yet, wait for it
	print("[CleanupRadioactivePuddles] ⏳ Waiting for Radioactive_Puddles to be added to Workspace...")

	workspace.ChildAdded:Connect(function(child)
		task.wait(0.5)  -- Give it time to fully load
		if child.Name == "Radioactive_Puddles" and child:IsA("Model") then
			print("[CleanupRadioactivePuddles] 🎯 Radioactive_Puddles detected! Running cleanup...")
			success, model = cleanupOldScripts()
			if success and model then
				local partsSetup = applyCorrectSolution(model)
				startDebounceCleanup()

				print("[CleanupRadioactivePuddles] ============================================")
				print("[CleanupRadioactivePuddles] ✅ CLEANUP COMPLETE!")
				print("[CleanupRadioactivePuddles] Scripts removed: " .. scriptsRemoved)
				print("[CleanupRadioactivePuddles] Parts configured: " .. partsSetup)
				print("[CleanupRadioactivePuddles] ============================================")
			end
		end
	end)
end
