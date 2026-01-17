-- Config.lua
-- 🎯 SINGLE SOURCE OF TRUTH for all game configuration
-- ⚠️ DEBUG_MODE MUST be false in production!

local Config = {}

-- ==================== METADATA ====================
Config.GAME_NAME = "Speed Dash"
Config.VERSION = "2.0.0"
Config.DEBUG_MODE = false  -- ⚠️ MUST BE FALSE IN PRODUCTION

-- ==================== PROGRESSION ====================
Config.Progression = {
	BASE_XP = 1,  -- XP per step

	-- XP Formula: XPRequired(level) = BASE + SCALE * level^EXPONENT
	FORMULA = {
		BASE = 20000,
		SCALE = 500,
		EXPONENT = 1.65,
	},

	-- Anchor point for validation (from reference game)
	ANCHOR = {
		Level = 64,
		XPRequired = 666750,
		TotalXP = 4779693,
	},
}

-- ==================== TREADMILLS ====================
Config.Treadmills = {
	-- FREE treadmill (gray)
	FREE = {
		Multiplier = 1,
		ProductId = 0,
		IsFree = true,
		Color = Color3.fromRGB(127, 127, 127),  -- Gray
	},

	-- GOLD treadmill (x3)
	GOLD = {
		Multiplier = 3,
		ProductId = 3510639799,  -- 59 Robux
		IsFree = false,
		Color = Color3.fromRGB(255, 215, 0),  -- Gold
	},

	-- BLUE treadmill (x9)
	BLUE = {
		Multiplier = 9,
		ProductId = 3510662188,  -- 149 Robux
		IsFree = false,
		Color = Color3.fromRGB(51, 102, 255),  -- Blue
	},

	-- PURPLE treadmill (x25)
	PURPLE = {
		Multiplier = 25,
		ProductId = 3510662405,  -- 399 Robux
		IsFree = false,
		Color = Color3.fromRGB(204, 51, 204),  -- Purple
	},
}

-- Valid multiplier values (for security validation)
Config.VALID_MULTIPLIERS = {
	[1] = true,   -- FREE
	[3] = true,   -- GOLD
	[9] = true,   -- BLUE
	[25] = true,  -- PURPLE
}

-- ==================== DATASTORE ====================
Config.DataStore = {
	AUTO_SAVE_INTERVAL = 60,  -- seconds between auto-saves
	SAVE_ON_LEVEL_UP = true,   -- immediately save on level up
	SAVE_ON_REBIRTH = true,    -- immediately save on rebirth
	SAVE_ON_PURCHASE = true,   -- immediately save on purchase
}

-- ==================== LEADERBOARD ====================
Config.Leaderboard = {
	UPDATE_INTERVAL = 60,  -- seconds between leaderboard updates
	TOP_COUNT = 10,        -- show top N players
}

-- ==================== SPEED BOOSTS ====================
Config.SpeedBoosts = {
	-- Exponential multipliers: 2^level
	[1] = { Multiplier = 2,  ProductId = 3510578826, Price = 3 },    -- x2 (3 R$)
	[2] = { Multiplier = 4,  ProductId = 3510802965, Price = 29 },   -- x4 (29 R$)
	[3] = { Multiplier = 8,  ProductId = 3510803353, Price = 81 },   -- x8 (81 R$)
	[4] = { Multiplier = 16, ProductId = 3510803870, Price = 599 },  -- x16 (599 R$)
}

-- ==================== WIN BOOSTS ====================
Config.WinBoosts = {
	-- Exponential multipliers: 2^level
	[1] = { Multiplier = 2,  ProductId = 3510580275, Price = 6 },    -- x2 (6 R$)
	[2] = { Multiplier = 4,  ProductId = 3511571771, Price = 12 },   -- x4 (12 R$)
	[3] = { Multiplier = 8,  ProductId = 3511572068, Price = 59 },   -- x8 (59 R$)
	[4] = { Multiplier = 16, ProductId = 3511572744, Price = 500 },  -- x16 (500 R$)
}

-- ==================== SPEED PACKS (ONE-TIME) ====================
Config.SpeedPacks = {
	[1] = { Speed = 100000,   ProductId = 3511569875, Price = 29 },   -- +100K (29 R$)
	[2] = { Speed = 1000000,  ProductId = 3511570288, Price = 99 },   -- +1M (99 R$)
	[3] = { Speed = 10000000, ProductId = 3511570659, Price = 500 },  -- +10M (500 R$)
}

