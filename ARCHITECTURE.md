# 🏗️ ARCHITECTURE - Speed Dash Treadmill System

**Versão:** 2.0 (PATCH 4 - Server-Authoritative)
**Data:** 2026-01-17

---

## 📐 DESIGN PRINCIPLES

### 1. Server is Source of Truth
- **Server** detecta qual zone o player está
- **Server** determina multiplier baseado em posição
- **Server** valida ownership antes de conceder XP
- **Client** apenas envia steps e exibe UI

### 2. Separation of Concerns
- **TreadmillRegistry:** Spatial indexing de zones (scan no boot)
- **TreadmillService:** Heartbeat loop para detectar posição dos players
- **SpeedGameServer:** Lógica de XP, ownership, DataStore
- **Client:** UX only (prompts, animações, feedback visual)

### 3. Performance First
- Spatial grid (50x50 studs) reduz busca O(n) para O(1)
- Só detecta players em movimento (velocity threshold)
- Cache de última zone conhecida
- Rate limiting em logs (max 1/s por categoria)

---

## 🔄 DATA FLOW

### Boot Sequence:
```
1. TreadmillSetup.server.lua
   → Aplica Attributes em todas as zones
   → Valida configuração

2. TreadmillService.server.lua
   → TreadmillRegistry.scanAndRegister()
   → Scan zones (CollectionService tag ou Attribute)
   → Constrói spatial grid
   → Inicia Heartbeat loop

3. SpeedGameServer.server.lua
   → Aguarda TreadmillService estar pronto
   → Conecta handlers (UpdateSpeedEvent)
```

### Player Join:
```
1. Server: onPlayerAdded()
   → Carrega ownership do DataStore2
   → Seta Attributes do player (TreadmillX3Owned, etc)
   → Envia snapshot via RemoteEvent (após 0.5s)

2. Client: aguarda snapshot (timeout: 5s)
   → Recebe {[3]=true, [9]=false, [25]=true}
   → Atualiza ownership cache
   → NUNCA sobrescreve true com false

3. TreadmillService: initializePlayerState()
   → Cria estado local do player
   → Inicia tracking de posição
```

### Gameplay Loop:
```
[HEARTBEAT - Server]
TreadmillService (a cada 0.15s):
  1. Para cada player em movimento:
  2. GetZoneAtPosition(position) → TreadmillRegistry
  3. Se em zone:
     → Seta player:SetAttribute("CurrentTreadmillMultiplier", mult)
     → Seta player:SetAttribute("OnTreadmill", true)
  4. Se fora de zone:
     → Seta multiplier = 0
     → Seta OnTreadmill = false

[HEARTBEAT - Client]
init.client.luau (a cada frame):
  1. Lê player:GetAttribute("OnTreadmill")
  2. Lê player:GetAttribute("CurrentTreadmillMultiplier")
  3. Se OnTreadmill:
     → Toca animação de corrida
     → Envia UpdateSpeedEvent:FireServer(steps)  // SEM multiplier!
     → Se !hasAccess: mostra prompt de compra
  4. Se walking:
     → Envia UpdateSpeedEvent:FireServer(steps)

[ON_SERVER_EVENT]
SpeedGameServer:
  1. Recebe (player, steps, clientMultiplier_OPTIONAL)
  2. multiplier = TreadmillService.getPlayerMultiplier(player)  // Server-authoritative!
  3. Se clientMultiplier != multiplier: log warning (possível exploit)
  4. Valida ownership baseado em multiplier
  5. Se hasAccess: concede XP
  6. Se !hasAccess: rejeita (client mostra prompt)
```

---

## 📂 FILE STRUCTURE

```
src/
├── server/
│   ├── TreadmillRegistry.lua          [ModuleScript] Spatial indexing
│   ├── TreadmillService.server.lua    [Script] Zone detection loop
│   ├── TreadmillSetup.server.lua      [Script] Config de zones no boot
│   ├── SpeedGameServer.server.lua     [Script] Game loop, XP, DataStore
│   └── TreadmillConfig.lua            [ModuleScript] Configs centralizadas
│
├── client/
│   └── init.client.luau               [LocalScript] UX only
│
└── shared/
    └── TelemetryService.lua           [ModuleScript] Logging (optional)
```

---

## 🔌 API REFERENCE

### TreadmillRegistry (ModuleScript)

```lua
-- Scan e indexação
TreadmillRegistry.scanAndRegister()
  → {scanned: number, valid: number, invalid: number}

-- Query
TreadmillRegistry.getZoneAtPosition(position: Vector3, tolerance: number?)
  → zoneData | nil, zoneInstance | nil

-- zoneData = {
--   Multiplier: number,
--   IsFree: boolean,
--   ProductId: number,
--   ZoneName: string,
--   ZoneInstance: Instance
-- }

-- Debug
TreadmillRegistry.getStats()
TreadmillRegistry.listAll()
TreadmillRegistry.setDebug(enabled: boolean)
```

