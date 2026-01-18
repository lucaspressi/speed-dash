# Admin Dashboard Integration Guide

**Version**: 1.0.0
**Last Updated**: 2026-01-17
**Status**: Production-Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Configuration](#configuration)
4. [Command Payload Schema](#command-payload-schema)
5. [Available Admin Actions](#available-admin-actions)
6. [Security & Validation](#security--validation)
7. [Testing in Studio](#testing-in-studio)
8. [Dashboard Integration](#dashboard-integration)
9. [Troubleshooting](#troubleshooting)

---

## Overview

This integration allows an external admin dashboard (e.g., Lovable/Next.js) to control player state in the Roblox game securely and in real-time. Commands are sent via **MessagingService** (Roblox Open Cloud) and authenticated using **HMAC-SHA256** signatures.

### Key Features

- ✅ **Server-Authoritative**: All changes are validated and executed on the game server
- ✅ **HMAC Authentication**: Commands must be signed with a secret key
- ✅ **Timestamp Validation**: Commands expire after 60 seconds (prevents replay attacks)
- ✅ **Idempotency**: Duplicate commands are rejected (10-minute window)
- ✅ **Rate Limiting**: Max 10 commands/second per server
- ✅ **Webhook Responses**: Results are POSTed back to dashboard with signature
- ✅ **Online Players Only**: Commands only affect players currently in-game (v1)

---

## Architecture

```
┌──────────────────────────────────────────┐
│       Admin Dashboard (Lovable)          │
│  - Next.js Frontend                      │
│  - Node.js Backend                       │
└──────────────┬───────────────────────────┘
               │ Roblox Open Cloud API
               ↓
┌──────────────────────────────────────────┐
│     MessagingService (Roblox Cloud)      │
│     Topic: "AdminCommands"               │
└──────────────┬───────────────────────────┘
               │ Publishes commands
               ↓
┌──────────────────────────────────────────┐
│       Roblox Game Server(s)              │
│  ┌────────────────────────────────────┐  │
│  │ AdminCommandListener.server.lua    │  │
│  │  - Validates signature & timestamp │  │
│  │  - Checks idempotency & rate limit │  │
│  │  - Executes command                │  │
│  │  - Sends webhook response          │  │
│  └────────────┬───────────────────────┘  │
│               ↓                           │
│  ┌────────────────────────────────────┐  │
│  │ AdminControlFunctions.lua          │  │
│  │  - 9 admin actions                 │  │
│  │  - Validation & safety checks      │  │
│  └────────────┬───────────────────────┘  │
│               ↓                           │
│  ┌────────────────────────────────────┐  │
│  │ SpeedGameServer.server.lua         │  │
│  │  - PlayerData (source of truth)    │  │
│  │  - DataStore2 persistence          │  │
│  │  - Restriction enforcement         │  │
│  └────────────────────────────────────┘  │
└───────────────┬──────────────────────────┘
                │ HttpService POST
                ↓
┌──────────────────────────────────────────┐
│    Dashboard Webhook Endpoint            │
│    POST /api/webhook                     │
│    (receives command results)            │
└──────────────────────────────────────────┘
```

---

## Configuration

### Step 1: Set ServerStorage Attributes

In Roblox Studio:

1. Open Explorer panel
2. Select **ServerStorage** (NOT ReplicatedStorage)
3. In Properties panel, click "+" next to Attributes
4. Add these three **String** attributes:

| Attribute Name | Type | Example Value |
|----------------|------|---------------|
| `AdminCommandSecret` | String | `your-secret-key-min-32-chars` |
| `AdminWebhookSecret` | String | `another-secret-key-min-32-chars` |
| `AdminWebhookURL` | String | `https://your-dashboard.com/api/webhook` |

**Important Security Notes**:
- ✅ **ServerStorage attributes are SERVER-ONLY** (never replicate to clients)
- ✅ Use strong random secrets (min 32 characters)
- ✅ Rotate secrets every 90 days
- ✅ Use different secrets for Command vs Webhook
- ✅ Never commit secrets to git

### Step 2: Generate Strong Secrets

Use a secure random generator:

```bash
# Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Python
python3 -c "import secrets; print(secrets.token_hex(32))"

# Online: https://1password.com/password-generator/
```

### Step 3: Configure Webhook URL

Your dashboard backend must expose a POST endpoint:

```
POST https://your-dashboard.com/api/webhook
Content-Type: application/json

{
  "commandId": "...",
  "success": true,
  "data": {...},
  "serverJobId": "...",
  "placeId": "...",
  "processedAt": 1700000001,
  "signature": "hmac-sha256-hex"
}
```

### Step 4: Enable HttpService

In Roblox Studio:
1. Home → Game Settings → Security
2. Enable "Allow HTTP Requests"
3. Save & Publish

### Step 5: Verify Configuration

In Studio Output, you should see:

```
[AdminConfig] ✅ Admin Dashboard configuration loaded successfully
[AdminCommandListener] ✅ Configuration loaded successfully
[AdminCommandListener] ✅ Subscribed to MessagingService topic: AdminCommands
[AdminCommandListener] Ready to receive admin commands
```

---

## Command Payload Schema

### Incoming Command (Dashboard → Roblox)

```json
{
  "commandId": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": 1705507200,
  "action": "set_player_wins",
  "userId": 123456789,
  "parameters": {
    "wins": 100
  },
  "signature": "abc123..."
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `commandId` | string (UUID) | ✅ | Unique identifier (prevents duplicates) |
| `timestamp` | number (unix) | ✅ | Current unix timestamp (expires in 60s) |
| `action` | string | ✅ | Action name (see Available Actions) |
| `userId` | number | ✅ | Roblox UserId (NOT username) |
| `parameters` | object | ❌ | Action-specific parameters |
| `signature` | string (hex) | ✅ | HMAC-SHA256 signature |

### Signature Calculation

**Canonical String** (fields concatenated with `|`):
```
commandId|timestamp|action|userId|json(parameters)
```

**Important**: `parameters` JSON must have **sorted keys** for stability.

**Example** (Node.js):
```javascript
const crypto = require('crypto');

function signCommand(command, secret) {
  // Sort parameters keys
  const sortedParams = {};
  Object.keys(command.parameters || {})
    .sort()
    .forEach(key => {
      sortedParams[key] = command.parameters[key];
    });

  // Build canonical string
  const canonical = [
    command.commandId,
    command.timestamp,
    command.action,
    command.userId,
    JSON.stringify(sortedParams)
  ].join('|');

  // Calculate HMAC
  const signature = crypto
    .createHmac('sha256', secret)
    .update(canonical)
    .digest('hex');

  return signature;
}
```

### Outgoing Response (Roblox → Dashboard)

```json
{
  "commandId": "550e8400-e29b-41d4-a716-446655440000",
  "success": true,
  "error": null,
  "data": {
    "Wins": 100
  },
  "serverJobId": "abc-123-def-456",
  "placeId": "987654321",
  "processedAt": 1705507201,
  "signature": "def456..."
}
```

### Response Signature Calculation

**Canonical String**:
```
commandId|success|serverJobId|processedAt
```

**Example** (Node.js):
```javascript
function verifyWebhookSignature(response, secret) {
  const canonical = [
    response.commandId,
    response.success,
    response.serverJobId,
    response.processedAt
  ].join('|');

  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(canonical)
    .digest('hex');

  return response.signature === expectedSignature;
}
```

---

## Available Admin Actions

### 1. `get_player_state`

Get complete player data snapshot.

**Parameters**: None

**Response**:
```json
{
  "success": true,
  "data": {
    "userId": 123456789,
    "username": "Player1",
    "TotalXP": 1000000,
    "Level": 50,
    "Wins": 250,
    "SpeedBoostLevel": 2,
    "TreadmillX3Owned": true,
    "Restricted": false,
    ...
  }
}
```

---

### 2. `set_player_speed_totalxp`

Set player TotalXP directly (forces Speed = X, including Speed = 1).

**Parameters**:
- `totalXP` (number, required): New TotalXP value (≥ 0)

**Example**:
```json
{
  "action": "set_player_speed_totalxp",
  "userId": 123456789,
  "parameters": {
    "totalXP": 5000000
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "TotalXP": 5000000,
    "Level": 75,
    "XP": 12500,
    "XPRequired": 50000
  }
}
```

**Side Effects**:
- Recalculates Level/XP from TotalXP
- Updates WalkSpeed
- Syncs leaderstats & UI

---

### 3. `set_player_level_xp`

Set Level and XP directly (also recalculates TotalXP).

**Parameters**:
- `level` (number, required): New Level (1-10000)
- `xp` (number, optional): XP into level (0 to XPRequired-1, default: 0)

**Example**:
```json
{
  "action": "set_player_level_xp",
  "userId": 123456789,
  "parameters": {
    "level": 100,
    "xp": 5000
  }
}
```

---

### 4. `set_player_wins`

Set Wins to exact value.

**Parameters**:
- `wins` (number, required): New Wins count (≥ 0)

**Example**:
```json
{
  "action": "set_player_wins",
  "userId": 123456789,
  "parameters": {
    "wins": 1000
  }
}
```

---

### 5. `set_speedboost_level`

Grant or remove SpeedBoost multiplier.

**Parameters**:
- `level` (number, required): Boost level (0-4)
  - 0 = 1x (none)
  - 1 = 2x
  - 2 = 4x
  - 3 = 8x
  - 4 = 16x

**Example**:
```json
{
  "action": "set_speedboost_level",
  "userId": 123456789,
  "parameters": {
    "level": 3
  }
}
```

---

### 6. `set_winboost_level`

Grant or remove WinsBoost multiplier (same formula as SpeedBoost).

**Parameters**:
- `level` (number, required): Boost level (0-4)

---

### 7. `set_treadmill_ownership`

Grant or revoke paid treadmill access.

**Parameters**:
- `multiplier` (number, required): 3, 9, or 25
- `owned` (boolean, required): true to grant, false to revoke

**Example**:
```json
{
  "action": "set_treadmill_ownership",
  "userId": 123456789,
  "parameters": {
    "multiplier": 25,
    "owned": true
  }
}
```

---

### 8. `reset_player_state`

Reset player to default values (like new player).

**Parameters**:
- `preserveTreadmills` (boolean, optional): Keep treadmill ownership (default: false)

**Example**:
```json
{
  "action": "reset_player_state",
  "userId": 123456789,
  "parameters": {
    "preserveTreadmills": true
  }
}
```

**Resets**:
- TotalXP → 0
- Level → 1
- XP → 0
- Wins → 0
- Rebirths → 0
- SpeedBoostLevel → 0
- WinBoostLevel → 0
- Restricted → false
- Treadmills → false (unless preserveTreadmills = true)

---

### 9. `restrict_player`

Add/remove player restriction (blocks XP gain, wins, rebirth, equip).

**Parameters**:
- `restricted` (boolean, required): true to restrict, false to unrestrict
- `reason` (string, optional): Reason for restriction

**Example**:
```json
{
  "action": "restrict_player",
  "userId": 123456789,
  "parameters": {
    "restricted": true,
    "reason": "Exploiting treadmill glitch"
  }
}
```

**Effects When Restricted**:
- ❌ Cannot gain XP (UpdateSpeed blocked)
- ❌ Cannot win (WinBlock blocked)
- ❌ Cannot rebirth (Rebirth blocked)
- ❌ Cannot equip Step Awards (EquipStepAward blocked)
- ✅ Can still move and chat

---

## Security & Validation

### Validation Rules (enforced)

| Field | Min | Max | Notes |
|-------|-----|-----|-------|
| TotalXP | 0 | ∞ | Cannot be negative |
| Level | 1 | 10000 | Clipped to range |
| XP | 0 | XPRequired-1 | Must fit within level |
| Wins | 0 | ∞ | Cannot be negative |
| SpeedBoost Level | 0 | 4 | Levels 5-6 not configured |
| WinBoost Level | 0 | 4 | Levels 5-6 not configured |
| Treadmill Multiplier | - | - | Must be 3, 9, or 25 |

### Security Layers

1. **Timestamp Validation**: Commands older than 60s are rejected
2. **Signature Validation**: HMAC-SHA256 with secret key
3. **Idempotency Check**: Duplicate commandId rejected (10-min window)
4. **Rate Limiting**: Max 10 commands/sec per server
5. **Player Online Check**: Only affects players currently in-game
6. **Input Validation**: All parameters validated against rules

### Error Responses

```json
{
  "success": false,
  "error": "Player not online (userId: 123456789)",
  "data": null
}
```

Common errors:
- `"Player not online (userId: X)"`
- `"Player data not loaded (userId: X)"`
- `"Timestamp expired (age: Xs, max: 60s)"`
- `"Signature validation failed"`
- `"Duplicate commandId (already processed)"`
- `"Rate limit exceeded (max 10 commands/sec)"`
- `"TotalXP cannot be negative"`
- `"Level must be between 1 and 10000"`

---

## Testing in Studio

### Method 1: Local Command Test (No MessagingService)

In Studio Command Bar:

```lua
_G.AdminCommandTest({
  commandId = "test-" .. game:GetService("HttpService"):GenerateGUID(false),
  timestamp = os.time(),
  action = "get_player_state",
  userId = game.Players:GetPlayers()[1].UserId,
  parameters = {},
  signature = "dummy" -- Signature check will fail, but structure is validated
})
```

**Note**: Signature validation will fail unless you calculate the real HMAC. This is useful for testing command structure and execution logic.

### Method 2: Bypass Signature (Development Only)

Temporarily comment out signature check in `AdminCommandListener.server.lua`:

```lua
-- Validation: Signature
-- valid, validErr = AdminSecurity.validateSignature(command, commandSecret)
-- if not valid then
--   response.error = "Signature validation failed: " .. validErr
--   warn("[AdminCommandListener] ❌ " .. response.error)
--   sendWebhookResponse(response)
--   return
-- end
```

**⚠️ WARNING**: Remove this bypass before production!

### Method 3: Full Integration Test (with MessagingService)

1. Publish game to Roblox
2. Enable API Services: Home → Game Settings → Security → Enable Studio Access to API Services
3. Use Roblox Open Cloud API to publish message:

```bash
curl -X POST "https://apis.roblox.com/messaging-service/v1/universes/{universeId}/topics/AdminCommands" \
  -H "x-api-key: YOUR_OPEN_CLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "{\"commandId\":\"test-123\",\"timestamp\":1705507200,\"action\":\"get_player_state\",\"userId\":123456789,\"parameters\":{},\"signature\":\"abc123...\"}"
  }'
```

---

## Dashboard Integration

### Publishing Commands (Node.js Example)

```javascript
const axios = require('axios');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');

const ROBLOX_UNIVERSE_ID = 'your-universe-id';
const ROBLOX_API_KEY = 'your-open-cloud-api-key';
const COMMAND_SECRET = 'your-admin-command-secret';

async function sendAdminCommand(action, userId, parameters = {}) {
  const command = {
    commandId: uuidv4(),
    timestamp: Math.floor(Date.now() / 1000),
    action,
    userId,
    parameters
  };

  // Sign command
  const sortedParams = {};
  Object.keys(parameters).sort().forEach(key => {
    sortedParams[key] = parameters[key];
  });

  const canonical = [
    command.commandId,
    command.timestamp,
    command.action,
    command.userId,
    JSON.stringify(sortedParams)
  ].join('|');

  command.signature = crypto
    .createHmac('sha256', COMMAND_SECRET)
    .update(canonical)
    .digest('hex');

  // Publish to MessagingService
  const response = await axios.post(
    `https://apis.roblox.com/messaging-service/v1/universes/${ROBLOX_UNIVERSE_ID}/topics/AdminCommands`,
    {
      message: JSON.stringify(command)
    },
    {
      headers: {
        'x-api-key': ROBLOX_API_KEY,
        'Content-Type': 'application/json'
      }
    }
  );

  return command.commandId;
}

// Usage
await sendAdminCommand('set_player_wins', 123456789, { wins: 1000 });
```

### Receiving Webhook Responses (Express Example)

```javascript
const express = require('express');
const crypto = require('crypto');

const app = express();
app.use(express.json());

const WEBHOOK_SECRET = 'your-admin-webhook-secret';

app.post('/api/webhook', (req, res) => {
  const response = req.body;

  // Verify signature
  const canonical = [
    response.commandId,
    response.success,
    response.serverJobId,
    response.processedAt
  ].join('|');

  const expectedSignature = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(canonical)
    .digest('hex');

  if (response.signature !== expectedSignature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  // Process response
  console.log('Command result:', response);

  // Store in database, notify frontend, etc.

  res.json({ received: true });
});

app.listen(3000);
```

---

## Troubleshooting

### "Player not online" Error

**Cause**: Player is not currently in the game server.

**Solution**: Commands only work on online players (v1). Check player is in-game before sending command.

### "Signature validation failed"

**Causes**:
1. Secret mismatch (dashboard vs ServerStorage attribute)
2. Incorrect canonical string format
3. Parameters JSON not sorted

**Solution**:
- Verify secrets match exactly
- Log canonical strings on both sides
- Sort parameter keys before JSON.stringify()

### "Timestamp expired"

**Cause**: Command took > 60s to reach server, or clock skew.

**Solution**:
- Use `Math.floor(Date.now() / 1000)` for current timestamp
- Check server clocks are synchronized (NTP)
- Reduce network latency

### "Idempotency check failed"

**Cause**: Same commandId sent twice within 10 minutes.

**Solution**: Use unique UUIDs for each command (e.g., `uuid.v4()`)

### "AdminCommandSecret not configured"

**Cause**: ServerStorage attributes not set.

**Solution**: Follow [Configuration](#configuration) steps above.

### "MessagingService subscription failed"

**Causes**:
1. API Services not enabled in Studio
2. Game not published to Roblox
3. MemoryStoreService not available (Beta)

**Solution**:
- Enable API Services: Game Settings → Security
- Publish game to Roblox (not local .rbxl file)

### No webhook responses received

**Causes**:
1. Webhook URL incorrect
2. HttpService disabled
3. Firewall blocking outbound requests

**Solution**:
- Verify webhook URL in ServerStorage attribute
- Enable HttpService: Game Settings → Security → Allow HTTP Requests
- Check server logs for HTTP errors

---

## Production Checklist

Before deploying to production:

- [ ] Strong secrets configured (32+ chars, random)
- [ ] Secrets stored securely (env vars, not code)
- [ ] Webhook URL uses HTTPS (not HTTP)
- [ ] Signature validation enabled (not bypassed)
- [ ] Rate limiting tested (10 commands/sec)
- [ ] Idempotency tested (duplicate rejection)
- [ ] Audit logging implemented (dashboard side)
- [ ] Error handling tested (offline players, invalid params)
- [ ] Monitoring setup (command success rate, latency)
- [ ] Secret rotation plan (every 90 days)

---

## Support & Feedback

For issues or questions:
1. Check Studio Output for error messages
2. Review webhook responses for error details
3. Test commands locally using `_G.AdminCommandTest()`
4. Verify configuration in ServerStorage attributes

---

**End of Documentation**
