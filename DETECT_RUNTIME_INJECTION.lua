-- DETECT_RUNTIME_INJECTION.lua
-- Detecta scripts que são INSERIDOS durante o runtime (quando o jogo roda)
-- Este é o método mais eficaz para pegar backdoors que se escondem

-- ==================== COPY FROM HERE ====================
local game = game

print("🔍 ==================== RUNTIME INJECTION DETECTOR ====================")
print("")
print("⚠️ Este script vai MONITORAR scripts que são inseridos enquanto o jogo roda.")
print("   Mantenha este script rodando e INICIE O JOGO (Play).")
print("   Qualquer script inserido será detectado e reportado!")
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

local detectedScripts = {}
local scriptCount = 0

-- Services to monitor
local servicesToMonitor = {
    {service = game:GetService("ServerScriptService"), name = "ServerScriptService"},
    {service = game:GetService("ServerStorage"), name = "ServerStorage"},
    {service = game:GetService("Workspace"), name = "Workspace"},
    {service = game:GetService("ReplicatedStorage"), name = "ReplicatedStorage"},
    {service = game:GetService("StarterGui"), name = "StarterGui"},
    {service = game:GetService("StarterPlayer"), name = "StarterPlayer"},
}

print("🎯 Monitoring services for new script insertions...")
print("")

-- Function to check if script is suspicious
local function checkScript(script)
    local success, source = pcall(function()
        return script.Source
    end)

    if success and source then
        local lowerSource = string.lower(source)

        -- Check for malicious patterns
        if string.find(source, "55") and (string.find(lowerSource, "robux") or string.find(lowerSource, "owner")) then
            return true, "Contains '55' + 'robux/owner'"
        end

        if string.find(lowerSource, "hd%s*admin") or string.find(lowerSource, "hdadmin") then
            return true, "Contains 'HD Admin'"
        end

        if string.find(source, "PromptProductPurchase") and string.find(source, "55") then
            return true, "Product purchase with 55 robux"
        end

        if string.find(source, "require%s*%(%s*%d+%s*%)") then
            return true, "Contains external require()"
        end

        if string.find(source, "loadstring") then
            return true, "Contains loadstring (obfuscation)"
        end
    end

    return false, ""
end

-- Monitor each service for new scripts
for _, serviceData in ipairs(servicesToMonitor) do
    serviceData.service.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            scriptCount = scriptCount + 1

            warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            warn("🚨 NEW SCRIPT INSERTED DURING RUNTIME!")
            warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            warn("")
            warn("Script name: " .. descendant.Name)
            warn("Script type: " .. descendant.ClassName)
            warn("Inserted in: " .. serviceData.name)
            warn("Full path: " .. descendant:GetFullName())
            warn("")

            -- Check if suspicious
            local isSuspicious, reason = checkScript(descendant)

            if isSuspicious then
                error("🔴🔴🔴 THIS SCRIPT IS HIGHLY SUSPICIOUS! 🔴🔴🔴")
                error("Reason: " .. reason)
                error("")

                local success, source = pcall(function() return descendant.Source end)
                if success and source then
                    error("FULL SOURCE CODE:")
                    error("----------------------------------------")
                    for line in string.gmatch(source, "[^\r\n]+") do
                        error(line)
                    end
                    error("----------------------------------------")
                end

                error("")
                error("⚠️ THIS IS LIKELY THE 55 ROBUX MALWARE!")
                error("⚠️ DELETE THIS SCRIPT IMMEDIATELY!")
                error("")
            else
                warn("Status: This script doesn't match known malware patterns")
                warn("(But still verify it manually!)")
                warn("")

                -- Show first 500 chars of source
                local success, source = pcall(function() return descendant.Source end)
                if success and source then
                    warn("Source preview (first 500 chars):")
                    warn(string.sub(source, 1, 500))
                    warn("")
                end
            end

            table.insert(detectedScripts, {
                name = descendant.Name,
                path = descendant:GetFullName(),
                suspicious = isSuspicious,
                reason = reason
            })

            warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            warn("")
        end
    end)
end

print("✅ Runtime monitoring is now ACTIVE!")
print("")
print("📝 INSTRUCTIONS:")
print("")
print("1. Keep this output window open")
print("2. Click the PLAY button (start the game server)")
print("3. Watch for any 'NEW SCRIPT INSERTED' warnings")
print("4. If a suspicious script is detected, you'll see the full source code")
print("5. DELETE any suspicious scripts immediately")
print("")
print("⏳ Waiting for runtime script insertions...")
print("   (If nothing appears when you press Play, that's GOOD - no malware!)")
print("")
print("🚨 ==================== MONITORING... ====================")

-- Keep the script alive
while true do
    task.wait(1)
end
-- ==================== COPY UNTIL HERE ====================
