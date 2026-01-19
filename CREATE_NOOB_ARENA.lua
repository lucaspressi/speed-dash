-- COMMAND BAR: Criar NoobArena perto do Buff Noob
-- Cole este script no Command Bar do Studio e pressione Enter

local npc = workspace:FindFirstChild("Buff Noob")
if not npc then
    warn("❌ Buff Noob não encontrado!")
    return
end

local npcPos = npc:GetPrimaryPartCFrame().Position or npc:FindFirstChild("HumanoidRootPart").Position

-- Criar Model NoobArena
local arenaModel = Instance.new("Model")
arenaModel.Name = "NoobArena"

-- Criar ArenaBounds (Part invisível que define os limites)
local arenaBounds = Instance.new("Part")
arenaBounds.Name = "ArenaBounds"
arenaBounds.Size = Vector3.new(100, 50, 100)  -- Tamanho inicial (você vai ajustar)
arenaBounds.Position = npcPos + Vector3.new(0, 25, 0)  -- Centralizado no NPC
arenaBounds.Anchored = true
arenaBounds.CanCollide = false
arenaBounds.Transparency = 0.8  -- Semi-transparente para você ver
arenaBounds.Color = Color3.fromRGB(255, 0, 0)  -- Vermelho
arenaBounds.Material = Enum.Material.Neon
arenaBounds.Parent = arenaModel

arenaModel.Parent = workspace

print("✅ NoobArena criada em: " .. tostring(arenaBounds.Position))
print("📏 Tamanho inicial: " .. tostring(arenaBounds.Size))
print("🔧 Ajuste o tamanho e posição nas Properties!")
print("💡 Depois de ajustar, mude Transparency para 1 (invisível)")
