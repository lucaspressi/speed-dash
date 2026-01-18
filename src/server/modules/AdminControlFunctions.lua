-- AdminControlFunctions.lua
-- Admin action implementations for external dashboard integration
-- IMPORTANT: This module expects SpeedGameServer to expose its API via _G.AdminAPI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProgressionMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProgressionMath"))

local AdminControlFunctions = {}

-- ==================== WAIT FOR ADMIN API ====================
-- SpeedGameServer must expose its API via _G.AdminAPI before this module loads

local function waitForAdminAPI()
	local maxWait = 30
	local waited = 0
	while not _G.AdminAPI and waited < maxWait do
		task.wait(0.5)
		waited = waited + 0.5
	end

	if not _G.AdminAPI then
		error("[AdminControlFunctions] SpeedGameServer AdminAPI not available after " .. maxWait .. "s")
	end

	return _G.AdminAPI
end

local AdminAPI = waitForAdminAPI()

-- ==================== HELPER FUNCTIONS ====================

local function getPlayerByUserId(userId)
	return Players:GetPlayerByUserId(userId)
end

local function validatePlayerOnline(userId)
	local player = getPlayerByUserId(userId)
	if not player then
		return nil, {success = false, error = "Player not online (userId: " .. userId .. ")"}
	end
	return player
end

local function validatePlayerData(userId)
	local player, err = validatePlayerOnline(userId)
	if not player then
		return nil, nil, err
	end

	local data = AdminAPI.getPlayerData(userId)
	if not data then
		return nil, nil, {success = false, error = "Player data not loaded (userId: " .. userId .. ")"}
	end

	return player, data
end

local function getSpeedBoostMultiplier(level)
	if (level or 0) <= 0 then return 1 end
	return math.pow(2, level)
end

local function getWinBoostMultiplier(level)
	if (level or 0) <= 0 then return 1 end
	return math.pow(2, level)
end

-- ==================== VALIDATION RULES ====================

local function validateTotalXP(value)
	if type(value) ~= "number" then
		return false, "TotalXP must be a number"
	end
	if value < 0 then
		return false, "TotalXP cannot be negative"
	end
	return true
end

local function validateLevel(value)
	if type(value) ~= "number" then
		return false, "Level must be a number"
	end
	if value < 1 or value > 10000 then
		return false, "Level must be between 1 and 10000"
	end
	return true
end

local function validateXP(value, xpRequired)
	if type(value) ~= "number" then
		return false, "XP must be a number"
	end
	if value < 0 then
		return false, "XP cannot be negative"
	end
	if xpRequired and value >= xpRequired then
		return false, "XP must be less than XPRequired (" .. xpRequired .. ")"
	end
	return true
end

local function validateWins(value)
	if type(value) ~= "number" then
		return false, "Wins must be a number"
	end
	if value < 0 then
		return false, "Wins cannot be negative"
	end
	return true
end

local function validateBoostLevel(value)
	if type(value) ~= "number" then
		return false, "Boost level must be a number"
	end
	if value < 0 or value > 4 then
		return false, "Boost level must be between 0 and 4"
	end
	return true
end

local function validateTreadmillMultiplier(value)
	if type(value) ~= "number" then
		return false, "Multiplier must be a number"
	end
	if value ~= 3 and value ~= 9 and value ~= 25 then
		return false, "Multiplier must be 3, 9, or 25"
	end
	return true
end

-- ==================== ACTION: GET_PLAYER_STATE ====================

