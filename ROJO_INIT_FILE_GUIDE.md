# 📚 Rojo Init File Convention Guide

## 🎯 Rule of Thumb

**`init.*` files represent the PARENT container**

### ✅ WHEN TO USE `init.*` files:

Use `init.*` when you want a **module/folder structure**:

#### Example 1: Module with children
```
src/shared/MyLibrary/
├── init.lua           ← Becomes MyLibrary (ModuleScript)
├── Utils.lua          ← Child of MyLibrary
└── Config.lua         ← Child of MyLibrary
```

**Rojo mapping:**
```json
"Shared": {
  "$path": "src/shared"
}
```

**Result in Studio:**
```
ReplicatedStorage
└─ Shared
    └─ MyLibrary (ModuleScript)  ← init.lua
        ├─ Utils (ModuleScript)
        └─ Config (ModuleScript)
```

#### Example 2: Custom Folder with scripts
```
src/server/Systems/
├── init.meta.json     ← Makes Systems a Folder (not ModuleScript)
├── CombatSystem.lua
└── EconomySystem.lua
```

**init.meta.json:**
```json
{
  "className": "Folder"
}
```

**Result:**
```
ServerScriptService
└─ Systems (Folder)  ← defined by init.meta.json
    ├─ CombatSystem
    └─ EconomySystem
```

---

### ❌ WHEN NOT TO USE `init.*` files:

**NEVER use `init.*` when mapping directly to Roblox service containers:**

#### ❌ Bad Example (Your Issue):
```
src/client/
├── init.client.lua          ← PROBLEM!
├── DebugLogExporter.lua
└── TestClient.lua
```

**Mapping:**
```json
"StarterPlayerScripts": {
  "$path": "src/client"
}
```

**What Rojo tries to do:**
1. Create StarterPlayerScripts service ✅
2. `init.client.lua` says "I AM the parent"
3. But parent IS StarterPlayerScripts (a service)
4. **Conflict!** Creates duplicate Folder/Script

**Result (WRONG):**
```
StarterPlayer
├─ StarterPlayerScripts (service - gray) ✅
│   ├─ DebugLogExporter
│   └─ TestClient
└─ StarterPlayerScripts (Folder - yellow) ❌ DUPLICATE from init!
```

---

#### ✅ Good Example (Fixed):
```
src/client/
├── ClientBootstrap.client.lua   ← Regular name, no conflict!
├── DebugLogExporter.lua
└── TestClient.lua
```

**Mapping:**
```json
"StarterPlayerScripts": {
  "$path": "src/client"
}
```

**Result (CORRECT):**
```
StarterPlayer
└─ StarterPlayerScripts (service - gray) ✅
    ├─ ClientBootstrap (LocalScript)
    ├─ DebugLogExporter (LocalScript)
    └─ TestClient (LocalScript)
```

---

## 📋 Services That Should NEVER Have init Files Mapped Directly

When mapping to these Roblox services, **DON'T use init files**:

| Service | Correct Approach |
|---------|------------------|
| StarterPlayerScripts | Regular script names (Main.client.lua, Bootstrap.client.lua) |
| ServerScriptService | Regular script names (Main.server.lua, Bootstrap.server.lua) |
| StarterCharacterScripts | Regular script names |
| ReplicatedFirst | Regular script names |

**Why?** These are **built-in services** that already exist. `init` files conflict with them.

---

## 🎯 Correct Patterns By Use Case

### Pattern 1: Single Entry Point Client Script

**Goal:** One main client script that runs everything

**Folder structure:**
```
src/client/
├── Main.client.lua        ← Entry point
├── UIHandler.lua          ← Module
└── SoundManager.lua       ← Module
```

**Mapping:**
```json
"StarterPlayerScripts": {
  "$path": "src/client"
}
```

**Result:**
```
StarterPlayerScripts
├─ Main (LocalScript)       ← runs first
├─ UIHandler (ModuleScript)
└─ SoundManager (ModuleScript)
```

---

### Pattern 2: Module Library with Submodules

**Goal:** A module with organized submodules

**Folder structure:**
```
src/shared/DataManager/
├── init.lua              ← Main module (exports API)
├── Cache.lua             ← Internal submodule
└── Validation.lua        ← Internal submodule
```

**Mapping:**
```json
"Shared": {
  "$path": "src/shared"
}
```

**Result:**
```
ReplicatedStorage
└─ Shared
    └─ DataManager (ModuleScript)  ← init.lua
        ├─ Cache (ModuleScript)
        └─ Validation (ModuleScript)
```

**Usage:**
```lua
local DataManager = require(ReplicatedStorage.Shared.DataManager)
-- init.lua can require ./Cache and ./Validation internally
```

---

### Pattern 3: Multiple Independent Scripts (Your Case)

**Goal:** Multiple independent client scripts

**Folder structure:**
```
src/client/
├── ClientBootstrap.client.lua    ← Main
├── DebugLogExporter.client.lua   ← Independent
├── TestClient.client.lua         ← Independent
└── UIHandler.lua                 ← Module
```

**Mapping:**
```json
"StarterPlayerScripts": {
  "$path": "src/client"
}
```

**Result:**
```
StarterPlayerScripts
├─ ClientBootstrap (LocalScript)
├─ DebugLogExporter (LocalScript)
├─ TestClient (LocalScript)
└─ UIHandler (ModuleScript)
```

✅ **This is your current (correct) setup!**

---

## 🔍 How To Identify The Issue

### Signs of init file conflict:

1. **Duplicate containers** with same name
2. **Yellow folder icon** where service icon should be gray
3. **Scripts executing twice** (duplicate logs)
4. **"Locked" duplicate** that can't be deleted in Studio

### How to check:

```bash
# Find any init files
find src -name "init.*"

# If mapping to services, these should return NOTHING
```

---

## 🛠️ How To Fix init File Conflicts

### Step 1: Identify the problem file
```bash
find src/client -name "init.*"
# If this returns anything, you have the issue!
```

### Step 2: Rename it
```bash
# Example: rename init to Bootstrap
mv src/client/init.client.lua src/client/ClientBootstrap.client.lua
```

### Step 3: Rebuild
```bash
rm build.rbxl
rojo build -o build.rbxl
```

### Step 4: Verify
- Open build.rbxl
- Check Explorer for duplicates
- Count service instances (should be ONE)

---

## 📝 Quick Reference

| Scenario | Use init? | File Name Example |
|----------|-----------|-------------------|
| Module library with children | ✅ YES | `init.lua` |
| Custom folder with children | ✅ YES (with init.meta.json) | `init.meta.json` |
| Mapping to StarterPlayerScripts | ❌ NO | `Main.client.lua` |
| Mapping to ServerScriptService | ❌ NO | `Main.server.lua` |
| Mapping to ReplicatedStorage/Shared | ✅ MAYBE | Depends on structure |
| Single entry point script | ❌ NO | `Bootstrap.client.lua` |

---

## ✅ Your Fixed Configuration

**Before (WRONG):**
```
src/client/init.client.lua  ← Caused duplicate!
```

**After (CORRECT):**
```
src/client/ClientBootstrap.client.lua  ← No conflict!
```

**Mapping (unchanged):**
```json
"StarterPlayerScripts": {
  "$path": "src/client"
}
```

**Result:**
```
StarterPlayer
└─ StarterPlayerScripts (ONE, gray icon)
    ├─ ClientBootstrap
    ├─ DebugLogExporter
    ├─ TestClient
    └─ UIHandler
```

✅ **No duplication!**
✅ **Correct structure!**
✅ **Client scripts work!**
