-- DIAGNOSE_STAGE3_DETAILED.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game RUNNING
-- Detailed diagnosis of Stage 3 floor physics issues

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== STAGE 3 DETAILED DIAGNOSTICS ====================")
print("")

-- Find all Procedual Futuristic Flooring models
local flooringModels = {}
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name == "Procedual Futuristic Flooring" and obj:IsA("Model") then
		table.insert(flooringModels, obj)
	end
end

print("📋 Found " .. #flooringModels .. " Procedual Futuristic Flooring models")
print("")

local unanchoredParts = {}
local movingParts = {}

for modelIndex, model in ipairs(flooringModels) do
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Model #" .. modelIndex .. ": " .. model:GetFullName())
	print("")

	-- Check PrimaryPart
	if model.PrimaryPart then
		print("   PrimaryPart: " .. model.PrimaryPart.Name)
		print("      Anchored: " .. tostring(model.PrimaryPart.Anchored))
		print("      CanCollide: " .. tostring(model.PrimaryPart.CanCollide))
	else
		warn("   ⚠️ No PrimaryPart set!")
	end

	-- Check all parts
	local parts = {}
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end

	print("   Total parts: " .. #parts)
	print("")

	local unanchoredCount = 0
	local anchoredCount = 0

	for _, part in ipairs(parts) do
		if not part.Anchored then
			unanchoredCount = unanchoredCount + 1
			table.insert(unanchoredParts, {model = model, part = part})
			warn("   ❌ UNANCHORED: " .. part.Name .. " at " .. tostring(part.Position))
		else
			anchoredCount = anchoredCount + 1
		end
	end

	print("   Anchored parts: " .. anchoredCount)
	print("   Unanchored parts: " .. unanchoredCount)
	print("")

	-- Check for constraints/welds
	local constraints = {}
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
			table.insert(constraints, obj)
		end
	end

	if #constraints > 0 then
		print("   Constraints/Welds found: " .. #constraints)
		for _, constraint in ipairs(constraints) do
			print("      - " .. constraint.ClassName .. ": " .. constraint.Name)
		end
	else
		print("   No constraints/welds")
	end

	print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check Stage3Part objects
local stage3Parts = {}
for _, obj in pairs(workspace:GetChildren()) do
	if string.match(obj.Name, "Stage3") and obj:IsA("BasePart") then
		table.insert(stage3Parts, obj)
	end
end

print("📋 Found " .. #stage3Parts .. " Stage3Part objects")
for i, part in ipairs(stage3Parts) do
	print("   Stage3Part #" .. i .. ":")
	print("      Name: " .. part.Name)
	print("      Anchored: " .. tostring(part.Anchored))
	print("      CanCollide: " .. tostring(part.CanCollide))
	print("      Position: " .. tostring(part.Position))
	if not part.Anchored then
		warn("      ❌ THIS PART IS NOT ANCHORED!")
		table.insert(unanchoredParts, {model = workspace, part = part})
	end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Summary
print("📊 SUMMARY:")
print("   Total unanchored parts found: " .. #unanchoredParts)
print("")

if #unanchoredParts > 0 then
	warn("❌ PROBLEM FOUND: " .. #unanchoredParts .. " unanchored parts will fall!")
	warn("   These parts need to be anchored in Studio:")
	for i, entry in ipairs(unanchoredParts) do
		if i <= 10 then -- Show first 10
			warn("   " .. i .. ". " .. entry.part:GetFullName())
		end
	end
	if #unanchoredParts > 10 then
		warn("   ... and " .. (#unanchoredParts - 10) .. " more")
	end
	print("")
	print("💡 Solution:")
	print("   1. Stop the game")
	print("   2. Run FIX_FUTURISTIC_FLOORING.lua")
	print("   3. SAVE the file (Ctrl+S / Cmd+S)")
	print("   4. Run this script again to verify")
else
	print("✅ All parts are properly anchored!")
	print("")
	print("💡 If the floor is still falling, the problem might be:")
	print("   1. A script is setting Anchored = false at runtime")
	print("   2. The floor was already falling before you fixed it")
	print("   3. You need to restart the game after saving")
end

print("")

-- Monitor for Anchored property changes
print("⏱️ Monitoring for Anchored property changes (10 seconds)...")
print("   (If a script is changing Anchored, we'll catch it)")
print("")

local connections = {}
for _, model in ipairs(flooringModels) do
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local conn = part:GetPropertyChangedSignal("Anchored"):Connect(function()
				warn("⚠️ ANCHORED CHANGED: " .. part:GetFullName() .. " → Anchored=" .. tostring(part.Anchored))
			end)
			table.insert(connections, conn)
		end
	end
end

for _, part in ipairs(stage3Parts) do
	local conn = part:GetPropertyChangedSignal("Anchored"):Connect(function()
		warn("⚠️ ANCHORED CHANGED: " .. part:GetFullName() .. " → Anchored=" .. tostring(part.Anchored))
	end)
	table.insert(connections, conn)
end

task.wait(10)

print("✅ Monitoring complete")
print("   If no warnings appeared above, no scripts are changing Anchored property")

-- Cleanup
for _, conn in ipairs(connections) do
	conn:Disconnect()
end

print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
