-- COMMAND BAR: TESTE VISUAL DE HIPHEIGHT
-- Cole enquanto o jogo está rodando e ajuste até os pés ficarem NO chão

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then warn("NPC não encontrado!") return end

local humanoid = npc:FindFirstChildOfClass("Humanoid")
local hrp = npc:FindFirstChild("HumanoidRootPart")
local leftFoot = npc:FindFirstChild("LeftFoot")

-- TESTE 1: Valores atuais
print("=== VALORES ATUAIS ===")
print("HipHeight atual: " .. humanoid.HipHeight)
print("HRP Position.Y: " .. hrp.Position.Y)
if leftFoot then
    print("LeftFoot Position.Y: " .. leftFoot.Position.Y)

    -- Raycast para encontrar o chão
    local rayOrigin = leftFoot.Position + Vector3.new(0, 1, 0)
    local rayDirection = Vector3.new(0, -10, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {npc}

    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if rayResult then
        local groundY = rayResult.Position.Y
        local footHeight = leftFoot.Position.Y - groundY
        print("Chão está em Y: " .. groundY)
        print("Pé está a " .. footHeight .. " studs do chão")

        if footHeight < -0.1 then
            print("❌ PÉ AFUNDADO! (negativo = dentro do chão)")
            local correction = math.abs(footHeight) + 0.2
            print("💡 CORREÇÃO NECESSÁRIA: +" .. correction .. " no HipHeight")
            print("")
            print("TESTE ESTE VALOR:")
            print("humanoid.HipHeight = " .. (humanoid.HipHeight + correction))
        elseif footHeight > 0.5 then
            print("⚠️ PÉ FLUTUANDO!")
        else
            print("✅ PÉ NO LUGAR CERTO!")
        end
    end
end

-- TESTE 2: Testar valores diferentes automaticamente
print("")
print("=== TESTE INTERATIVO ===")
print("Cole estes comandos para testar:")
print("")
print("-- AUMENTAR HipHeight (+1):")
print("workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight = workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight + 1")
print("")
print("-- DIMINUIR HipHeight (-1):")
print("workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight = workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight - 1")
print("")
print("-- VER VALOR ATUAL:")
print("print(workspace['Buff Noob']:FindFirstChildOfClass('Humanoid').HipHeight)")
