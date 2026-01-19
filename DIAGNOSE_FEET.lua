-- COMMAND BAR: Diagnosticar problema de pé afundado
-- Cole no Command Bar enquanto o jogo está rodando

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then
    warn("❌ Buff Noob não encontrado!")
    return
end

local humanoid = npc:FindFirstChildOfClass("Humanoid")
local hrp = npc:FindFirstChild("HumanoidRootPart")
local lowerTorso = npc:FindFirstChild("LowerTorso")
local leftUpperLeg = npc:FindFirstChild("LeftUpperLeg")
local leftLowerLeg = npc:FindFirstChild("LeftLowerLeg")
local leftFoot = npc:FindFirstChild("LeftFoot")
local rightFoot = npc:FindFirstChild("RightFoot")

print("=== DIAGNÓSTICO DE PÉ AFUNDADO ===")
print("")

-- 1. Verificar HipHeight
if humanoid then
    print("HipHeight atual: " .. humanoid.HipHeight)
end

-- 2. Calcular HipHeight correto
if lowerTorso and leftUpperLeg and leftLowerLeg and leftFoot then
    local legHeight = leftUpperLeg.Size.Y + leftLowerLeg.Size.Y + leftFoot.Size.Y
    local torsoHalf = lowerTorso.Size.Y / 2
    local correctHipHeight = torsoHalf + legHeight

    print("HipHeight calculado: " .. correctHipHeight)
    print("Diferença: " .. math.abs(humanoid.HipHeight - correctHipHeight))
    print("")
    print("Componentes:")
    print("  LowerTorso.Y/2: " .. torsoHalf)
    print("  LeftUpperLeg.Y: " .. leftUpperLeg.Size.Y)
    print("  LeftLowerLeg.Y: " .. leftLowerLeg.Size.Y)
    print("  LeftFoot.Y: " .. leftFoot.Size.Y)
end

-- 3. Verificar posição e distância do chão
if hrp and leftFoot then
    print("")
    print("Posições:")
    print("  HRP.Y: " .. hrp.Position.Y)
    print("  LeftFoot.Y: " .. leftFoot.Position.Y)
    print("  Distância pé até HRP: " .. (hrp.Position.Y - leftFoot.Position.Y))

    -- Raycast para encontrar o chão
    local rayOrigin = leftFoot.Position
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {npc}

    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if rayResult then
        print("  Chão detectado em Y: " .. rayResult.Position.Y)
        print("  Distância pé até chão: " .. (leftFoot.Position.Y - rayResult.Position.Y))
    else
        print("  ❌ Chão não detectado!")
    end
end

-- 4. Verificar propriedades dos pés
print("")
print("Propriedades dos pés:")
if leftFoot then
    print("  LeftFoot.CanCollide: " .. tostring(leftFoot.CanCollide))
    print("  LeftFoot.Size: " .. tostring(leftFoot.Size))
end
if rightFoot then
    print("  RightFoot.CanCollide: " .. tostring(rightFoot.CanCollide))
    print("  RightFoot.Size: " .. tostring(rightFoot.Size))
end

-- 5. Verificar se há scripts interferindo
print("")
print("Scripts no NPC:")
for _, child in pairs(npc:GetDescendants()) do
    if child:IsA("BaseScript") and child.Enabled then
        print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
end

print("")
print("=== FIM DO DIAGNÓSTICO ===")
