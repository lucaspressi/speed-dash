-- DIAGNOSE_FREE_TREADMILLS.lua
-- COMMAND BAR SCRIPT - Run with game STOPPED
-- Diagnoses why FREE treadmills are not working

-- ==================== COPY FROM HERE ====================
local workspace = game:GetService("Workspace")

print("🔍 ==================== DIAGNOSE FREE TREADMILLS ====================")
print("")

-- Find all TreadmillFree models
local freeModels = {}
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "TreadmillFree" and obj:IsA("Model") then
        table.insert(freeModels, obj)
    end
end

print("📋 Found " .. #freeModels .. " TreadmillFree models")
print("")

for i, model in ipairs(freeModels) do
    print("TreadmillFree #" .. i .. ": " .. model:GetFullName())
    
    local zonePart = model:FindFirstChild("TreadmillZone")
    
    if zonePart then
        print("   ✅ Has TreadmillZone part")
        
        -- Check attributes
        local multiplier = zonePart:GetAttribute("Multiplier")
        local isFree = zonePart:GetAttribute("IsFree")
        local productId = zonePart:GetAttribute("ProductId")
        
        print("   Attributes:")
        print("      Multiplier: " .. tostring(multiplier))
        print("      IsFree: " .. tostring(isFree))
        print("      ProductId: " .. tostring(productId))
        
        -- Validation
        if multiplier == nil then
            warn("      ❌ Multiplier is NIL! TreadmillRegistry will skip this zone")
        elseif multiplier == 1 and isFree == true then
            print("      ✅ Valid FREE zone config")
        elseif multiplier == 1 and isFree ~= true then
            warn("      ⚠️ Multiplier=1 but IsFree is not true! Should be IsFree=true")
        end
        
        -- Check position
        print("   Position:")
        print("      X: " .. string.format("%.1f", zonePart.Position.X))
        print("      Y: " .. string.format("%.1f", zonePart.Position.Y))
        print("      Z: " .. string.format("%.1f", zonePart.Position.Z))
        print("   Size:")
        print("      X: " .. string.format("%.1f", zonePart.Size.X))
        print("      Y: " .. string.format("%.1f", zonePart.Size.Y))
        print("      Z: " .. string.format("%.1f", zonePart.Size.Z))
        
        -- Check physical properties
        print("   Physical:")
        print("      Anchored: " .. tostring(zonePart.Anchored))
        print("      CanCollide: " .. tostring(zonePart.CanCollide))
        print("      Transparency: " .. tostring(zonePart.Transparency))
        
    else
        warn("   ❌ NO TreadmillZone part!")
    end
    
    print("")
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Compare with working zones (Blue)
print("📊 COMPARISON: Checking a working Blue zone for reference...")
print("")

local blueModel = workspace:FindFirstChild("TreadmillBlue")
if blueModel then
    local blueZone = blueModel:FindFirstChild("TreadmillZone")
    if blueZone then
        print("TreadmillBlue (working) config:")
        print("   Multiplier: " .. tostring(blueZone:GetAttribute("Multiplier")))
        print("   IsFree: " .. tostring(blueZone:GetAttribute("IsFree")))
        print("   ProductId: " .. tostring(blueZone:GetAttribute("ProductId")))
        print("   Position: " .. tostring(blueZone.Position))
        print("   Size: " .. tostring(blueZone.Size))
    end
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

print("💡 COMMON ISSUES:")
print("")
print("1. ❌ Multiplier = nil → Zone is SKIPPED by TreadmillRegistry")
print("2. ❌ IsFree = nil or false (should be true for FREE zones)")
print("3. ❌ Position at 0,0,0 (might be overlapping with other zones)")
print("4. ❌ Size too small (player might not be detected)")
print("")
print("🔍 ==================== END DIAGNOSTICS ====================")
-- ==================== COPY UNTIL HERE ====================
