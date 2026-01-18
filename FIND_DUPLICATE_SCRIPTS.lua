-- FIND_DUPLICATE_SCRIPTS.lua
-- Paste in Studio SERVER console to find ALL scripts in StarterPlayerScripts
-- and identify potential duplications or scripts not managed by Rojo

print("==================== SCANNING StarterPlayerScripts ====================")

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")

if not StarterPlayerScripts then
    warn("❌ StarterPlayerScripts NOT FOUND!")
    print("==================== END ====================")
    return
end

-- Expected scripts from Rojo (src/client/)
local EXPECTED_ROJO_SCRIPTS = {
    "ClientBootstrap",
    "DebugLogExporter",
    "DiagnosticClient",
    "TestClient",
    "UIHandler"
}

print("\n📋 EXPECTED SCRIPTS FROM ROJO (src/client/):")
for _, name in ipairs(EXPECTED_ROJO_SCRIPTS) do
    print("   ✓ " .. name)
end

print("\n" .. string.rep("━", 60))
print("📊 SCANNING ALL CHILDREN IN StarterPlayerScripts...")
print(string.rep("━", 60) .. "\n")

local allScripts = {}
local scriptsByName = {}

-- Recursively find all scripts
local function scanDescendants(parent, depth)
    depth = depth or 0
    local indent = string.rep("   ", depth)

    for _, child in ipairs(parent:GetChildren()) do
        local info = {
            name = child.Name,
            className = child.ClassName,
            fullName = child:GetFullName(),
            depth = depth,
            parent = parent
        }

        table.insert(allScripts, info)

        -- Track by name for duplicate detection
        if not scriptsByName[child.Name] then
            scriptsByName[child.Name] = {}
        end
        table.insert(scriptsByName[child.Name], info)

        -- Print current item
        local icon = "📄"
        if child:IsA("Script") then icon = "🔷"
        elseif child:IsA("LocalScript") then icon = "🔶"
        elseif child:IsA("ModuleScript") then icon = "📦"
        elseif child:IsA("Folder") then icon = "📁"
        end

        print(indent .. icon .. " " .. child.Name .. " (" .. child.ClassName .. ")")

        -- Recursively scan children
        if #child:GetChildren() > 0 then
            scanDescendants(child, depth + 1)
        end
    end
end

scanDescendants(StarterPlayerScripts)

print("\n" .. string.rep("━", 60))
print("📊 ANALYSIS RESULTS")
print(string.rep("━", 60))

print("\n1️⃣ TOTAL ITEMS FOUND: " .. #allScripts)

-- Check for duplicates
print("\n2️⃣ CHECKING FOR DUPLICATE NAMES:")
local foundDuplicates = false
for name, instances in pairs(scriptsByName) do
    if #instances > 1 then
        foundDuplicates = true
        warn("   ⚠️  DUPLICATE: '" .. name .. "' appears " .. #instances .. " times:")
        for i, info in ipairs(instances) do
            print("      [" .. i .. "] " .. info.fullName .. " (" .. info.className .. ")")
        end
    end
end
if not foundDuplicates then
    print("   ✅ No duplicate names found")
end

-- Check for unexpected scripts
print("\n3️⃣ COMPARING WITH ROJO EXPECTATIONS:")
local unexpectedScripts = {}
local missingScripts = {}

-- Find unexpected scripts (exist in Studio but not in EXPECTED_ROJO_SCRIPTS)
for name, instances in pairs(scriptsByName) do
    local isExpected = false
    for _, expectedName in ipairs(EXPECTED_ROJO_SCRIPTS) do
        if name == expectedName then
            isExpected = true
            break
        end
    end

    if not isExpected then
        for _, info in ipairs(instances) do
            if info.depth == 0 then  -- Only root level scripts
                table.insert(unexpectedScripts, info)
            end
        end
    end
end

-- Find missing scripts (expected but not found)
for _, expectedName in ipairs(EXPECTED_ROJO_SCRIPTS) do
    if not scriptsByName[expectedName] then
        table.insert(missingScripts, expectedName)
    end
end

if #unexpectedScripts > 0 then
    warn("\n   ⚠️  UNEXPECTED SCRIPTS (not in Rojo src/client/):")
    for _, info in ipairs(unexpectedScripts) do
        warn("      • " .. info.name .. " (" .. info.className .. ")")
        warn("        └─ " .. info.fullName)
    end
    print("\n   💡 These scripts might have been created directly in Studio!")
    print("      They are NOT managed by Rojo and will be overwritten on next sync.")
else
    print("   ✅ No unexpected scripts found")
end

if #missingScripts > 0 then
    warn("\n   ⚠️  MISSING EXPECTED SCRIPTS:")
    for _, name in ipairs(missingScripts) do
        warn("      • " .. name)
    end
else
    print("   ✅ All expected scripts from Rojo are present")
end

print("\n" .. string.rep("━", 60))
print("4️⃣ COMPLETE HIERARCHY:")
print(string.rep("━", 60))
print("\nStarterPlayer")
print("   └─ StarterPlayerScripts")
scanDescendants(StarterPlayerScripts, 2)

print("\n" .. string.rep("━", 60))
print("✅ SCAN COMPLETE")
print(string.rep("━", 60))

print("\n💡 RECOMMENDATIONS:")
if foundDuplicates then
    print("   1. ⚠️  RESOLVE DUPLICATES: Delete duplicate scripts in Studio")
end
if #unexpectedScripts > 0 then
    print("   2. ⚠️  REMOVE UNEXPECTED SCRIPTS: These were likely created in Studio")
    print("      and will be lost on next Rojo sync!")
end
if #missingScripts > 0 then
    print("   3. ⚠️  MISSING SCRIPTS: Run 'rojo serve' and sync to restore them")
end
if not foundDuplicates and #unexpectedScripts == 0 and #missingScripts == 0 then
    print("   ✅ Everything looks good! StarterPlayerScripts is in sync with Rojo.")
end

print("\n==================== END ====================")
