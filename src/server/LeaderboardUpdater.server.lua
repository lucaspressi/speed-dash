local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local workspace = game:GetService("Workspace")

-- OrderedDataStores for leaderboards
local SpeedLeaderboard = DataStoreService:GetOrderedDataStore("SpeedLeaderboard")
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("WinsLeaderboard")

-- Find leaderboard displays with retry mechanism
local speedBoardModel = nil
local winsBoardModel = nil
local speedSurfaceGui = nil
local winsSurfaceGui = nil
local speedTimerLabel = nil
local winsTimerLabel = nil

-- Function to find leaderboard components
local function findLeaderboardComponents()
    speedBoardModel = workspace:FindFirstChild("SpeedLeaderboard")
    winsBoardModel = workspace:FindFirstChild("WinsLeaderboard")

    if speedBoardModel then
        speedSurfaceGui = speedBoardModel:FindFirstChild("ScoreBlock") and speedBoardModel.ScoreBlock:FindFirstChild("Leaderboard")
        local timer = speedBoardModel:FindFirstChild("UpdateBoardTimer")
        if timer then
            local surfaceGui = timer:FindFirstChild("Timer")
            if surfaceGui then
                speedTimerLabel = surfaceGui:FindFirstChild("TextLabel")
            end
        end
    end

    if winsBoardModel then
        winsSurfaceGui = winsBoardModel:FindFirstChild("ScoreBlock") and winsBoardModel.ScoreBlock:FindFirstChild("Leaderboard")
        local timer = winsBoardModel:FindFirstChild("UpdateBoardTimer")
        if timer then
            local surfaceGui = timer:FindFirstChild("Timer")
            if surfaceGui then
                winsTimerLabel = surfaceGui:FindFirstChild("TextLabel")
            end
        end
    end

    return speedSurfaceGui ~= nil or winsSurfaceGui ~= nil
end

-- Try to find leaderboards with retry (max 5 attempts, 2 seconds apart)
local maxRetries = 5
local retryDelay = 2
local attempt = 1
local found = findLeaderboardComponents()

while not found and attempt <= maxRetries do
    print("[LeaderboardUpdater] Attempt " .. attempt .. "/" .. maxRetries .. ": Leaderboards not found, retrying in " .. retryDelay .. "s...")
    task.wait(retryDelay)
    found = findLeaderboardComponents()
    attempt = attempt + 1
end

print("[LeaderboardUpdater] Speed GUI found: " .. tostring(speedSurfaceGui ~= nil))
print("[LeaderboardUpdater] Wins GUI found: " .. tostring(winsSurfaceGui ~= nil))
print("[LeaderboardUpdater] Speed Timer found: " .. tostring(speedTimerLabel ~= nil))
print("[LeaderboardUpdater] Wins Timer found: " .. tostring(winsTimerLabel ~= nil))

-- Early return if no leaderboard GUIs exist in the map after all retries
if not speedSurfaceGui and not winsSurfaceGui then
    warn("[LeaderboardUpdater] No leaderboard displays found in workspace after " .. maxRetries .. " attempts. Leaderboard updates disabled.")
    return
end

print("[LeaderboardUpdater] ✅ Leaderboard components initialized successfully!")

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
        warn("[LeaderboardUpdater] Failed to get leaderboard: " .. tostring(result))
        return
    end

    if not result then
        warn("[LeaderboardUpdater] GetSortedAsync returned nil result")
        return
    end

    local pageSuccess, page = pcall(function()
        return result:GetCurrentPage()
    end)

    if not pageSuccess then
        warn("[LeaderboardUpdater] Failed to get current page: " .. tostring(page))
        return
    end

    if not page then
        warn("[LeaderboardUpdater] GetCurrentPage returned nil")
        return
    end

    if type(page) ~= "table" then
        warn("[LeaderboardUpdater] GetCurrentPage returned invalid type: " .. type(page))
        return
    end

    print("[LeaderboardUpdater] Retrieved " .. #page .. " entries from leaderboard")

    local namesFolder = surfaceGui:FindFirstChild("Names")
    local scoreFolder = surfaceGui:FindFirstChild("Score")
    local avatarsFolder = surfaceGui:FindFirstChild("Avatars")

    if not namesFolder or not scoreFolder then
        warn("[LeaderboardUpdater] Missing Names or Score folder in surfaceGui")
        return
    end

    if not avatarsFolder then
        warn("[LeaderboardUpdater] ⚠️ Avatars folder not found! Avatar thumbnails will not be displayed.")
        warn("[LeaderboardUpdater] Create an 'Avatars' folder in the SurfaceGui with Avatar1-Avatar10 ImageLabels")
    else
        print("[LeaderboardUpdater] ✅ Avatars folder found, loading thumbnails...")
    end

    for i = 1, 10 do
        local nameLabel = namesFolder:FindFirstChild("Name" .. i)
        local scoreLabel = scoreFolder:FindFirstChild("Score" .. i)
        local avatarImage = avatarsFolder and avatarsFolder:FindFirstChild("Avatar" .. i)

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

            -- Set player avatar thumbnail
            if avatarImage and avatarImage:IsA("ImageLabel") then
                local thumbnailSuccess, thumbnailUrl = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        tonumber(userId),
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size48x48
                    )
                end)
                if thumbnailSuccess and thumbnailUrl then
                    avatarImage.Image = thumbnailUrl
                    print("[LeaderboardUpdater] 🖼️ Loaded avatar for " .. username)
                else
                    warn("[LeaderboardUpdater] ❌ Failed to get thumbnail for " .. username)
                    -- Reset to default Roblox icon if available
                    avatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                end
            elseif avatarsFolder then
                warn("[LeaderboardUpdater] ⚠️ Avatar" .. i .. " ImageLabel not found or is not an ImageLabel!")
            end

            print("[LeaderboardUpdater] Position " .. i .. ": " .. username .. " - " .. formatNumber(score))
        else
            if nameLabel then nameLabel.Text = "---" end
            if scoreLabel then scoreLabel.Text = "0" end
            if avatarImage and avatarImage:IsA("ImageLabel") then
                avatarImage.Image = ""
            end
        end
    end
