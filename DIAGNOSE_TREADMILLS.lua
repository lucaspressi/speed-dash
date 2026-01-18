-- DIAGNOSE_TREADMILLS.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Diagnoses why treadmills are not working

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

print("🔍 ==================== TREADMILL DIAGNOSTICS ====================")
print("")

-- Check TreadmillService
print("📊 Checking TreadmillService...")
print("")

local TreadmillService = _G.TreadmillService
if not TreadmillService then
	warn("❌ TreadmillService NOT FOUND in _G!")
	warn("   This means TreadmillService.server.lua is not running")
	warn("")
	warn("💡 Solution:")
	warn("   1. Check ServerScriptService for TreadmillService.server.lua")
	warn("   2. Make sure it's ENABLED")
	warn("   3. Restart the game")
	print("")
else
	print("✅ TreadmillService is loaded")

	-- Get stats
	local stats = TreadmillService.getStats()
	print("   Registered zones: " .. stats.registeredZones)
	print("   Active players: " .. stats.activePlayers)
	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check CollectionService tags
print("🏷️ Checking CollectionService tags...")
print("")

local taggedZones = CollectionService:GetTagged("TreadmillZone")
print("   Zones with 'TreadmillZone' tag: " .. #taggedZones)

if #taggedZones > 0 then
	for i, zone in ipairs(taggedZones) do
		print("      #" .. i .. ": " .. zone:GetFullName())
	end
else
	print("   ℹ️ No zones with 'TreadmillZone' tag (using fallback method)")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Scan for TreadmillZone parts
print("🔍 Scanning for TreadmillZone parts...")
print("")

local treadmillZones = {}

-- Look for common treadmill models
local treadmillNames = {
	"TreadmillFree",
	"TreadmillBlue",
	"TreadmillPurple",
	"TreadmillGold",
	"TreadmillPaid",
	"Treadmill"
}

for _, name in ipairs(treadmillNames) do
	for _, obj in pairs(workspace:GetChildren()) do
		if string.match(obj.Name, name) and obj:IsA("Model") then
			table.insert(treadmillZones, obj)
		end
	end
end

print("   Found " .. #treadmillZones .. " treadmill models:")
print("")

for i, model in ipairs(treadmillZones) do
	print("   Treadmill #" .. i .. ": " .. model.Name)
	print("      FullName: " .. model:GetFullName())

	-- Look for TreadmillZone part inside
	local zonePart = model:FindFirstChild("TreadmillZone")

	if zonePart then
		print("      ✅ Has TreadmillZone part")

		-- Check attributes
		local multiplier = zonePart:GetAttribute("Multiplier")
		local isFree = zonePart:GetAttribute("IsFree")
		local productId = zonePart:GetAttribute("ProductId")

		print("         Multiplier: " .. tostring(multiplier))
		print("         IsFree: " .. tostring(isFree))
		print("         ProductId: " .. tostring(productId))

		-- Validation
		if not multiplier then
			warn("         ❌ Missing Multiplier attribute!")
		elseif multiplier == 1 or isFree == true then
			print("         ✅ Valid FREE zone")
		elseif multiplier > 1 then
			if not productId or productId == 0 then
				warn("         ❌ PAID zone missing ProductId!")
			else
				print("         ✅ Valid PAID zone")
			end
		end

		-- Check if part is properly positioned
		print("         Position: " .. tostring(zonePart.Position))
		print("         Size: " .. tostring(zonePart.Size))
		print("         Anchored: " .. tostring(zonePart.Anchored))
		print("         CanCollide: " .. tostring(zonePart.CanCollide))
		print("         Transparency: " .. tostring(zonePart.Transparency))

	else
		warn("      ❌ No TreadmillZone part found inside model!")
		warn("         Model needs a Part named 'TreadmillZone' to work")
	end

	print("")
end

if #treadmillZones == 0 then
	warn("❌ No treadmill models found!")
	warn("   Looked for models named: " .. table.concat(treadmillNames, ", "))
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check player state (if any player is in game)
print("👤 Checking player states...")
print("")

local players = Players:GetPlayers()
if #players > 0 then
	for _, player in ipairs(players) do
		print("   Player: " .. player.Name)

		-- Check attributes
		local multiplier = player:GetAttribute("CurrentTreadmillMultiplier")
		local onTreadmill = player:GetAttribute("OnTreadmill")

		print("      CurrentTreadmillMultiplier: " .. tostring(multiplier))
		print("      OnTreadmill: " .. tostring(onTreadmill))

		-- Check character position
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				print("      Position: " .. tostring(hrp.Position))

				-- Try to detect zone at current position
				if TreadmillService then
					local zoneData, zoneInstance = TreadmillService.getPlayerZone(player)
					if zoneData then
						print("      ✅ Currently on zone: " .. zoneInstance:GetFullName())
						print("         Zone Multiplier: " .. zoneData.Multiplier)
					else
						print("      ℹ️ Not currently on any zone")
					end
				end
			end
		end

		print("")
	end
else
	print("   ℹ️ No players in game")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 RECOMMENDATIONS:")
print("")

if not TreadmillService then
	warn("❌ TreadmillService is not running!")
	print("   1. Check ServerScriptService for TreadmillService.server.lua")
	print("   2. Make sure it's ENABLED")
	print("   3. Check Output window for errors")
	print("")
elseif TreadmillService.getStats().registeredZones == 0 then
	warn("❌ No zones registered!")
	print("   This means:")
	print("   1. TreadmillZone parts don't have required Attributes")
	print("   2. Or they're not named 'TreadmillZone'")
	print("   3. Or they're not in the Workspace")
	print("")
	print("   Run FIX_TREADMILLS.lua to fix this")
	print("")
else
	print("✅ TreadmillService is working")
	print("   If zones still don't work, check:")
	print("   1. Are the zones properly positioned?")
	print("   2. Are players actually standing ON the zones?")
	print("   3. Check Output window for errors")
	print("")
end

print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
