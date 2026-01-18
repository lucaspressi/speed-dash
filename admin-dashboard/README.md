# 🎮 Speed Dash Admin API

Backend REST API for managing Speed Dash Roblox game via Roblox Open Cloud API.

**Frontend:** Hosted separately on Lovable.dev (separate repository)

## ⚡ Quick Start

### Step 1: Get Universe ID

1. Open `build.rbxl` in Roblox Studio
2. Create a new Script in ServerScriptService
3. Copy the contents of `../UniverseIDFinder.server.lua` into the script
4. Press F5 (Play Test)
5. Check Output window for the Universe ID
6. Copy the `ROBLOX_UNIVERSE_ID=...` line

### Step 2: Get API Key

1. Go to https://create.roblox.com/credentials
2. Click "Create API Key"
3. Name: `SpeedDashAdmin`
4. Enable these permissions:
   - ✅ `messaging-service:publish`
   - ✅ `universe-datastores:read` (optional, for future features)
5. Add your experience by Universe ID
6. Click "Save & Generate Key"
7. **Copy the key immediately** (you can't see it again!)

### Step 3: Configure Environment

1. Copy `.env.example` to `.env`:
   ```bash
   cp ../.env.example ../.env
   ```

2. Edit `.env`:
   ```bash
   ROBLOX_UNIVERSE_ID=123456789  # From Step 1
   ROBLOX_API_KEY=your_api_key_here  # From Step 2
   ```

### Step 4: Install & Run

```bash
# Install dependencies
npm install

# Start the dashboard
npm run dev
```

API will be available at: http://localhost:3000

---

## 📋 Features

### 👤 Player Management
- **Kick Player** - Remove player from all servers
- **Ban Player** - Ban player (requires game-side implementation)

### 📢 Announcements
- Send messages to all game servers
- Configurable display duration

### ⭐ XP & Level Management
- Give XP to players
- Set player levels directly

### 🖥️ Server Management
- Graceful server shutdown
- Connection testing

---

## 🔧 API Endpoints

### Health Check
```bash
GET /api/health
```

### Test Connection
```bash
GET /api/messaging/test
```

### Kick Player
```bash
POST /api/admin/kick
{
  "userId": 123456789,
  "reason": "Violation of rules"
}
```

### Ban Player
```bash
POST /api/admin/ban
{
  "userId": 123456789,
  "reason": "Cheating",
  "duration": 0  # 0 = permanent
}
```

### Send Announcement
```bash
POST /api/admin/announce
{
  "message": "Server restart in 5 minutes",
  "duration": 10  # seconds
}
```

### Give XP
```bash
POST /api/admin/give-xp
{
  "userId": 123456789,
  "amount": 1000
}
```

### Set Level
```bash
POST /api/admin/set-level
{
  "userId": 123456789,
  "level": 50
}
```

### Shutdown Servers
```bash
POST /api/admin/shutdown
{
  "delay": 60,  # seconds
  "message": "Server maintenance"
}
```

---

## 🎮 Game-Side Setup

To receive admin commands in your game, add this script to ServerScriptService:

```lua
-- AdminCommandListener.server.lua
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local TOPIC = "AdminCommands"

MessagingService:SubscribeAsync(TOPIC, function(message)
    local data = game:GetService("HttpService"):JSONDecode(message.Data)

    if data.type ~= "admin_command" then return end

    local command = data.command
    local params = data.params

    if command == "kick" then
        local player = Players:GetPlayerByUserId(params.userId)
        if player then
            player:Kick(params.reason)
        end

    elseif command == "ban" then
        local player = Players:GetPlayerByUserId(params.userId)
        if player then
            -- Add to ban list in DataStore
            -- Then kick
            player:Kick(params.reason)
        end

    elseif command == "announce" then
        -- Show announcement to all players
        for _, player in ipairs(Players:GetPlayers()) do
            -- Your announcement logic here
            print("[ANNOUNCEMENT] " .. params.message)
        end

    elseif command == "give_xp" then
        local player = Players:GetPlayerByUserId(params.userId)
        if player then
            -- Your XP giving logic here
        end

    elseif command == "set_level" then
        local player = Players:GetPlayerByUserId(params.userId)
        if player then
            -- Your level setting logic here
        end

    elseif command == "shutdown" then
        -- Announce shutdown
        task.wait(params.delay)
        -- Kick all players
        for _, player in ipairs(Players:GetPlayers()) do
            player:Kick(params.message)
        end
    end
end)

print("✅ Admin command listener active")
```

---

## 🔒 Security

### Current Security Measures
- Rate limiting (100 requests per 15 minutes per IP)
- Helmet.js security headers
- CORS configuration
- API key validation

### Recommended Additional Security
1. **Add authentication** to the dashboard (login system)
2. **Use HTTPS** in production
3. **Whitelist IPs** for admin access
4. **Audit logging** of all admin actions
5. **Two-factor authentication**

---

## 🚀 Production Deployment

### Environment Variables
```bash
ROBLOX_UNIVERSE_ID=123456789
ROBLOX_API_KEY=your_production_key
PORT=3000
NODE_ENV=production
```

### Docker (Optional)
```bash
# Build
docker build -t speed-dash-admin .

# Run
docker run -p 3000:3000 --env-file .env speed-dash-admin
```

---

## 🐛 Troubleshooting

### "Universe ID not found" (404 Error)
- ❌ You used **Place ID** instead of **Universe ID**
- ✅ Run `UniverseIDFinder.server.lua` and use `game.GameId` (not `game.PlaceId`)

### "Invalid API key" (401 Error)
- Check that you copied the entire API key
- Verify the key hasn't expired
- Regenerate key if needed

### "API key lacks permissions" (403 Error)
- Edit API key at https://create.roblox.com/credentials
- Enable `messaging-service:publish` permission
- Add your Universe ID to the allowed experiences

### Dashboard won't start
```bash
# Check Node version (must be >= 18)
node --version

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Check .env file exists
ls -la ../.env
```

---

## 📚 Resources

- [Roblox Open Cloud Docs](https://create.roblox.com/docs/cloud/open-cloud)
- [MessagingService API](https://create.roblox.com/docs/cloud/reference/MessagingService)
- [API Key Management](https://create.roblox.com/credentials)

---

## 📝 License

MIT
