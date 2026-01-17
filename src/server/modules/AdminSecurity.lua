-- AdminSecurity.lua
-- Security utilities for admin dashboard integration
-- Handles HMAC signing, timestamp validation, idempotency, and rate limiting

local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local AdminSecurity = {}

-- ==================== CONSTANTS ====================
local TIMESTAMP_TOLERANCE_SECONDS = 60
local IDEMPOTENCY_WINDOW_SECONDS = 600 -- 10 minutes
local RATE_LIMIT_WINDOW_SECONDS = 1
local MAX_COMMANDS_PER_SECOND = 10

-- MemoryStore for idempotency and rate limiting
local idempotencyStore = MemoryStoreService:GetSortedMap("AdminCommandIdempotency")
local rateLimitStore = MemoryStoreService:GetSortedMap("AdminCommandRateLimit")

-- ==================== HMAC-SHA256 IMPLEMENTATION ====================
-- Pure Lua implementation since Roblox doesn't provide native HMAC

local function rightRotate(num, bits)
	return bit32.band(bit32.bor(bit32.rshift(num, bits), bit32.lshift(num, 32 - bits)), 0xFFFFFFFF)
end

local function sha256(data)
	-- Use Roblox's built-in SHA256 from HttpService
	-- Note: This returns hex string directly
	local hash = HttpService:GetHashFromString(data)
	return hash
end

local function hmacSha256(key, message)
	local blockSize = 64 -- SHA256 block size in bytes

	-- If key is longer than block size, hash it
	if #key > blockSize then
		key = sha256(key)
		-- Convert hex string to bytes
		local keyBytes = {}
		for i = 1, #key, 2 do
			table.insert(keyBytes, string.char(tonumber(key:sub(i, i+1), 16)))
		end
		key = table.concat(keyBytes)
	end

	-- Pad key to block size
	if #key < blockSize then
		key = key .. string.rep(string.char(0), blockSize - #key)
	end

	-- Create inner and outer padding
	local innerPad = {}
	local outerPad = {}
	for i = 1, blockSize do
		local keyByte = key:byte(i)
		table.insert(innerPad, string.char(bit32.bxor(keyByte, 0x36)))
		table.insert(outerPad, string.char(bit32.bxor(keyByte, 0x5c)))
	end

	local innerPadStr = table.concat(innerPad)
	local outerPadStr = table.concat(outerPad)

	-- HMAC(K, m) = H((K' ⊕ opad) || H((K' ⊕ ipad) || m))
	local innerHash = sha256(innerPadStr .. message)

	-- Convert hex to bytes for outer hash
	local innerHashBytes = {}
	for i = 1, #innerHash, 2 do
		table.insert(innerHashBytes, string.char(tonumber(innerHash:sub(i, i+1), 16)))
	end
	local innerHashStr = table.concat(innerHashBytes)

	local finalHash = sha256(outerPadStr .. innerHashStr)

	return finalHash
end

-- ==================== CANONICAL PAYLOAD ====================

function AdminSecurity.buildCanonicalPayload(command)
	-- Canonical format: commandId|timestamp|action|userId|json(parameters)
	-- Parameters JSON must have sorted keys for stability

	local parametersJson = ""
	if command.parameters then
		-- Sort keys for stable JSON
		local sortedKeys = {}
		for k in pairs(command.parameters) do
			table.insert(sortedKeys, k)
		end
		table.sort(sortedKeys)

		-- Build sorted JSON manually
		local parts = {}
		for _, k in ipairs(sortedKeys) do
			local v = command.parameters[k]
			local valueStr
			if type(v) == "string" then
				valueStr = '"' .. v .. '"'
			elseif type(v) == "boolean" then
				valueStr = tostring(v)
			elseif type(v) == "number" then
				valueStr = tostring(v)
			elseif v == nil then
				valueStr = "null"
			else
				valueStr = '"' .. tostring(v) .. '"'
			end
			table.insert(parts, '"' .. k .. '":' .. valueStr)
		end
		parametersJson = "{" .. table.concat(parts, ",") .. "}"
	else
		parametersJson = "{}"
	end

	local canonical = table.concat({
		command.commandId or "",
		tostring(command.timestamp or 0),
		command.action or "",
		tostring(command.userId or 0),
		parametersJson
	}, "|")

	return canonical
