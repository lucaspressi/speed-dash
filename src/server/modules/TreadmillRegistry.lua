-- TreadmillRegistry.lua
-- ModuleScript para gerenciar registro e spatial indexing de treadmill zones
-- Server-side only, usado pelo TreadmillService

local CollectionService = game:GetService("CollectionService")
local workspace = game:GetService("Workspace")

local TreadmillRegistry = {}

-- ==================== CONFIGURAÇÃO ====================
local DEBUG = true
local COLLECTION_TAG = "TreadmillZone"  -- Tag para CollectionService
local SPATIAL_GRID_SIZE = 50  -- Tamanho da célula do grid (studs)

-- ==================== ESTADO INTERNO ====================
local registeredZones = {}  -- Array de {Instance, Data}
local spatialGrid = {}      -- Grid[X][Z] = {zones...}
local isInitialized = false

-- ==================== FUNÇÕES UTILITÁRIAS ====================
local function debugLog(message)
	if DEBUG then
		print("[TreadmillRegistry] " .. message)
	end
end

-- Converte posição 3D para célula do grid
local function getGridCell(position)
	local cellX = math.floor(position.X / SPATIAL_GRID_SIZE)
	local cellZ = math.floor(position.Z / SPATIAL_GRID_SIZE)
	return cellX, cellZ
end

-- Adiciona zone ao spatial grid
local function addToSpatialGrid(zone, zoneData)
	if not zone:IsA("BasePart") then
		warn("[TreadmillRegistry] Zone is not a BasePart: " .. zone:GetFullName())
		return
	end

	local position = zone.Position
	local cellX, cellZ = getGridCell(position)

	-- Inicializa célula se não existir
	if not spatialGrid[cellX] then
		spatialGrid[cellX] = {}
	end
	if not spatialGrid[cellX][cellZ] then
		spatialGrid[cellX][cellZ] = {}
	end

	-- Adiciona zone à célula
	table.insert(spatialGrid[cellX][cellZ], {
		zone = zone,
		data = zoneData,
		position = position,
		size = zone.Size
	})

	debugLog(string.format("Added zone to grid [%d,%d]: %s (Mult=%d)",
		cellX, cellZ, zone:GetFullName(), zoneData.Multiplier))
end

-- ==================== VALIDAÇÃO ====================
local function validateZoneData(zone)
	local multiplier = zone:GetAttribute("Multiplier")
	local isFree = zone:GetAttribute("IsFree")
	local productId = zone:GetAttribute("ProductId")

	-- Validação básica
	if not multiplier then
		return nil, "Missing Multiplier attribute"
	end

	-- FREE zones
	if multiplier == 1 or isFree == true then
		return {
			Multiplier = multiplier,
			IsFree = true,
			ProductId = productId or 0,
			ZoneName = zone.Name,
			ZoneInstance = zone
		}, "free"
	end

	-- PAID zones
	if multiplier > 1 then
		if not productId or productId == 0 then
			return nil, "PAID zone missing ProductId"
		end

		return {
			Multiplier = multiplier,
			IsFree = false,
			ProductId = productId,
			ZoneName = zone.Name,
			ZoneInstance = zone
		}, "paid"
	end

	return nil, "Invalid configuration"
end

