-- UniverseIDFinder.server.lua
-- 🎯 INSTRUCTIONS:
-- 1. Open build.rbxl in Roblox Studio
-- 2. Create a new Script in ServerScriptService
-- 3. Paste this entire file into that script
-- 4. Press F5 (Play Test)
-- 5. Check the Output window (View → Output)
-- 6. Copy the ROBLOX_UNIVERSE_ID value shown

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎮 ROBLOX EXPERIENCE IDENTIFICATION")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Get both IDs
local universeId = game.GameId
local placeId = game.PlaceId
local placeName = game.Name

-- Display results
print("📋 EXPERIENCE INFORMATION:")
print("")
print("Experience Name:       " .. tostring(placeName))
print("Universe ID (GameId):  " .. tostring(universeId))
print("Place ID (PlaceId):    " .. tostring(placeId))
print("")

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ WHICH ID TO USE WHERE:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("🌐 USE UNIVERSE ID (" .. tostring(universeId) .. ") FOR:")
print("   ✓ Roblox Open Cloud API")
print("   ✓ MessagingService (cross-server communication)")
print("   ✓ External admin dashboards")
print("   ✓ DataStore API requests")
print("   ✓ Analytics and monitoring")
print("   ✓ Environment variable: ROBLOX_UNIVERSE_ID")
print("")
print("📍 USE PLACE ID (" .. tostring(placeId) .. ") FOR:")
print("   ✓ TeleportService (teleporting players)")
print("   ✓ Place-specific operations ONLY")
print("   ✗ DO NOT use for Open Cloud API")
print("   ✗ DO NOT use for MessagingService")
print("")

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("💾 COPY THESE VALUES TO .env FILE:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("ROBLOX_UNIVERSE_ID=" .. tostring(universeId))
print("ROBLOX_PLACE_ID=" .. tostring(placeId))
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📝 NEXT STEPS:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("1. Copy the ROBLOX_UNIVERSE_ID value above")
print("2. Open the project folder in your code editor")
print("3. Create/edit the .env file")
print("4. Paste the ROBLOX_UNIVERSE_ID line")
print("5. Add your ROBLOX_API_KEY (from https://create.roblox.com/credentials)")
print("6. Run: npm install (in admin-dashboard folder)")
print("7. Run: npm run dev (to start the dashboard)")
print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Validation check
if universeId == 0 then
	warn("⚠️ WARNING: Universe ID is 0!")
	warn("This place might not be published yet.")
	warn("Publish the place to Roblox first, then run this script again.")
end

if placeId == 0 then
	warn("⚠️ WARNING: Place ID is 0!")
	warn("This is a local file. Publish to Roblox first.")
end

-- Save to DataStore for easy retrieval (optional)
local success, err = pcall(function()
	game:GetService("DataStoreService"):GetDataStore("_SystemConfig"):SetAsync("UniverseId", universeId)
	game:GetService("DataStoreService"):GetDataStore("_SystemConfig"):SetAsync("PlaceId", placeId)
end)

if success then
	print("✅ IDs saved to DataStore '_SystemConfig' for reference")
else
	warn("⚠️ Could not save to DataStore (Studio API services might be disabled)")
end

print("")
print("🎉 Identification complete! Copy the values above.")
print("")
