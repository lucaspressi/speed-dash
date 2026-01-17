# 🧪 STUDIO VALIDATION CHECKLIST - Speed Dash

**Build File:** `build.rbxl` (99KB)
**Generated:** 2026-01-17 06:08
**Status:** ✅ Ready for Testing

---

## 📋 PRE-FLIGHT CHECK

Before opening in Studio, verify:
- [x] Build file exists: `build.rbxl` (99KB)
- [x] Rojo build succeeded with no errors
- [x] All changes committed and pushed to GitHub

---

## 🚀 STEP 1: OPEN IN STUDIO

1. Open Roblox Studio
2. **File** → **Open from File**
3. Navigate to: `/Users/lucassampaio/Projects/speed-dash/build.rbxl`
4. Click **Open**

⏱️ Expected: Studio loads in 5-10 seconds

---

## 🔍 STEP 2: EXPLORER STRUCTURE VALIDATION

### Check ServerScriptService

Navigate to **ServerScriptService** in Explorer and verify:

```
📁 ServerScriptService
  ⚡ RemotesBootstrap          ← NEW! Should be FIRST
  ⚡ SpeedGameServer
  ⚡ TreadmillService
  ⚡ TreadmillSetup
  ⚡ LeaderboardUpdater
  ⚡ ProgressionValidator
  ⚡ AxeController
  ⚡ RollingBallController
  ⚡ NoobNpcAI
  ⚡ SmokeTest
  🚫 MapSanitizer (Disabled - gray icon)
  📂 Modules
    📦 TreadmillConfig
    📦 TreadmillRegistry
  📦 DataStore2
```

**Critical Checks:**
- [ ] RemotesBootstrap is FIRST script in list
- [ ] RemotesBootstrap is a Script (⚡ icon)
- [ ] MapSanitizer has gray icon (Disabled)
- [ ] Modules folder exists with 2 ModuleScripts

### Check ReplicatedStorage

Navigate to **ReplicatedStorage** and verify:

```
📁 ReplicatedStorage
  📂 Remotes (should be empty initially - created at runtime)
  📂 Shared (UPPERCASE "S")
    📦 ProgressionConfig
    📦 ProgressionMath
    📦 TelemetryService
    🔷 Hello
```

**Critical Checks:**
- [ ] Shared folder exists with UPPERCASE "S" (not "shared")
- [ ] Shared contains 3-4 ModuleScripts
- [ ] Remotes folder may not exist yet (RemotesBootstrap creates it)

### Check StarterPlayer

Navigate to **StarterPlayer**:

```
📁 StarterPlayer
  📁 StarterPlayerScripts
    🖥️ init
    🖥️ UIHandler
    🖥️ DebugLogExporter
```

**Critical Checks:**
- [ ] Only ONE StarterPlayerScripts folder
- [ ] Contains 3 LocalScripts
- [ ] NO duplicate StarterPlayerScripts anywhere

### Check ServerStorage

Navigate to **ServerStorage**:

```
📁 ServerStorage
  📂 Templates
    📦 TreadmillZoneHandler (non-executing template)
```

**Critical Checks:**
- [ ] TreadmillZoneHandler is in Templates (not executing)
- [ ] TreadmillZoneHandler is ModuleScript (not Script)

---

## ▶️ STEP 3: PLAY SOLO (Console Validation)

1. Click **Play Solo** button (F5)
2. Wait 2-3 seconds for initialization
3. Check **Output** console

### Expected Console Output (First 10 lines)