-- ==================== SCAN E REGISTRO ====================
function TreadmillRegistry.scanAndRegister()
	debugLog("==================== SCANNING ZONES ====================")

	local scannedCount = 0
	local validCount = 0
	local invalidCount = 0

	-- Método 1: CollectionService tag
	local taggedZones = CollectionService:GetTagged(COLLECTION_TAG)
	debugLog("Found " .. #taggedZones .. " zones with tag '" .. COLLECTION_TAG .. "'")

	for _, zone in ipairs(taggedZones) do
		scannedCount = scannedCount + 1

		local zoneData, validationType = validateZoneData(zone)
		if zoneData then
			table.insert(registeredZones, {Instance = zone, Data = zoneData})
			addToSpatialGrid(zone, zoneData)
			validCount = validCount + 1
		else
			warn("[TreadmillRegistry] Invalid zone: " .. zone:GetFullName() .. " (" .. tostring(validationType) .. ")")
			invalidCount = invalidCount + 1
		end
	end

	-- Método 2: Fallback - Scan por Attribute (se tag não foi usada)
	if #taggedZones == 0 then
		debugLog("No tagged zones found. Falling back to Attribute scan...")

		for _, obj in pairs(workspace:GetDescendants()) do
			if obj.Name == "TreadmillZone" and obj:IsA("BasePart") then
				local hasMultiplier = obj:GetAttribute("Multiplier") ~= nil

				if hasMultiplier then
					scannedCount = scannedCount + 1

					local zoneData, validationType = validateZoneData(obj)
					if zoneData then
						table.insert(registeredZones, {Instance = obj, Data = zoneData})
						addToSpatialGrid(obj, zoneData)
						validCount = validCount + 1
						debugLog("Fallback: Registered " .. obj:GetFullName())
					else
						-- ✅ Reduced spam: Only log first 3 invalid zones, then summarize
						invalidCount = invalidCount + 1
						if invalidCount <= 3 then
							warn("[TreadmillRegistry] Invalid zone: " .. obj:GetFullName() .. " (" .. tostring(validationType) .. ")")
						end
					end
				end
			end
		end
	end

	debugLog("==================== SCAN COMPLETE ====================")
	debugLog("Scanned: " .. scannedCount)
	debugLog("Valid: " .. validCount)
	debugLog("Invalid: " .. invalidCount)
	debugLog("Spatial grid cells: " .. TreadmillRegistry.getGridStats())

	-- ✅ Summary warning if many invalid zones (legacy zones without proper config)
	if invalidCount > 3 then
		warn("[TreadmillRegistry] ⚠️ Found " .. invalidCount .. " invalid zones (first 3 logged above). These are likely legacy zones missing ProductId or Multiplier Attributes. Run TreadmillSetup to migrate them.")
	end

	isInitialized = true

	return {
		scanned = scannedCount,
		valid = validCount,
		invalid = invalidCount
	}
end

-- ==================== QUERY ====================

-- Encontra zone na posição do player
-- Retorna: zoneData, zoneInstance ou nil, nil
function TreadmillRegistry.getZoneAtPosition(position, tolerance)
	if not isInitialized then
		warn("[TreadmillRegistry] Not initialized! Call scanAndRegister() first.")
		return nil, nil
	end

	tolerance = tolerance or 2  -- Default: 2 studs de tolerância

	local cellX, cellZ = getGridCell(position)

	-- Busca na célula atual e células adjacentes (3x3 grid)
	local candidateZones = {}

	for dx = -1, 1 do
		for dz = -1, 1 do
			local checkX = cellX + dx
			local checkZ = cellZ + dz

			if spatialGrid[checkX] and spatialGrid[checkX][checkZ] then
				for _, entry in ipairs(spatialGrid[checkX][checkZ]) do
					table.insert(candidateZones, entry)
				end
			end
		end
	end

	-- Verifica cada candidata
	local bestMatch = nil
	local bestMultiplier = 0

	for _, entry in ipairs(candidateZones) do
		local zone = entry.zone
		local zonePos = entry.position
		local zoneSize = entry.size

		-- Bounding box check
		local dx = math.abs(position.X - zonePos.X)
		local dy = position.Y - zonePos.Y
		local dz = math.abs(position.Z - zonePos.Z)

		local inBoundsX = dx < (zoneSize.X / 2 + tolerance)
		local inBoundsZ = dz < (zoneSize.Z / 2 + tolerance)
		local inBoundsY = dy > 0 and dy < 5  -- Player acima da zone

		if inBoundsX and inBoundsZ and inBoundsY then
			-- Prioridade: maior multiplier ganha (Purple > Blue > Gold > Free)
			if entry.data.Multiplier > bestMultiplier then
				bestMatch = entry
				bestMultiplier = entry.data.Multiplier
			end
		end
	end

	if bestMatch then
		return bestMatch.data, bestMatch.zone
	end

	return nil, nil
end

-- ==================== ESTATÍSTICAS ====================
function TreadmillRegistry.getStats()
	return {
		totalZones = #registeredZones,
		gridCells = TreadmillRegistry.getGridStats(),
		isInitialized = isInitialized
	}
end

function TreadmillRegistry.getGridStats()
	local cellCount = 0
	for _, xTable in pairs(spatialGrid) do
		for _ in pairs(xTable) do
			cellCount = cellCount + 1
		end
	end
	return cellCount
end

-- Lista todas as zones registradas (debug)
function TreadmillRegistry.listAll()
	debugLog("==================== REGISTERED ZONES ====================")
	for i, entry in ipairs(registeredZones) do
		local data = entry.Data
		debugLog(string.format("#%d: %s (Mult=%d, Free=%s)",
			i, entry.Instance:GetFullName(), data.Multiplier, tostring(data.IsFree)))
	end
	debugLog("========================================================")
end

-- ==================== CLEANUP ====================
function TreadmillRegistry.clear()
	registeredZones = {}
	spatialGrid = {}
	isInitialized = false
	debugLog("Registry cleared")
end

-- ==================== DEBUG ====================
function TreadmillRegistry.setDebug(enabled)
	DEBUG = enabled
end

-- ==================== EXPORT ====================
return TreadmillRegistry
