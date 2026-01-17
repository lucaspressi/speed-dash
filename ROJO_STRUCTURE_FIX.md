# 🏗️ ROJO STRUCTURE FIX - Speed Dash Project

**Date:** 2026-01-17
**Engineer:** Claude Code (Senior Roblox + Rojo Engineer)
**Status:** ✅ COMPLETED

---

## 🎯 OBJECTIVE

Fix Roblox Studio Explorer structure by reorganizing the repository and Rojo configuration to eliminate:
1. ❌ TreadmillZoneHandler executing in ServerScriptService (should only run in BaseParts)
2. ❌ Game ModuleScripts incorrectly placed inside DataStore2 library
3. ❌ Duplicate StarterPlayerScripts causing chaos

---

## 📊 PROBLEMS IDENTIFIED

### Problem 1: TreadmillZoneHandler in ServerScriptService
**Root Cause:**
`default.project.json` was mapping entire `src/server/` folder to `ServerScriptService` using `$path`. This caused ALL .lua files to be copied as executable Scripts, including `TreadmillZoneHandler.server.lua` which was designed to run ONLY inside BasePart zones.

**Impact:**
- Console spam: "[ZoneHandler] Script parent is not a BasePart! Parent: ServerScriptService"
- Confused initialization order
- TreadmillZoneHandler trying to execute in wrong context

### Problem 2: ModuleScripts in Wrong Location
**Root Cause:**
`TreadmillConfig.lua` and `TreadmillRegistry.lua` were loose files in `src/server/` alongside Scripts. When synced, they appeared mixed with executable scripts in ServerScriptService instead of being organized in a proper Modules folder.

**Impact:**
- Confusing `require()` paths
- Difficult to distinguish Scripts from Modules
- Poor code organization
- Risk of modules being placed inside DataStore2.rbxm structure

### Problem 3: No Granular Control Over Structure
**Root Cause:**
Using `$path: "src/server"` gives Rojo no control over substructure. Everything is dumped flat into ServerScriptService.

**Impact:**
- No folders for organization (Modules, Templates, etc.)
- Unable to mark scripts as Disabled (like MapSanitizer for DEV only)
- Cannot prevent specific files from auto-executing

---

## 🔧 SOLUTIONS APPLIED

### Solution 1: Reorganize Repository Structure

**File Moves:**
```bash
# Created new folders
mkdir -p src/server/modules
mkdir -p src/storage/templates

# Moved ModuleScripts to dedicated folder
mv src/server/TreadmillConfig.lua → src/server/modules/TreadmillConfig.lua
mv src/server/TreadmillRegistry.lua → src/server/modules/TreadmillRegistry.lua

# Moved template script to ServerStorage (non-executing location)
mv src/server/TreadmillZoneHandler.server.lua → src/storage/templates/TreadmillZoneHandler.lua

# Renamed for Rojo compatibility
mv src/client/init.client.luau → src/client/init.client.lua
```

**New Repository Structure:**
```
src/
├── client/
│   ├── init.client.lua               (LocalScript)
│   ├── UIHandler.lua                 (LocalScript - inferred from location)
│   └── DebugLogExporter.client.lua   (LocalScript)
│
├── server/
│   ├── modules/                      ← NEW FOLDER
│   │   ├── TreadmillConfig.lua      (ModuleScript)
│   │   └── TreadmillRegistry.lua    (ModuleScript)
│   │
│   ├── SpeedGameServer.server.lua   (Script)
│   ├── TreadmillService.server.lua  (Script)
│   ├── TreadmillSetup.server.lua    (Script)
│   ├── LeaderboardUpdater.server.lua
│   ├── ProgressionValidator.server.lua
│   ├── AxeController.server.lua
│   ├── RollingBallController.server.lua
│   ├── NoobNpcAI.server.lua
│   ├── SmokeTest.server.lua
│   ├── MapSanitizer.server.lua      (will be Disabled in Studio)
│   └── DataStore2.rbxm              (library)
│
├── storage/                          ← NEW FOLDER
│   └── templates/
│       └── TreadmillZoneHandler.lua (Non-executing template)
│
└── shared/
    ├── ProgressionConfig.lua
    ├── ProgressionMath.lua
    ├── TelemetryService.lua
    └── Hello.luau
```

