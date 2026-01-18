# NPC Customization Guide

## Como usar um NPC customizado

O sistema aceita qualquer modelo R15 do Roblox. Aqui está como trocar o NPC padrão:

### Opção 1: Usar modelo do Toolbox (Recomendado)

1. **No Roblox Studio:**
   - Abra o Toolbox (View → Toolbox)
   - Pesquise por modelos R15:
     - "Brainrot"
     - "Tuntuntun Sahur"
     - "Nextbot"
     - Qualquer outro R15 character

2. **Insira no Workspace:**
   - Arraste o modelo para o Workspace
   - **IMPORTANTE:** Renomeie para **"Buff Noob"**

3. **Verifique:**
   - O modelo deve ter:
     - ✅ Humanoid
     - ✅ HumanoidRootPart
     - ✅ R15 body parts

4. **Stop + Play:**
   - O script NpcAutoSpawn vai detectar e usar seu modelo customizado
   - Verá no log: `[NpcAutoSpawn] ✅ Buff Noob already exists (custom model)`

### Opção 2: Usar Asset ID

Se você tiver o Asset ID de um modelo:

1. No Studio, use Insert → Object → Model
2. Ou cole este código no Command Bar:
   ```lua
   local InsertService = game:GetService("InsertService")
   local model = InsertService:LoadAsset(ASSET_ID_AQUI):GetChildren()[1]
   model.Name = "Buff Noob"
   model.Parent = workspace
   ```

### Modelos Compatíveis

**Funcionam:**
- ✅ Qualquer R15 character (padrão do Roblox)
- ✅ Modelos com Humanoid + HumanoidRootPart
- ✅ Nextbots
- ✅ Custom avatars exportados do Avatar Editor

**Não funcionam:**
- ❌ Modelos R6 (sistema requer R15)
- ❌ Modelos sem Humanoid
- ❌ Modelos com scripts internos conflitantes

### Ajustando Escala

Se o NPC ficar muito grande/pequeno:

1. Selecione "Buff Noob" no Workspace
2. Properties → Scale
3. Ajuste o valor (ex: 1.5 para 50% maior)

**Nota:** Velocidades já estão ajustadas para NPCs grandes:
- WalkSpeed = 50
- CHASE_SPEED = 80

### Troubleshooting

**NPC não se move:**
- Verifique se tem HumanoidRootPart
- Verifique se HumanoidRootPart.Anchored = false
- Aumente WalkSpeed no código se necessário

**NPC não aparece:**
- Verifique o nome: deve ser exatamente "Buff Noob"
- Verifique se está no Workspace (não em ServerStorage)

**Animações não funcionam:**
- Alguns modelos customizados podem não ter Animator
- NoobNpcAI cria Animator automaticamente se não existir

### Exemplo: Brainrot NPC

```lua
-- Cole no Command Bar do Studio:
local model = game:GetObjects("rbxassetid://BRAINROT_ID")[1]
model.Name = "Buff Noob"
model.Parent = workspace
model:MoveTo(Vector3.new(0, 30, 600))
```

### Revertendo para Padrão

1. Delete "Buff Noob" do Workspace
2. Stop + Play
3. O script criará um R15 padrão automaticamente

---

**Dica:** Mantenha uma cópia do modelo customizado em ServerStorage para fácil reinstalação!
