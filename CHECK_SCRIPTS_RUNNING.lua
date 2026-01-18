-- CHECK_SCRIPTS_RUNNING.lua
-- Run in Command Bar (SERVER with game RUNNING)
-- Checks if critical scripts are actually running at runtime

-- ==================== COPY FROM HERE ====================
local ServerScriptService = game:GetService("ServerScriptService")

print("⚙️ ==================== CHECKING SCRIPTS RUNTIME ====================")
print("")

-- Critical scripts that must be running
local criticalScripts = {
    {name = "SpeedGameServer", required = true},
    {name = "NoobNpcAI", required = true},
    {name = "LavaKill", required = true},
    {name = "TreadmillService", required = true},
    {name = "TreadmillAutoFix", required = false},
    {name = "RollingBallController", required = false},
}

local allGood = true

for _, scriptInfo in ipairs(criticalScripts) do
    print("🔍 Checking: " .. scriptInfo.name)

    local script = ServerScriptService:FindFirstChild(scriptInfo.name, true)

    if not script then
        if scriptInfo.required then
            warn("   ❌ NOT FOUND (required!)")
            allGood = false
        else
            print("   ⚠️ Not found (optional)")
        end
    else
        print("   ✅ Found at: " .. script:GetFullName())
        print("      Enabled: " .. tostring(script.Enabled))

        if not script.Enabled then
            if scriptInfo.required then
                warn("      ❌ DISABLED (required!)")
                allGood = false
            else
                print("      ⚠️ Disabled (optional)")
            end
        end

        -- Try to check if script actually ran
        if scriptInfo.name == "LavaKill" then
            print("      Checking if LavaKill setup happened...")
            -- LavaKill should print a message on boot
            print("      (Check Output for '[LavaKill]' messages)")
        elseif scriptInfo.name == "NoobNpcAI" then
            print("      Checking if NoobAI is running...")
            print("      (Check Output for '[NoobAI]' messages)")
        elseif scriptInfo.name == "SpeedGameServer" then
            print("      Checking if SpeedGameServer initialized...")
            print("      (Check Output for '[SpeedGameServer]' or similar)")
        end
    end

    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Check _G for runtime services
print("🌐 Checking _G (global services)...")
print("")

if _G.TreadmillService then
    print("✅ _G.TreadmillService exists (runtime initialized)")
else
    warn("❌ _G.TreadmillService NOT FOUND (TreadmillService didn't initialize)")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Final verdict
if allGood then
    print("✅ All required scripts are present and enabled!")
    print("")
    print("If systems still don't work:")
    print("   1. Check Output window for ERROR messages in RED")
    print("   2. Look for script runtime errors")
    print("   3. Scripts may have errors preventing them from running")
else
    warn("❌ Some required scripts are missing or disabled!")
    print("")
    print("ACTION REQUIRED:")
    print("   1. Make sure Rojo is syncing (rojo serve)")
    print("   2. Publish to Roblox (File > Publish)")
    print("   3. Enable any disabled scripts")
end

print("")
print("⚙️ ==================== END CHECK ====================")
-- ==================== COPY UNTIL HERE ====================
