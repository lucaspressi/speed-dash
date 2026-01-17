# Admin Dashboard Discovery - Technical Inventory

**Generated**: 2026-01-17
**Purpose**: Complete technical documentation for building an external admin dashboard to control Roblox game state

---

## Table of Contents
1. [Phase 0: Repository Map](#phase-0-repository-map)
2. [Phase 1: Authoritative State Model](#phase-1-authoritative-state-model)
3. [Phase 2: Admin-Safe Control Points](#phase-2-admin-safe-control-points)
4. [Phase 3: Networking & Remotes](#phase-3-networking--remotes)
5. [Phase 4: Treadmills & Ownership](#phase-4-treadmills--ownership)
6. [Phase 5: Integration Strategy](#phase-5-integration-strategy)

---

## Phase 0: Repository Map

### Core Server Files

| File Path | Type | Purpose | Data Read/Write | Remotes Used |
|-----------|------|---------|----------------|--------------|
| `src/server/SpeedGameServer.server.lua` | Server | Main game logic, DataStore2, player state, dev products | **Writes**: All player data fields; **Reads**: All fields on join | All remotes (creates/handles) |
| `src/server/TreadmillService.server.lua` | Server | Server-authoritative treadmill zone detection | **Reads**: Player position; **Sets**: Player attributes (OnTreadmill, CurrentTreadmillMultiplier) | None (uses _G export) |
| `src/server/RemotesBootstrap.server.lua` | Server | Creates all RemoteEvents/Functions on boot | None | Creates all remotes |
| `src/server/LeaderboardUpdater.server.lua` | Server | Updates ordered leaderboards | **Reads**: leaderstats.Speed | None |
| `src/server/TreadmillSetup.server.lua` | Server | Auto-setup script for treadmill zones | **Writes**: Zone attributes (Multiplier, ProductId, IsFree) | None |
| `src/server/NoobNpcAI.server.lua` | Server | NPC enemy AI | None | NpcKillPlayer, NpcLaserSlowEffect |

### Shared Modules

| File Path | Type | Purpose | Data Read/Write | Remotes Used |
|-----------|------|---------|----------------|--------------|
| `src/shared/ProgressionMath.lua` | Shared | XP/Level calculation formulas | None (pure functions) | None |
| `src/shared/ProgressionConfig.lua` | Shared | Progression constants (formula parameters, anchors) | None (constants) | None |
| `src/server/modules/TreadmillConfig.lua` | Server | Treadmill definitions, ProductId mapping | None (constants) | None |
| `src/server/modules/TreadmillRegistry.lua` | Server | Spatial grid for zone lookup | **Reads**: Zone attributes | None |

### Client Files

| File Path | Type | Purpose | Data Read/Write | Remotes Used |
|-----------|------|---------|----------------|--------------|
| `src/client/ClientBootstrap.client.lua` | Client | Movement detection, treadmill UX, ownership cache | **Reads**: Player attributes (TreadmillXNOwned, OnTreadmill) | UpdateSpeed, UpdateUI, TreadmillOwnershipUpdated, AddWin, EquipStepAward |
| `src/client/UIHandler.lua` | Client | UI rendering (stats, modals, notifications) | **Reads**: Data from UpdateUI | UpdateUI, Rebirth, VerifyGroup, ClaimGift, ShowWin, Prompt* |

### Storage Templates

| File Path | Type | Purpose | Data Read/Write | Remotes Used |
|-----------|------|---------|----------------|--------------|
| `src/storage/templates/TreadmillZoneHandler.lua` | Template | Validates zone configuration (attached to zones) | **Reads**: Zone attributes | None |

---

## Phase 1: Authoritative State Model

### A) Player Persistent Data Schema

**DataStore Key**: `"SpeedGameData"`
**Implementation**: DataStore2 with combined stores (SpeedGameServer.server.lua:73-79)

```json
{
  "datastore_name": "SpeedGameData",
  "schema": {
    "TotalXP": "number",
    "Level": "number",
    "XP": "number",
    "Wins": "number",
    "Rebirths": "number",
    "Multiplier": "number",
    "StepBonus": "number",
    "GiftClaimed": "boolean",
    "TreadmillX3Owned": "boolean",
    "TreadmillX9Owned": "boolean",
    "TreadmillX25Owned": "boolean",
    "SpeedBoostLevel": "number",
    "WinBoostLevel": "number"
  },
  "default_values": {
    "TotalXP": 0,
    "Level": 1,
    "XP": 0,
    "Wins": 0,
    "Rebirths": 0,
    "Multiplier": 1,
    "StepBonus": 1,
    "GiftClaimed": false,
    "TreadmillX3Owned": false,
    "TreadmillX9Owned": false,
    "TreadmillX25Owned": false,
    "SpeedBoostLevel": 0,
    "WinBoostLevel": 0
  }
}
```

**Save Logic**:
- Auto-save: Every 60 seconds (SpeedGameServer.server.lua:389-400)
- On player leave (SpeedGameServer.server.lua:368-383)
- On game shutdown via BindToClose (SpeedGameServer.server.lua:402-419)
- After important events (purchase, rebirth, level up, win)
- Debouncing: No explicit debounce, but saves are atomic per-key via DataStore2

**Migrations**: None currently implemented

**Source Code References**:
- DataStore2 initialization: SpeedGameServer.server.lua:70-79
- Default data: SpeedGameServer.server.lua:167-181
- getStores(): SpeedGameServer.server.lua:183-199
- getPlayerData(): SpeedGameServer.server.lua:201-216
- savePlayerData(): SpeedGameServer.server.lua:218-226
- saveAll(): SpeedGameServer.server.lua:229-251

---

### B) Runtime State

**leaderstats Folder** (created per player):
- **Speed** (IntValue): Displays `TotalXP` value
- **Wins** (IntValue): Displays `Wins` value

**Player Attributes** (server-authoritative):
| Attribute Name | Type | Purpose | Set By |
|----------------|------|---------|--------|
| `TreadmillX3Owned` | boolean | Owns x3 treadmill | SpeedGameServer (on join, purchase) |
| `TreadmillX9Owned` | boolean | Owns x9 treadmill | SpeedGameServer (on join, purchase) |
| `TreadmillX25Owned` | boolean | Owns x25 treadmill | SpeedGameServer (on join, purchase) |
| `OnTreadmill` | boolean | Currently on any treadmill | TreadmillService |
| `TreadmillMultiplier` | number | Current treadmill multiplier (1/3/9/25) | SpeedGameServer |
| `CurrentTreadmillMultiplier` | number | Real-time multiplier from position | TreadmillService |

**Source of Truth Hierarchy**:
1. **DataStore** = persistent source of truth (survives server restart)
2. **PlayerData table** (server RAM) = runtime cache (SpeedGameServer.server.lua:114)
3. **leaderstats** = UI display only (derived from PlayerData)
4. **Attributes** = sync mechanism for client + cross-script communication

**⚠️ CRITICAL**: Admin changes MUST update all three layers:
1. Update `PlayerData[userId]` in server RAM
2. Call `savePlayerData()` to persist to DataStore2
3. Update `leaderstats` values
4. Fire `UpdateUI` RemoteEvent to client
5. Update relevant attributes

---

## Phase 2: Admin-Safe Control Points

### Action 1: Set Player Speed (TotalXP)

**Function**: Direct modification of `data.TotalXP` + recalculate Level from TotalXP

**Location**: SpeedGameServer.server.lua:201-216 (getPlayerData), :218-226 (savePlayerData)

**Admin-Safe Implementation**:
```lua
-- Pseudo-code for admin endpoint
function setPlayerSpeed(userId, newTotalXP)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    -- Set TotalXP
    data.TotalXP = math.max(0, newTotalXP)

    -- Recalculate Level and XP from TotalXP using ProgressionMath
    local level, xpIntoLevel, xpRequired = ProgressionMath.LevelFromTotalXP(data.TotalXP)
    data.Level = level
    data.XP = xpIntoLevel
    data.XPRequired = xpRequired

    -- Update walk speed
    updateWalkSpeed(player, data)

    -- Sync to client and leaderstats
    UpdateUIEvent:FireClient(player, data)
    updateLeaderstats(player, data)

    -- Persist
    saveAll(player, data, "admin_set_speed")

    return {success = true}
end
```

**Validation**: `newTotalXP >= 0`

**Derived Values**: Level, XP, XPRequired, WalkSpeed (auto-recalculated)

**Reference**: ProgressionMath.LevelFromTotalXP (ProgressionMath.lua:63-90)

---

### Action 2: Set Player Level and XP

**Function**: Set Level + XP directly OR derive TotalXP from Level+XP

**Location**: SpeedGameServer.server.lua:881-884 (admin adjust level)

**Admin-Safe Implementation**:
```lua
function setPlayerLevel(userId, newLevel, newXP)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    -- Clamp to valid ranges
    newLevel = math.clamp(newLevel, 1, 10000)

    -- Calculate XPRequired for this level
    local xpRequired = ProgressionMath.XPRequired(newLevel)

    -- Clamp XP to valid range [0, xpRequired)
    newXP = math.clamp(newXP or 0, 0, xpRequired - 1)

    -- Calculate TotalXP from Level+XP
    local totalXPToReachLevel = ProgressionMath.TotalXPToReachLevel(newLevel)
    data.TotalXP = totalXPToReachLevel + newXP

    -- Set Level/XP
    data.Level = newLevel
    data.XP = newXP
    data.XPRequired = xpRequired

    -- Update walk speed
    updateWalkSpeed(player, data)

    -- Sync
    UpdateUIEvent:FireClient(player, data)
    updateLeaderstats(player, data)
    saveAll(player, data, "admin_set_level")

    return {success = true}
end
```

**Validation**:
- Level: 1 to 10000
- XP: 0 to (XPRequired - 1)

**Derived Values**: TotalXP (calculated from Level+XP), XPRequired, WalkSpeed

---

### Action 3: Grant/Remove Wins

**Function**: Increment or set Wins field

**Location**: SpeedGameServer.server.lua:934 (win block handler)

**Admin-Safe Implementation**:
```lua
function setPlayerWins(userId, newWins)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    data.Wins = math.max(0, newWins)

    UpdateUIEvent:FireClient(player, data)
    updateLeaderstats(player, data)
    saveAll(player, data, "admin_set_wins")

    return {success = true}
end

function addPlayerWins(userId, amount)
    -- Similar to above, but data.Wins += amount
end
```

**Validation**: `newWins >= 0`

---

### Action 4: Grant/Remove SpeedBoost

**Function**: Set SpeedBoostLevel (0 = none, 1 = x2, 2 = x4, 3 = x8, 4 = x16)

**Location**: SpeedGameServer.server.lua:499-522 (purchase handler)

**Multiplier Formula**: `2^level` (implemented in getSpeedBoostMultiplier, line 145-148)

**Admin-Safe Implementation**:
```lua
function setPlayerSpeedBoost(userId, newLevel)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    -- Clamp to valid levels (0-4 configured, 0-6 theoretical)
    newLevel = math.clamp(newLevel, 0, 6)

    data.SpeedBoostLevel = newLevel
    data.SpeedBoostActive = newLevel > 0
    data.CurrentSpeedBoostMultiplier = getSpeedBoostMultiplier(newLevel)

    UpdateUIEvent:FireClient(player, data)
    saveAll(player, data, "admin_set_speedboost")

    return {success = true, multiplier = data.CurrentSpeedBoostMultiplier}
end
```

**Validation**: Level 0-6 (0-4 have ProductIds configured)

**Configured Levels** (SpeedGameServer.server.lua:27-34):
- Level 0: 1x (none)
- Level 1: 2x (ProductId 3510578826)
- Level 2: 4x (ProductId 3510802965)
- Level 3: 8x (ProductId 3510803353)
- Level 4: 16x (ProductId 3510803870)
- Level 5-6: Theoretical (not configured)

---

### Action 5: Grant/Remove WinsBoost

**Function**: Set WinBoostLevel (same exponential formula as SpeedBoost)

**Location**: SpeedGameServer.server.lua:524-547 (purchase handler)

**Multiplier Formula**: `2^level`

**Admin-Safe Implementation**: (Similar to SpeedBoost, replace field names)

**Configured Levels** (SpeedGameServer.server.lua:37-44):
- Level 0: 1x (none)
- Level 1: 2x (ProductId 3510580275)
- Level 2: 4x (ProductId 3511571771)
- Level 3: 8x (ProductId 3511572068)
- Level 4: 16x (ProductId 3511572744)

---

### Action 6: Grant/Remove Treadmill Access

**Function**: Set `TreadmillX3Owned`, `TreadmillX9Owned`, or `TreadmillX25Owned`

**Location**: SpeedGameServer.server.lua:584-612 (purchase handler)

**Admin-Safe Implementation**:
```lua
function setTreadmillOwnership(userId, multiplier, owned)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    -- Validate multiplier
    if multiplier ~= 3 and multiplier ~= 9 and multiplier ~= 25 then
        return {error = "Invalid multiplier (must be 3, 9, or 25)"}
    end

    local key = "TreadmillX" .. multiplier .. "Owned"
    data[key] = owned == true

    -- Update player attribute (for client sync)
    player:SetAttribute(key, owned == true)

    -- Notify client immediately (for UI update)
    TreadmillOwnershipUpdated:FireClient(player, multiplier, owned)

    saveAll(player, data, "admin_treadmill_" .. multiplier)

    return {success = true}
end
```

**Validation**: Multiplier must be 3, 9, or 25

**⚠️ Important**: Must fire `TreadmillOwnershipUpdated` RemoteEvent to client (ClientBootstrap.client.lua:88-143)

---

### Action 7: Reset Player State

**Function**: Reset to default values (like new player)

**Admin-Safe Implementation**:
```lua
function resetPlayerState(userId)
    local player = Players:GetPlayerByUserId(userId)
    if not player then return {error = "Player not online"} end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    -- Reset to defaults (excluding treadmill ownership if desired)
    data.TotalXP = 0
    data.Level = 1
    data.XP = 0
    data.Wins = 0
    data.Rebirths = 0
    data.Multiplier = 1
    data.StepBonus = 1
    data.SpeedBoostLevel = 0
    data.WinBoostLevel = 0
    data.XPRequired = ProgressionMath.XPRequired(1)

    -- Optional: Reset treadmill ownership
    -- data.TreadmillX3Owned = false
    -- data.TreadmillX9Owned = false
    -- data.TreadmillX25Owned = false

    updateWalkSpeed(player, data)
    UpdateUIEvent:FireClient(player, data)
    updateLeaderstats(player, data)
    saveAll(player, data, "admin_reset")

    return {success = true}
end
```

---

### Action 8: View Player State

**Function**: Query current player data

**Location**: SpeedGameServer.server.lua:201-216 (getPlayerData)

**Implementation**:
```lua
function getPlayerState(userId)
    local player = Players:GetPlayerByUserId(userId)
    if not player then
        -- Try to load from DataStore2 if offline (requires async)
        return {error = "Player not online (offline query not implemented)"}
    end

    local data = PlayerData[userId]
    if not data then return {error = "Player data not loaded"} end

    return {
        success = true,
        data = {
            TotalXP = data.TotalXP,
            Level = data.Level,
            XP = data.XP,
            XPRequired = data.XPRequired,
            Wins = data.Wins,
            Rebirths = data.Rebirths,
            Multiplier = data.Multiplier,
            StepBonus = data.StepBonus,
            SpeedBoostLevel = data.SpeedBoostLevel,
            WinBoostLevel = data.WinBoostLevel,
            TreadmillX3Owned = data.TreadmillX3Owned,
            TreadmillX9Owned = data.TreadmillX9Owned,
            TreadmillX25Owned = data.TreadmillX25Owned,
            GiftClaimed = data.GiftClaimed,
            -- Derived fields
            CurrentSpeedBoostMultiplier = getSpeedBoostMultiplier(data.SpeedBoostLevel),
            CurrentWinBoostMultiplier = getWinBoostMultiplier(data.WinBoostLevel),
            WalkSpeed = 16 + math.min(data.Level, 500)
        }
    }
end
```

---

### Action 9: Reset Global Leaderboard

**Function**: Clear OrderedDataStore leaderboard

**Location**: LeaderboardUpdater.server.lua (reads leaderstats and updates leaderboard)

**Implementation**: Requires direct OrderedDataStore access (not currently exposed)

**Risk**: High - affects all players, irreversible

**Recommendation**: Do NOT implement unless absolutely necessary. Instead, provide "view top N players" functionality.

---

### Action 10: Restrict/Ban Player

**Function**: Not currently implemented in codebase

**Location**: Would need to be added (e.g., check against BanService or custom DataStore)

**Recommendation**: Implement via ADMIN_USER_IDS whitelist approach (SpeedGameServer.server.lua:10-13) or Roblox's built-in ban system

**Implementation Strategy**: Add `Banned` field to DataStore schema, check on PlayerAdded

---

## Phase 3: Networking & Remotes

### Remote Inventory

All remotes are created by RemotesBootstrap.server.lua and stored in `ReplicatedStorage.Remotes`.

#### RemoteEvents (Client ↔ Server)

| Name | Direction | Payload | Security | Purpose |
|------|-----------|---------|----------|---------|
| `UpdateSpeed` | Client→Server | `(steps, clientMultiplier?)` | ✅ Server validates multiplier via TreadmillService | Player sends step count; server calculates XP gain |
| `UpdateUI` | Server→Client | `(data: table)` | ✅ Server-only fire | Syncs full player state to client UI |
| `AddWin` | Client→Server | `()` | ⚠️ Uses debounce (2s cooldown) | Client notifies server of win block touch |
| `EquipStepAward` | Client→Server | `(bonus: number)` | ⚠️ Server should validate ownership | Player equips step bonus multiplier |
| `TreadmillOwnershipUpdated` | Server→Client | `(multiplier: number, owned: bool)` OR `(snapshot: table)` | ✅ Server-only fire | Notifies client of treadmill purchase |
| `Rebirth` | Client→Server | `()` | ✅ Server validates level requirement | Player requests rebirth |
| `RebirthSuccess` | Server→Client | `()` | ✅ Server-only fire | Plays rebirth sound/animation |
| `PromptSpeedBoost` | Client→Server | `()` | ✅ Server prompts purchase | Opens speed boost purchase dialog |
| `PromptWinsBoost` | Client→Server | `()` | ✅ Server prompts purchase | Opens wins boost purchase dialog |
| `Prompt100KSpeed` | Client→Server | `()` | ✅ Server prompts purchase | Opens +100K speed pack purchase |
| `Prompt1MSpeed` | Client→Server | `()` | ✅ Server prompts purchase | Opens +1M speed pack purchase |
| `Prompt10MSpeed` | Client→Server | `()` | ✅ Server prompts purchase | Opens +10M speed pack purchase |
| `ClaimGift` | Client→Server | `()` | ✅ Server validates group membership | Claims free group gift |
| `ShowWin` | Server→Client | `(amount: number)` | ✅ Server-only fire | Shows win notification on client |
| `NpcKillPlayer` | Server→Client | `()` | ✅ Server-only fire | Plays death sound when NPC kills player |
| `NpcLaserSlowEffect` | Server→Client | `(duration: number)` | ✅ Server-only fire | Shows slow effect when hit by laser |
| `AdminAdjustStat` | Client→Server | `(payload: table)` | ✅ Checks ADMIN_USER_IDS | Admin-only stat adjustments (DEPRECATED for external dashboard) |

#### RemoteFunctions (Client ↔ Server)

| Name | Direction | Payload | Returns | Security | Purpose |
|------|-----------|---------|---------|----------|---------|
| `VerifyGroup` | Client→Server | `()` | `boolean` | ✅ Server checks group membership | Verifies if player is in game group |

---

### Security Analysis

**✅ Secure Remotes** (Server-authoritative):
- `UpdateSpeed`: Server validates multiplier via TreadmillService (SpeedGameServer.server.lua:638-766)
- `Rebirth`: Server validates level requirement (SpeedGameServer.server.lua:777-824)
- All `Prompt*` events: Server controls MarketplaceService prompts
- All server→client events: Cannot be exploited by client

**⚠️ Potential Exploits** (Require validation):
- `AddWin`: Uses 2s debounce, but could be exploited with multiple clients or teleport hacks
- `EquipStepAward`: Server does NOT validate if player meets win requirement (ClientBootstrap.client.lua:921)
  - **FIX NEEDED**: Add server-side validation in SpeedGameServer.server.lua:768-775

**🚫 Insecure (Client Trust)**:
- None found (all critical logic is server-side)

---

### Recommended Admin Remotes

For external dashboard integration, create **NEW server-only RemoteFunctions**:

```lua
-- Example structure
local AdminRemotes = ReplicatedStorage:FindFirstChild("AdminRemotes")

-- Server-to-Dashboard communication via HttpService (Roblox → External)
-- Dashboard-to-Roblox: Use MessagingService or Polling DataStore

-- Option 1: HTTP POST to external webhook
HttpService:PostAsync("https://your-dashboard.com/api/webhook", {
    type = "player_joined",
    userId = player.UserId,
    username = player.Name
})

-- Option 2: MessagingService (for cross-server admin commands)
MessagingService:SubscribeAsync("AdminCommands", function(message)
    local cmd = message.Data
    if cmd.action == "set_player_speed" then
        setPlayerSpeed(cmd.userId, cmd.value)
    end
end)

-- Option 3: Polling DataStore (admin writes, game reads every N seconds)
-- Check GlobalDataStore("AdminCommands") for pending commands
```

**Recommendation**: Use **MessagingService** + **Secure Token Authentication**
- Admin dashboard publishes commands to MessagingService topic
- Game server subscribes and validates token before executing
- Tokens should be time-limited and signed (HMAC-SHA256)

---

## Phase 4: Treadmills & Ownership

### Treadmill Tier Definitions

| Tier Name | Multiplier | ProductId | Price (Robux) | Color | IsFree |
|-----------|------------|-----------|---------------|-------|--------|
| Free | 1 | 0 | Free | White | ✅ |
| Gold | 3 | 3510639799 | 59 | Gold | ❌ |
| Blue | 9 | 3510662188 | 149 | Blue | ❌ |
| Purple | 25 | 3510662405 | 399 | Purple | ❌ |

**Source**: TreadmillConfig.lua:16-45, SpeedGameServer.server.lua:47-55

---

### Ownership Tracking

**DataStore Fields**:
- `TreadmillX3Owned` (boolean)
- `TreadmillX9Owned` (boolean)
- `TreadmillX25Owned` (boolean)

**Player Attributes** (synced to client):
- `TreadmillX3Owned`
- `TreadmillX9Owned`
- `TreadmillX25Owned`

**Purchase Flow**:
1. Client touches zone without ownership → prompts purchase (ClientBootstrap.client.lua:831-854)
2. User completes purchase → MarketplaceService.ProcessReceipt fires (SpeedGameServer.server.lua:488-615)
3. Server sets `data.TreadmillXNOwned = true`
4. Server sets `player:SetAttribute("TreadmillXNOwned", true)`
5. Server fires `TreadmillOwnershipUpdated:FireClient(player, multiplier, true)`
6. Client updates ownership cache (ClientBootstrap.client.lua:88-143)
7. Server persists via `saveAll()`

---

### Zone Configuration System

**TreadmillZone Attributes** (set by TreadmillSetup.server.lua):
- `Multiplier` (number): 1, 3, 9, or 25
- `ProductId` (number): Dev product ID (0 for free)
- `IsFree` (boolean): Auto-detected or explicit

**Zone Detection** (server-authoritative):
1. TreadmillRegistry scans workspace for `TreadmillZone` parts (TreadmillRegistry.lua:105-177)
2. Builds spatial grid for fast position→zone lookup (TreadmillRegistry.lua:28-62)
3. TreadmillService monitors player positions every 0.15s (TreadmillService.server.lua:97-175)
4. Sets player attributes `OnTreadmill` and `CurrentTreadmillMultiplier`
5. SpeedGameServer reads attributes to calculate XP gain (SpeedGameServer.server.lua:638-766)

**Access Validation** (SpeedGameServer.server.lua:689-707):
```lua
-- Checks if player owns the treadmill they're standing on
if treadmillMultiplier == 3 and data.TreadmillX3Owned then
    hasAccess = true
elseif treadmillMultiplier == 9 and data.TreadmillX9Owned then
    hasAccess = true
elseif treadmillMultiplier == 25 and data.TreadmillX25Owned then
    hasAccess = true
elseif treadmillMultiplier == 1 then
    hasAccess = true  -- Free treadmill
end

if not hasAccess then
    return  -- Block XP gain
end
```

---

### "TreadmillZone missing ProductId or Multiplier" Error

**Root Cause**: Zones created in Studio without proper attributes

**Solution**: Run TreadmillSetup.server.lua (or TreadmillSetupWizard.server.lua) to auto-configure zones

**Prevention**: Always use TreadmillZoneHandler.lua template when creating new zones

**Manual Fix**:
```lua
-- Set attributes on zone
zone:SetAttribute("Multiplier", 3)  -- 1, 3, 9, or 25
zone:SetAttribute("ProductId", 3510639799)  -- 0 for free
zone:SetAttribute("IsFree", false)  -- true for free
```

---

### Admin Dashboard: Treadmill Management

**Actions**:
1. **Grant/Revoke Treadmill Access**: Use `setTreadmillOwnership(userId, multiplier, owned)`
2. **View Ownership**: Query `data.TreadmillX3Owned`, `data.TreadmillX9Owned`, `data.TreadmillX25Owned`
3. **List All Treadmills**: Query TreadmillRegistry (server-side only)

**Endpoints Needed**:
```json
{
  "get_player_treadmills": {
    "input": {"userId": 123},
    "output": {"x3": true, "x9": false, "x25": true}
  },
  "set_treadmill_ownership": {
    "input": {"userId": 123, "multiplier": 9, "owned": true},
    "output": {"success": true}
  }
}
```

---

## Phase 5: Integration Strategy

### System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Admin Dashboard (Lovable)              │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Next.js Frontend (TypeScript + React)             │ │
│  │  - Player search & view                            │ │
│  │  - Stat editing forms                              │ │
│  │  - Treadmill management                            │ │
│  │  - Real-time monitoring                            │ │
│  └────────────────────────────────────────────────────┘ │
│                         ↕ HTTPS REST API                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Backend API (Node.js + Express)                   │ │
│  │  - Authentication & Authorization                  │ │
│  │  - Rate limiting & validation                      │ │
│  │  - Command queue & retry logic                     │ │
│  │  - Webhook receiver (Roblox → Dashboard)           │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↕
            ┌────────────────────────────┐
            │  MessagingService Bridge   │
            │  (Roblox Cloud API)        │
            └────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────────┐
│                 Roblox Game Server(s)                    │
│  ┌────────────────────────────────────────────────────┐ │
│  │  AdminCommandListener.server.lua (NEW)             │ │
│  │  - Subscribes to MessagingService topic            │ │
│  │  - Validates command tokens (HMAC)                 │ │
│  │  - Routes to control functions                     │ │
│  │  - Sends response via HttpService webhook          │ │
│  └────────────────────────────────────────────────────┘ │
│                         ↕                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │  AdminControlFunctions.lua (NEW MODULE)            │ │
│  │  - setPlayerSpeed()                                │ │
│  │  - setPlayerLevel()                                │ │
│  │  - setPlayerWins()                                 │ │
│  │  - setTreadmillOwnership()                         │ │
│  │  - getPlayerState()                                │ │
│  │  - ... (all admin functions)                       │ │
│  └────────────────────────────────────────────────────┘ │
│                         ↕                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │  SpeedGameServer.server.lua (EXISTING)             │ │
│  │  - PlayerData table (source of truth)              │ │
│  │  - DataStore2 persistence                          │ │
│  │  - getStores() / savePlayerData()                  │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

### Recommended Integration: MessagingService + Token Auth

**Why MessagingService?**
- ✅ Works across all game servers (automatic fan-out)
- ✅ No need for DataStore polling (real-time)
- ✅ Roblox Cloud API support (can publish from external)
- ✅ Low latency (~100-500ms)

**Security Model**:
1. Dashboard generates command with timestamp + HMAC signature
2. Publishes to MessagingService topic: `AdminCommands`
3. Game server validates HMAC using shared secret
4. Executes command if signature valid + timestamp < 60s old
5. Sends response via HttpService POST to dashboard webhook

**Token Format**:
```json
{
  "commandId": "uuid-v4",
  "timestamp": 1705507200,
  "action": "set_player_speed",
  "userId": 123456789,
  "parameters": {"newTotalXP": 5000000},
  "signature": "hmac-sha256(secret, commandId+timestamp+action+userId+params)"
}
```

**Game Server Pseudo-Code**:
```lua
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

local ADMIN_SECRET = "your-secret-key-here"  -- Store securely
local DASHBOARD_WEBHOOK = "https://your-dashboard.com/api/webhook"

MessagingService:SubscribeAsync("AdminCommands", function(message)
    local cmd = message.Data

    -- Validate timestamp (prevent replay attacks)
    local now = os.time()
    if math.abs(now - cmd.timestamp) > 60 then
        return  -- Command expired
    end

    -- Validate signature
    local payload = cmd.commandId .. cmd.timestamp .. cmd.action .. cmd.userId .. HttpService:JSONEncode(cmd.parameters)
    local expectedSig = calculateHMAC(ADMIN_SECRET, payload)
    if cmd.signature ~= expectedSig then
        return  -- Invalid signature
    end

    -- Execute command
    local result = AdminControlFunctions.executeCommand(cmd)

    -- Send response to dashboard
    HttpService:PostAsync(DASHBOARD_WEBHOOK, HttpService:JSONEncode({
        commandId = cmd.commandId,
        success = result.success,
        error = result.error,
        data = result.data
    }))
end)
```

---

### Alternative: DataStore Polling (Simpler, Higher Latency)

**How it Works**:
1. Dashboard writes command to GlobalDataStore: `AdminCommandQueue`
2. Game server polls every 5-10 seconds
3. Executes pending commands, marks as processed
4. Dashboard polls `AdminCommandResults` for responses

**Pros**:
- ✅ Simpler (no MessagingService)
- ✅ No webhook configuration needed
- ✅ Works with Roblox Open Cloud (DataStore API)

**Cons**:
- ❌ Higher latency (5-10s polling interval)
- ❌ More DataStore requests (rate limits)
- ❌ No cross-server fan-out (must poll all servers)

---

### NOT Recommended: Roblox Open Cloud (DataStore API)

**Why Not?**
- ❌ Cannot directly execute Lua code (only read/write DataStores)
- ❌ Would require offline data manipulation (player must rejoin to see changes)
- ❌ No way to trigger UpdateUI or other real-time events
- ❌ High risk of data corruption (race conditions with game server)

**Only Use Case**: Offline player data viewer (read-only)

---

### Security Requirements

**Authentication**:
- Dashboard users must authenticate (email + password, OAuth, etc.)
- Role-based access control (RBAC):
  - **Viewer**: Can view player stats
  - **Moderator**: Can modify stats, grant treadmills
  - **Admin**: Can reset players, view logs

**Authorization**:
- Every command must be signed with HMAC-SHA256
- Shared secret must be stored securely (environment variable, not in code)
- Rotate secret regularly (every 90 days)

**Rate Limiting**:
- Dashboard API: Max 100 requests/minute per user
- Game server: Max 10 admin commands/second globally
- Reject duplicate commandIds (prevent replay)

**Audit Logging**:
- Log all admin actions to external database (not Roblox DataStore)
- Include: timestamp, admin user, action, target player, parameters, result
- Retain logs for 1 year minimum

---

### Risks & Security Notes

**Critical Risks**:
1. **HMAC Secret Exposure**: If leaked, attacker can execute unlimited admin commands
   - **Mitigation**: Store in environment variables, rotate regularly, use separate secrets per server
2. **Rate Limit Bypass**: Attacker spams admin commands to crash server
   - **Mitigation**: Implement command queue with max 10/sec processing rate
3. **Data Corruption**: Concurrent admin + player actions cause race condition
   - **Mitigation**: Use locks or atomic operations (DataStore2 handles this)
4. **Privilege Escalation**: Moderator gains admin access via bug
   - **Mitigation**: Strictly validate roles on every request (server-side)

**What Must NEVER Run on Client**:
- Setting player data fields (TotalXP, Wins, Levels, etc.)
- Granting treadmill ownership
- Setting boost levels
- Any admin commands

**What Must Be Server-Validated**:
- All admin commands (signature + timestamp)
- Player ownership checks (before allowing treadmill use)
- Rebirth level requirements
- Win block touches (add server-side validation)

---

## Appendix A: admin_actions.json

See separate file: `admin_actions.json`

---

## Appendix B: Key Files Reference

### Must Read Files (for implementation):
1. `src/server/SpeedGameServer.server.lua` - Main game logic, all control functions
2. `src/shared/ProgressionMath.lua` - XP/Level calculation formulas
3. `src/server/TreadmillService.server.lua` - Zone detection logic
4. `src/server/modules/TreadmillConfig.lua` - Treadmill definitions
5. `src/server/RemotesBootstrap.server.lua` - Remote inventory

### Optional Files (for reference):
- `src/client/ClientBootstrap.client.lua` - Client-side UX (not needed for admin)
- `src/client/UIHandler.lua` - UI rendering (not needed for admin)
- `src/server/LeaderboardUpdater.server.lua` - Leaderboard logic (if implementing reset)

---

## Appendix C: Open Questions & Recommendations

**Questions to Resolve**:
1. Do you want admin actions to work on **offline players** or only online?
   - **Recommendation**: Start with online-only (much simpler)
2. Should admins be able to **reset the global leaderboard**?
   - **Recommendation**: No (too dangerous, irreversible)
3. Do you need **real-time monitoring** (e.g., live player stats dashboard)?
   - **Recommendation**: Yes, implement via HttpService webhooks on player join/leave/level-up
4. Should ban/restrict functionality be built-in or use Roblox's built-in system?
   - **Recommendation**: Use Roblox's BanService (no custom implementation needed)

**Next Steps**:
1. ✅ Review this document
2. Choose integration strategy (MessagingService recommended)
3. Set up admin dashboard backend (Node.js + Express)
4. Implement AdminCommandListener.server.lua in Roblox
5. Implement AdminControlFunctions.lua module
6. Build dashboard frontend (React + Next.js)
7. Test in private server before production
8. Implement audit logging
9. Deploy & monitor

---

**End of Document**
