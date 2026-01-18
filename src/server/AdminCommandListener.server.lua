-- AdminCommandListener.server.lua
-- Subscribes to MessagingService "AdminCommands" topic
-- Validates, executes, and responds to admin commands from external dashboard

local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

print("[AdminCommandListener] ==================== STARTING ====================")

-- ==================== LOAD MODULES ====================

local AdminSecurity = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("AdminSecurity"))
local AdminConfig = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("AdminConfig"))
local AdminControlFunctions = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("AdminControlFunctions"))

-- ==================== CONFIGURATION ====================

local TOPIC_NAME = "AdminCommands"
local commandSecret = nil
local webhookSecret = nil
local webhookURL = nil

-- Validate configuration
local isConfigured, configError = AdminConfig.validateConfiguration()
if isConfigured then
	commandSecret = AdminConfig.getCommandSecret()
	webhookSecret = AdminConfig.getWebhookSecret()
	webhookURL = AdminConfig.getWebhookURL()
	print("[AdminCommandListener] ✅ Configuration loaded successfully")
else
	warn("[AdminCommandListener] ⚠️ NOT CONFIGURED: " .. tostring(configError))
	warn("[AdminCommandListener] Admin commands will NOT work until configured")
	warn("[AdminCommandListener] See AdminConfig.lua for setup instructions")
end

-- ==================== WEBHOOK RESPONSE ====================

local function sendWebhookResponse(response)
	if not webhookURL or webhookURL == "" then
		warn("[AdminCommandListener] Cannot send webhook: URL not configured")
		return
	end

	-- Sign response
	response.signature = AdminSecurity.signWebhookResponse(response, webhookSecret)

	-- Send POST request
	local success, result = pcall(function()
		local jsonBody = HttpService:JSONEncode(response)
		local httpResponse = HttpService:PostAsync(
			webhookURL,
			jsonBody,
			Enum.HttpContentType.ApplicationJson,
			false -- Not compressed
		)
		return httpResponse
	end)

	if success then
		print("[AdminCommandListener] ✅ Webhook sent successfully: " .. response.commandId)
	else
		warn("[AdminCommandListener] ❌ Webhook failed: " .. tostring(result))
	end
end

-- ==================== COMMAND PROCESSOR ====================

local function processCommand(command)
	local commandId = command.commandId or "unknown"
	local startTime = os.time()

	print("[AdminCommandListener] 📥 Received command: " .. commandId .. " (action: " .. tostring(command.action) .. ")")

	-- Build response template
	local response = {
		commandId = commandId,
		success = false,
		error = nil,
		data = nil,
		serverJobId = game.JobId,
		placeId = game.PlaceId,
		processedAt = startTime
	}

	-- Validation: Basic structure
	local valid, validErr = AdminSecurity.validateCommand(command)
	if not valid then
		response.error = "Invalid command structure: " .. validErr
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	-- Validation: Timestamp
	valid, validErr = AdminSecurity.validateTimestamp(command.timestamp)
	if not valid then
		response.error = "Timestamp validation failed: " .. validErr
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	-- Validation: Signature
	valid, validErr = AdminSecurity.validateSignature(command, commandSecret)
	if not valid then
		response.error = "Signature validation failed: " .. validErr
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	-- Validation: Idempotency
	valid, validErr = AdminSecurity.checkIdempotency(commandId)
	if not valid then
		response.error = "Idempotency check failed: " .. validErr
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	-- Validation: Rate limit
	valid, validErr = AdminSecurity.checkRateLimit()
	if not valid then
		response.error = "Rate limit exceeded: " .. validErr
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	print("[AdminCommandListener] ✅ All validations passed, executing command...")

	-- Execute command
	local executeSuccess, executeResult = pcall(function()
		return AdminControlFunctions.execute(command)
	end)

	if not executeSuccess then
		-- Execution error (unexpected)
		response.error = "Command execution error: " .. tostring(executeResult)
		warn("[AdminCommandListener] ❌ " .. response.error)
		sendWebhookResponse(response)
		return
	end

	-- Command executed (may have business logic errors)
	if executeResult.success then
		response.success = true
		response.data = executeResult.data
		print("[AdminCommandListener] ✅ Command executed successfully: " .. commandId)
	else
		response.error = executeResult.error or "Unknown error"
		warn("[AdminCommandListener] ❌ Command failed: " .. response.error)
	end

	response.processedAt = os.time()

	-- Send response
	sendWebhookResponse(response)
end

-- ==================== MESSAGING SERVICE SUBSCRIPTION ====================

local function subscribeToCommands()
	if not isConfigured then
		warn("[AdminCommandListener] Skipping MessagingService subscription (not configured)")
		return
	end

	local success, connection = pcall(function()
		return MessagingService:SubscribeAsync(TOPIC_NAME, function(message)
			local messageData = message.Data

			-- Parse JSON if string
			local command
			if type(messageData) == "string" then
				local parseSuccess, parseResult = pcall(function()
					return HttpService:JSONDecode(messageData)
				end)

				if not parseSuccess then
					warn("[AdminCommandListener] Failed to parse command JSON: " .. tostring(parseResult))
					return
				end

				command = parseResult
			else
				command = messageData
			end

			-- Process command in separate thread (non-blocking)
			task.spawn(function()
				processCommand(command)
			end)
		end)
	end)

	if success then
		print("[AdminCommandListener] ✅ Subscribed to MessagingService topic: " .. TOPIC_NAME)
		print("[AdminCommandListener] Ready to receive admin commands")
	else
		warn("[AdminCommandListener] ❌ Failed to subscribe to MessagingService: " .. tostring(connection))
	end
end

-- ==================== INITIALIZATION ====================

-- Subscribe to MessagingService
subscribeToCommands()

print("[AdminCommandListener] ==================== READY ====================")

-- ==================== TESTING HELPER (Optional) ====================
-- Expose test function for local Studio testing
_G.AdminCommandTest = function(command)
	print("[AdminCommandTest] Testing command locally...")
	processCommand(command)
end

-- Example usage in Studio command bar:
--[[
_G.AdminCommandTest({
	commandId = "test-123",
	timestamp = os.time(),
	action = "get_player_state",
	userId = game.Players:GetPlayers()[1].UserId,
	parameters = {},
	signature = "dummy" -- Will fail signature check, but good for structure testing
})
]]
