# 🔥 BRUTAL REFACTOR - Production Ready

## Phase 0: Inventory (Current State)

### Scripts Count
- **Server**: 17 scripts
- **Client**: 4 scripts  
- **Shared**: 3 modules
- **Total Lines**: 6,891

### Critical Issues Found

**BLOCKERS:**
1. ✅ 28 infinite `WaitForChild()` calls (no timeout)
2. ✅ 423 print statements (massive log spam)
3. ✅ CoreTextureSystem spamming nil errors
4. ✅ DataStore queue warnings (saving too often)
5. ✅ UI not updating (UIHandler blocking forever)

**MAJOR:**
6. Duplicated treadmill logic (TreadmillConfig + TreadmillRegistry + TreadmillZoneHandler)
7. No single entrypoint (17 server scripts all run independently)
8. Client/server boundary violations (client setting attributes)
9. No centralized config (values scattered across files)
10. ProgressionValidator running despite being disabled

**MINOR:**
11. Test scripts enabled in production
12. Debug logs everywhere
13. Inconsistent naming (init.client vs ClientBootstrap)

---

## Phase 1: Immediate Fixes (Stop the Bleeding)

### Fix #1: CoreTextureSystem Nil Errors

**File:** `src/server/CleanupBadScripts.server.lua`

**Problem:** CoreTextureSystem (from free model) spamming `attempt to index nil with 'Value'`

**Solution:**
```lua
-- Search ENTIRE workspace recursively and disable
for _, descendant in ipairs(workspace:GetDescendants()) do
    if descendant.Name == "CoreTextureSystem" and descendant:IsA("Script") then
        descendant.Disabled = true
        descendant:Destroy()  -- Remove completely
    end
end
```

### Fix #2: Infinite WaitForChild Calls

**Files:** ALL client scripts

**Problem:** 28 calls like `ReplicatedStorage:WaitForChild("Remotes")` with no timeout

**Solution Pattern:**
```lua
-- ❌ BEFORE (infinite yield)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ✅ AFTER (graceful exit)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    warn("[Script] Remotes not found - exiting gracefully")
    return
end
```

**Apply to:**
- `UIHandler.lua` (10 calls)
- `ClientBootstrap.client.lua` (8 calls)
- All other client scripts

### Fix #3: DataStore Spam

**File:** `src/server/SpeedGameServer.server.lua`

**Problem:** Saving on every XP update → queue warnings

**Current:**
```lua
-- UpdateSpeed handler saves EVERY TIME
data.XP += xpGain
saveAll(player, data, "xp_update")  -- SPAM!
```

**Solution:**
```lua
-- Add dirty flag + debouncing
local PlayerDataDirty = {}  -- track which players need save

-- In UpdateSpeed handler:
data.XP += xpGain
PlayerDataDirty[player.UserId] = true  -- mark dirty
-- Don't save immediately

-- Auto-save loop (separate):
task.spawn(function()
    while true do
        task.wait(60)  -- every 60 seconds
        for userId, isDirty in pairs(PlayerDataDirty) do
            if isDirty then
                local player = Players:GetPlayerByUserId(userId)
                if player and PlayerData[userId] then
                    saveAll(player, PlayerData[userId], "autosave")
                    PlayerDataDirty[userId] = false
                end
            end
        end
    end
end)

-- Still save immediately on level up:
if data.Level > oldLevel then
    saveAll(player, data, "level_up")
    PlayerDataDirty[player.UserId] = false
end
```

---

## Phase 2: New Architecture

### Directory Structure

