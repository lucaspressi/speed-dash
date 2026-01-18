-- CHECK_TREADMILL_SERVICE.lua
-- COMMAND BAR SCRIPT - Run on SERVER with game STOPPED
-- Checks if TreadmillService script exists and is enabled

-- ==================== COPY FROM HERE ====================
local ServerScriptService = game:GetService("ServerScriptService")

print("🔍 ==================== CHECK TREADMILL SERVICE ====================")
print("")

-- Check for TreadmillService
local treadmillService = ServerScriptService:FindFirstChild("TreadmillService")

if not treadmillService then
	warn("❌ TreadmillService.server.lua NOT FOUND in ServerScriptService!")
	warn("")
	warn("💡 This script needs to be synced from src/server/")
	warn("   Solution:")
	warn("   1. Use Rojo to sync: Plugins → Rojo → Connect")
	warn("   2. Or manually copy TreadmillService.server.lua to ServerScriptService")
	print("")
else
	print("✅ TreadmillService.server.lua found")
	print("   ClassName: " .. treadmillService.ClassName)
	print("   Enabled: " .. tostring(treadmillService.Enabled))
	print("")
	
	if not treadmillService.Enabled then
		warn("❌ TreadmillService is DISABLED!")
		warn("   Enable it in ServerScriptService properties")
		print("")
	else
		print("✅ TreadmillService is ENABLED")
		print("")
	end
end

-- Check for TreadmillRegistry module
print("🔍 Checking TreadmillRegistry module...")
print("")

local modules = ServerScriptService:FindFirstChild("Modules")
if modules then
	local treadmillRegistry = modules:FindFirstChild("TreadmillRegistry")
	
	if treadmillRegistry then
		print("✅ TreadmillRegistry module found")
		print("   ClassName: " .. treadmillRegistry.ClassName)
	else
		warn("❌ TreadmillRegistry NOT FOUND in ServerScriptService.Modules!")
	end
else
	warn("❌ Modules folder NOT FOUND in ServerScriptService!")
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- List all scripts in ServerScriptService
print("📋 Scripts in ServerScriptService:")
print("")

for _, obj in pairs(ServerScriptService:GetChildren()) do
	if obj:IsA("Script") or obj:IsA("ModuleScript") then
		local enabled = ""
		if obj:IsA("Script") then
			enabled = obj.Enabled and "✅" or "❌"
		end
		print("   " .. enabled .. " " .. obj.Name .. " (" .. obj.ClassName .. ")")
	end
end

print("")
print("🔍 ==================== END CHECK ====================")
-- ==================== COPY UNTIL HERE ====================