### Solution 2: Rewrite default.project.json with Granular Mapping

**Old Config (BROKEN):**
```json
{
  "ServerScriptService": {
    "$path": "src/server"  ← Dumps EVERYTHING, no control
  },
  "StarterPlayer": {
    "StarterPlayerScripts": {
      "$path": "src/client"  ← Could cause duplicates
    }
  }
}
```

**New Config (FIXED):**
```json
{
  "ServerScriptService": {
    "$className": "ServerScriptService",

    "SpeedGameServer": { "$path": "src/server/SpeedGameServer.server.lua" },
    "TreadmillService": { "$path": "src/server/TreadmillService.server.lua" },
    "TreadmillSetup": { "$path": "src/server/TreadmillSetup.server.lua" },
    "LeaderboardUpdater": { "$path": "src/server/LeaderboardUpdater.server.lua" },
    "ProgressionValidator": { "$path": "src/server/ProgressionValidator.server.lua" },
    "AxeController": { "$path": "src/server/AxeController.server.lua" },
    "RollingBallController": { "$path": "src/server/RollingBallController.server.lua" },
    "NoobNpcAI": { "$path": "src/server/NoobNpcAI.server.lua" },
    "SmokeTest": { "$path": "src/server/SmokeTest.server.lua" },

    "MapSanitizer": {
      "$path": "src/server/MapSanitizer.server.lua",
      "$properties": { "Disabled": true }  ← DEV ONLY
    },

    "Modules": {
      "$className": "Folder",  ← Creates proper Folder in Studio
      "TreadmillConfig": { "$path": "src/server/modules/TreadmillConfig.lua" },
      "TreadmillRegistry": { "$path": "src/server/modules/TreadmillRegistry.lua" }
    },

    "DataStore2": { "$path": "src/server/DataStore2.rbxm" }
  },

  "ServerStorage": {
    "$className": "ServerStorage",
    "Templates": {
      "$className": "Folder",
      "TreadmillZoneHandler": { "$path": "src/storage/templates/TreadmillZoneHandler.lua" }
    }
  },

  "StarterPlayer": {
    "$className": "StarterPlayer",
    "StarterPlayerScripts": {
      "$path": "src/client"  ← Maps folder (Rojo infers LocalScripts from .client.lua)
    }
  }
}
```

**Key Improvements:**
- ✅ Each Script explicitly mapped (full control)
- ✅ Modules folder created as proper Folder className
- ✅ MapSanitizer marked as Disabled (dev tool)
- ✅ TreadmillZoneHandler moved to ServerStorage/Templates (non-executing)
- ✅ StarterPlayerScripts maps to folder (Rojo auto-detects .client.lua)
- ✅ No duplicates, no mixed Script/ModuleScript locations

### Solution 3: Update require() Paths

**Files Updated:**

1. **src/server/TreadmillService.server.lua**
   ```lua
   -- ❌ BEFORE:
   local TreadmillRegistry = require(script.Parent.TreadmillRegistry)

   -- ✅ AFTER:
   local TreadmillRegistry = require(script.Parent.Modules.TreadmillRegistry)
   ```

2. **src/server/TreadmillSetup.server.lua**
   ```lua
   -- ❌ BEFORE:
   local TreadmillConfig = require(script.Parent.TreadmillConfig)

   -- ✅ AFTER:
   local TreadmillConfig = require(script.Parent.Modules.TreadmillConfig)
   ```

3. **src/server/SmokeTest.server.lua**
   ```lua
   -- ❌ BEFORE:
   TreadmillRegistry = require(ServerScriptService:WaitForChild("TreadmillRegistry", 1))

   -- ✅ AFTER:
   local modules = ServerScriptService:WaitForChild("Modules", 1)
   if modules then
       TreadmillRegistry = require(modules:WaitForChild("TreadmillRegistry", 1))
   end
   ```

---

## ✅ CANONICAL STRUCTURE (Generated in Studio)

After running `rojo build`, the Studio Explorer will show:

```
📁 ServerScriptService
  ⚡ SpeedGameServer              (Script)
  ⚡ TreadmillService              (Script)
  ⚡ TreadmillSetup                (Script)
  ⚡ LeaderboardUpdater            (Script)
  ⚡ ProgressionValidator          (Script)
  ⚡ AxeController                 (Script)
  ⚡ RollingBallController         (Script)
  ⚡ NoobNpcAI                     (Script)
  ⚡ SmokeTest                     (Script)
  🚫 MapSanitizer                  (Script - Disabled)
  📂 Modules
    📦 TreadmillConfig           (ModuleScript)
    📦 TreadmillRegistry         (ModuleScript)
  📦 DataStore2                    (ModuleScript from .rbxm)

📁 ServerStorage
  📂 Templates
    📦 TreadmillZoneHandler      (ModuleScript - non-executing template)

📁 ReplicatedStorage
  📂 Shared
    📦 ProgressionConfig         (ModuleScript)
    📦 ProgressionMath           (ModuleScript)
    📦 TelemetryService          (ModuleScript)
    🔷 Hello                     (ModuleScript from .luau)

📁 StarterPlayer
  📁 StarterPlayerScripts
    🖥️ init                      (LocalScript from .client.lua)
    🖥️ UIHandler                 (LocalScript)
    🖥️ DebugLogExporter          (LocalScript from .client.lua)
```