function AdminControlFunctions.get_player_state(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Return complete player state snapshot
	return {
		success = true,
		data = {
			userId = userId,
			username = player.Name,
			displayName = player.DisplayName,
			-- Core stats
			TotalXP = data.TotalXP,
			Level = data.Level,
			XP = data.XP,
			XPRequired = data.XPRequired,
			Wins = data.Wins,
			Rebirths = data.Rebirths,
			Multiplier = data.Multiplier,
			StepBonus = data.StepBonus,
			-- Boosts
			SpeedBoostLevel = data.SpeedBoostLevel,
			SpeedBoostActive = data.SpeedBoostActive,
			CurrentSpeedBoostMultiplier = data.CurrentSpeedBoostMultiplier,
			WinBoostLevel = data.WinBoostLevel,
			WinBoostActive = data.WinBoostActive,
			CurrentWinBoostMultiplier = data.CurrentWinBoostMultiplier,
			-- Treadmills
			TreadmillX3Owned = data.TreadmillX3Owned,
			TreadmillX9Owned = data.TreadmillX9Owned,
			TreadmillX25Owned = data.TreadmillX25Owned,
			-- Other
			GiftClaimed = data.GiftClaimed,
			Restricted = data.Restricted or false,
			RestrictionReason = data.RestrictionReason,
			-- Derived
			WalkSpeed = 16 + math.min(data.Level, 500)
		}
	}
end

-- ==================== ACTION: SET_PLAYER_SPEED_TOTALXP ====================

function AdminControlFunctions.set_player_speed_totalxp(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local newTotalXP = parameters.totalXP or parameters.value
	if not newTotalXP then
		return {success = false, error = "Missing parameter: totalXP"}
	end

	local valid, validErr = validateTotalXP(newTotalXP)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Set TotalXP
	data.TotalXP = newTotalXP

	-- Recalculate Level, XP, XPRequired from TotalXP
	local level, xpIntoLevel, xpRequired = ProgressionMath.LevelFromTotalXP(data.TotalXP)
	data.Level = level
	data.XP = xpIntoLevel
	data.XPRequired = xpRequired

	-- Update walk speed
	AdminAPI.updateWalkSpeed(player, data)

	-- Sync to client and leaderstats
	AdminAPI.updateUI(player, data)
	AdminAPI.updateLeaderstats(player, data)

	-- Persist
	AdminAPI.saveAll(player, data, "admin_set_speed_totalxp")

	return {
		success = true,
		data = {
			TotalXP = data.TotalXP,
			Level = data.Level,
			XP = data.XP,
			XPRequired = data.XPRequired
		}
	}
end

-- ==================== ACTION: SET_PLAYER_LEVEL_XP ====================

function AdminControlFunctions.set_player_level_xp(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local newLevel = parameters.level
	local newXP = parameters.xp or 0

	if not newLevel then
		return {success = false, error = "Missing parameter: level"}
	end

	local valid, validErr = validateLevel(newLevel)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Calculate XPRequired for this level
	local xpRequired = ProgressionMath.XPRequired(newLevel)

	-- Validate XP
	valid, validErr = validateXP(newXP, xpRequired)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Calculate TotalXP from Level + XP
	local totalXPToReachLevel = ProgressionMath.TotalXPToReachLevel(newLevel)
	data.TotalXP = totalXPToReachLevel + newXP

	-- Set Level/XP
	data.Level = newLevel
	data.XP = newXP
	data.XPRequired = xpRequired

	-- Update walk speed
	AdminAPI.updateWalkSpeed(player, data)

	-- Sync
	AdminAPI.updateUI(player, data)
	AdminAPI.updateLeaderstats(player, data)
	AdminAPI.saveAll(player, data, "admin_set_level_xp")

	return {
		success = true,
		data = {
			Level = data.Level,
			XP = data.XP,
			TotalXP = data.TotalXP,
			XPRequired = data.XPRequired
		}
	}
end

-- ==================== ACTION: SET_PLAYER_WINS ====================

function AdminControlFunctions.set_player_wins(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local newWins = parameters.wins or parameters.value
	if not newWins then
		return {success = false, error = "Missing parameter: wins"}
	end

	local valid, validErr = validateWins(newWins)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Set wins
	data.Wins = newWins

	-- Sync
	AdminAPI.updateUI(player, data)
	AdminAPI.updateLeaderstats(player, data)
	AdminAPI.saveAll(player, data, "admin_set_wins")

	return {
		success = true,
		data = {
			Wins = data.Wins
		}
	}
end

-- ==================== ACTION: SET_SPEEDBOOST_LEVEL ====================

function AdminControlFunctions.set_speedboost_level(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local newLevel = parameters.level or parameters.value
	if not newLevel then
		return {success = false, error = "Missing parameter: level"}
	end

	local valid, validErr = validateBoostLevel(newLevel)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Set boost level
	data.SpeedBoostLevel = newLevel
	data.SpeedBoostActive = newLevel > 0
	data.CurrentSpeedBoostMultiplier = getSpeedBoostMultiplier(newLevel)

	-- Sync
	AdminAPI.updateUI(player, data)
	AdminAPI.saveAll(player, data, "admin_set_speedboost")

	return {
		success = true,
		data = {
			SpeedBoostLevel = data.SpeedBoostLevel,
			SpeedBoostActive = data.SpeedBoostActive,
			CurrentSpeedBoostMultiplier = data.CurrentSpeedBoostMultiplier
		}
	}
end

-- ==================== ACTION: SET_WINBOOST_LEVEL ====================

function AdminControlFunctions.set_winboost_level(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local newLevel = parameters.level or parameters.value
	if not newLevel then
		return {success = false, error = "Missing parameter: level"}
	end

	local valid, validErr = validateBoostLevel(newLevel)
	if not valid then
		return {success = false, error = validErr}
	end

	-- Set boost level
	data.WinBoostLevel = newLevel
	data.WinBoostActive = newLevel > 0
	data.CurrentWinBoostMultiplier = getWinBoostMultiplier(newLevel)

	-- Sync
	AdminAPI.updateUI(player, data)
	AdminAPI.saveAll(player, data, "admin_set_winboost")

	return {
		success = true,
		data = {
			WinBoostLevel = data.WinBoostLevel,
			WinBoostActive = data.WinBoostActive,
			CurrentWinBoostMultiplier = data.CurrentWinBoostMultiplier
		}
	}
end

-- ==================== ACTION: SET_TREADMILL_OWNERSHIP ====================

function AdminControlFunctions.set_treadmill_ownership(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local multiplier = parameters.multiplier
	local owned = parameters.owned

	if not multiplier then
		return {success = false, error = "Missing parameter: multiplier"}
	end

	if owned == nil then
		return {success = false, error = "Missing parameter: owned"}
	end

	local valid, validErr = validateTreadmillMultiplier(multiplier)
	if not valid then
		return {success = false, error = validErr}
	end

	if type(owned) ~= "boolean" then
		return {success = false, error = "Parameter 'owned' must be boolean"}
	end

	-- Set ownership
	local key = "TreadmillX" .. multiplier .. "Owned"
	data[key] = owned

	-- Update player attribute (for client sync)
	player:SetAttribute(key, owned)

	-- Notify client immediately (for UI update)
	local TreadmillOwnershipUpdated = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("TreadmillOwnershipUpdated")
	if TreadmillOwnershipUpdated then
		TreadmillOwnershipUpdated:FireClient(player, multiplier, owned)
	end

	-- Persist
	AdminAPI.saveAll(player, data, "admin_treadmill_" .. multiplier)

	return {
		success = true,
		data = {
			multiplier = multiplier,
			owned = owned
		}
	}
end

-- ==================== ACTION: RESET_PLAYER_STATE ====================

function AdminControlFunctions.reset_player_state(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Check if treadmills should be preserved
	local preserveTreadmills = parameters.preserveTreadmills or false

	-- Reset to defaults
	data.TotalXP = 0
	data.Level = 1
	data.XP = 0
	data.Wins = 0
	data.Rebirths = 0
	data.Multiplier = 1
	data.StepBonus = 1
	data.SpeedBoostLevel = 0
	data.WinBoostLevel = 0
	data.XPRequired = ProgressionMath.XPRequired(1)
	data.SpeedBoostActive = false
	data.CurrentSpeedBoostMultiplier = 1
	data.WinBoostActive = false
	data.CurrentWinBoostMultiplier = 1

	-- Optionally reset treadmill ownership
	if not preserveTreadmills then
		data.TreadmillX3Owned = false
		data.TreadmillX9Owned = false
		data.TreadmillX25Owned = false

		player:SetAttribute("TreadmillX3Owned", false)
		player:SetAttribute("TreadmillX9Owned", false)
		player:SetAttribute("TreadmillX25Owned", false)
	end

	-- Reset restriction
	data.Restricted = false
	data.RestrictionReason = nil

	-- Update walk speed
	AdminAPI.updateWalkSpeed(player, data)

	-- Sync
	AdminAPI.updateUI(player, data)
	AdminAPI.updateLeaderstats(player, data)
	AdminAPI.saveAll(player, data, "admin_reset_player")

	return {
		success = true,
		data = {
			message = "Player state reset to defaults",
			preservedTreadmills = preserveTreadmills
		}
	}
end

-- ==================== ACTION: RESTRICT_PLAYER ====================

function AdminControlFunctions.restrict_player(userId, parameters)
	local player, data, err = validatePlayerData(userId)
	if not player then
		return err
	end

	-- Validate input
	local restricted = parameters.restricted
	local reason = parameters.reason

	if restricted == nil then
		return {success = false, error = "Missing parameter: restricted"}
	end

	if type(restricted) ~= "boolean" then
		return {success = false, error = "Parameter 'restricted' must be boolean"}
	end

	-- Set restriction
	data.Restricted = restricted
	data.RestrictionReason = reason or nil

	-- Persist
	AdminAPI.saveAll(player, data, "admin_restrict_player")

	return {
		success = true,
		data = {
			Restricted = data.Restricted,
			RestrictionReason = data.RestrictionReason
		}
	}
end

-- ==================== COMMAND DISPATCHER ====================

function AdminControlFunctions.execute(command)
	local action = command.action
	local userId = command.userId
	local parameters = command.parameters or {}

	-- Dispatch to appropriate handler
	if action == "get_player_state" then
		return AdminControlFunctions.get_player_state(userId, parameters)
	elseif action == "set_player_speed_totalxp" then
		return AdminControlFunctions.set_player_speed_totalxp(userId, parameters)
	elseif action == "set_player_level_xp" then
		return AdminControlFunctions.set_player_level_xp(userId, parameters)
	elseif action == "set_player_wins" then
		return AdminControlFunctions.set_player_wins(userId, parameters)
	elseif action == "set_speedboost_level" then
		return AdminControlFunctions.set_speedboost_level(userId, parameters)
	elseif action == "set_winboost_level" then
		return AdminControlFunctions.set_winboost_level(userId, parameters)
	elseif action == "set_treadmill_ownership" then
		return AdminControlFunctions.set_treadmill_ownership(userId, parameters)
	elseif action == "reset_player_state" then
		return AdminControlFunctions.reset_player_state(userId, parameters)
	elseif action == "restrict_player" then
		return AdminControlFunctions.restrict_player(userId, parameters)
	else
		return {
			success = false,
			error = "Unknown action: " .. tostring(action)
		}
	end
end

-- ==================== EXPORT ====================

return AdminControlFunctions
