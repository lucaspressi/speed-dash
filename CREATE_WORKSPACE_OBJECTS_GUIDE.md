# Guia: Criar Objetos Faltantes no Workspace

## 🚨 Problema

Os scripts dependem de objetos no Workspace que não existem. Se faltarem, os sistemas não funcionam.

---

## ✅ Como Verificar

**No Studio ou Produção:**

Cole e rode no Command Bar (ou Console F9 > Server):

```lua
-- Cole todo conteúdo de: CHECK_WORKSPACE_OBJECTS.lua
```

Isso vai mostrar **exatamente** o que está faltando.

---

## 📦 Objetos Necessários

### 1. **Buff Noob** (NPC)

**O que é:** O NPC que patrulha e persegue jogadores na Stage 2

**Como criar:**

1. Abra Roblox Studio
2. **Insert** (Home tab) > **Rig** > **R15** (ou R6)
3. O rig vai aparecer no Workspace
4. **Renomeie para:** `Buff Noob` (nome exato!)
5. **(Opcional)** Customize a aparência:
   - Mude as cores dos body parts
   - Adicione acessórios
   - Escale o tamanho (Scale tool)

**Verificação:**
- Deve ter: `Humanoid`, `HumanoidRootPart`, `Head`
- Todos os rigs do Roblox já vêm com esses

---

### 2. **Stage2NpcKill** (Pasta com Parts)

**O que é:** Define a área onde o NPC pode patrulhar

**Como criar:**

1. No Workspace, clique com botão direito
2. **Insert Object** > **Folder**
3. **Renomeie para:** `Stage2NpcKill`
4. Dentro dessa pasta, adicione **Parts**:
   - Insert > **Part**
   - Posicione os Parts para formar a área de patrulha
   - Pode usar vários Parts para definir limites
5. O NPC vai patrulhar dentro dos limites formados por esses Parts

**Dica:**
- Use Parts invisíveis (Transparency = 1)
- CanCollide = false para não atrapalhar jogadores
- Posicione os Parts formando um retângulo ao redor da Stage 2

**Exemplo:**
```
Stage2NpcKill (Folder)
  ├─ BoundaryPart1 (Part) - Canto superior esquerdo
  ├─ BoundaryPart2 (Part) - Canto superior direito
  ├─ BoundaryPart3 (Part) - Canto inferior esquerdo
  └─ BoundaryPart4 (Part) - Canto inferior direito
```

---

### 3. **sphere1, sphere2** (Bolas Rolantes)

**O que é:** Obstáculos que rolam e matam jogadores

**Opção 1: Script Automático (RECOMENDADO)**

Cole e rode no Command Bar:

```lua
-- Cole todo conteúdo de: CREATE_MISSING_ROLLING_BALLS.lua
```

**Opção 2: Manual**

1. Insert > **Part**
2. Propriedades:
   - Name: `sphere1`
   - Shape: **Ball**
   - Size: `(6, 6, 6)` ou maior
   - Material: Metal ou Neon
   - Color: Vermelho/Laranja (perigoso!)
   - CanCollide: true
   - Anchored: true (o script controla movimento)
3. Repita para `sphere2`
4. Posicione em locais onde vão rolar

---

### 4. **BallRollPart1, BallRollPart2** (Trilhos das Bolas)

**O que é:** Partes invisíveis que definem o caminho de cada bola

**Como criar:**

1. Insert > **Part**
2. Propriedades:
   - Name: `BallRollPart1`
   - Size: `(4, 1, 100)` - Longo e horizontal
   - Transparency: 1 (invisível)
   - CanCollide: false
   - Anchored: true
3. Posicione onde a `sphere1` deve rolar
4. Repita para `BallRollPart2` e `sphere2`

**Dica:**
- O comprimento (Size.Z) define o quão longe a bola rola
- A bola rola de uma ponta à outra do Part

---

### 5. **SpeedLeaderboard, WinsLeaderboard** (Opcional)

**O que é:** Displays físicos de leaderboard no mapa

**Se NÃO quiser leaderboards no mapa:**
- Desabilite `LeaderboardUpdater.server.lua` no ServerScriptService
- Os jogadores ainda terão leaderstats (Speed/Wins no canto superior direito)

**Se QUISER leaderboards no mapa:**

1. Insert > **Model**
2. Renomeie para `SpeedLeaderboard`
3. Dentro do Model:
   - Adicione um **Part** chamado `ScoreBlock`
   - Dentro do ScoreBlock, adicione um **SurfaceGui** chamado `Leaderboard`
   - Configure a estrutura de TextLabels para mostrar nomes e scores
4. Repita para `WinsLeaderboard`

**Nota:** Isso é complexo. Se não tiver leaderboards físicos, é melhor desabilitar o script.

---

## 🔧 Checklist de Criação

Depois de criar os objetos, verifique:

- [ ] `Buff Noob` existe no Workspace
  - [ ] Tem Humanoid
  - [ ] Tem HumanoidRootPart
  - [ ] Tem Head

- [ ] `Stage2NpcKill` existe no Workspace
  - [ ] É uma Folder
  - [ ] Tem pelo menos 1 Part dentro

- [ ] `sphere1` existe no Workspace
  - [ ] É um Part com Shape = Ball
  - [ ] Anchored = true

- [ ] `sphere2` existe no Workspace
  - [ ] É um Part com Shape = Ball
  - [ ] Anchored = true

- [ ] `BallRollPart1` existe no Workspace
  - [ ] Anchored = true
  - [ ] Transparente

- [ ] `BallRollPart2` existe no Workspace
  - [ ] Anchored = true
  - [ ] Transparente

- [ ] Salvei o arquivo (Ctrl+S)

- [ ] Publiquei (File > Publish to Roblox)

---

## 🎯 Ordem Recomendada

1. **Crie as bolas rolantes** (mais fácil - use o script)
2. **Crie o NPC** (insira um Rig)
3. **Crie a área de patrulha** (Folder com Parts)
4. **Salve e publique**
5. **Teste**

---

## 🐛 Troubleshooting

### "RollingBallController trava o servidor!"

**Problema:** Script tem WaitForChild sem timeout

**Solução temporária:**
1. Abra `RollingBallController.server.lua` no Studio
2. Desabilite o script (Enabled = false)
3. Crie os objetos faltantes
4. Habilite o script novamente

**Solução permanente:**
Vou criar uma versão melhorada do script com timeouts.

### "NoobNPC não aparece mesmo com Buff Noob criado"

**Verifique:**
1. O nome é exato? `Buff Noob` (com espaço, B maiúsculo)
2. Está no Workspace? (não dentro de pasta)
3. Tem Humanoid?
4. NoobNpcAI.server.lua está habilitado?

### "Leaderboard não mostra nada"

**Verifique:**
1. SpeedGameServer.server.lua está habilitado?
2. Player tem leaderstats? (F9 > Explorer > Players > SeuNome > leaderstats)
3. Se não tiver displays físicos, desabilite LeaderboardUpdater.server.lua

---

## 📞 Próximos Passos

1. **Rode:** `CHECK_WORKSPACE_OBJECTS.lua` para ver o que falta
2. **Crie** os objetos faltantes seguindo este guia
3. **Salve** e **Publique**
4. **Teste** em produção
5. Se ainda não funcionar, rode `DIAGNOSE_ALL_SYSTEMS.lua` e me manda o output!

---

## 💡 Dica Final

Use o script `CHECK_WORKSPACE_OBJECTS.lua` **SEMPRE** que publicar o jogo. Ele te avisa se algo está faltando antes de você descobrir jogando! 🚀
