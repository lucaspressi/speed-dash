-- COMMAND BAR: FIX IMEDIATO - AUTO AJUSTA HIPHEIGHT
-- Cole enquanto jogo está rodando para corrigir automaticamente

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then warn("❌ NPC não encontrado!") return end

local humanoid = npc:FindFirstChildOfClass("Humanoid")
local hrp = npc:FindFirstChild("HumanoidRootPart")
local leftFoot = npc:FindFirstChild("LeftFoot")
local rightFoot = npc:FindFirstChild("RightFoot")

if not humanoid or not hrp or not leftFoot then
    warn("❌ Componentes não encontrados!")
    return
end

-- Método: Medir a distância real das pernas usando Motor6D
local function calculateLegHeight()
    local lowerTorso = npc:FindFirstChild("LowerTorso")
    local leftUpperLeg = npc:FindFirstChild("LeftUpperLeg")
    local leftLowerLeg = npc:FindFirstChild("LeftLowerLeg")

    if not lowerTorso or not leftUpperLeg or not leftLowerLeg or not leftFoot then
        return nil
    end

    -- Somar as distâncias reais dos Motor6D
    local legHeight = 0

    -- LeftHip Motor6D (LowerTorso -> LeftUpperLeg)
    local hip = leftUpperLeg:FindFirstChild("LeftHip")
    if hip then
        legHeight = legHeight + math.abs(hip.C0.Y) + math.abs(hip.C1.Y)
    else
        legHeight = legHeight + leftUpperLeg.Size.Y
    end

    -- LeftKnee Motor6D (LeftUpperLeg -> LeftLowerLeg)
    local knee = leftLowerLeg:FindFirstChild("LeftKnee")
    if knee then
        legHeight = legHeight + math.abs(knee.C0.Y) + math.abs(knee.C1.Y)
    else
        legHeight = legHeight + leftLowerLeg.Size.Y
    end

    -- LeftAnkle Motor6D (LeftLowerLeg -> LeftFoot)
    local ankle = leftFoot:FindFirstChild("LeftAnkle")
    if ankle then
        legHeight = legHeight + math.abs(ankle.C0.Y) + math.abs(ankle.C1.Y)
    else
        legHeight = legHeight + leftFoot.Size.Y
    end

    return legHeight
end

-- Método 1: Usar raycast do pé até o chão para calcular correção
local rayOrigin = leftFoot.Position + Vector3.new(0, 2, 0)
local rayDirection = Vector3.new(0, -15, 0)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {npc}

local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

if rayResult then
    local groundY = rayResult.Position.Y
    local footBottomY = leftFoot.Position.Y - (leftFoot.Size.Y / 2)
    local sinkAmount = groundY - footBottomY

    print("=== DIAGNÓSTICO ===")
    print("Chão em Y: " .. groundY)
    print("Fundo do pé em Y: " .. footBottomY)
    print("Afundamento: " .. sinkAmount .. " studs")

    if sinkAmount > 0.1 then
        -- Pé está afundado
        local correction = sinkAmount + 0.3  -- +0.3 de margem
        local newHipHeight = humanoid.HipHeight + correction

        print("❌ PÉ AFUNDADO!")
        print("HipHeight atual: " .. humanoid.HipHeight)
        print("Correção necessária: +" .. correction)
        print("Novo HipHeight: " .. newHipHeight)

        humanoid.HipHeight = newHipHeight
        print("✅ HipHeight AJUSTADO! Teste agora.")
    elseif sinkAmount < -0.5 then
        -- Pé está flutuando
        local correction = math.abs(sinkAmount) - 0.3
        local newHipHeight = humanoid.HipHeight - correction

        print("⚠️ PÉ FLUTUANDO!")
        print("HipHeight atual: " .. humanoid.HipHeight)
        print("Correção necessária: -" .. correction)
        print("Novo HipHeight: " .. newHipHeight)

        humanoid.HipHeight = newHipHeight
        print("✅ HipHeight AJUSTADO! Teste agora.")
    else
        print("✅ PÉS NO LUGAR CERTO!")
        print("HipHeight atual: " .. humanoid.HipHeight)
    end

    -- Método 2: Calcular altura das pernas por Motor6D
    local legHeight = calculateLegHeight()
    if legHeight then
        print("")
        print("=== ANÁLISE ALTERNATIVA (Motor6D) ===")
        print("Altura total das pernas: " .. legHeight)
        local lowerTorso = npc:FindFirstChild("LowerTorso")
        if lowerTorso then
            local theoreticalHipHeight = (lowerTorso.Size.Y / 2) + legHeight
            print("HipHeight teórico: " .. theoreticalHipHeight)
            print("Diferença do atual: " .. (theoreticalHipHeight - humanoid.HipHeight))
        end
    end
else
    warn("❌ Não consegui detectar o chão!")
end

-- Garantir física dos pés
leftFoot.CanCollide = true
leftFoot.Massless = false
if rightFoot then
    rightFoot.CanCollide = true
    rightFoot.Massless = false
end

print("")
print("💡 Se ainda não funcionar, cole no Command Bar:")
print("workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight = [VALOR]")
