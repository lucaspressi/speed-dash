# Speed Dash - Roblox Speed Simulator

A high-performance Roblox speed simulator game with treadmill mechanics, progressive leveling, rebirth system, and gamepass integration.

**Status:** ✅ All systems operational (2026-01-17)

## 🚀 Quick Start

### Option 1: Quick Script Testing (5 seconds)
```bash
./open-and-fix.sh
```
Opens build.rbxl with all scripts and 3 test zones. Great for rapid iteration on server logic.

### Option 2: Full Development (with UI and map)
```bash
./setup-rojo-serve.sh
```
Then in Studio: Open your original .rbxl → Click Rojo → Connect

📖 **See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for detailed workflow guide**

---

## 📚 Documentation

- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - One-page workflow cheat sheet
- **[WORKFLOWS_GUIDE.md](WORKFLOWS_GUIDE.md)** - Complete development workflows guide
- **[FIX_FINAL_INSTRUCTIONS.md](FIX_FINAL_INSTRUCTIONS.md)** - Troubleshooting and setup instructions
- **[BUILD_TESTAVEL_STATUS.md](BUILD_TESTAVEL_STATUS.md)** - What's included in build.rbxl

---

## 🎮 Game Features

### Core Systems
- **TreadmillService** - Multi-zone treadmill system with auto-detection
- **Speed/Level/XP** - Progressive leveling with exponential scaling
- **Rebirth System** - Prestige system with permanent multipliers
- **Step Awards** - Milestone rewards based on wins
- **Gamepass Integration** - Premium treadmills (x9, x25, x50, x100, etc.)

### Technical Highlights
- Server-authoritative architecture
- Spatial grid indexing for O(1) zone lookups
- RemoteEvents bootstrap system (17 remotes)
- DataStore2 integration for persistence
- Auto-setup wizard for 60+ treadmill zones
- Comprehensive test suite (28 tests)

---

## 🛠️ Project Structure

```
speed-dash/
├── src/
│   ├── server/           # Server scripts
│   │   ├── modules/      # Shared server modules
│   │   ├── RemotesBootstrap.server.lua
│   │   ├── SpeedGameServer.server.lua
│   │   ├── TreadmillService.server.lua
│   │   ├── TreadmillSetupWizard.server.lua
│   │   └── ...
│   ├── client/           # Client scripts
│   │   ├── init.client.lua
│   │   └── UIHandler.lua
│   ├── shared/           # Shared modules
│   └── storage/          # Templates
├── build.rbxl            # Test build (3 zones, no UI)
├── default.project.json  # Rojo configuration
└── *.sh                  # Automation scripts
```

---

## 🔧 Development Workflows

### Workflow A: Script Testing (build.rbxl)
**Best for:** Rapid testing of server logic without UI distractions

**Includes:**
- ✅ All scripts (server + client)
- ✅ TreadmillService (3 test zones)
- ✅ WinBlocks (3 test blocks)
- ✅ Auto-configured attributes
- ❌ No UI (SpeedGameUI)

**Run:** `./open-and-fix.sh`

### Workflow B: Full Development (rojo serve)
**Best for:** Complete game testing with UI, all zones, and live sync

**Includes:**
- ✅ All scripts (live synced)
- ✅ Full UI (SpeedGameUI)
- ✅ 60+ treadmill zones
- ✅ Complete map
- ✅ Instant updates on save

**Run:** `./setup-rojo-serve.sh`

📖 **Full comparison:** [WORKFLOWS_GUIDE.md](WORKFLOWS_GUIDE.md)

---

## ✅ Expected Output (Success)

When you run Play Solo, you should see:
```
[RemotesBootstrap] ✅ All remotes ready for use
[AutoSetup] ✅ Auto-setup complete: 3 treadmills configured
[TreadmillService] ✅ TreadmillService initialized with 3 zones
[SpeedGameServer] ✅ Player data loaded for [Player]
```

**Zero concatenation errors = Success!**

---

## 🐛 Troubleshooting

**"attempt to concatenate table with string"**
→ You're opening an old file! Run `./open-and-fix.sh`

**"NO VALID ZONES FOUND"**
→ Run TreadmillSetupWizard: ServerScriptService → Right-click → Run

**"Buttons/UI don't appear"**
→ Use Workflow B (rojo serve + original file), not build.rbxl

**"Scripts don't update"**
→ Check Rojo connection in Studio and terminal is open

📖 **Full troubleshooting:** [FIX_FINAL_INSTRUCTIONS.md](FIX_FINAL_INSTRUCTIONS.md)

---

## 🧪 Testing

Run tests in Studio:
1. Open build.rbxl
2. ServerScriptService → SmokeTest → Run
3. Check Output for test results

**Current Status:** 28/32 tests passing (4 DataStore tests require published game)

---

## 📦 Manual Build

To build the place from scratch:
```bash
rojo build -o build.rbxl
```

To start the sync server:
```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).

---

## 📝 Recent Fixes (2026-01-17)

- ✅ Fixed TreadmillRegistry syntax error (missing 'end')
- ✅ Fixed VerifyGroup remote type (RemoteEvent → RemoteFunction)
- ✅ Fixed 6 client concatenation errors (added tostring())
- ✅ Added AutoSetupTreadmills for test zones
- ✅ Created comprehensive documentation and automation scripts

**All critical blockers resolved. Game fully operational.**

---

## 🤝 Contributing

This project uses:
- [Rojo](https://github.com/rojo-rbx/rojo) 7.6.1 for project management
- [DataStore2](https://github.com/Kampfkarren/Roblox) for data persistence
- Luau for scripting

---

**Last Updated:** 2026-01-17
**Build Status:** ✅ Passing (28/32 tests)
**Rojo Version:** 7.6.1