### TreadmillService (Script → _G API)

```lua
-- Query player state
_G.TreadmillService.getPlayerMultiplier(player: Player)
  → multiplier: number

_G.TreadmillService.isPlayerOnTreadmill(player: Player)
  → boolean

_G.TreadmillService.getPlayerZone(player: Player)
  → zoneData | nil, zoneInstance | nil

-- Debug
_G.TreadmillService.setDebug(enabled: boolean)
_G.TreadmillService.getStats()
_G.TreadmillService.debugPlayer(playerName: string)
```

### Player Attributes (Server → Client sync)

```lua
-- Setados pelo TreadmillService (server-side):
player:GetAttribute("OnTreadmill")                → boolean
player:GetAttribute("CurrentTreadmillMultiplier") → number

-- Setados pelo SpeedGameServer (ownership):
player:GetAttribute("TreadmillX3Owned")  → boolean
player:GetAttribute("TreadmillX9Owned")  → boolean
player:GetAttribute("TreadmillX25Owned") → boolean
```

---

## 🎯 ZONE CONFIGURATION

### Attributes (setados por TreadmillSetup):

```lua
TreadmillZone (BasePart):
  - Multiplier: number      (1, 3, 9, 25)
  - IsFree: boolean         (true para x1, false para pagos)
  - ProductId: number       (0 para free, DevProduct ID para pagos)
```

### CollectionService Tag (opcional):

```
Tag: "TreadmillZone"
```

Se tag não existir, fallback para scan por Attribute "Multiplier".

---

## 🔒 SECURITY

### Exploit Protection:

1. **Multiplier validation:**
   - Client não envia multiplier (PATCH 4)
   - Se enviar, server ignora e usa detecção própria
   - Logs warning se valores divergirem

2. **Ownership validation:**
   - Server valida ownership antes de conceder XP
   - Client cache é read-only (não pode sobrescrever)
   - Snapshot do server é source of truth

3. **Position validation:**
   - Server-side position check (não confia no client)
   - Spatial grid previne false positives
   - Tolerance de 2 studs para bounding box

---

## ⚡ PERFORMANCE

### Benchmarks (estimados):

| Operação | Complexidade | Tempo |
|----------|--------------|-------|
| scanAndRegister() | O(n) | <100ms para 100 zones |
| getZoneAtPosition() | O(1) avg | <0.1ms por query |
| Heartbeat loop | O(p) | <1ms para 50 players |

**p** = número de players
**n** = número de zones

### Optimizations:

- ✅ Spatial grid (50x50) reduz busca de O(n) para O(1)
- ✅ Velocity threshold (só detecta players em movimento)
- ✅ Update interval 0.15s (não todo frame)
- ✅ Rate limiting em logs (max 1/s por categoria)
- ✅ Cache de última zone conhecida

---

## 🐛 DEBUGGING

### Server Console Commands:

```lua
-- Debug player state
_G.TreadmillService.debugPlayer("PlayerName")

-- Get stats
print(_G.TreadmillService.getStats())
print(TreadmillRegistry.getStats())

-- List all zones
TreadmillRegistry.listAll()

-- Toggle debug
_G.TreadmillService.setDebug(true)
TreadmillRegistry.setDebug(true)
```

### Client Attributes (inspect via Properties):

```lua
player:GetAttribute("OnTreadmill")                 -- Should match server
player:GetAttribute("CurrentTreadmillMultiplier")  -- Should match zone
```

---

## 🚀 ROLLBACK PLAN

Se PATCH 4 tiver problemas:

1. **Client-side detection:** Descomentar código em init.client.luau
   - `isOnTreadmill()` function (linha ~602)
   - `setupTreadmills()` function (linha ~860)
   - `task.spawn(setupTreadmills)` (linha ~935)

2. **Server:** Comentar integração com TreadmillService
   - SpeedGameServer.lua: Usar `clientMultiplier` direto (linha ~620)

3. **Remover:** TreadmillService.server.lua e TreadmillRegistry.lua

**Tempo estimado de rollback:** <5 minutos

---

## 📚 RELATED DOCS

- `TREADMILL_FIX_README.md` - Instruções de uso
- `TEAM_ANALYSIS_REPORT.md` - Análise do time de agentes
- `QA_TEST_CHECKLIST.md` - Test suite completo

---

**Arquitetura projetada pelo Time de 6 Agentes (PATCH 4)**
**"Server is source of truth. Client is for UX. Validate everything. Trust nothing."**
