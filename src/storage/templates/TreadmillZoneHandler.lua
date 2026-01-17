-- TreadmillZoneHandler.server.lua
-- Script que deve ser anexado a cada TreadmillZone Part
-- Valida configuração e prevê inicialização duplicada

-- ==================== EARLY SAFETY CHECK ====================
-- Se este script não está dentro de uma BasePart, não faz nada
-- (evita rodar no ServerScriptService por engano)
if not script.Parent or not script.Parent:IsA("BasePart") then
	return  -- Silenciosamente retorna
end

local ServerScriptService = game:GetService("ServerScriptService")

-- Debug flag (pode ser desligado)
local DEBUG = true

local function debugLog(message)
	if DEBUG then
		print("[TREADMILL-FIX] [ZoneHandler] " .. message)
	end
end

-- ==================== PREVINE DUPLICAÇÃO ====================
-- Se já foi inicializado, não roda novamente
if script:GetAttribute("Initialized") then
	debugLog("Zone already initialized, skipping: " .. script.Parent:GetFullName())
	return
end

-- Marca como inicializado
script:SetAttribute("Initialized", true)

-- ==================== CARREGA CONFIGURAÇÃO ====================
local zone = script.Parent

if not zone or not zone:IsA("BasePart") then
	warn("[TREADMILL-FIX] [ZoneHandler] Script parent is not a BasePart! Parent: " .. tostring(zone))
	return
end

debugLog("Initializing zone: " .. zone:GetFullName())

-- Tenta carregar o TreadmillConfig (se disponível)
local TreadmillConfig = nil
pcall(function()
	-- Ajuste o caminho conforme sua estrutura
	local configModule = ServerScriptService:FindFirstChild("TreadmillConfig")
	if configModule then
		TreadmillConfig = require(configModule)
	end
end)

-- ==================== LÊ ATTRIBUTES ====================
local multiplier = zone:GetAttribute("Multiplier")
local isFree = zone:GetAttribute("IsFree")
local productId = zone:GetAttribute("ProductId")

-- Fallback: lê de IntValues legados se attributes não existirem
if not multiplier then
	local multValue = zone:FindFirstChild("Multiplier")
	if multValue and multValue:IsA("IntValue") then
		multiplier = multValue.Value
		debugLog("Fallback: Read Multiplier from IntValue = " .. multiplier)
		-- Migra para Attribute
		zone:SetAttribute("Multiplier", multiplier)
	end
end

if not productId then
	local prodValue = zone:FindFirstChild("ProductId")
	if prodValue and prodValue:IsA("IntValue") then
		productId = prodValue.Value
		debugLog("Fallback: Read ProductId from IntValue = " .. productId)
		-- Migra para Attribute
		zone:SetAttribute("ProductId", productId)
	end
end

-- Auto-detecta IsFree se não estiver setado
if isFree == nil then
	if multiplier == 1 or productId == 0 then
		isFree = true
		zone:SetAttribute("IsFree", true)
		debugLog("Auto-detected IsFree=true")
	else
		isFree = false
	end
end

debugLog("Zone config:")
debugLog("  Multiplier: " .. tostring(multiplier))
debugLog("  IsFree: " .. tostring(isFree))
debugLog("  ProductId: " .. tostring(productId))

-- ==================== VALIDAÇÃO ====================

-- Usa TreadmillConfig se disponível
if TreadmillConfig then
	local isValid, validationType = TreadmillConfig.validateZone(zone)
	if not isValid then
		warn("[TREADMILL-FIX] [ZoneHandler] Zone validation FAILED: " .. zone:GetFullName())
		warn("[TREADMILL-FIX] [ZoneHandler] Error: " .. tostring(validationType))
		return
	end
	debugLog("✓ Zone validated via TreadmillConfig (type: " .. validationType .. ")")
else
	-- Validação manual (fallback se módulo não estiver disponível)
	if isFree == true or multiplier == 1 then
		debugLog("✓ Zone validated as FREE (no ProductId required)")
	elseif multiplier and multiplier > 1 then
		if not productId or productId == 0 then
			warn("[TREADMILL-FIX] [ZoneHandler] PAID zone missing ProductId!")
			warn("[TREADMILL-FIX] [ZoneHandler] Zone: " .. zone:GetFullName())
			warn("[TREADMILL-FIX] [ZoneHandler] Multiplier: " .. tostring(multiplier))
			return
		end
		debugLog("✓ Zone validated as PAID (ProductId=" .. productId .. ", Multiplier=" .. multiplier .. ")")
	else
		warn("[TREADMILL-FIX] [ZoneHandler] Zone missing required configuration!")
		warn("[TREADMILL-FIX] [ZoneHandler] Zone: " .. zone:GetFullName())
		return
	end
end

-- ==================== ZONA INICIALIZADA COM SUCESSO ====================
debugLog("✅ Zone initialized successfully: " .. zone:GetFullName())

-- Opcional: Adiciona visual feedback (cor baseada no tipo)
if isFree then
	-- FREE zone: branco/verde claro
	zone.Color = Color3.fromRGB(200, 255, 200)
elseif multiplier == 3 then
	-- GOLD zone: dourado
	zone.Color = Color3.fromRGB(255, 215, 0)
elseif multiplier == 9 then
	-- BLUE zone: azul
	zone.Color = Color3.fromRGB(0, 150, 255)
elseif multiplier == 25 then
	-- PURPLE zone: roxo
	zone.Color = Color3.fromRGB(150, 0, 255)
end

-- Nota: A lógica de detecção de jogador e XP gain fica no client (init.client.luau)
-- e no server (SpeedGameServer.lua UpdateSpeedEvent handler)
-- Este script só valida a configuração da zone.