end

-- Ignored user IDs (won't appear on leaderboards)
local IGNORED_USERS = {
    -- Add user IDs to ignore here
}

-- Save all players' scores to OrderedDataStore
local function saveAllScores()
    local savedCount = 0
    local skippedCount = 0

    for _, player in pairs(Players:GetPlayers()) do
        -- Skip ignored users
        if IGNORED_USERS[player.UserId] then
            print("[LeaderboardUpdater] Skipping ignored user: " .. player.Name)
            skippedCount = skippedCount + 1
            continue
        end

        -- Skip restricted players
        local isRestricted = player:GetAttribute("Restricted")
        if isRestricted then
            print("[LeaderboardUpdater] Skipping restricted player: " .. player.Name)
            skippedCount = skippedCount + 1
            continue
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local speedStat = leaderstats:FindFirstChild("Speed")
            local winsStat = leaderstats:FindFirstChild("Wins")
            local userId = tostring(player.UserId)

            if speedStat and type(speedStat.Value) == "number" then
                local speedValue = speedStat.Value
                -- Validate: must be finite, non-negative number
                if speedValue >= 0 and speedValue == speedValue and speedValue ~= math.huge then
                    local success, err = pcall(function()
                        SpeedLeaderboard:SetAsync(userId, math.floor(speedValue))
                    end)
                    if success then
                        print("[LeaderboardUpdater] Saved " .. player.Name .. " Speed: " .. math.floor(speedValue))
                        savedCount = savedCount + 1
                    else
                        warn("[LeaderboardUpdater] Failed to save Speed for " .. player.Name .. ": " .. tostring(err))
                    end
                else
                    warn("[LeaderboardUpdater] Invalid Speed value for " .. player.Name .. ": " .. tostring(speedValue))
                end
            end

            task.wait(0.5)

            if winsStat and type(winsStat.Value) == "number" then
                local winsValue = winsStat.Value
                -- Validate: must be finite, non-negative number
                if winsValue >= 0 and winsValue == winsValue and winsValue ~= math.huge then
                    local success, err = pcall(function()
                        WinsLeaderboard:SetAsync(userId, math.floor(winsValue))
                    end)
                    if success then
                        print("[LeaderboardUpdater] Saved " .. player.Name .. " Wins: " .. math.floor(winsValue))
                    else
                        warn("[LeaderboardUpdater] Failed to save Wins for " .. player.Name .. ": " .. tostring(err))
                    end
                else
                    warn("[LeaderboardUpdater] Invalid Wins value for " .. player.Name .. ": " .. tostring(winsValue))
                end
            end

            task.wait(0.5)
        end
    end

    print("[LeaderboardUpdater] Save complete: " .. savedCount .. " players saved, " .. skippedCount .. " skipped")
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
        task.wait(5)  -- Increased to 5s to ensure DataStore replication completes
        updateDisplays()
        
        print("Leaderboards updated")
    end
end)

-- Initial update after 5 seconds
task.delay(5, function()
    if speedTimerLabel then speedTimerLabel.Text = "Loading..." end
    if winsTimerLabel then winsTimerLabel.Text = "Loading..." end
    
    saveAllScores()
    task.wait(5)  -- Increased to 5s to ensure DataStore replication completes
    updateDisplays()

    print("Initial leaderboard update done")
end)

print("LeaderboardUpdater ready with countdown timer!")
