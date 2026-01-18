-- REMOVE_DUPLICATES.lua
-- Detecta e remove objetos duplicados no Workspace
-- Run in Command Bar (SERVER)

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== DUPLICATE REMOVER ====================")
print("")

-- Track objects by name
local objectsByName = {}
local duplicatesFound = 0
local duplicatesRemoved = 0

-- Scan workspace for duplicates
print("📊 Scanning Workspace for duplicates...")
print("")

for _, obj in ipairs(workspace:GetChildren()) do
    local name = obj.Name

    if not objectsByName[name] then
        -- First occurrence - keep it
        objectsByName[name] = {obj}
    else
        -- Duplicate found!
        table.insert(objectsByName[name], obj)
    end
end

-- Report duplicates
print("📋 DUPLICATE REPORT:")
print("")

for name, objects in pairs(objectsByName) do
    if #objects > 1 then
        duplicatesFound = duplicatesFound + 1
        print("⚠️  Found " .. #objects .. " instances of: " .. name)

        for i, obj in ipairs(objects) do
            if i == 1 then
                print("   ✅ Keeping: " .. obj:GetFullName() .. " (first instance)")
            else
                print("   ❌ Removing: " .. obj:GetFullName() .. " (duplicate #" .. (i-1) .. ")")
            end
        end
        print("")
    end
end

if duplicatesFound == 0 then
    print("✅ No duplicates found!")
    print("==================== END ====================")
    return
end

-- Ask for confirmation
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
print("🗑️  Ready to remove duplicates.")
print("⚠️  This will DELETE duplicate objects permanently!")
print("")
print("To proceed, run this script again with CONFIRM = true")
print("")
print("==================== END ====================")

-- Set this to true to actually delete
local CONFIRM = false

if not CONFIRM then
    return
end

-- Remove duplicates (only if CONFIRM = true)
print("")
print("🗑️  REMOVING DUPLICATES...")
print("")

for name, objects in pairs(objectsByName) do
    if #objects > 1 then
        -- Keep first, remove rest
        for i = 2, #objects do
            local obj = objects[i]
            print("   Removing: " .. obj:GetFullName())
            obj:Destroy()
            duplicatesRemoved = duplicatesRemoved + 1
        end
    end
end

print("")
print("✅ Removed " .. duplicatesRemoved .. " duplicate objects!")
print("")
print("==================== END ====================")
-- ==================== COPY UNTIL HERE ====================
