-- COMMAND BAR: FORÇA O NPC A FICAR NO CHÃO (TESTE)
-- Cole enquanto o jogo está rodando

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then warn("NPC não encontrado!") return end

local humanoid = npc:FindFirstChildOfClass("Humanoid")
local hrp = npc:FindFirstChild("HumanoidRootPart")

print("=== FORÇANDO POSIÇÃO DO CHÃO ===")
print("HipHeight: " .. humanoid.HipHeight)

-- Monitor que FORÇA o HRP a ficar na altura correta
game:GetService("RunService").Heartbeat:Connect(function()
    if not hrp or not hrp.Parent then return end

    -- Raycast do HRP para o chão
    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {npc}

    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if rayResult then
        local groundY = rayResult.Position.Y
        local targetY = groundY + humanoid.HipHeight
        local currentY = hrp.Position.Y

        -- Se está muito baixo, FORÇA para cima
        local diff = targetY - currentY
        if math.abs(diff) > 0.5 then
            hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
            warn("CORRIGIDO! Diff: " .. diff)
        end
    end
end)

print("✅ Monitor ativo - NPC será forçado para altura correta")