```
src/
├── client/
│   └── ClientBootstrap.client.lua    # SINGLE entrypoint
│
├── server/
│   ├── ServerBootstrap.server.lua    # SINGLE entrypoint (NEW)
│   ├── core/                          # Core systems (NEW)
│   │   ├── PlayerDataService.lua     # DataStore2 wrapper
│   │   ├── ProgressionService.lua    # XP/levels
│   │   └── TreadmillService.lua      # Zone detection
│   ├── features/                      # Optional features (NEW)
│   │   ├── LeaderboardService.lua
│   │   └── RebirthService.lua
│   └── setup/                         # Init only (NEW)
│       └── RemotesSetup.lua
│
├── shared/
│   ├── Config.lua                     # SINGLE SOURCE OF TRUTH (NEW)
│   ├── ProgressionMath.lua
│   └── Remotes.lua                    # Remote names
│
└── tests/                             # Disabled by default (NEW)
    ├── SystemValidator.server.lua
    └── ProgressionValidator.server.lua
```

### New default.project.json

```json
{
  "name": "speed-dash",
  "tree": {
    "$className": "DataModel",

    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/shared"
      }
    },

    "ServerScriptService": {
      "$className": "ServerScriptService",
      "ServerBootstrap": {
        "$path": "src/server/ServerBootstrap.server.lua"
      },
      "core": {
        "$className": "Folder",
        "$path": "src/server/core"
      },
      "features": {
        "$className": "Folder",
        "$path": "src/server/features"
      },
      "setup": {
        "$className": "Folder",
        "$path": "src/server/setup"
      },
      "DataStore2": {
        "$path": "src/server/DataStore2.rbxm"
      }
    },

    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$path": "src/client"
      }
    },

    "Workspace": {
      "$properties": {
        "FilteringEnabled": true
      }
    }
  }
}
```

---

## Phase 3: Migration Steps

### Step 1: Create Config (No Breaking Changes)

Create `src/shared/Config.lua`:
```lua
return {
    DEBUG_MODE = false,  -- MUST be false in production
    
    Progression = {
        BASE_XP = 1,
        FORMULA = { BASE = 20000, SCALE = 500, EXPONENT = 1.65 }
    },
    
    Treadmills = {
        FREE = { Multiplier = 1, ProductId = 0 },
        GOLD = { Multiplier = 3, ProductId = 3510639799 },
        BLUE = { Multiplier = 9, ProductId = 3510662188 },
        PURPLE = { Multiplier = 25, ProductId = 3510662405 }
    },
    
    DataStore = {
        AUTO_SAVE_INTERVAL = 60,
        SAVE_ON_LEVEL_UP = true
    }
}
```

### Step 2: Fix Immediate Blockers

1. Apply Fix #1 (CoreTextureSystem)
2. Apply Fix #2 (WaitForChild timeouts)  
3. Apply Fix #3 (DataStore debouncing)

**Files to patch:**
- `CleanupBadScripts.server.lua`
- `UIHandler.lua`
- `ClientBootstrap.client.lua`
- `SpeedGameServer.server.lua`

### Step 3: Create Services (Parallel with Old Code)

Extract logic from `SpeedGameServer.server.lua`:

**Create `PlayerDataService.lua`:**
- Move DataStore2 logic
- Add debouncing
- Clean API: `getData()`, `addXP()`, `save()`

**Create `ProgressionService.lua`:**
- Move XP calculation
- Move level-up logic
- Use ProgressionMath module

**Create `TreadmillService.lua`:**
- Already exists, just move to `core/`

### Step 4: Create Bootstrap

**Create `ServerBootstrap.server.lua`:**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

-- Phase 1: Setup
local RemotesSetup = require(script.Parent.setup.RemotesSetup)
RemotesSetup.init()

-- Phase 2: Core Services
local PlayerDataService = require(script.Parent.core.PlayerDataService)
local ProgressionService = require(script.Parent.core.ProgressionService)
local TreadmillService = require(script.Parent.core.TreadmillService)

PlayerDataService.init()
ProgressionService.init()
TreadmillService.init()

-- Phase 3: Features
local LeaderboardService = require(script.Parent.features.LeaderboardService)
LeaderboardService.init()

if Config.DEBUG_MODE then
    print("[ServerBootstrap] All systems online")
