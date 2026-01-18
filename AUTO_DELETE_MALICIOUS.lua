-- AUTO_DELETE_MALICIOUS.lua
-- AUTOMATIC MALWARE REMOVAL SCRIPT
-- ⚠️ USE WITH CAUTION - This will DELETE scripts automatically!
-- Run in Command Bar with game STOPPED

-- ==================== COPY FROM HERE ====================
local game = game

print("🚨 ==================== AUTOMATIC MALWARE REMOVAL ====================")
print("")
print("⚠️ WARNING: This script will DELETE suspicious scripts automatically!")
print("⚠️ Make sure you have a BACKUP before running this!")
print("")
print("Starting in 3 seconds... Press STOP if you're not sure!")
print("")

wait(3)

local deletedScripts = {}
local protectedScripts = {}
local totalDeleted = 0

-- Patterns for HIGH PRIORITY threats
local deletePatterns = {
    {pattern = "55.*[Rr]obux", description = "55 Robux"},
    {pattern = "55.*[Oo]wner", description = "55 Owner"},
    {pattern = "[Hh][Dd]%s*[Aa]dmin", description = "HD Admin"},
    {pattern = "[Oo]wner%s*[Rr]ank", description = "Owner Rank"},
}

-- Known malicious asset IDs
local maliciousAssets = {
    "166285876", -- HD Admin backdoor
    "172732271", -- Common backdoor
}

-- Protected locations (don't delete from here automatically)
local protectedPaths = {
    "ServerScriptService",
    "ReplicatedStorage.Shared",
    "StarterPlayer.StarterPlayerScripts",
}

-- Function to check if script is in protected location
local function isProtected(scriptPath)
    for _, protectedPath in ipairs(protectedPaths) do
        if string.find(scriptPath, protectedPath) then
            return true
        end
    end
    return false
end

-- Services to clean
local servicesToClean = {
    game:GetService("Workspace"),
    game:GetService("ServerStorage"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
}

print("🔍 Scanning for malicious scripts...")
print("")

-- Scan and delete
for _, service in ipairs(servicesToClean) do
    for _, obj in pairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function()
                return obj.Source
            end)

            if success and source then
                local shouldDelete = false
                local reason = ""

                -- Check for malicious patterns
                for _, patternData in ipairs(deletePatterns) do
                    if string.find(source, patternData.pattern) or
                       string.find(string.lower(source), string.lower(patternData.pattern)) then
                        shouldDelete = true
                        reason = patternData.description
                        break
                    end
                end

                -- Check for malicious asset IDs
                if not shouldDelete then
                    for _, assetId in ipairs(maliciousAssets) do
                        if string.find(source, assetId) then
                            shouldDelete = true
                            reason = "Malicious Asset ID: " .. assetId
                            break
                        end
                    end
                end

                if shouldDelete then
                    local scriptPath = obj:GetFullName()

                    if isProtected(scriptPath) then
                        table.insert(protectedScripts, {
                            name = obj.Name,
                            path = scriptPath,
                            reason = reason
                        })
                        warn("⚠️ PROTECTED: Not deleting " .. scriptPath .. " (in protected location)")
                    else
                        table.insert(deletedScripts, {
                            name = obj.Name,
                            path = scriptPath,
                            reason = reason
                        })

                        -- DELETE the script
                        obj:Destroy()
                        totalDeleted = totalDeleted + 1

                        warn("🗑️ DELETED: " .. scriptPath .. " (Reason: " .. reason .. ")")
                    end
                end
            end
        end
    end
end

-- Also delete suspicious scripts in unusual locations
print("")
print("🔍 Deleting ALL scripts in unusual locations...")
print("")

local unusualServices = {
    {service = game:GetService("Workspace"), name = "Workspace"},
    {service = game:GetService("Lighting"), name = "Lighting"},
    {service = game:GetService("SoundService"), name = "SoundService"},
}

for _, location in ipairs(unusualServices) do
    for _, obj in pairs(location.service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local scriptPath = obj:GetFullName()

            table.insert(deletedScripts, {
                name = obj.Name,
                path = scriptPath,
                reason = "Script in unusual location: " .. location.name
            })

            obj:Destroy()
            totalDeleted = totalDeleted + 1

            warn("🗑️ DELETED: " .. scriptPath .. " (unusual location)")
        end
    end
end

-- Summary
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 DELETION SUMMARY:")
print("   Total scripts deleted: " .. totalDeleted)
print("   Scripts protected (review manually): " .. #protectedScripts)
print("")

if totalDeleted > 0 then
    print("✅ Deleted scripts:")
    for i, script in ipairs(deletedScripts) do
        print("   " .. i .. ". " .. script.path)
        print("      Reason: " .. script.reason)
    end
    print("")
end

if #protectedScripts > 0 then
    warn("⚠️ PROTECTED scripts (review these manually):")
    for i, script in ipairs(protectedScripts) do
        warn("   " .. i .. ". " .. script.path)
        warn("      Reason: " .. script.reason)
        warn("      ⚠️ This script is in a protected location - review manually!")
    end
    warn("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("✅ MALWARE REMOVAL COMPLETE!")
print("")
print("📝 NEXT STEPS:")
print("1. Save the game")
print("2. Run FIND_55_ROBUX_PROMPT.lua again to verify it's clean")
print("3. Test the game - the 55 robux prompt should be gone")
print("4. If protected scripts were found, review them manually")
print("5. Consider rebuilding from clean Rojo source for maximum security")
print("")
print("🚨 ==================== END CLEANUP ====================")
-- ==================== COPY UNTIL HERE ====================
