-- FIX_MISSING_MULTIPLIERS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Fixes TreadmillZones that are missing Multiplier attributes

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔧 ==================== FIXING MISSING MULTIPLIERS ====================")
print("")

local fixedCount = 0
local treadmillNames = {"TreadmillFree", "TreadmillBlue", "TreadmillPurple", "TreadmillGold", "TreadmillPaid"}

for _, name in ipairs(treadmillNames) do
	for _, obj in pairs(workspace:GetChildren()) do
		if string.match(obj.Name, name) and obj:IsA("Model") then
			local zonePart = obj:FindFirstChild("TreadmillZone")
			
			if zonePart then
				local multiplier = zonePart:GetAttribute("Multiplier")
				
				if not multiplier then
					-- Determine multiplier based on model name
					local newMultiplier = 1
					local newProductId = 0
					local isFree = true
					
					if string.match(name, "Blue") then
						newMultiplier = 9
						newProductId = 3510662188
						isFree = false
					elseif string.match(name, "Purple") then
						newMultiplier = 25
						newProductId = 3510662405
						isFree = false
					elseif string.match(name, "Gold") or string.match(name, "Paid") then
						newMultiplier = 3
						newProductId = 3510662188
						isFree = false
					end
					
					-- Set attributes
					zonePart:SetAttribute("Multiplier", newMultiplier)
					zonePart:SetAttribute("IsFree", isFree)
					zonePart:SetAttribute("ProductId", newProductId)
					
					fixedCount = fixedCount + 1
					print("✅ Fixed: " .. obj:GetFullName())
					print("   Multiplier: " .. newMultiplier)
					print("   IsFree: " .. tostring(isFree))
					print("   ProductId: " .. newProductId)
					print("")
				end
			end
		end
	end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

if fixedCount > 0 then
	print("✅ Fixed " .. fixedCount .. " treadmill zones!")
	print("")
	print("💾 IMPORTANT: SAVE the file now (Ctrl+S / Cmd+S)!")
	print("")
	print("🎮 Next steps:")
	print("   1. Save the file")
	print("   2. Run CHECK_TREADMILL_SERVICE.lua to verify TreadmillService")
	print("   3. Sync with Rojo if TreadmillService is missing")
	print("   4. Run the game and test!")
else
	print("✅ All treadmill zones already have Multiplier attributes")
end

print("")
print("🔧 ==================== END FIX ====================")
-- ==================== COPY UNTIL HERE ====================