```
✅ [RemotesBootstrap] ==================== STARTING ====================
✅ [RemotesBootstrap] Created Remotes folder
✅ [RemotesBootstrap] Created Shared folder
✅ [RemotesBootstrap] Creating RemoteEvents...
✅ [RemotesBootstrap]   ✅ Created: UpdateSpeed
✅ [RemotesBootstrap]   ✅ Created: UpdateUI
✅ [RemotesBootstrap]   ✅ Created: AddWin
✅ [RemotesBootstrap]   ✅ Created: EquipStepAward
✅ [RemotesBootstrap]   ✅ Created: TreadmillOwnershipUpdated
✅ [RemotesBootstrap]   ✅ Created: Rebirth
✅ [RemotesBootstrap]   ✅ Created: RebirthSuccess
✅ [RemotesBootstrap]   ✅ Created: PromptSpeedBoost
✅ [RemotesBootstrap]   ✅ Created: PromptWinsBoost
✅ [RemotesBootstrap]   ✅ Created: Prompt100KSpeed
✅ [RemotesBootstrap]   ✅ Created: Prompt1MSpeed
✅ [RemotesBootstrap]   ✅ Created: Prompt10MSpeed
✅ [RemotesBootstrap]   ✅ Created: VerifyGroup
✅ [RemotesBootstrap]   ✅ Created: ClaimGift
✅ [RemotesBootstrap]   ✅ Created: ShowWin
✅ [RemotesBootstrap] ==================== COMPLETE ====================
✅ [RemotesBootstrap] Created: 16 remotes
✅ [RemotesBootstrap] Total: 16 remotes
✅ [RemotesBootstrap] ✅ All remotes ready for use
```

### Critical Console Checks

**MUST SEE (Required):**
- [ ] `[RemotesBootstrap] Created: 16 remotes`
- [ ] `[TreadmillService] ✅ TreadmillService ready`
- [ ] `[SpeedGameServer] ✅ TreadmillService connected`
- [ ] `[SmokeTest] 🎉 ALL TESTS PASSED!`

**MUST NOT SEE (Errors):**
- [ ] NO "Infinite yield possible on" errors
- [ ] NO "attempt to index nil" errors
- [ ] NO "TreadmillZone missing ProductId" spam (should be 3 warnings + summary)
- [ ] NO "[ZoneHandler] Script parent is not a BasePart"

### TreadmillRegistry Output (Expected)

```
[TreadmillRegistry] Scanned: 4
[TreadmillRegistry] Valid: 4
[TreadmillRegistry] Invalid: 63
⚠️ [TreadmillRegistry] Invalid zone: Workspace.Zone1 (PAID zone missing ProductId)
⚠️ [TreadmillRegistry] Invalid zone: Workspace.Zone2 (PAID zone missing ProductId)
⚠️ [TreadmillRegistry] Invalid zone: Workspace.Zone3 (PAID zone missing ProductId)
⚠️ [TreadmillRegistry] Found 63 invalid zones (first 3 logged above). Run TreadmillSetup to migrate.
```

**Check:**
- [ ] Only first 3 invalid zones logged (not 60+)
- [ ] Summary line appears if >3 invalid zones

---

## 🎮 STEP 4: GAMEPLAY VALIDATION (In Play Solo)

### Test 1: Movement & XP Gain

1. Use WASD to walk around the map
2. Watch the XP bar in UI (top of screen)

**Expected:**
- [ ] Character moves normally
- [ ] XP increases as you walk
- [ ] XP bar fills up gradually
- [ ] Level shown in UI (default: Level 0 or 1)

### Test 2: Level Up

1. Walk until XP bar fills completely
2. Observe what happens

**Expected:**
- [ ] Level increases by 1
- [ ] XP bar resets to 0
- [ ] WalkSpeed increases (character moves faster)
- [ ] UI updates to show new Level

### Test 3: FREE Treadmill (1x)

1. Find a FREE treadmill zone (usually white/gray)
2. Walk onto it
3. Observe XP gain rate

**Expected:**
- [ ] XP increases faster than walking on ground
- [ ] Console shows: `player:SetAttribute("OnTreadmill", true)`
- [ ] No purchase prompt (FREE zone)

### Test 4: PAID Treadmill (3x/9x/25x)

1. Find a GOLD/BLUE/PURPLE treadmill (paid)
2. Walk onto it
3. Observe behavior

**Expected:**
- [ ] Purchase prompt appears (if not owned)
- [ ] Can close prompt and continue testing
- [ ] Console shows treadmill detection
- [ ] XP may not increase if not owned (correct behavior)

### Test 5: Buttons/Prompts

1. Find SpeedBoost button in UI
2. Click it

**Expected:**
- [ ] Purchase prompt appears
- [ ] No errors in console
- [ ] Can close prompt

