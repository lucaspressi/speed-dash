# 🔧 Setup Status

## ✅ Completed

- [x] Universe ID obtained: `9545646115`
- [x] Backend API structure created
- [x] `.env` file configured with Universe ID
- [x] Security secrets generated (HMAC & Webhook)
- [x] Game-side `AdminCommandListener.server.lua` created
- [x] API documentation completed

## ⏳ Pending

### 1. Get Roblox API Key ⚠️ REQUIRED

You need to create an API key from Roblox to enable MessagingService.

**Steps:**

1. Go to: https://create.roblox.com/credentials

2. Click **"Create API Key"**

3. Configure the key:
   - **Name:** `SpeedDashAdmin`
   - **Permissions:** Enable `messaging-service:publish`
   - **Experience Access:** Add Universe ID `9545646115`

4. Click **"Save & Generate Key"**

5. **COPY THE KEY IMMEDIATELY** (you can't see it again!)

6. Open `/Users/lucassampaio/Projects/speed-dash/.env`

7. Replace this line:
   ```
   ROBLOX_API_KEY=YOUR_API_KEY_HERE
   ```
   With your actual key:
   ```
   ROBLOX_API_KEY=your_actual_key_from_roblox
   ```

### 2. Install Dependencies

```bash
cd admin-dashboard
npm install
```

### 3. Test Backend

```bash
npm run dev
```

Should see:
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

### 4. Test Connection

```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-17T...",
  "universeId": "9545646115",
  "environment": "development"
}
```

```bash
curl http://localhost:3000/api/messaging/test
```

Should return:
```json
{
  "success": true,
  "message": "Connection successful",
  "universeId": "9545646115"
}
```

### 5. Add AdminCommandListener to Game

1. Open `build.rbxl` in Roblox Studio
2. Copy content from `/src/server/AdminCommandListener.server.lua`
3. Create new Script in ServerScriptService
4. Paste the code
5. Publish the game
6. Test in-game

### 6. Lovable Frontend Sync

Waiting for Lovable repo link to sync.

---

## 📋 Configuration Summary

```bash
Universe ID: 9545646115
API Key: [PENDING - Get from create.roblox.com]
HMAC Secret: a3dcba4a2f5d282f7c9156cb856e1c71495152a1ccfea468deaa7663880218e9
Webhook Secret: 2236a11bd7eb4bf425068a4d18e7964552a85bc51f597f69ffda02fa57e38ff0
Backend Port: 3000
Environment: development
```

---

## 🔗 Quick Links

- **Create API Key:** https://create.roblox.com/credentials
- **API Documentation:** `/admin-dashboard/API_SPEC.md`
- **Lovable Integration:** `/admin-dashboard/LOVABLE_CONFIG.md`
- **Backend README:** `/admin-dashboard/README.md`

---

## 🐛 Troubleshooting

If you see errors when starting the backend:

**"Missing required environment variables"**
- Make sure `.env` file exists in project root
- Check that `ROBLOX_API_KEY` is set (not `YOUR_API_KEY_HERE`)

**"Invalid API key" (401)**
- Verify the API key is correct
- Check it hasn't expired
- Make sure you copied the entire key

**"Universe ID not found" (404)**
- Should not happen (you have the correct Universe ID: 9545646115)
- If it does, verify the key has the correct experience added

**"API key lacks permissions" (403)**
- Edit the API key at create.roblox.com/credentials
- Enable `messaging-service:publish` permission
- Add Universe ID `9545646115` to allowed experiences