-- ==================== REBIRTH ====================
Config.Rebirth = {
	Tiers = {
		{ Level = 25,  Multiplier = 1.5 },
		{ Level = 50,  Multiplier = 2.0 },
		{ Level = 100, Multiplier = 2.5 },
		{ Level = 150, Multiplier = 3.0 },
		{ Level = 200, Multiplier = 3.5 },
		{ Level = 300, Multiplier = 4.0 },
		{ Level = 500, Multiplier = 5.0 },
		{ Level = 750, Multiplier = 6.0 },
		{ Level = 1000, Multiplier = 7.5 },
		{ Level = 1500, Multiplier = 10.0 },
	},

	-- Badge IDs (0 = disabled)
	WELCOME_BADGE_ID = 0,
	REBIRTH_BADGE_ID = 0,
}

-- ==================== ADMIN ====================
Config.Admin = {
	USER_IDS = {
		[10286998085] = true,
		[10291926911] = true,
	},
}

-- ==================== GROUP ====================
Config.Group = {
	ID = 0,              -- Group ID (0 = disabled)
	GIFT_REWARD = 15000, -- Speed reward for joining group
}

-- ==================== AUDIO ====================
Config.Audio = {
	-- Background music (loops)
	BackgroundMusic = {
		SoundId = "rbxassetid://1837879082",  -- Chill music
		Volume = 0.3,
		Looped = true,
	},

	-- NPC kill sound (meme)
	NpcKillSound = {
		SoundId = "rbxassetid://12221967",  -- Skull emoji (tuntuntun)
		Volume = 1.0,
	},
}

-- ==================== PERFORMANCE ====================
Config.Performance = {
	TREADMILL_UPDATE_INTERVAL = 0.15,  -- seconds (TreadmillService heartbeat)
	WALKING_COOLDOWN = 0.4,             -- seconds (XP gain cooldown when walking)
	VISUAL_COOLDOWN = 1.5,              -- seconds (+XP visual effect cooldown)
}

-- ==================== REMOTE NAMES ====================
-- Centralized remote names (prevents typos)
Config.Remotes = {
	UpdateSpeed = "UpdateSpeed",
	UpdateUI = "UpdateUI",
	Rebirth = "Rebirth",
	AddWin = "AddWin",
	TreadmillOwnershipUpdated = "TreadmillOwnershipUpdated",
	PromptSpeedBoost = "PromptSpeedBoost",
	PromptWinsBoost = "PromptWinsBoost",
	Prompt100KSpeed = "Prompt100KSpeed",
	Prompt1MSpeed = "Prompt1MSpeed",
	Prompt10MSpeed = "Prompt10MSpeed",
	RebirthSuccess = "RebirthSuccess",
	ShowWin = "ShowWin",
	VerifyGroup = "VerifyGroup",
	ClaimGift = "ClaimGift",
	EquipStepAward = "EquipStepAward",
	AdminAdjustStat = "AdminAdjustStat",
	NpcKillPlayer = "NpcKillPlayer",
	NpcLaserSlowEffect = "NpcLaserSlowEffect",
	ClientAliveTest = "ClientAliveTest",
}

-- ==================== LOGGING ====================
-- Logging helper (respects DEBUG_MODE)
function Config.log(prefix, message)
	if Config.DEBUG_MODE then
		print("[" .. prefix .. "] " .. message)
	end
end

function Config.warn(prefix, message)
	warn("[" .. prefix .. "] " .. message)
end

-- ==================== VALIDATION ====================
-- Validate config on load (catches typos/errors early)
function Config.validate()
	assert(type(Config.DEBUG_MODE) == "boolean", "Config.DEBUG_MODE must be boolean")
	assert(Config.Progression.BASE_XP > 0, "BASE_XP must be positive")
	assert(Config.DataStore.AUTO_SAVE_INTERVAL > 0, "AUTO_SAVE_INTERVAL must be positive")
	assert(Config.Leaderboard.UPDATE_INTERVAL > 0, "UPDATE_INTERVAL must be positive")

	-- Validate treadmill configs
	for name, treadmill in pairs(Config.Treadmills) do
		assert(treadmill.Multiplier, name .. " missing Multiplier")
		assert(treadmill.ProductId ~= nil, name .. " missing ProductId")
	end

	if Config.DEBUG_MODE then
		warn("⚠️ Config.DEBUG_MODE = true (DISABLE IN PRODUCTION!)")
	end

	return true
end

-- Auto-validate on load
Config.validate()

return Config
