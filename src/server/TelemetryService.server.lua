-- TelemetryService.server.lua
-- Sends diagnostic logs to external backend for analysis
-- Automatically logs critical events and errors

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ==================== CONFIGURATION ====================

-- Set this to your backend URL (from .env or hardcode for testing)
local BACKEND_URL = "http://localhost:3001/api/telemetry"

-- Only send telemetry in production (not Studio)
local ENABLED = not RunService:IsStudio()

-- Buffer logs and send in batches (more efficient)
local BATCH_SIZE = 10
local BATCH_INTERVAL = 30 -- seconds

-- ==================== STATE ====================

local logBuffer = {}
local lastSendTime = tick()

-- ==================== HELPER FUNCTIONS ====================

local function getServerInfo()
	return {
		placeId = game.PlaceId,
		jobId = game.JobId,
		serverId = game.JobId:sub(1, 8), -- Short ID for readability
	}
end

local function sendBatch(logs)
	if #logs == 0 then return end

	local success, response = pcall(function()
		return HttpService:PostAsync(
			BACKEND_URL .. "/batch",
			HttpService:JSONEncode({
				logs = logs
			}),
			Enum.HttpContentType.ApplicationJson,
			false -- compress
		)
	end)

	if not success then
		warn("[TelemetryService] Failed to send batch:", response)
	end
end

local function flushBuffer()
	if #logBuffer > 0 then
		sendBatch(logBuffer)
		logBuffer = {}
		lastSendTime = tick()
	end
end

-- ==================== PUBLIC API ====================

local TelemetryService = {}

function TelemetryService.log(level, category, message, context)
	-- Always print locally for immediate feedback
	local prefix = {
		info = "[INFO]",
		warn = "[WARN]",
		error = "[ERROR]",
		debug = "[DEBUG]"
	}

	print(string.format("%s [%s] %s", prefix[level] or "[LOG]", category, message))
	if context then
		print("  Context:", HttpService:JSONEncode(context))
	end

	-- If not enabled, don't send to backend
	if not ENABLED then return end

	-- Add to buffer
	local serverInfo = getServerInfo()
	table.insert(logBuffer, {
		level = level,
		category = category,
		message = message,
		context = context,
		serverId = serverInfo.serverId,
		placeId = serverInfo.placeId,
		jobId = serverInfo.jobId,
	})

	-- Send immediately if buffer is full
	if #logBuffer >= BATCH_SIZE then
		flushBuffer()
	end
end

function TelemetryService.info(category, message, context)
	TelemetryService.log("info", category, message, context)
end

function TelemetryService.warn(category, message, context)
	TelemetryService.log("warn", category, message, context)
end

function TelemetryService.error(category, message, context)
	TelemetryService.log("error", category, message, context)
end

function TelemetryService.debug(category, message, context)
	TelemetryService.log("debug", category, message, context)
end

-- ==================== AUTO-FLUSH ====================

-- Flush buffer periodically
task.spawn(function()
	while true do
		task.wait(BATCH_INTERVAL)

		if tick() - lastSendTime >= BATCH_INTERVAL then
			flushBuffer()
		end
	end
end)

-- Flush on server shutdown
game:BindToClose(function()
	flushBuffer()
	task.wait(1) -- Give time for HTTP request to complete
end)

-- ==================== INITIALIZATION ====================

print("[TelemetryService] ==================== TELEMETRY SERVICE ====================")
print("[TelemetryService] Backend URL: " .. BACKEND_URL)
print("[TelemetryService] Enabled: " .. tostring(ENABLED))
print("[TelemetryService] Batch Size: " .. BATCH_SIZE)
print("[TelemetryService] Batch Interval: " .. BATCH_INTERVAL .. "s")

if ENABLED then
	print("[TelemetryService] ✅ Telemetry will be sent to backend")

	-- Send initial boot log
	TelemetryService.info("Server", "Server started", {
		placeId = game.PlaceId,
		jobId = game.JobId,
		playerCount = #game:GetService("Players"):GetPlayers()
	})
else
	print("[TelemetryService] ⚠️  Telemetry disabled (Studio mode)")
	print("[TelemetryService] Logs will print locally only")
end

print("[TelemetryService] =================================================================")

-- ==================== EXPORT ====================

_G.TelemetryService = TelemetryService

return TelemetryService