end
```

### Step 5: Update default.project.json

Point to new structure, disable old scripts.

### Step 6: Test & Validate

Run `SystemValidator.server.lua` to verify:
- All services load
- No infinite yields
- DataStore not spamming
- XP/levels working

### Step 7: Cleanup

Delete deprecated files:
- `SmokeTest.server.lua`
- `TestClient.client.lua`
- `ClientTestListener.server.lua`
- `DebugLogExporter.client.lua`
- Any disabled scripts

---

## Phase 4: Verification Checklist

### Expected Explorer Tree

```
ReplicatedStorage
└── Shared
    ├── Config
    ├── ProgressionMath
    └── Remotes

ServerScriptService
├── ServerBootstrap
├── core/
│   ├── PlayerDataService
│   ├── ProgressionService
│   └── TreadmillService
├── features/
│   ├── LeaderboardService
│   └── RebirthService
├── setup/
│   └── RemotesSetup
└── DataStore2

StarterPlayer
└── StarterPlayerScripts
    └── ClientBootstrap
```

### Expected Logs (Clean, No Spam)

```
[ServerBootstrap] Initializing...
[RemotesSetup] Created 10 RemoteEvents
[PlayerDataService] Ready
[ProgressionService] Ready
[TreadmillService] Registered 3 zones
[LeaderboardService] Ready
[ServerBootstrap] All systems online
```

### Tests Must Pass

- [ ] Player joins: leaderstats created within 2s
- [ ] Walk on treadmill: XP increases
- [ ] Level up: save happens immediately
- [ ] Auto-save: runs every 60s, only if dirty
- [ ] DataStore: NO "queue" warnings in 5min test
- [ ] Leaderboard: updates every 60s
- [ ] UI: updates when XP changes
- [ ] No infinite yield warnings
- [ ] No nil deref errors
- [ ] Print statements < 10 per minute

---

## Phase 5: Files Changed Summary

### DELETED
- SmokeTest.server.lua
- TestClient.client.lua
- ClientTestListener.server.lua
- DebugLogExporter.client.lua
- AxeController.server.lua (if unused)
- RollingBallController.server.lua
- MapSanitizer.server.lua
- NoobNpcAI.server.lua (if unused)

### CREATED
- shared/Config.lua
- server/ServerBootstrap.server.lua
- server/core/PlayerDataService.lua
- server/core/ProgressionService.lua
- server/features/LeaderboardService.lua
- server/features/RebirthService.lua
- server/setup/RemotesSetup.lua

### MODIFIED
- server/CleanupBadScripts.server.lua (better search)
- client/UIHandler.lua (add timeouts)
- client/ClientBootstrap.client.lua (add timeouts)
- server/SpeedGameServer.server.lua (debounce saves)
- default.project.json (new structure)

### MOVED
- server/TreadmillService.server.lua → server/core/TreadmillService.lua
- server/LeaderboardUpdater.server.lua → server/features/LeaderboardService.lua
- tests/SystemValidator.server.lua (keep for validation)
- tests/ProgressionValidator.server.lua (keep for math tests)

---

## Timeline

- **Immediate (15 min)**: Apply 3 critical fixes
- **Phase 1 (1 hour)**: Create Config + Services  
- **Phase 2 (1 hour)**: Create Bootstrap, migrate logic
- **Phase 3 (30 min)**: Update project.json, test
- **Phase 4 (30 min)**: Cleanup, final validation

**Total: ~3.5 hours for production-ready refactor**

---

## Success Metrics

| Metric | Before | After Target |
|--------|--------|--------------|
| Server FPS | Unknown | > 55 |
| DataStore queue warnings | Many | 0 |
| Print statements/min | 423+ | < 10 |
| Infinite yields | 28 | 0 |
| Nil deref errors | Multiple | 0 |
| Player join time | Unknown | < 3s |
| Scripts in prod | 24 | 8 |
