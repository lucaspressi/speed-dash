# ✅ QA TEST CHECKLIST - SPEED DASH TREADMILL SYSTEM

**Versão:** 2.0 (Team-Based Fix)
**Data:** 2026-01-17
**Responsável QA:** Roblox QA Agent

---

## 📋 PRÉ-REQUISITOS

Antes de iniciar os testes:

- [ ] Todos os arquivos foram deployados no Roblox Studio
- [ ] TreadmillConfig.lua está em ServerScriptService
- [ ] TreadmillSetup.server.lua rodou com sucesso (verificar Output)
- [ ] MapSanitizer.server.lua executado e relatório analisado
- [ ] Backup do jogo criado (caso precise rollback)

---

## 🧪 CATEGORIA 1: FREE TREADMILL (x1)

### TC-1.1: Player Novo em Free Zone
**Passos:**
1. Criar conta nova de teste (sem ownership)
2. Entrar no jogo
3. Pisar na FREE treadmill (x1)

**Resultado Esperado:**
- [ ] XP concedido imediatamente
- [ ] Nenhum prompt de compra aparece
- [ ] Logs no Output: `[XP_GAIN] ... treadmillMult=1`
- [ ] Visual +XP aparece no client

**Output Esperado (Server):**
```
[XP_GAIN] PlayerName - steps=1 treadmillMult=1
  WALKING: xpGain=... totalMult=...
```

---

### TC-1.2: Zone FREE com ProductId=0
**Passos:**
1. Inspecionar TreadmillFree/TreadmillZone no Explorer
2. Verificar Attributes:
   - Multiplier = 1
   - IsFree = true
   - ProductId = 0

**Resultado Esperado:**
- [ ] Todos os attributes corretos
- [ ] Nenhum erro no Output sobre "missing ProductId"
- [ ] TreadmillSetup logs: `✓ Zone validated as FREE`

**Output Esperado (Server):**
```
[TREADMILL-FIX] Setting up zone: Workspace.TreadmillFree.TreadmillZone
  Multiplier: 1
  IsFree: true
  ProductId: 0
[TREADMILL-FIX]   ✓ Config applied successfully
```

---

### TC-1.3: Zone FREE sem ProductId (Edge Case)
**Passos:**
1. Criar zone de teste com apenas:
   - Multiplier = 1
   - IsFree = true
   - ProductId = nil

**Resultado Esperado:**
- [ ] TreadmillConfig valida como FREE
- [ ] Nenhum erro no Output
- [ ] Funciona normalmente

---

## 🧪 CATEGORIA 2: PAID TREADMILLS (x3/x9/x25)

### TC-2.1: Player Sem Ownership - GOLD (x3)
**Passos:**
1. Usar conta sem x3 ownership
2. Pisar na GOLD treadmill (x3)

**Resultado Esperado:**
- [ ] Prompt de compra aparece (MarketplaceService)
- [ ] XP **NÃO** é concedido
- [ ] Logs: `BLOCKED: Player doesn't own treadmill x3`

**Output Esperado (Server):**
```
[XP_GAIN] PlayerName - steps=1 treadmillMult=3
  BLOCKED: Player doesn't own treadmill x3
```

---

### TC-2.2: Compra de x3 Durante Gameplay
**Passos:**
1. Pisar na GOLD zone (prompt aparece)
2. Completar compra (usar test product se possível)
3. Pisar novamente na zone

**Resultado Esperado:**
- [ ] Ownership salvo no DataStore2
- [ ] Client recebe RemoteEvent: `TreadmillOwnershipUpdated`
- [ ] Cache do client atualizado: `treadmillOwnershipCache[3] = true`
- [ ] Próxima vez que pisar: XP é concedido
- [ ] **NUNCA** aparece log: `TreadmillX3Owned changed to false`

**Output Esperado (Server):**
```
[PURCHASE] PlayerName successfully purchased Treadmill x3!
  Ownership is now: true
[PURCHASE]   Notified client of ownership for x3
[DATA] SaveAll OK (purchase_treadmill_x3)
```

**Output Esperado (Client):**
```
[CLIENT] TreadmillOwnershipUpdated received: x3 = true
[CLIENT] Ownership cache updated. Can now use x3 treadmill!
```

---

### TC-2.3: Player com x3 Tenta Usar x9 (Sem x9)
**Passos:**
1. Usar conta com x3 mas SEM x9
2. Pisar na BLUE treadmill (x9)

**Resultado Esperado:**
- [ ] Prompt de compra x9 aparece
- [ ] XP **NÃO** é concedido
- [ ] x3 continua funcionando normalmente

---

### TC-2.4: Validação de Multipliers Inválidos (SECURITY)
**Passos:**
1. Usar exploit/script executor (ou simular via Command Bar)
2. Executar: `game.ReplicatedStorage.Remotes.UpdateSpeed:FireServer(1, 999)`

