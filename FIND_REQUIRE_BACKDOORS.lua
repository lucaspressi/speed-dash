-- FIND_REQUIRE_BACKDOORS.lua
-- Detecta backdoors que usam require() com asset IDs externos
-- Run in Command Bar with game STOPPED

-- ==================== COPY FROM HERE ====================
local game = game

print("🔍 ==================== REQUIRE BACKDOOR DETECTOR ====================")
print("")
print("⚠️ Procurando por require() com asset IDs (backdoors comuns)...")
print("")

local suspiciousRequires = {}
local totalScripts = 0

-- Known malicious asset IDs
local knownMaliciousAssets = {
    "166285876", -- HD Admin (backdoored version)
    "172732271", -- Common backdoor
    "1348967749", -- Another common backdoor
    "5277869238", -- Fake admin
}

-- Services to scan
local servicesToScan = {
    game:GetService("Workspace"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
}

print("🔎 Scanning all scripts for require() patterns...")
print("")

for _, service in ipairs(servicesToScan) do
    for _, obj in pairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            totalScripts = totalScripts + 1

            local success, source = pcall(function()
                return obj.Source
            end)

            if success and source and #source > 0 then
                -- Check for require(NUMBER) pattern
                for assetId in string.gmatch(source, "require%s*%(%s*(%d+)%s*%)") do
                    local isKnownMalicious = false

                    -- Check if it's a known malicious asset
                    for _, maliciousId in ipairs(knownMaliciousAssets) do
                        if assetId == maliciousId then
                            isKnownMalicious = true
                            break
                        end
                    end

                    table.insert(suspiciousRequires, {
                        script = obj,
                        location = obj:GetFullName(),
                        assetId = assetId,
                        isKnownMalicious = isKnownMalicious,
                        source = source
                    })
                end
            end
        end
    end
end

print("📊 SCAN COMPLETE:")
print("   Total scripts scanned: " .. totalScripts)
print("   Suspicious require() found: " .. #suspiciousRequires)
print("")

if #suspiciousRequires > 0 then
    error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    error("🚨 BACKDOORS DETECTADOS!")
    error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    error("")

    for i, backdoor in ipairs(suspiciousRequires) do
        if backdoor.isKnownMalicious then
            error("🔴 BACKDOOR CONFIRMADO #" .. i .. " (ASSET ID MALICIOSO CONHECIDO):")
        else
            error("⚠️ BACKDOOR SUSPEITO #" .. i .. " (require externo):")
        end

        error("   Script: " .. backdoor.script.Name)
        error("   Tipo: " .. backdoor.script.ClassName)
        error("   Localização: " .. backdoor.location)
        error("   Asset ID: " .. backdoor.assetId)
        error("")
        error("   CÓDIGO COMPLETO DO SCRIPT:")
        error("   ----------------------------------------")
        for line in string.gmatch(backdoor.source, "[^\r\n]+") do
            error("   " .. line)
        end
        error("   ----------------------------------------")
        error("")
        error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        error("")
    end

    print("")
    print("⚠️ AÇÃO IMEDIATA NECESSÁRIA:")
    print("")
    print("1. DELETE todos os scripts listados acima")
    print("2. Esses require() externos carregam código malicioso da internet")
    print("3. NUNCA use require() com asset IDs que você não reconhece")
    print("4. Verifique se esses scripts vieram de free models")
    print("")
else
    print("✅ Nenhum require() externo suspeito encontrado!")
    print("")
    print("Isso significa que o backdoor NÃO está no código do jogo.")
    print("O prompt provavelmente vem de um PLUGIN MALICIOSO.")
    print("")
    print("📝 PRÓXIMOS PASSOS:")
    print("")
    print("1. Feche o Roblox Studio completamente")
    print("2. No terminal, rode: ./FIND_PLUGIN_MALWARE.sh")
    print("3. Delete TODOS os plugins suspeitos")
    print("4. Reabra o Studio e teste novamente")
    print("")
end

print("🚨 ==================== END SCAN ====================")
-- ==================== COPY UNTIL HERE ====================
