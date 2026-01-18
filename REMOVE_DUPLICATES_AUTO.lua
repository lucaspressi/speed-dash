-- REMOVE_DUPLICATES_AUTO.lua
-- Automatically removes duplicate objects in Workspace
-- Run in Command Bar (SERVER) - WILL DELETE DUPLICATES IMMEDIATELY
-- Keeps the FIRST instance, removes all others

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🗑️ ==================== AUTO DUPLICATE REMOVER ====================")
print("")
print("⚠️  WARNING: This will IMMEDIATELY remove duplicate objects!")
print("⚠️  Keeping only the FIRST instance of each duplicate.")
print("")

local objectsByName = {}
local duplicatesRemoved = 0
local removedList = {}

-- Scan and categorize
for _, obj in ipairs(workspace:GetChildren()) do
    local name = obj.Name

    if not objectsByName[name] then
        objectsByName[name] = obj  -- Keep first instance
    else
        -- This is a duplicate - mark for removal
        table.insert(removedList, {name = name, obj = obj})
    end
end

if #removedList == 0 then
    print("✅ No duplicates found in Workspace!")
    print("==================== END ====================")
    return
end

print("📋 Found " .. #removedList .. " duplicate(s):")
print("")

for _, item in ipairs(removedList) do
    print("   🗑️  Removing duplicate: " .. item.name)
end

print("")
print("🔧 Removing duplicates...")

for _, item in ipairs(removedList) do
    local success, err = pcall(function()
        item.obj:Destroy()
    end)

    if success then
        duplicatesRemoved = duplicatesRemoved + 1
        print("   ✅ Removed: " .. item.name)
    else
        warn("   ❌ Failed to remove " .. item.name .. ": " .. tostring(err))
    end
end

print("")
print("✅ Successfully removed " .. duplicatesRemoved .. " duplicate object(s)!")
print("")
print("📊 SUMMARY:")
print("   Total duplicates found: " .. #removedList)
print("   Successfully removed: " .. duplicatesRemoved)
print("   Failed: " .. (#removedList - duplicatesRemoved))
print("")
print("==================== END ====================")
-- ==================== COPY UNTIL HERE ====================
