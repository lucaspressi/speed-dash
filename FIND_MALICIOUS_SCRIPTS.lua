-- FIND_MALICIOUS_SCRIPTS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Scans ENTIRE game for suspicious scripts

-- ==================== COPY FROM HERE ====================
local game = game
local workspace = game:GetService("Workspace")

print("🚨 ==================== SCANNING FOR MALICIOUS SCRIPTS ====================")
print("")

local suspiciousKeywords = {
    "HD Admin",
    "Owner Rank",
    "55",
    "robux",
    "PromptGamePassPurchase",
    "PromptProductPurchase",
    "admin",
    "owner",
    "require(%d+)",  -- require(assetId) - can load malicious code
}

local foundScripts = {}
local suspiciousScripts = {}

-- Scan ALL services
local servicesToScan = {
    workspace,
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
}

print("🔍 Scanning all scripts in game...")
print("")

for _, service in ipairs(servicesToScan) do
    for _, obj in pairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(foundScripts, {
                script = obj,
                location = obj:GetFullName()
            })
            
            -- Try to read source (may fail for some scripts)
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source then
                local lowerSource = string.lower(source)
                
                -- Check for suspicious keywords
                for _, keyword in ipairs(suspiciousKeywords) do
                    if string.find(lowerSource, string.lower(keyword)) then
                        table.insert(suspiciousScripts, {
                            script = obj,
                            location = obj:GetFullName(),
                            keyword = keyword,
                            source = source
                        })
                        break
                    end
                end
            end
        end
    end
end

print("📊 SCAN RESULTS:")
print("   Total scripts found: " .. #foundScripts)
print("   Suspicious scripts: " .. #suspiciousScripts)
print("")

if #suspiciousScripts > 0 then
    warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    warn("🚨 SUSPICIOUS SCRIPTS FOUND:")
    warn("")
    
    for i, entry in ipairs(suspiciousScripts) do
        warn("Suspicious Script #" .. i .. ":")
        warn("   Name: " .. entry.script.Name)
        warn("   Type: " .. entry.script.ClassName)
        warn("   Location: " .. entry.location)
        warn("   Matched keyword: " .. entry.keyword)
        warn("   Enabled: " .. tostring(entry.script.Enabled))
        warn("")
        
        -- Print first 500 characters of source
        if #entry.source > 0 then
            warn("   Source preview (first 500 chars):")
            warn("   " .. string.sub(entry.source, 1, 500))
            warn("")
        end
        warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        warn("")
    end
    
    print("")
    print("⚠️ RECOMMENDATIONS:")
    print("")
    print("1. DISABLE or DELETE suspicious scripts immediately")
    print("2. Check if they came from free models")
    print("3. Never use 'require(assetId)' from unknown sources")
    print("4. Scan your Toolbox models for malicious content")
    print("")
else
    print("✅ No obviously suspicious scripts found with keyword search")
    print("")
    print("💡 However, check for:")
    print("   1. Scripts with obfuscated/encoded code")
    print("   2. Scripts that you don't recognize")
    print("   3. Scripts in unexpected locations (Workspace, Lighting, etc)")
    print("")
end

-- List all scripts in Workspace (often where malicious scripts hide)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("📋 Scripts in WORKSPACE (check these manually):")
print("")

local workspaceScripts = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("Script") or obj:IsA("LocalScript") then
        table.insert(workspaceScripts, obj)
    end
end

if #workspaceScripts > 0 then
    for i, script in ipairs(workspaceScripts) do
        print("   Script #" .. i .. ": " .. script:GetFullName())
        print("      Enabled: " .. tostring(script.Enabled))
    end
else
    print("   ✅ No scripts in Workspace")
end

print("")
print("🚨 ==================== END SCAN ====================")
-- ==================== COPY UNTIL HERE ====================
