-- FIND_55_ROBUX_PROMPT.lua
-- ADVANCED MALICIOUS SCRIPT DETECTOR
-- Run this in Command Bar with game STOPPED in Roblox Studio

-- ==================== COPY FROM HERE ====================
local game = game

print("🔍 ==================== ADVANCED MALWARE SCANNER ====================")
print("")
print("⚠️ SCANNING FOR 55 ROBUX PROMPT AND MALICIOUS CODE...")
print("")

local MarketplaceService = game:GetService("MarketplaceService")
local suspiciousScripts = {}
local highPriorityThreats = {}
local obfuscatedScripts = {}

-- Services to scan
local servicesToScan = {
    game:GetService("Workspace"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
    game:GetService("Players"),
}

-- High priority patterns (VERY suspicious)
local highPriorityPatterns = {
    {pattern = "55.*[Rr]obux", description = "55 Robux reference"},
    {pattern = "55.*[Pp]roduct", description = "55 + Product"},
    {pattern = "55.*[Oo]wner", description = "55 + Owner"},
    {pattern = "[Hh][Dd]%s*[Aa]dmin", description = "HD Admin"},
    {pattern = "[Oo]wner%s*[Rr]ank", description = "Owner Rank"},
    {pattern = "PromptProductPurchase.*55", description = "Product Purchase with 55"},
    {pattern = "PromptGamePassPurchase.*55", description = "GamePass Purchase with 55"},
}

-- Obfuscation indicators
local obfuscationPatterns = {
    "loadstring",
    "getfenv",
    "setfenv",
    "\\%d%d%d", -- \000 style encoding
    "[%w_]+%s*=%s*\"%w+\"%s*%.%.", -- String concatenation obfuscation
    "require%(%d+%)", -- External require (asset ID)
}

-- Known malicious asset IDs (common backdoors)
local knownMaliciousAssets = {
    "166285876", -- HD Admin (often backdoored)
    "172732271", -- Another common backdoor
}

print("🔎 Scanning all scripts in game...")
print("")

local totalScripts = 0
local scriptsWithSource = 0

for _, service in ipairs(servicesToScan) do
    for _, obj in pairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            totalScripts = totalScripts + 1

            local success, source = pcall(function()
                return obj.Source
            end)

            if success and source and #source > 0 then
                scriptsWithSource = scriptsWithSource + 1
                local lowerSource = string.lower(source)

                -- Check HIGH PRIORITY patterns first
                for _, patternData in ipairs(highPriorityPatterns) do
                    if string.find(source, patternData.pattern) or string.find(lowerSource, string.lower(patternData.pattern)) then
                        local enabled = "N/A"
                        if obj:IsA("Script") or obj:IsA("LocalScript") then
                            enabled = obj.Enabled
                        end
                        table.insert(highPriorityThreats, {
                            script = obj,
                            location = obj:GetFullName(),
                            reason = patternData.description,
                            source = source,
                            enabled = enabled
                        })
                        break
                    end
                end

                -- Check for obfuscation
                local obfuscationScore = 0
                local obfuscationReasons = {}

                for _, pattern in ipairs(obfuscationPatterns) do
                    if string.find(source, pattern) then
                        obfuscationScore = obfuscationScore + 1
                        table.insert(obfuscationReasons, pattern)
                    end
                end

                if obfuscationScore >= 2 then
                    local enabled = "N/A"
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        enabled = obj.Enabled
                    end
                    table.insert(obfuscatedScripts, {
                        script = obj,
                        location = obj:GetFullName(),
                        score = obfuscationScore,
                        reasons = obfuscationReasons,
                        source = source,
                        enabled = enabled
                    })
                end

                -- Check for known malicious asset IDs
                for _, assetId in ipairs(knownMaliciousAssets) do
                    if string.find(source, assetId) then
                        local enabled = "N/A"
                        if obj:IsA("Script") or obj:IsA("LocalScript") then
                            enabled = obj.Enabled
                        end
                        table.insert(highPriorityThreats, {
                            script = obj,
                            location = obj:GetFullName(),
                            reason = "Known malicious asset ID: " .. assetId,
                            source = source,
                            enabled = enabled
                        })
                        break
                    end
                end
            end
        end
    end
end

print("📊 SCAN COMPLETE:")
print("   Total scripts: " .. totalScripts)
print("   Scripts with source: " .. scriptsWithSource)
print("   Scripts WITHOUT source (protected/binary): " .. (totalScripts - scriptsWithSource))
print("")

-- Report HIGH PRIORITY THREATS first
if #highPriorityThreats > 0 then
    error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    error("🚨🚨🚨 HIGH PRIORITY THREATS DETECTED! 🚨🚨🚨")
    error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    error("")

    for i, threat in ipairs(highPriorityThreats) do
        error("🔴 THREAT #" .. i .. ":")
        error("   Name: " .. threat.script.Name)
        error("   Type: " .. threat.script.ClassName)
        error("   Location: " .. threat.location)
        error("   Reason: " .. threat.reason)
        error("   Enabled: " .. tostring(threat.enabled))
        error("")
        error("   FULL SOURCE CODE:")
        error("   ----------------------------------------")
        for line in string.gmatch(threat.source, "[^\r\n]+") do
            error("   " .. line)
        end
        error("   ----------------------------------------")
        error("")
        error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        error("")
    end

    print("")
    print("⚠️ IMMEDIATE ACTION REQUIRED:")
    print("   1. DELETE these scripts immediately")
    print("   2. Check your Plugins folder for malicious plugins")
    print("   3. Remove all free models you don't recognize")
    print("   4. Rebuild the game from clean Rojo source")
    print("")
else
    print("✅ No high priority threats found with 55 Robux patterns")
    print("")
end

-- Report OBFUSCATED scripts
if #obfuscatedScripts > 0 then
    warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    warn("⚠️ OBFUSCATED SCRIPTS DETECTED (possibly malicious):")
    warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    warn("")

    for i, script in ipairs(obfuscatedScripts) do
        warn("Obfuscated Script #" .. i .. ":")
        warn("   Name: " .. script.script.Name)
        warn("   Location: " .. script.location)
        warn("   Obfuscation Score: " .. script.score)
        warn("   Patterns Found: " .. table.concat(script.reasons, ", "))
        warn("   Enabled: " .. tostring(script.enabled))
        warn("")
        warn("   Source preview (first 1000 chars):")
        warn("   " .. string.sub(script.source, 1, 1000))
        warn("")
        warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        warn("")
    end
end

-- Scan for scripts in unusual locations
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📍 SCRIPTS IN UNUSUAL LOCATIONS:")
print("")

local unusualLocations = {
    {service = game:GetService("Workspace"), name = "Workspace"},
    {service = game:GetService("Lighting"), name = "Lighting"},
    {service = game:GetService("SoundService"), name = "SoundService"},
}

for _, location in ipairs(unusualLocations) do
    local scriptsFound = {}
    for _, obj in pairs(location.service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(scriptsFound, obj:GetFullName())
        end
    end

    if #scriptsFound > 0 then
        warn("⚠️ Scripts in " .. location.name .. " (SUSPICIOUS):")
        for _, path in ipairs(scriptsFound) do
            warn("   - " .. path)
        end
        warn("")
    end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("🔍 NEXT STEPS:")
print("")
print("1. If HIGH PRIORITY threats found: DELETE them immediately")
print("2. Check your Roblox Studio Plugins folder:")
print("   - Windows: %LOCALAPPDATA%\\Roblox\\Plugins")
print("   - Mac: ~/Documents/Roblox/Plugins")
print("3. Remove any plugins you don't recognize or didn't install")
print("4. Delete all free models from the game")
print("5. Rebuild from clean Rojo source using 'rojo build'")
print("")
print("🚨 ==================== END SCAN ====================")
-- ==================== COPY UNTIL HERE ====================