Repeat for other buttons:
- [ ] WinBoost button works
- [ ] 100K Speed button works (if visible)
- [ ] 1M Speed button works (if visible)

### Test 6: Win Blocks

1. Complete the obby/course to reach a WinBlock
2. Touch the WinBlock

**Expected:**
- [ ] Wins stat increases by 1 (or configured amount)
- [ ] Teleports back to spawn
- [ ] UI shows updated Wins count
- [ ] Leaderstats updates

---

## 🔬 STEP 5: DETAILED ATTRIBUTE VERIFICATION

While in Play Solo:

1. Stop play mode (press Stop button)
2. Click **Play Solo** again
3. Once game loads, open **Explorer**
4. Navigate to **Players** → (Your character name)
5. Click on your character to select it
6. Open **Properties** window (View → Properties)

### Check Player Attributes

Scroll down in Properties to **Attributes** section:

**Expected Attributes:**
- [ ] `OnTreadmill` = false (boolean)
- [ ] `CurrentTreadmillMultiplier` = 0 (number)
- [ ] `TreadmillX3Owned` = false (boolean)
- [ ] `TreadmillX9Owned` = false (boolean)
- [ ] `TreadmillX25Owned` = false (boolean)

**Critical:**
- All attributes should EXIST (not nil)
- Values may be false, but attributes must be present

### Check Leaderstats

Expand your character in Explorer:
```
📁 YourCharacterName
  📂 leaderstats
    🔢 Speed (IntValue)
    🔢 Wins (IntValue)
```

**Check:**
- [ ] leaderstats folder exists
- [ ] Speed IntValue exists
- [ ] Wins IntValue exists

---

## 🧪 STEP 6: RUN SMOKETEST

While in Play Solo:

1. Open **Output** console
2. Wait for game to fully load (3-5 seconds)
3. Look for SmokeTest output

### Expected SmokeTest Output

```
==================== SMOKE TEST STARTING ====================

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST CATEGORY: ReplicatedStorage Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PASS: Shared folder exists (CASE SENSITIVE)
✅ PASS: Remotes folder exists
✅ PASS: UpdateSpeed RemoteEvent exists
✅ PASS: UpdateUI RemoteEvent exists
✅ PASS: AddWin RemoteEvent exists
✅ PASS: EquipStepAward RemoteEvent exists
✅ PASS: TreadmillOwnershipUpdated RemoteEvent exists
✅ PASS: Rebirth RemoteEvent exists
✅ PASS: RebirthSuccess RemoteEvent exists
✅ PASS: PromptSpeedBoost RemoteEvent exists
✅ PASS: PromptWinsBoost RemoteEvent exists
✅ PASS: Prompt100KSpeed RemoteEvent exists
✅ PASS: Prompt1MSpeed RemoteEvent exists
✅ PASS: Prompt10MSpeed RemoteEvent exists
✅ PASS: VerifyGroup RemoteEvent exists
✅ PASS: ClaimGift RemoteEvent exists
✅ PASS: ShowWin RemoteEvent exists
  Total remotes checked: 16

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST CATEGORY: TreadmillService
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PASS: _G.TreadmillService exists
✅ PASS: TreadmillService.getPlayerMultiplier exists
✅ PASS: TreadmillService.isPlayerOnTreadmill exists
✅ PASS: TreadmillService.getPlayerZone exists
✅ PASS: TreadmillService.getPlayerMultiplier(player) works

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST CATEGORY: TreadmillRegistry
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PASS: TreadmillRegistry module exists
  Registry stats: 4 zones registered
✅ PASS: TreadmillRegistry has zones

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST CATEGORY: Player Data
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Testing with player: YourName
✅ PASS: Player has OnTreadmill attribute
✅ PASS: Player has CurrentTreadmillMultiplier attribute
✅ PASS: Player has TreadmillX3Owned attribute
✅ PASS: Player has TreadmillX9Owned attribute
✅ PASS: Player has TreadmillX25Owned attribute
✅ PASS: Player has leaderstats
✅ PASS: Leaderstats has Speed stat
✅ PASS: Leaderstats has Wins stat

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SMOKE TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Passed: 30+
❌ Failed: 0

🎉 ALL TESTS PASSED! Game systems are operational.

==================== SMOKE TEST COMPLETE ====================
```

