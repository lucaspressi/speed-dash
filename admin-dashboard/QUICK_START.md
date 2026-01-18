# ⚡ Quick Start Guide

## ✅ Current Status

- ✅ Universe ID configured: `9545646115`
- ✅ Backend dependencies installed
- ✅ Security secrets generated
- ⚠️ **MISSING: Roblox API Key**

---

## 🔑 Step 1: Get API Key (5 minutes)

1. **Open:** https://create.roblox.com/credentials

2. **Click:** "Create API Key"

3. **Configure:**
   ```
   Name: SpeedDashAdmin

   Permissions:
   ✅ messaging-service:publish

   Experiences:
   Universe ID: 9545646115
   ```

4. **Click:** "Save & Generate Key"

5. **Copy the key** (example format):
   ```
   RBXOCLOUD-123abc...xyz789
   ```

6. **Edit `.env` file** (in project root):
   ```bash
   # Open the file
   code .env
   # Or: nano .env
   ```

7. **Replace this line:**
   ```bash
   ROBLOX_API_KEY=YOUR_API_KEY_HERE
   ```
   **With:**
   ```bash
   ROBLOX_API_KEY=RBXOCLOUD-123abc...xyz789  # Your actual key
   ```

8. **Save the file**

---

## 🚀 Step 2: Start Backend

```bash
cd admin-dashboard
npm run dev
```

You should see:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎮 Speed Dash Admin API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ API running on http://localhost:3000
🌐 Universe ID: 9545646115
📝 Environment: development
📚 API Docs: See API_SPEC.md
🔗 Frontend: Lovable.dev (separate repo)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🧪 Step 3: Test Connection

Open a new terminal and test:

```bash
# Test 1: Health check
curl http://localhost:3000/api/health

# Should return:
# {
#   "status": "healthy",
#   "timestamp": "...",
#   "universeId": "9545646115",
#   "environment": "development"
# }

# Test 2: Roblox connection
curl http://localhost:3000/api/messaging/test

# Should return:
# {
#   "success": true,
#   "message": "Connection successful",
#   "universeId": "9545646115"
# }
```

If Test 2 fails:
- ❌ API key is wrong or expired
- ❌ API key doesn't have `messaging-service:publish` permission
- ❌ Universe ID `9545646115` not added to API key

---

## 🎮 Step 4: Add Listener to Game

1. **Open** `build.rbxl` in Roblox Studio

2. **In ServerScriptService**, create new Script

3. **Copy content** from:
   ```
   /src/server/AdminCommandListener.server.lua
   ```

4. **Paste** into the script

5. **Publish** the game (File → Publish to Roblox)

6. **Press F5** to test

7. **Check Output** - should see:
   ```
   [AdminCommandListener] ✅ Subscribed to topic: AdminCommands
   [AdminCommandListener] ✅ Ready to receive commands
   ```

---

## 🎨 Step 5: Lovable Frontend

Once you share the Lovable repo link, we'll sync:

**Environment variables needed in Lovable:**
```bash
VITE_API_BASE_URL=http://localhost:3000/api
VITE_ROBLOX_UNIVERSE_ID=9545646115
VITE_ADMIN_HMAC_SECRET=a3dcba4a2f5d282f7c9156cb856e1c71495152a1ccfea468deaa7663880218e9
VITE_WEBHOOK_SECRET=2236a11bd7eb4bf425068a4d18e7964552a85bc51f597f69ffda02fa57e38ff0
```

---

## 📚 Full Documentation

- **API Spec:** `API_SPEC.md`
- **Lovable Guide:** `LOVABLE_CONFIG.md`
- **Setup Details:** `README.md`
- **Status:** `SETUP_STATUS.md`

---

## ✅ Checklist

- [ ] Got API key from create.roblox.com
- [ ] Configured `.env` with API key
- [ ] Started backend (`npm run dev`)
- [ ] Tested `/api/health` endpoint
- [ ] Tested `/api/messaging/test` endpoint
- [ ] Added `AdminCommandListener.server.lua` to game
- [ ] Published game to Roblox
- [ ] Tested listener in Studio Output
- [ ] Ready to connect Lovable frontend

---

## 🆘 Need Help?

**Backend won't start:**
- Check `.env` file exists in project root
- Verify `ROBLOX_API_KEY` is set (not placeholder text)
- Try: `npm install` again

**Connection test fails:**
- Verify API key is correct (no spaces, full key)
- Check permissions on create.roblox.com/credentials
- Ensure Universe ID `9545646115` is added to key

**Listener not working:**
- Check Output window in Studio for errors
- Verify MessagingService is enabled (Studio settings)
- Make sure game is published (not just local file)

---

🎉 **You're almost ready!** Just need to add the API key and you can start testing!
