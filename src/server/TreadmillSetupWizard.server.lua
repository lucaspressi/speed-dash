-- TreadmillSetupWizard.server.lua
-- 🧙 WIZARD: Configura TODAS as TreadmillZones automaticamente
-- Execute UMA VEZ no Studio para configurar todos os atributos

local ServerScriptService = game:GetService("ServerScriptService")
local workspace = game:GetService("Workspace")

print("[WIZARD] ============================================")
print("[WIZARD] 🧙 Treadmill Setup Wizard Starting...")
print("[WIZARD] ============================================")

-- Carrega TreadmillConfig
local TreadmillConfig = require(ServerScriptService.Modules.TreadmillConfig)

-- Mapeamento de padrões de nome → definição
local NAME_PATTERNS = {
	-- Purple treadmills (x25)
	{pattern = "purple", mult = 25, productId = 3510662405, name = "TreadmillPurple"},
	{pattern = "roxa", mult = 25, productId = 3510662405, name = "TreadmillPurple"},
	{pattern = "x25", mult = 25, productId = 3510662405, name = "TreadmillPurple"},

	-- Blue treadmills (x9)
	{pattern = "blue", mult = 9, productId = 3510662188, name = "TreadmillBlue"},
	{pattern = "azul", mult = 9, productId = 3510662188, name = "TreadmillBlue"},
	{pattern = "x9", mult = 9, productId = 3510662188, name = "TreadmillBlue"},

	-- Gold/Paid treadmills (x3)
	{pattern = "paid", mult = 3, productId = 3510639799, name = "TreadmillPaid"},
	{pattern = "gold", mult = 3, productId = 3510639799, name = "TreadmillPaid"},
	{pattern = "dourada", mult = 3, productId = 3510639799, name = "TreadmillPaid"},
	{pattern = "x3", mult = 3, productId = 3510639799, name = "TreadmillPaid"},

	-- Free treadmills (x1)
	{pattern = "free", mult = 1, productId = 0, name = "TreadmillFree"},
	{pattern = "esteira1x", mult = 1, productId = 0, name = "TreadmillFree"},
	{pattern = "x1", mult = 1, productId = 0, name = "TreadmillFree"},
}

-- Função para detectar tipo baseado no nome do parent/model
local function detectTreadmillType(zone)
	local parent = zone.Parent
	local parentName = parent and parent.Name or ""
	local normalizedName = string.lower(parentName:gsub("%s+", ""))

	-- Tenta detectar por patterns
	for _, mapping in ipairs(NAME_PATTERNS) do
		if string.find(normalizedName, mapping.pattern, 1, true) then
			print("[WIZARD]   Detected: " .. mapping.name .. " (pattern: " .. mapping.pattern .. ")")
			return mapping.mult, mapping.productId, mapping.name
		end
	end

	-- Fallback: FREE se não detectou
	print("[WIZARD]   ⚠️ Could not detect type, defaulting to FREE")
	return 1, 0, "TreadmillFree"
end

-- Função para configurar uma zone
local function setupZone(zone)
	local zonePath = zone:GetFullName()
	print("[WIZARD] Processing: " .. zonePath)

	-- Detecta tipo
	local mult, productId, detectedName = detectTreadmillType(zone)

	-- Seta atributos
	zone:SetAttribute("Multiplier", mult)
	zone:SetAttribute("ProductId", productId)
	zone:SetAttribute("IsFree", mult == 1)

	-- Remove IntValues legados
	for _, child in ipairs(zone:GetChildren()) do
		if child.Name == "Multiplier" or child.Name == "ProductId" or child.Name == "Value" then
			child:Destroy()
			print("[WIZARD]   Removed legacy IntValue: " .. child.Name)
		end
	end

	-- Valida
	local config = TreadmillConfig.readZoneConfig(zone)
	local isValid, validationType = TreadmillConfig.validateZone(zone)

	if isValid then
		print("[WIZARD]   ✅ SUCCESS: Multiplier=" .. mult .. " ProductId=" .. productId .. " Type=" .. validationType)
	else
		warn("[WIZARD]   ❌ FAILED VALIDATION: " .. tostring(validationType))
	end

	return isValid
end

-- Busca TODAS as TreadmillZones no workspace
local function findAllZones()
	local zones = {}

	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Name == "TreadmillZone" then
			table.insert(zones, desc)
		end
	end

	return zones
end

-- MAIN
local zones = findAllZones()
print("[WIZARD] Found " .. #zones .. " TreadmillZones in workspace")
print("[WIZARD] ============================================")

if #zones == 0 then
	warn("[WIZARD] ⚠️ NO ZONES FOUND! Make sure:")
	warn("[WIZARD]   1. TreadmillZones exist in Workspace")
	warn("[WIZARD]   2. They are BaseParts (not Models)")
	warn("[WIZARD]   3. They are named 'TreadmillZone'")
	return
end

local successCount = 0
local failCount = 0

for i, zone in ipairs(zones) do
	print("")
	print("[WIZARD] ──────────────────────────────────────────")
	print("[WIZARD] Zone " .. i .. "/" .. #zones)

	local success = setupZone(zone)

	if success then
		successCount = successCount + 1
	else
		failCount = failCount + 1
	end
end

print("")
print("[WIZARD] ============================================")
print("[WIZARD] 🎉 SETUP COMPLETE!")
print("[WIZARD] ✅ Success: " .. successCount .. " zones")
print("[WIZARD] ❌ Failed: " .. failCount .. " zones")
print("[WIZARD] ============================================")

if failCount > 0 then
	warn("[WIZARD] ⚠️ Some zones failed validation!")
	warn("[WIZARD] Check logs above for details")
end

print("[WIZARD] 🧙 Wizard finished! You can now:")
print("[WIZARD]   1. Test walking on treadmills")
print("[WIZARD]   2. Check server logs for [TREADMILL-FIX] messages")
print("[WIZARD]   3. Delete or disable this script after confirmation")
