# Quick NPC Setup - Cole no Command Bar

## Opção 1: Nextbot Simples (Recomendado)

Cole no **Command Bar** do Studio e pressione Enter:

```lua
-- NEXTBOT AUTOMÁTICO
local assetId = 10572519924 -- Nextbot do Creator Store

local InsertService = game:GetService("InsertService")
local success, model = pcall(function()
    return InsertService:LoadAsset(assetId)
end)

if success and model then
    local npc = model:GetChildren()[1]
    if npc then
        npc.Name = "Buff Noob"
        npc.Parent = workspace

        -- Posicionar na arena
        if npc.PrimaryPart then
            npc:SetPrimaryPartCFrame(CFrame.new(0, 30, 600))
        elseif npc:FindFirstChild("HumanoidRootPart") then
            npc.HumanoidRootPart.CFrame = CFrame.new(0, 30, 600)
        end

        print("✅ NPC Nextbot criado com sucesso!")
    end
    model:Destroy()
else
    warn("❌ Falha ao carregar asset. Tente manualmente pelo Toolbox.")
end
```

## Opção 2: Identity Nextbot (Mais Realista)

```lua
-- IDENTITY NEXTBOT
local assetId = 14237262120

local InsertService = game:GetService("InsertService")
local success, model = pcall(function()
    return InsertService:LoadAsset(assetId)
end)

if success and model then
    local npc = model:GetChildren()[1]
    if npc then
        npc.Name = "Buff Noob"
        npc.Parent = workspace

        if npc.PrimaryPart then
            npc:SetPrimaryPartCFrame(CFrame.new(0, 30, 600))
        elseif npc:FindFirstChild("HumanoidRootPart") then
            npc.HumanoidRootPart.CFrame = CFrame.new(0, 30, 600)
        end

        print("✅ NPC Identity Nextbot criado!")
    end
    model:Destroy()
else
    warn("❌ Erro. Use Toolbox: pesquise 'Identity Nextbot'")
end
```

## Opção 3: Método Manual (100% Funciona)

Se os scripts acima não funcionarem (permissões):

1. **Abra Toolbox** (View → Toolbox)
2. **Pesquise:**
   - "nextbot"
   - "R15 character"
   - "brainrot"
3. **Arraste para Workspace**
4. **Renomeie para:** `Buff Noob`
5. **Mova para posição:** X=0, Y=30, Z=600
6. **Stop + Play**

## Opção 4: Usar Avatar do Jogo

Cole no Command Bar:

```lua
-- USA O PRÓPRIO AVATAR DO PLAYER
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]

if player and player.Character then
    local npc = player.Character:Clone()
    npc.Name = "Buff Noob"

    -- Remove player-specific stuff
    for _, child in pairs(npc:GetChildren()) do
        if child:IsA("Script") or child:IsA("LocalScript") then
            child:Destroy()
        end
    end

    npc.Parent = workspace
    npc:MoveTo(Vector3.new(0, 30, 600))

    print("✅ NPC criado baseado no seu avatar!")
end
```

## Verificar se Funcionou

Depois de criar o NPC, rode no Command Bar:

```lua
local npc = workspace:FindFirstChild("Buff Noob")
if npc then
    print("✅ NPC encontrado!")
    print("   Humanoid: " .. tostring(npc:FindFirstChild("Humanoid")))
    print("   HRP: " .. tostring(npc:FindFirstChild("HumanoidRootPart")))
    print("   Position: " .. tostring(npc.PrimaryPart and npc.PrimaryPart.Position))
else
    warn("❌ NPC não encontrado! Nome correto: 'Buff Noob'")
end
```

## Asset IDs Úteis

- `637633533` - R15 Model (básico)
- `1220029096` - Updated R15 Model
- `10572519924` - Nextbot (simples)
- `14237262120` - Identity Nextbot (realista)
- `11119759274` - Customizable Nextbot

## Troubleshooting

**"LoadAsset is not allowed":**
- Use Método Manual (Toolbox)

**"Asset não encontrado":**
- O asset pode ter sido deletado
- Pesquise no Toolbox manualmente

**NPC aparece mas não se move:**
- Verifique se tem Humanoid
- Verifique se HumanoidRootPart.Anchored = false
- Stop + Play para reiniciar scripts

---

**Após criar o NPC, Stop + Play para o NoobNpcAI detectar!**
