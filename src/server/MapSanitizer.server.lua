-- MapSanitizer.server.lua
-- Script de diagnóstico para analisar estado do Workspace
-- Execute UMA VEZ no Studio para gerar relatório

local workspace = game:GetService("Workspace")

print("==================== MAP SANITIZER REPORT ====================")
print("Analyzing Workspace for treadmill zones...")
print("")

-- ==================== COLETA DE DADOS ====================
local allTreadmillZones = {}
local allTreadmillRelated = {}

for _, obj in pairs(workspace:GetDescendants()) do
	if obj.Name == "TreadmillZone" then
		table.insert(allTreadmillZones, obj)
	end

	if string.match(obj.Name:lower(), "treadmill") then
		table.insert(allTreadmillRelated, obj)
	end
end

print("📊 STATISTICS:")
print("  Total objects with 'Treadmill' in name: " .. #allTreadmillRelated)
print("  Total TreadmillZone objects: " .. #allTreadmillZones)
print("")

-- ==================== ANÁLISE DE ZONES ====================
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 TREADMILL ZONE ANALYSIS:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local validZones = 0
local invalidZones = 0
local duplicates = {}
local orphanedZones = {}

-- Detecta duplicatas por posição
local positionMap = {}

for i, zone in ipairs(allTreadmillZones) do
	print("")
	print("Zone #" .. i .. ":")
	print("  FullName: " .. zone:GetFullName())
	print("  ClassName: " .. zone.ClassName)
	print("  Parent: " .. (zone.Parent and zone.Parent.Name or "nil"))

	if zone:IsA("BasePart") then
		local pos = zone.Position
		local posKey = string.format("%.1f_%.1f_%.1f", pos.X, pos.Y, pos.Z)

		print("  Position: " .. tostring(pos))

		if positionMap[posKey] then
			print("  ⚠️ DUPLICATE POSITION! Same as Zone #" .. positionMap[posKey])
			table.insert(duplicates, {zone1 = positionMap[posKey], zone2 = i})
		else
			positionMap[posKey] = i
		end
	end

	-- Verifica Attributes
	local multiplier = zone:GetAttribute("Multiplier")
	local isFree = zone:GetAttribute("IsFree")
	local productId = zone:GetAttribute("ProductId")

	print("  Attributes:")
	print("    Multiplier: " .. tostring(multiplier))
	print("    IsFree: " .. tostring(isFree))
	print("    ProductId: " .. tostring(productId))

	-- Valida
	local isValid = false
	if multiplier then
		if multiplier == 1 or isFree == true then
			print("  ✅ Valid FREE zone")
			isValid = true
		elseif multiplier > 1 and productId and productId > 0 then
			print("  ✅ Valid PAID zone")
			isValid = true
		elseif multiplier > 1 and (not productId or productId == 0) then
			print("  ❌ INVALID: PAID zone missing ProductId")
		end
	else
		print("  ❌ INVALID: Missing Multiplier attribute")
	end

	if isValid then
		validZones = validZones + 1
	else
		invalidZones = invalidZones + 1
	end

	-- Verifica parent
	local parent = zone.Parent
	if parent then
		local parentName = parent.Name
		local isStandardParent =
			parentName == "TreadmillFree" or
			parentName == "TreadmillPaid" or
			parentName == "TreadmillBlue" or
			parentName == "TreadmillPurple"

		if not isStandardParent then
			print("  ⚠️ NON-STANDARD PARENT: " .. parentName)
			table.insert(orphanedZones, {zone = i, parent = parentName})
		end
	else
		print("  ❌ NO PARENT!")
	end
end

-- ==================== SUMMARY ====================
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📋 SUMMARY:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("Total zones: " .. #allTreadmillZones)
print("Valid zones: " .. validZones)
print("Invalid zones: " .. invalidZones)
print("Duplicate positions: " .. #duplicates)
print("Orphaned (non-standard parent): " .. #orphanedZones)
print("")

if #duplicates > 0 then
	print("⚠️ DUPLICATES FOUND:")
	for _, dup in ipairs(duplicates) do
		print("  Zone #" .. dup.zone1 .. " and Zone #" .. dup.zone2 .. " have same position")
	end
	print("")
end

if #orphanedZones > 0 then
	print("⚠️ ORPHANED ZONES:")
	for _, orphan in ipairs(orphanedZones) do
		print("  Zone #" .. orphan.zone .. " has parent: " .. orphan.parent)
	end
	print("")
end

-- ==================== RECOMMENDATIONS ====================
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("💡 RECOMMENDATIONS:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if invalidZones > 0 then
	print("❌ " .. invalidZones .. " invalid zones need fixing!")
	print("   Action: Run TreadmillSetup.server.lua to apply configs")
end

if #duplicates > 0 then
	print("⚠️ " .. #duplicates .. " duplicate zones detected!")
	print("   Action: Remove duplicate zones manually in Studio")
end

if #orphanedZones > 0 then
	print("⚠️ " .. #orphanedZones .. " zones have non-standard parents")
	print("   Action: TreadmillSetup should migrate them automatically")
end

if validZones == #allTreadmillZones and #duplicates == 0 then
	print("✅ Map is clean! All zones are valid and no duplicates found.")
end

print("")
print("==================== END OF REPORT ====================")

-- Auto-delete after running (opcional)
-- script:Destroy()