end

-- ==================== SIGNATURE VALIDATION ====================

function AdminSecurity.validateSignature(command, secret)
	if not command.signature then
		return false, "Missing signature"
	end

	if not secret or secret == "" then
		return false, "Secret not configured"
	end

	local canonical = AdminSecurity.buildCanonicalPayload(command)
	local expectedSignature = hmacSha256(secret, canonical)

	-- Constant-time comparison to prevent timing attacks
	if #command.signature ~= #expectedSignature then
		return false, "Invalid signature"
	end

	local matches = 0
	for i = 1, #expectedSignature do
		if command.signature:sub(i, i) == expectedSignature:sub(i, i) then
			matches = matches + 1
		end
	end

	if matches == #expectedSignature then
		return true
	else
		return false, "Invalid signature"
	end
end

-- ==================== TIMESTAMP VALIDATION ====================

function AdminSecurity.validateTimestamp(timestamp)
	if not timestamp or type(timestamp) ~= "number" then
		return false, "Invalid timestamp format"
	end

	local now = os.time()
	local age = math.abs(now - timestamp)

	if age > TIMESTAMP_TOLERANCE_SECONDS then
		return false, "Timestamp expired (age: " .. age .. "s, max: " .. TIMESTAMP_TOLERANCE_SECONDS .. "s)"
	end

	return true
end

-- ==================== IDEMPOTENCY ====================

function AdminSecurity.checkIdempotency(commandId)
	if not commandId or commandId == "" then
		return false, "Missing commandId"
	end

	local success, result = pcall(function()
		-- Try to set commandId with expiration
		-- If it already exists, this will return nil
		local wasSet = idempotencyStore:SetAsync(
			commandId,
			true,
			IDEMPOTENCY_WINDOW_SECONDS
		)
		return wasSet ~= nil
	end)

	if not success then
		warn("[AdminSecurity] Idempotency check failed: " .. tostring(result))
		-- Fail open: allow command but log warning
		return true
	end

	if result then
		return true -- New command, proceed
	else
		return false, "Duplicate commandId (already processed within 10 minutes)"
	end
end

-- ==================== RATE LIMITING ====================

local commandCountThisSecond = 0
local lastResetTime = os.clock()

function AdminSecurity.checkRateLimit()
	local now = os.clock()

	-- Reset counter every second
	if now - lastResetTime >= RATE_LIMIT_WINDOW_SECONDS then
		commandCountThisSecond = 0
		lastResetTime = now
	end

	if commandCountThisSecond >= MAX_COMMANDS_PER_SECOND then
		return false, "Rate limit exceeded (max " .. MAX_COMMANDS_PER_SECOND .. " commands/sec)"
	end

	commandCountThisSecond = commandCountThisSecond + 1
	return true
end

-- ==================== WEBHOOK SIGNING ====================

function AdminSecurity.signWebhookResponse(response, secret)
	if not secret or secret == "" then
		warn("[AdminSecurity] Webhook secret not configured")
		return ""
	end

	-- Canonical format for webhook: commandId|success|serverId|timestamp
	local canonical = table.concat({
		response.commandId or "",
		tostring(response.success),
		response.serverJobId or "",
		tostring(response.processedAt or 0)
	}, "|")

	local signature = hmacSha256(secret, canonical)
	return signature
end

-- ==================== VALIDATION HELPERS ====================

function AdminSecurity.validateCommand(command)
	-- Basic structure validation
	if not command then
		return false, "Command is nil"
	end

	if not command.commandId or command.commandId == "" then
		return false, "Missing commandId"
	end

	if not command.timestamp then
		return false, "Missing timestamp"
	end

	if not command.action or command.action == "" then
		return false, "Missing action"
	end

	if not command.userId then
		return false, "Missing userId"
	end

	if type(command.userId) ~= "number" or command.userId <= 0 then
		return false, "Invalid userId"
	end

	return true
end

-- ==================== EXPORT ====================

return AdminSecurity