**Resultado Esperado:**
- [ ] Request rejeitado silenciosamente
- [ ] Logs no Output: `[SECURITY] Player ... sent invalid treadmillMultiplier: 999`
- [ ] XP **NÃO** concedido
- [ ] Player não kickado (silent rejection)

**Output Esperado (Server):**
```
[SECURITY] Player ExploiterName sent invalid treadmillMultiplier: 999
[SECURITY]   Possible exploit attempt detected!
[SECURITY]   Valid multipliers: 1, 3, 9, 25
```

---

## 🧪 CATEGORIA 3: OWNERSHIP PERSISTENCE

### TC-3.1: Respawn com Ownership
**Passos:**
1. Comprar x3
2. Verificar que x3 funciona
3. Resetar character (respawn)
4. Pisar novamente na x3

**Resultado Esperado:**
- [ ] Ownership persiste após respawn
- [ ] Attribute `TreadmillX3Owned` ainda = true
- [ ] XP concedido normalmente

---

### TC-3.2: Reconnect com Ownership
**Passos:**
1. Comprar x3
2. Desconectar do jogo
3. Reconectar (mesma conta)
4. Verificar Output server: snapshot enviado
5. Pisar na x3

**Resultado Esperado:**
- [ ] Ownership restaurado do DataStore2
- [ ] Snapshot enviado ao client: `{[3]=true, ...}`
- [ ] Client cache inicializado com true
- [ ] XP concedido normalmente

**Output Esperado (Server):**
```
[PLAYER JOIN] PlayerName joining...
[DATA] PlayerName loaded:
  Treadmill x3: true
[TREADMILL] Sending ownership snapshot to PlayerName:
  x3: true
  x9: false
  x25: false
[TREADMILL] Ownership snapshot sent to PlayerName
```

**Output Esperado (Client):**
```
[CLIENT] Initializing ownership cache from player attributes...
[CLIENT] Initial cache: x3=true x9=false x25=false
[CLIENT] TreadmillOwnershipUpdated received SNAPSHOT:
  x3 = true
  x9 = false
  x25 = false
[CLIENT] Ownership cache fully updated from snapshot!
```

---

### TC-3.3: Server Restart (DataStore Persistence)
**Passos:**
1. Comprar x3
2. Fechar Roblox Studio completamente
3. Reabrir Studio e iniciar jogo
4. Entrar com mesma conta

**Resultado Esperado:**
- [ ] Ownership restaurado do DataStore2
- [ ] Funciona normalmente

---

## 🧪 CATEGORIA 4: SYNC SERVER ↔ CLIENT

### TC-4.1: Snapshot no Player Join
**Passos:**
1. Entrar no jogo (com ownership misto: x3=true, x9=false, x25=true)
2. Observar Output (Server + Client)

**Resultado Esperado:**
- [ ] Server envia snapshot 0.5s após join
- [ ] Client recebe snapshot ANTES de qualquer signal disparar
- [ ] Cache inicializado corretamente
- [ ] **NUNCA** aparece: `changed to false` se server enviou true

---

### TC-4.2: Race Condition Test (Critical)
**Passos:**
1. Criar conta com x3/x9/x25 = true no DataStore
2. Entrar no jogo
3. Verificar logs de inicialização do cache

**Resultado Esperado:**
- [ ] Linha 28-32 init.client: cache inicializa ANTES dos signals (linha 58+)
- [ ] Nenhum log de `changed to false` se DataStore tem true
- [ ] Ordem correta:
   1. `Initializing ownership cache...`
   2. `Initial cache: x3=true ...`
   3. `TreadmillOwnershipUpdated received SNAPSHOT`
   4. Signals disparados (se houver mudança)

---

## 🧪 CATEGORIA 5: MAP VALIDATION

### TC-5.1: Migração de Zone Legada
**Passos:**
1. Criar zone de teste com parent "TreadMill New" (nome não-padrão)
2. Rodar TreadmillSetup.server.lua
3. Verificar logs

**Resultado Esperado:**
- [ ] TreadmillSetup detecta zone órfã
- [ ] Detecta tipo baseado no nome do parent
- [ ] Aplica Attributes automaticamente
- [ ] Logs: `Migrating orphaned zone`

**Output Esperado (Server):**
```
[TREADMILL-FIX] Migrating orphaned zone: Workspace.Esteira1x.TreadMill New.TreadmillZone
[TREADMILL-FIX]   Parent: TreadMill New → Detected as: TreadmillFree
[TREADMILL-FIX]   ✓ Config applied successfully
```

---

### TC-5.2: Detecção de Duplicatas
**Passos:**
1. Executar MapSanitizer.server.lua
2. Analisar relatório no Output

**Resultado Esperado:**
- [ ] Se houver duplicatas: `⚠️ DUPLICATES FOUND`
- [ ] Lista zones com mesma posição
- [ ] Recomendação: remover manualmente

