local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local workspace = game:GetService("Workspace")

-- OrderedDataStores for leaderboards
local SpeedLeaderboard = DataStoreService:GetOrderedDataStore("SpeedLeaderboard")
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("WinsLeaderboard")

-- Find leaderboard displays
local speedBoardModel = workspace:FindFirstChild("SpeedLeaderboard")
local winsBoardModel = workspace:FindFirstChild("WinsLeaderboard")

local speedSurfaceGui = speedBoardModel and speedBoardModel:FindFirstChild("ScoreBlock") and speedBoardModel.ScoreBlock:FindFirstChild("Leaderboard")
local winsSurfaceGui = winsBoardModel and winsBoardModel:FindFirstChild("ScoreBlock") and winsBoardModel.ScoreBlock:FindFirstChild("Leaderboard")

-- Find timer labels
local speedTimerLabel = nil
local winsTimerLabel = nil

if speedBoardModel then
    local timer = speedBoardModel:FindFirstChild("UpdateBoardTimer")
    if timer then
        local surfaceGui = timer:FindFirstChild("Timer")
        if surfaceGui then
            speedTimerLabel = surfaceGui:FindFirstChild("TextLabel")
        end
    end
end

if winsBoardModel then
    local timer = winsBoardModel:FindFirstChild("UpdateBoardTimer")
    if timer then
        local surfaceGui = timer:FindFirstChild("Timer")
        if surfaceGui then
            winsTimerLabel = surfaceGui:FindFirstChild("TextLabel")
        end
    end
end

print("[LeaderboardUpdater] Speed GUI found: " .. tostring(speedSurfaceGui ~= nil))
print("[LeaderboardUpdater] Wins GUI found: " .. tostring(winsSurfaceGui ~= nil))
print("[LeaderboardUpdater] Speed Timer found: " .. tostring(speedTimerLabel ~= nil))
print("[LeaderboardUpdater] Wins Timer found: " .. tostring(winsTimerLabel ~= nil))

-- Early return if no leaderboard GUIs exist in the map
if not speedSurfaceGui and not winsSurfaceGui then
	print("[LeaderboardUpdater] No leaderboard displays found in workspace. Leaderboard updates disabled.")
	return
end

-- Format large numbers with abbreviations
local function formatNumber(num)
	if num < 1000 then
		return tostring(math.floor(num))
	end

	local suffixes = {
		{1e30, "No"},  -- Nonillion
		{1e27, "Oc"},  -- Octillion
		{1e24, "Sp"},  -- Septillion
		{1e21, "Sx"},  -- Sextillion
		{1e18, "Qi"},  -- Quintillion
		{1e15, "Qa"},  -- Quadrillion
		{1e12, "T"},   -- Trillion
		{1e9, "B"},    -- Billion
		{1e6, "M"},    -- Million
		{1e3, "K"}     -- Thousand
	}

	for _, data in ipairs(suffixes) do
		local value, suffix = data[1], data[2]
		if num >= value then
			local formatted = num / value
			-- Show 2 decimal places for values < 10, 1 decimal for values < 100, 0 decimals for >= 100
			if formatted < 10 then
				return string.format("%.2f", formatted) .. suffix
			elseif formatted < 100 then
				return string.format("%.1f", formatted) .. suffix
			else
				return string.format("%.0f", formatted) .. suffix
			end
		end
	end

	return tostring(math.floor(num))
end

-- Update timer text
local function updateTimerText(seconds)
    local text = "Updating in " .. seconds .. " seconds"
    if speedTimerLabel then
        speedTimerLabel.Text = text
    end
    if winsTimerLabel then
        winsTimerLabel.Text = text
    end
end

-- Update leaderboard display
local function updateLeaderboardDisplay(orderedDataStore, surfaceGui)
    local success, result = pcall(function()
        return orderedDataStore:GetSortedAsync(false, 10)
    end)
    
    if not success then
        warn("Failed to get leaderboard: " .. tostring(result))
        return
    end
    
    local page = result:GetCurrentPage()
    
    local namesFolder = surfaceGui:FindFirstChild("Names")
    local scoreFolder = surfaceGui:FindFirstChild("Score")
    
    if not namesFolder or not scoreFolder then return end
    
    for i = 1, 10 do
        local nameLabel = namesFolder:FindFirstChild("Name" .. i)
        local scoreLabel = scoreFolder:FindFirstChild("Score" .. i)
        
        local entry = page[i]
        
        if entry then
            local userId = entry.key
            local score = entry.value
            
            local username = "Player"
            local nameSuccess, name = pcall(function()
                return Players:GetNameFromUserIdAsync(tonumber(userId))
            end)
            if nameSuccess then
                username = name
            end
            
            if nameLabel then nameLabel.Text = username end
            if scoreLabel then scoreLabel.Text = formatNumber(score) end
        else
            if nameLabel then nameLabel.Text = "---" end
            if scoreLabel then scoreLabel.Text = "0" end
        end
    end
end

-- Ignored user IDs (won't appear on leaderboards)
local IGNORED_USERS = {
    -- Add user IDs to ignore here
}

-- Save all players' scores to OrderedDataStore
local function saveAllScores()
    for _, player in pairs(Players:GetPlayers()) do
        -- Skip ignored users
        if IGNORED_USERS[player.UserId] then continue end
        
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local speedStat = leaderstats:FindFirstChild("Speed")
            local winsStat = leaderstats:FindFirstChild("Wins")
            local userId = tostring(player.UserId)
            
            if speedStat then
                pcall(function()
                    SpeedLeaderboard:SetAsync(userId, math.floor(speedStat.Value))
                end)
            end
            
            task.wait(0.5)
            
            if winsStat then
                pcall(function()
                    WinsLeaderboard:SetAsync(userId, math.floor(winsStat.Value))
                end)
            end
            
            task.wait(0.5)
        end
    end
end

-- Update displays
local function updateDisplays()
    if speedSurfaceGui then
        updateLeaderboardDisplay(SpeedLeaderboard, speedSurfaceGui)
    end
    
    if winsSurfaceGui then
        updateLeaderboardDisplay(WinsLeaderboard, winsSurfaceGui)
    end
end

-- Main loop with countdown timer
local UPDATE_INTERVAL = 60

task.spawn(function()
    while true do
        -- Countdown
        for i = UPDATE_INTERVAL, 1, -1 do
            updateTimerText(i)
            task.wait(1)
        end
        
        -- Update
        updateTimerText(0)
        
        if speedTimerLabel then speedTimerLabel.Text = "Updating..." end
        if winsTimerLabel then winsTimerLabel.Text = "Updating..." end
        
        saveAllScores()
        task.wait(2)
        updateDisplays()
        
        print("Leaderboards updated")
    end
end)

-- Initial update after 5 seconds
task.delay(5, function()
    if speedTimerLabel then speedTimerLabel.Text = "Loading..." end
    if winsTimerLabel then winsTimerLabel.Text = "Loading..." end
    
    saveAllScores()
    task.wait(2)
    updateDisplays()
    
    print("Initial leaderboard update done")
end)

print("LeaderboardUpdater ready with countdown timer!")