**Critical Checks:**
- [ ] `✅ Passed: 30+` (should be 30 or more)
- [ ] `❌ Failed: 0` (MUST be zero)
- [ ] `🎉 ALL TESTS PASSED!` message appears

---

## 📊 STEP 7: VERIFY REMOTES CREATED

While in Play Solo:

1. In **Explorer**, navigate to **ReplicatedStorage**
2. Expand **Remotes** folder

### Expected Contents

```
📁 ReplicatedStorage
  📂 Remotes
    📡 AdminAdjustStat (RemoteEvent)
    📡 AddWin (RemoteEvent)
    📡 ClaimGift (RemoteEvent)
    📡 EquipStepAward (RemoteEvent)
    📡 Prompt100KSpeed (RemoteEvent)
    📡 Prompt1MSpeed (RemoteEvent)
    📡 Prompt10MSpeed (RemoteEvent)
    📡 PromptSpeedBoost (RemoteEvent)
    📡 PromptWinsBoost (RemoteEvent)
    📡 Rebirth (RemoteEvent)
    📡 RebirthSuccess (RemoteEvent)
    📡 ShowWin (RemoteEvent)
    📡 TreadmillOwnershipUpdated (RemoteEvent)
    📡 UpdateSpeed (RemoteEvent)
    📡 UpdateUI (RemoteEvent)
    📡 VerifyGroup (RemoteEvent)
```

**Count:**
- [ ] Total RemoteEvents: 16
- [ ] All are RemoteEvent type (not RemoteFunction)
- [ ] No missing remotes from list above

---

## ✅ FINAL VALIDATION SUMMARY

### Console Health Check
- [ ] ✅ ZERO "Infinite yield" errors
- [ ] ✅ ZERO "attempt to index nil" errors
- [ ] ✅ RemotesBootstrap created 16 remotes
- [ ] ✅ TreadmillService ready
- [ ] ✅ SpeedGameServer connected
- [ ] ✅ SmokeTest passed (0 failures)

### Explorer Structure Check
- [ ] ✅ RemotesBootstrap is FIRST script in ServerScriptService
- [ ] ✅ ReplicatedStorage/Shared exists (UPPERCASE)
- [ ] ✅ ReplicatedStorage/Remotes has 16 RemoteEvents
- [ ] ✅ Only ONE StarterPlayerScripts folder
- [ ] ✅ MapSanitizer is Disabled (gray icon)

### Gameplay Check
- [ ] ✅ XP increases when walking
- [ ] ✅ Level up works
- [ ] ✅ Treadmills detect player position
- [ ] ✅ Buttons show purchase prompts
- [ ] ✅ Win blocks increase Wins stat

### Player Data Check
- [ ] ✅ Attributes exist (OnTreadmill, TreadmillX3/X9/X25Owned)
- [ ] ✅ Leaderstats exist (Speed, Wins)
- [ ] ✅ Ownership snapshot received by client

---

## 🎉 SUCCESS CRITERIA

**IF ALL CHECKS PASS:**
- ✅ Build is VALID
- ✅ Game is FULLY OPERATIONAL
- ✅ Ready for production deployment
- ✅ All bootstrap fixes working correctly

**IF ANY CHECKS FAIL:**
- ⚠️ Review failed item in checklist
- ⚠️ Check console for specific error messages
- ⚠️ Compare with expected output above
- ⚠️ Refer to GAME_BOOTSTRAP_FIX.md for troubleshooting

---

## 📝 NOTES

**Build Info:**
- File: `build.rbxl`
- Size: 99KB
- Generated: 2026-01-17 06:08
- Rojo Version: 7.6.1
- Commit: bf7f232

**Key Changes Validated:**
- RemotesBootstrap (NEW) - Creates all remotes at boot
- Case sensitivity fix: "shared" → "Shared"
- Attributes always initialized (even if false)
- getOrCreateRemote pattern for all remotes
- Log spam reduction (3 warnings + summary)

---

**Validation conducted by:** [Your Name]
**Date:** [Fill in after testing]
**Result:** [ ] PASS / [ ] FAIL (with notes)
**Notes:** [Any observations or issues found]
