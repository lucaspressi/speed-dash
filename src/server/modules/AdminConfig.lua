-- AdminConfig.lua
-- Secure configuration management for admin dashboard integration
-- Reads secrets from ServerStorage attributes (NOT replicated to client)

local ServerStorage = game:GetService("ServerStorage")

local AdminConfig = {}

-- ==================== CONFIGURATION LOADING ====================

-- IMPORTANT: Configure these values in Studio via ServerStorage attributes:
-- 1. Select ServerStorage in Explorer
-- 2. In Properties panel, add Attributes:
--    - AdminCommandSecret (string): Shared secret for validating incoming commands
--    - AdminWebhookSecret (string): Secret for signing outgoing webhook responses
--    - AdminWebhookURL (string): Dashboard webhook endpoint (e.g., https://your-dashboard.com/api/webhook)
--
-- SECURITY NOTE: ServerStorage attributes are SERVER-ONLY and never replicate to clients.
-- For production, consider using environment injection via DataStoreService or external config.

local function getConfigValue(key, default)
	local value = ServerStorage:GetAttribute(key)

	if value == nil or value == "" then
		warn("[AdminConfig] Missing configuration: " .. key .. " (using default)")
		return default
	end

	return value
end

-- ==================== PUBLIC API ====================

function AdminConfig.getCommandSecret()
	return getConfigValue("AdminCommandSecret", "CHANGE_ME_IN_PRODUCTION")
end

function AdminConfig.getWebhookSecret()
	return getConfigValue("AdminWebhookSecret", "CHANGE_ME_IN_PRODUCTION")
end

function AdminConfig.getWebhookURL()
	return getConfigValue("AdminWebhookURL", "")
end

function AdminConfig.isConfigured()
	local commandSecret = AdminConfig.getCommandSecret()
	local webhookSecret = AdminConfig.getWebhookSecret()
	local webhookURL = AdminConfig.getWebhookURL()

	if commandSecret == "CHANGE_ME_IN_PRODUCTION" or commandSecret == "" then
		return false, "AdminCommandSecret not configured"
	end

	if webhookSecret == "CHANGE_ME_IN_PRODUCTION" or webhookSecret == "" then
		return false, "AdminWebhookSecret not configured"
	end

	if webhookURL == "" then
		return false, "AdminWebhookURL not configured"
	end

	return true
end

function AdminConfig.validateConfiguration()
	local isValid, errorMsg = AdminConfig.isConfigured()

	if not isValid then
		warn("[AdminConfig] ⚠️ Admin Dashboard NOT CONFIGURED: " .. errorMsg)
		warn("[AdminConfig] Configure via ServerStorage attributes:")
		warn("[AdminConfig]   1. Select ServerStorage in Explorer")
		warn("[AdminConfig]   2. Add attributes in Properties panel:")
		warn("[AdminConfig]      - AdminCommandSecret (string)")
		warn("[AdminConfig]      - AdminWebhookSecret (string)")
		warn("[AdminConfig]      - AdminWebhookURL (string)")
		return false
	end

	print("[AdminConfig] ✅ Admin Dashboard configuration loaded successfully")
	return true
end

-- ==================== EXPORT ====================

return AdminConfig
