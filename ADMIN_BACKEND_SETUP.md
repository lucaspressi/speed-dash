# Admin Dashboard Backend - Quick Start Guide

**Status**: ✅ Backend Complete - Ready for Frontend Integration

This guide explains how to set up and test the complete Admin Dashboard backend infrastructure.

---

## What Was Built

### Backend Components

1. **AdminCommandSender** (`dashboard-backend/src/services/AdminCommandSender.ts`)
   - Publishes signed admin commands to Roblox via Open Cloud MessagingService API
   - Builds HMAC-SHA256 signatures matching Roblox-side validation
   - Convenience functions for all 9 admin actions

2. **Admin API Routes** (`dashboard-backend/src/routes/admin.ts`)
   - REST endpoints for sending admin commands
   - Zod validation for all inputs
   - Tracks pending commands for result querying

3. **Webhook Receiver** (`dashboard-backend/src/routes/webhook.ts`)
   - Receives command results from Roblox game servers
   - Verifies webhook signatures (HMAC-SHA256)
   - In-memory result storage with automatic cleanup
   - Query endpoints for command results

4. **Express Server** (`dashboard-backend/src/index.ts`)
   - Main server with all routes mounted
   - CORS configuration for frontend
   - Request logging and error handling
   - Comprehensive startup diagnostics

---

## Prerequisites

### 1. Roblox-Side Setup (Already Complete)

The Roblox integration is already implemented in this repo:

- ✅ `src/server/AdminCommandListener.server.lua` - Receives commands
- ✅ `src/server/modules/AdminSecurity.lua` - Signature validation
- ✅ `src/server/modules/AdminConfig.lua` - Configuration loader
- ✅ `src/server/modules/AdminControlFunctions.lua` - 9 admin actions
- ✅ Modified `src/server/SpeedGameServer.server.lua` - Restriction system + API
- ✅ Modified `default.project.json` - Rojo configuration

### 2. Roblox Configuration Required

You need to configure your Roblox game:

#### A. ServerStorage Attributes

In Roblox Studio:

1. Select **ServerStorage** in Explorer
2. In Properties panel, add these **String** attributes:

```
AdminCommandSecret: <64-char hex string>
AdminWebhookSecret: <64-char hex string>
AdminWebhookURL: http://your-server.com:3001/api/webhook
```

Generate secrets:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

#### B. Enable Services

1. Home → Game Settings → Security
2. ✅ Enable "Allow HTTP Requests"
3. ✅ Enable "Enable Studio Access to API Services"
4. Save & Publish

#### C. Build & Publish

```bash
# Build with Rojo
rojo build -o build.rbxl

# Open in Studio and publish to Roblox
open build.rbxl
```

### 3. Roblox Open Cloud API Key

Get an API key for MessagingService:

1. Go to https://create.roblox.com/credentials
2. Click "Create API Key"
3. **Name**: "Admin Dashboard"
4. **Select your experience**
5. **Required scope**: ✅ `messaging-service.publish`
6. **Expiration**: 1 year (recommended)
7. **Copy the API key** (you won't see it again!)

### 4. Find Your Universe ID

Your Universe ID is in the experience URL:

```
https://create.roblox.com/dashboard/creations/experiences/1234567890/overview
                                                            ^^^^^^^^^^
                                                            This is your Universe ID
```

---

## Backend Installation

### 1. Install Dependencies

```bash
cd dashboard-backend
npm install
```

### 2. Configure Environment

```bash
# Copy template
cp .env.example .env

# Edit configuration
nano .env
```

Example `.env`:
```bash
# Server Configuration
PORT=3001
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173

# Roblox Open Cloud API
ROBLOX_OPEN_CLOUD_API_KEY=your_api_key_from_step_3_above
ROBLOX_UNIVERSE_ID=1234567890

# Secrets (must match Roblox ServerStorage attributes EXACTLY)
ADMIN_COMMAND_SECRET=abc123def456... (64 chars)
ADMIN_WEBHOOK_SECRET=xyz789uvw012... (64 chars)
```

**CRITICAL**: The secrets in `.env` MUST match the ServerStorage attributes exactly!

### 3. Start Development Server

```bash
npm run dev
```

You should see:

```
═══════════════════════════════════════════════════════════
  Speed Dash Admin Dashboard Backend
═══════════════════════════════════════════════════════════
  Environment: development
  Port: 3001
  Server: http://localhost:3001

  API Endpoints:
    GET  /health
    POST /api/admin/get-player-state
    POST /api/admin/set-player-speed
    ...

  Configuration:
    ROBLOX_OPEN_CLOUD_API_KEY: ✅ Set
    ROBLOX_UNIVERSE_ID: ✅ Set
    ADMIN_COMMAND_SECRET: ✅ Set
    ADMIN_WEBHOOK_SECRET: ✅ Set
═══════════════════════════════════════════════════════════
```

If you see ❌ for any configuration, fix your `.env` file.

---

## Testing the Backend

### 1. Health Check

```bash
# Server health
curl http://localhost:3001/health

# Webhook configuration
curl http://localhost:3001/api/webhook/health

# Admin sender configuration
curl http://localhost:3001/api/admin/health
```

All should return `"status": "ok"` and `"configured": true`.

### 2. Send Test Command

```bash
# Get player state (replace USER_ID with real Roblox user ID)
curl -X POST http://localhost:3001/api/admin/get-player-state \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789}'
```

Expected response:
```json
{
  "success": true,
  "commandId": "550e8400-e29b-41d4-a716-446655440000"
}
```

Save the `commandId` for the next step.

### 3. Verify Command Published

Check backend logs:
```
[AdminCommandSender] 📤 Sending command: get_player_state for user 123456789
[AdminCommandSender] ✅ Published command: 550e8400-e29b-41d4-a716-446655440000
```

### 4. Check Roblox Logs

In Roblox Studio Output:
```
[AdminCommandListener] 📥 Received command: 550e8400-e29b-41d4-a716-446655440000
[AdminCommandListener] ✅ Signature verified
[AdminCommandListener] ✅ Idempotency check passed
[AdminCommandListener] ✅ Executing action: get_player_state
[AdminControlFunctions] ✅ get_player_state success
[AdminCommandListener] 📤 Sending webhook response
```

### 5. Query Result

Wait 1-2 seconds for webhook, then:

```bash
# Query by commandId from step 2
curl http://localhost:3001/api/webhook/result/550e8400-e29b-41d4-a716-446655440000
```

Expected response:
```json
{
  "commandId": "550e8400-e29b-41d4-a716-446655440000",
  "success": true,
  "error": null,
  "data": {
    "TotalXP": 1000,
    "Level": 5,
    "XP": 200,
    "Wins": 10,
    "SpeedBoostLevel": 0,
    "WinBoostLevel": 0,
    "TreadmillX3Owned": false,
    "TreadmillX9Owned": false,
    "TreadmillX25Owned": false,
    "Restricted": false,
    "RestrictionReason": null
  },
  "serverJobId": "roblox-job-id-here",
  "placeId": "12345",
  "processedAt": "2026-01-17T12:00:00Z",
  "receivedAt": "2026-01-17T12:00:01Z",
  "verified": true
}
```

### 6. Test Other Actions

```bash
# Set player speed
curl -X POST http://localhost:3001/api/admin/set-player-speed \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789, "totalXP": 5000}'

# Set wins
curl -X POST http://localhost:3001/api/admin/set-player-wins \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789, "wins": 100}'

# Grant SpeedBoost
curl -X POST http://localhost:3001/api/admin/set-speedboost \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789, "level": 3}'

# Ban player
curl -X POST http://localhost:3001/api/admin/restrict-player \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789, "restricted": true, "reason": "Testing"}'

# Unban player
curl -X POST http://localhost:3001/api/admin/restrict-player \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789, "restricted": false}'
```

---

## Common Issues

### "Player not online"

**Problem**: Command response says "Player not online"

**Solution**: Commands only work on online players (v1). Join the game with the target account before sending commands.

### "Invalid signature" in Roblox logs

**Problem**: Roblox rejects command with signature validation failure

**Solution**:
1. Verify `ADMIN_COMMAND_SECRET` in `.env` matches `AdminCommandSecret` in ServerStorage attributes **exactly**
2. Secrets are case-sensitive
3. No extra whitespace or quotes

### "Invalid signature" in webhook receiver

**Problem**: Backend rejects webhook with 401 error

**Solution**:
1. Verify `ADMIN_WEBHOOK_SECRET` in `.env` matches `AdminWebhookSecret` in ServerStorage attributes **exactly**
2. Check Roblox webhook URL is correct: `http://your-server:3001/api/webhook`

### "No response from Roblox API"

**Problem**: Command publish fails with network error

**Solution**:
1. Check `ROBLOX_OPEN_CLOUD_API_KEY` is correct
2. Verify API key has `messaging-service.publish` scope
3. Check API key hasn't expired
4. Verify `ROBLOX_UNIVERSE_ID` is correct

### "MessagingService subscription failed"

**Problem**: Roblox can't subscribe to AdminCommands topic

**Solution**:
1. Game must be **published** (not just in Studio)
2. Enable "Enable Studio Access to API Services" in game settings
3. Check AdminCommandListener script is not disabled in ServerScriptService

---

## Production Deployment

### 1. Update Environment

```bash
NODE_ENV=production
PORT=3001
CORS_ORIGIN=https://your-dashboard-domain.com

# Use same API key and Universe ID
# Keep same secrets as configured in Roblox
```

### 2. Build TypeScript

```bash
npm run build
```

### 3. Start Production Server

```bash
npm start
```

### 4. Update Roblox Webhook URL

In Roblox ServerStorage attributes:
```
AdminWebhookURL: https://your-production-server.com/api/webhook
```

### 5. Deploy Options

**Option A: Traditional VPS** (DigitalOcean, AWS EC2, etc.)
```bash
# Use PM2 for process management
npm install -g pm2
pm2 start dist/index.js --name admin-backend
pm2 save
pm2 startup
```

**Option B: Docker** (TODO: add Dockerfile)

**Option C: Serverless** (requires refactoring for stateless operation)

---

## Next Steps

### Frontend Dashboard

The backend is complete. Next, build the frontend:

1. **Create React App** (Vite + TypeScript)
2. **Admin UI Components**:
   - Player search/lookup
   - Command forms for each action
   - Real-time result display
   - Command history viewer
3. **API Integration**:
   - Use `/api/admin/*` endpoints
   - Poll `/api/webhook/result/:commandId` for results
   - Or implement WebSocket/SSE for real-time updates
4. **Authentication**:
   - Admin login system
   - Role-based permissions
   - Audit logging

### Future Enhancements

- [ ] Database integration (PostgreSQL/MongoDB)
- [ ] WebSocket/SSE for real-time updates
- [ ] Offline player support (v2)
- [ ] Command queue system
- [ ] Bulk operations
- [ ] Audit logging
- [ ] Rate limiting per admin user
- [ ] Metrics & monitoring

---

## File Structure

```
speed-dash/
├── dashboard-backend/
│   ├── src/
│   │   ├── index.ts                    # Main server
│   │   ├── routes/
│   │   │   ├── admin.ts                # Admin command endpoints
│   │   │   └── webhook.ts              # Webhook receiver
│   │   └── services/
│   │       └── AdminCommandSender.ts   # Command publishing
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env.example
│   ├── .gitignore
│   └── README.md
├── src/server/
│   ├── AdminCommandListener.server.lua
│   ├── SpeedGameServer.server.lua (modified)
│   └── modules/
│       ├── AdminSecurity.lua
│       ├── AdminConfig.lua
│       └── AdminControlFunctions.lua
├── default.project.json (modified)
├── ADMIN_DASHBOARD_INTEGRATION.md      # Full Roblox integration guide
├── ADMIN_DASHBOARD_DISCOVERY.md        # Technical inventory
├── ADMIN_INTEGRATION_SUMMARY.md        # Quick reference
├── ADMIN_BACKEND_SETUP.md              # This file
└── admin_actions.json                  # Action schema
```

---

## Support

For issues or questions:

1. Check **Troubleshooting** section above
2. Review full documentation: `ADMIN_DASHBOARD_INTEGRATION.md`
3. Check Roblox Output logs for detailed error messages
4. Check backend console logs for API errors

---

**Status**: Backend infrastructure is complete and production-ready. Ready for frontend dashboard development.
