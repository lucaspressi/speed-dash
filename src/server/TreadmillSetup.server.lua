-- TreadmillSetup.server.lua
-- Configura todas as treadmills do workspace com Attributes
-- Suporta migração automática de estruturas legadas

local workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

-- Carrega módulo de configuração
local TreadmillConfig = require(script.Parent.Modules.TreadmillConfig)
local debugLog = TreadmillConfig.debugLog

debugLog("==================== TREADMILL SETUP STARTING ====================")

-- ==================== MIGRAÇÃO AUTOMÁTICA ====================

-- Procura por todas as TreadmillZones no workspace
local function findAllTreadmillZones()
	local zones = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
			table.insert(zones, obj)
		end
	end
	return zones
end

-- Aplica configuração em uma zone detectada
local function setupZone(zone, treadmillDef)
	debugLog("Setting up zone: " .. zone:GetFullName())
	TreadmillConfig.applyConfigToZone(zone, treadmillDef)
end

-- ==================== SETUP PADRÃO ====================

-- Tenta encontrar zona pelo nome do parent model exato
local function setupStandardTreadmills()
	debugLog("Starting standard treadmill setup...")

	for _, def in ipairs(TreadmillConfig.TREADMILL_DEFINITIONS) do
		debugLog("Looking for: " .. def.name)

		-- Procura o Model parent primeiro
		local parentModel = workspace:FindFirstChild(def.name)

		if parentModel then
			-- Procura TreadmillZone dentro do Model
			local zone = parentModel:FindFirstChild("TreadmillZone", true)

			if zone and zone:IsA("BasePart") then
				debugLog("  ✓ Found zone in " .. parentModel:GetFullName())
				setupZone(zone, def)
			else
				warn("[TREADMILL-FIX] Model '" .. def.name .. "' found but no TreadmillZone (BasePart) inside!")
			end
		else
			debugLog("  ⚠️ Model '" .. def.name .. "' not found in workspace")
		end
	end
end

-- ==================== MIGRAÇÃO DE ESTRUTURAS LEGADAS ====================

local function migrateOrphanedZones()
	debugLog("Starting orphaned zone migration...")

	local allZones = findAllTreadmillZones()
	local migratedCount = 0
	local skippedCount = 0

	for _, zone in ipairs(allZones) do
		-- Verifica se já tem configuração válida
		local config = TreadmillConfig.readZoneConfig(zone)
		local isValid, validationType = TreadmillConfig.validateZone(zone)

		if isValid then
			debugLog("Zone already configured: " .. zone:GetFullName() .. " (type: " .. validationType .. ")")
			skippedCount = skippedCount + 1
		else
			-- Zona órfã ou inválida - tenta detectar tipo pelo parent
			local parent = zone.Parent
			if parent then
				local detectedType = TreadmillConfig.detectTreadmillType(parent.Name)
				local def = TreadmillConfig.getDefinitionByName(detectedType)

				if def then
					debugLog("Migrating orphaned zone: " .. zone:GetFullName())
					debugLog("  Parent: " .. parent.Name .. " → Detected as: " .. detectedType)
					setupZone(zone, def)
					migratedCount = migratedCount + 1
				else
					warn("[TREADMILL-FIX] Could not find definition for detected type: " .. detectedType)
				end
			else
				warn("[TREADMILL-FIX] Zone has no parent: " .. zone:GetFullName())
			end
		end
	end

	debugLog("Migration complete: " .. migratedCount .. " migrated, " .. skippedCount .. " already configured")
end

-- ==================== VALIDAÇÃO FINAL ====================

local function validateAllZones()
	debugLog("Running final validation...")

	local allZones = findAllTreadmillZones()
	local validCount = 0
	local invalidCount = 0
	local freeCount = 0
	local paidCount = 0

	for _, zone in ipairs(allZones) do
		local isValid, validationType = TreadmillConfig.validateZone(zone)

		if isValid then
			validCount = validCount + 1
			if validationType == "free" then
				freeCount = freeCount + 1
			elseif validationType == "paid" then
				paidCount = paidCount + 1
			end
		else
			invalidCount = invalidCount + 1
			warn("[TREADMILL-FIX] Invalid zone found: " .. zone:GetFullName())
		end
	end

	debugLog("==================== VALIDATION SUMMARY ====================")
	debugLog("Total zones found: " .. #allZones)
	debugLog("Valid zones: " .. validCount .. " (Free: " .. freeCount .. ", Paid: " .. paidCount .. ")")
	debugLog("Invalid zones: " .. invalidCount)

	if invalidCount > 0 then
		warn("[TREADMILL-FIX] " .. invalidCount .. " zones are invalid and will not work!")
	else
		debugLog("✅ All zones validated successfully!")
	end

	debugLog("========================================================")
end

-- ==================== EXECUÇÃO ====================

-- 1. Setup padrão (busca por nomes exatos)
setupStandardTreadmills()

-- 2. Espera um frame para garantir que o workspace carregou
task.wait(0.5)

-- 3. Migra zonas órfãs ou com estrutura legada
migrateOrphanedZones()

-- 4. Validação final
task.wait(0.5)
validateAllZones()

debugLog("==================== TREADMILL SETUP COMPLETE ====================")