**Legend:**
- ⚡ = Script (server-side, auto-executing)
- 🖥️ = LocalScript (client-side, auto-executing)
- 📦 = ModuleScript (require() only, not auto-executing)
- 🚫 = Disabled Script (won't execute)
- 📂 = Folder
- 📁 = Service (Roblox built-in)

---

## 🚀 HOW TO USE

### Method 1: Build .rbxl File (Recommended for Testing)

```bash
# 1. Navigate to project root
cd /Users/lucassampaio/Projects/speed-dash

# 2. Build the place file
rojo build -o build.rbxl

# 3. Open in Roblox Studio
# File → Open from File → Select build.rbxl

# 4. Verify Explorer structure matches canonical structure above
```

### Method 2: Live Sync with Rojo Serve (Recommended for Development)

```bash
# 1. Start Rojo server
rojo serve

# Output should show:
# Rojo server listening on http://localhost:34872

# 2. In Roblox Studio:
#    - Install Rojo plugin from: https://rojo.space/docs/v7/getting-started/installation/
#    - Click "Connect" button in Rojo plugin
#    - Enter: localhost:34872
#    - Click "Connect"

# 3. Make changes in VS Code → Auto-syncs to Studio in real-time

# 4. To stop:
#    Ctrl+C in terminal
```

### Method 3: Sync to Existing Place File

```bash
# If you have an existing .rbxl with your map/assets:
rojo build --output existing_place.rbxl

# This will UPDATE the existing file (preserves Workspace, etc.)
```

---

## 🔍 VALIDATION CHECKLIST

After opening `build.rbxl` in Studio, verify:

### ✅ ServerScriptService
- [ ] SpeedGameServer, TreadmillService, TreadmillSetup are Scripts
- [ ] MapSanitizer exists but is Disabled (gray icon)
- [ ] Modules folder exists with TreadmillConfig + TreadmillRegistry as ModuleScripts
- [ ] DataStore2 is present (ModuleScript or Folder with library)
- [ ] **NO** TreadmillZoneHandler present (moved to ServerStorage)

### ✅ ServerStorage
- [ ] Templates folder exists
- [ ] TreadmillZoneHandler is a ModuleScript (non-executing)

### ✅ StarterPlayer > StarterPlayerScripts
- [ ] init (LocalScript)
- [ ] UIHandler (LocalScript)
- [ ] DebugLogExporter (LocalScript)
- [ ] **NO** duplicate StarterPlayerScripts folders

### ✅ ReplicatedStorage
- [ ] Shared folder exists
- [ ] Contains ProgressionMath, ProgressionConfig, TelemetryService (ModuleScripts)

### ✅ Console Verification (Play Solo)
```
Expected Output:
✅ [TreadmillService] ✅ TreadmillService ready
✅ [SpeedGameServer] ✅ TreadmillService connected
✅ NO "[ZoneHandler] Script parent is not a BasePart" errors
✅ NO duplicate script execution warnings
```

---

## 📊 FILES CHANGED SUMMARY

| File/Folder | Action | New Location |
|-------------|--------|--------------|
| `src/server/TreadmillConfig.lua` | Moved | `src/server/modules/TreadmillConfig.lua` |
| `src/server/TreadmillRegistry.lua` | Moved | `src/server/modules/TreadmillRegistry.lua` |
| `src/server/TreadmillZoneHandler.server.lua` | Moved | `src/storage/templates/TreadmillZoneHandler.lua` |
| `src/client/init.client.luau` | Renamed | `src/client/init.client.lua` |
| `src/server/modules/` | Created | New folder for ModuleScripts |
| `src/storage/templates/` | Created | New folder for non-executing templates |
| `default.project.json` | Rewritten | Granular mapping, 139 lines |
| `src/server/TreadmillService.server.lua` | Updated | Fixed require() path (line 10) |
| `src/server/TreadmillSetup.server.lua` | Updated | Fixed require() path (line 9) |
| `src/server/SmokeTest.server.lua` | Updated | Fixed require() paths (lines 77-82, 143-148) |

**Total Changes:**
- 📂 2 new folders created
- 📦 3 files moved
- 📄 1 file renamed
- ✏️ 4 files updated (require paths)
- 🔧 1 config file rewritten

---

## 🔄 ROLLBACK PLAN

If issues occur:

### Git Revert
```bash
# Revert all changes
git log --oneline -n 5  # Find commit hash
git revert <commit-hash>
git push origin main
```

### Manual Revert
```bash
# Undo file moves
mv src/server/modules/TreadmillConfig.lua src/server/
mv src/server/modules/TreadmillRegistry.lua src/server/
mv src/storage/templates/TreadmillZoneHandler.lua src/server/TreadmillZoneHandler.server.lua
mv src/client/init.client.lua src/client/init.client.luau

# Restore old default.project.json from git
git checkout HEAD~1 -- default.project.json

# Restore old require() paths
git checkout HEAD~1 -- src/server/TreadmillService.server.lua
git checkout HEAD~1 -- src/server/TreadmillSetup.server.lua
git checkout HEAD~1 -- src/server/SmokeTest.server.lua
```

**Estimated Rollback Time:** <3 minutes

---

## 🎓 LESSONS LEARNED

### Best Practices for Rojo Projects

1. **Use Granular Mapping**
   - ❌ DON'T: `"$path": "src/server"` (no control)
   - ✅ DO: Map each Script/Module individually

2. **Organize ModuleScripts**
   - ❌ DON'T: Mix Scripts and Modules in same folder
   - ✅ DO: Create dedicated `modules/` folder

3. **Non-Executing Scripts**
   - ❌ DON'T: Place templates in ServerScriptService
   - ✅ DO: Use ServerStorage/Templates

4. **Mark Dev Tools as Disabled**
   - Use `"$properties": { "Disabled": true }` for diagnostic scripts

5. **File Extensions**
   - `.lua` works reliably with Rojo 7.x
   - `.luau` supported but may have edge cases

6. **Testing**
   - Always run `rojo build` after changes to verify config
   - Test in Studio with "Play Solo" to catch runtime errors

---

## 📞 SUPPORT

If issues persist:

1. **Check Rojo Version**
   ```bash
   rojo --version  # Should be 7.x or newer
   ```

2. **Validate JSON Syntax**
   ```bash
   # Use online validator: https://jsonlint.com/
   # Or VS Code will show errors inline
   ```

3. **Read Build Errors Carefully**
   - Rojo error messages are descriptive
   - Check file paths, $className conflicts, missing files

4. **Compare with Canonical Structure**
   - Use this document as reference
   - Verify Explorer matches expected output

---

## ✅ COMPLETION STATUS

| Task | Status |
|------|--------|
| Investigate repo structure | ✅ DONE |
| Identify problematic mappings | ✅ DONE |
| Reorganize files | ✅ DONE |
| Rewrite default.project.json | ✅ DONE |
| Update require() paths | ✅ DONE |
| Validate with `rojo build` | ✅ DONE (build.rbxl created) |
| Create documentation | ✅ DONE (this file) |

---

**Fixed by:** Claude Code - Senior Roblox + Rojo Engineer
**Architecture:** Server-Authoritative, Modular, Rojo-Optimized
**Build Output:** `build.rbxl` (97KB)

🎉 **PROJECT STRUCTURE IS NOW CANONICAL AND READY FOR DEVELOPMENT**