---

### TC-5.3: Zone Sem Attributes
**Passos:**
1. Criar zone completamente vazia (sem Attributes)
2. Rodar TreadmillSetup
3. Tentar usar a zone

**Resultado Esperado:**
- [ ] TreadmillSetup detecta como inválida
- [ ] Tenta migrar (se parent válido)
- [ ] Client **NÃO** detecta zone sem Multiplier
- [ ] Logs warning: `Zone missing Multiplier attribute`

---

## 🧪 CATEGORIA 6: REGRESSÕES

### TC-6.1: Treadmills Pagas Continuam Funcionando
**Passos:**
1. Testar TODOS os 3 treadmills pagos (x3/x9/x25)
2. Com e sem ownership

**Resultado Esperado:**
- [ ] x3 funciona normalmente
- [ ] x9 funciona normalmente
- [ ] x25 funciona normalmente
- [ ] Prompts aparecem corretamente
- [ ] XP calculado corretamente

---

### TC-6.2: DataStore2 Não Corrompeu
**Passos:**
1. Verificar saves funcionando
2. Comprar algo, desconectar, reconectar
3. Verificar Level, XP, Wins, Rebirths

**Resultado Esperado:**
- [ ] Todos os dados persistem
- [ ] Nenhum dado zerado
- [ ] Autosave funcionando (a cada 60s)

---

### TC-6.3: UI Continua Funcionando
**Passos:**
1. Verificar UI:
   - Speed display
   - Level bar
   - Wins counter
   - Rebirth button

**Resultado Esperado:**
- [ ] Todos os elementos funcionam
- [ ] Valores corretos
- [ ] Level up notification aparece

---

### TC-6.4: SpeedBoost Não Quebrou
**Passos:**
1. Comprar SpeedBoost (x2, x4, etc.)
2. Verificar multiplicador
3. Testar em treadmill e walking

**Resultado Esperado:**
- [ ] SpeedBoost aplica corretamente FORA da treadmill
- [ ] **NÃO** aplica dentro da treadmill (comportamento correto)
- [ ] Valores de XP corretos

---

### TC-6.5: WinBlocks Funcionam
**Passos:**
1. Tocar nos WinBlocks (1, 5, 10, 50, 200 wins)
2. Verificar contador de wins

**Resultado Esperado:**
- [ ] Wins concedidos
- [ ] Contador atualizado
- [ ] Visual notification aparece

---

## 🧪 CATEGORIA 7: TELEMETRY (OPTIONAL)

**Se TelemetryService foi integrado:**

### TC-7.1: Logs Estruturados
**Passos:**
1. Verificar Output após jogar 5 minutos
2. Procurar por logs TelemetryService

**Resultado Esperado:**
- [ ] Logs com timestamp
- [ ] Logs com contexto (Player, Zone, Multiplier)
- [ ] Categorias corretas (TREADMILL, OWNERSHIP, etc.)
- [ ] Níveis corretos (INFO, WARNING, ERROR)

---

## 🧪 CATEGORIA 8: PERFORMANCE

### TC-8.1: Client FPS
**Passos:**
1. Habilitar Shift+F3 (stats)
2. Jogar por 10 minutos
3. Observar FPS

**Resultado Esperado:**
- [ ] FPS estável (>30 FPS em devices médios)
- [ ] Sem memory leaks
- [ ] Sem lag spikes quando pisa em treadmill

---

### TC-8.2: Server Performance
**Passos:**
1. Adicionar 10+ players (usar alt accounts ou simular)
2. Verificar Server Stats no Studio

**Resultado Esperado:**
- [ ] Heartbeat estável
- [ ] Memory usage razoável (<1GB)
- [ ] Sem warnings de throttling

---

## ✅ SIGN-OFF FINAL

**Testes Executados:** ___ / ___
**Passed:** ___
**Failed:** ___
**Blocked:** ___

### Critical Bugs (Blocker):
- [ ] Nenhum bug crítico encontrado

### High Priority Bugs:
- [ ] Nenhum bug alto encontrado

### Medium/Low Priority Bugs:
- [ ] (listar se houver)

---

## 🚀 READY FOR PRODUCTION?

- [ ] Todos os testes críticos (CATEGORIA 1-4) passaram
- [ ] Nenhuma regressão detectada (CATEGORIA 6)
- [ ] Performance aceitável (CATEGORIA 8)
- [ ] DEBUG flags desligadas (TreadmillConfig.DEBUG = false)
- [ ] MapSanitizer removido ou desabilitado
- [ ] Backup do jogo criado

**QA Sign-Off:**
Nome: _______________
Data: _______________
Assinatura: _______________

---

**✅ SE TODOS OS CHECKBOXES ESTÃO MARCADOS: APPROVED FOR PRODUCTION**

**❌ SE HOUVER FALHAS: RETURN TO DEV TEAM COM BUG REPORT**
