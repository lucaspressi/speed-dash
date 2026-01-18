# Speed Dash Admin Dashboard Backend

Node.js/Express backend for the Speed Dash Roblox Admin Dashboard. Provides REST API endpoints to send admin commands to Roblox game servers and receive webhook responses.

## Architecture

```
Frontend Dashboard (Lovable/React)
  ↓ HTTP POST
Backend API (this service)
  ↓ Roblox Open Cloud API (MessagingService)
Roblox Game Servers
  ↓ Webhook HTTP POST
Backend Webhook Endpoint
  ↓ WebSocket/SSE (TODO)
Frontend Dashboard (real-time updates)
```

## Features

- **Admin Command Sender**: Publishes signed commands to Roblox via Open Cloud MessagingService API
- **Webhook Receiver**: Receives and validates command results from Roblox game servers
- **HMAC-SHA256 Signatures**: All commands and responses cryptographically signed
- **TypeScript**: Full type safety with Zod runtime validation
- **REST API**: Clean endpoints for all 9 admin actions
- **In-Memory Storage**: Command results cached (TODO: database integration)

## Prerequisites

- Node.js 18+ (for native fetch support)
- npm or yarn
- Roblox Open Cloud API Key with `messaging-service.publish` scope
- Roblox Universe ID (Experience ID)
- Admin secrets matching Roblox ServerStorage attributes

## Installation

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

## Configuration

### Environment Variables

Create a `.env` file in this directory:

```bash
# Server Configuration
PORT=3001
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173

# Roblox Open Cloud API
ROBLOX_OPEN_CLOUD_API_KEY=your_api_key_here
ROBLOX_UNIVERSE_ID=1234567890

# Secrets (must match Roblox ServerStorage attributes)
ADMIN_COMMAND_SECRET=64_char_hex_string_here
ADMIN_WEBHOOK_SECRET=64_char_hex_string_here
```

### Getting Roblox Open Cloud API Key

1. Go to https://create.roblox.com/credentials
2. Click "Create API Key"
3. Name: "Admin Dashboard"
4. Select your experience
5. **Required scope**: `messaging-service.publish`
6. Set expiration (recommend 1 year)
7. Copy the API key (you won't see it again!)

### Finding Universe ID

Your Universe ID is in the experience URL:

```
https://create.roblox.com/dashboard/creations/experiences/1234567890/overview
                                                            ^^^^^^^^^^
                                                            Universe ID
```

### Generating Secrets

Secrets must be 32+ characters. Generate with:

```bash
# Generate AdminCommandSecret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate AdminWebhookSecret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**CRITICAL**: These secrets MUST match the `AdminCommandSecret` and `AdminWebhookSecret` attributes in Roblox ServerStorage!

## Running the Server

### Development Mode

```bash
# Start with hot-reload
npm run dev
```

Server will start on http://localhost:3001

### Production Mode

```bash
# Build TypeScript
npm run build

# Start production server
npm start
```

## API Endpoints

### Health Checks

#### Server Health
```http
GET /health
```

Response:
```json
{
  "status": "ok",
  "environment": "development",
  "timestamp": 1234567890
}
```

#### Webhook Health
```http
GET /api/webhook/health
```

Response:
```json
{
  "status": "ok",
  "configured": true,
  "resultsInMemory": 42,
  "pendingCommands": 5
}
```

#### Admin Sender Health
```http
GET /api/admin/health
```

Response:
```json
{
  "status": "ok",
  "sender": {
    "configured": true,
    "hasApiKey": true,
    "hasUniverseId": true,
    "hasSecret": true,
    "messagingTopic": "AdminCommands"
  }
}
```

### Admin Commands

All admin endpoints:
- Use POST method
- Accept JSON request body
- Return `{ success: boolean, commandId?: string, error?: string }`
- Command ID can be used to query result via `/api/webhook/result/:commandId`

#### Get Player State
```http
POST /api/admin/get-player-state
Content-Type: application/json

{
  "userId": 123456789
}
```

#### Set Player Speed (TotalXP)
```http
POST /api/admin/set-player-speed
Content-Type: application/json

{
  "userId": 123456789,
  "totalXP": 1000000
}
```

#### Set Player Level & XP
```http
POST /api/admin/set-player-level-xp
Content-Type: application/json

{
  "userId": 123456789,
  "level": 50,
  "xp": 500
}
```

#### Set Player Wins
```http
POST /api/admin/set-player-wins
Content-Type: application/json

{
  "userId": 123456789,
  "wins": 100
}
```

#### Set SpeedBoost Level
```http
POST /api/admin/set-speedboost
Content-Type: application/json

{
  "userId": 123456789,
  "level": 3
}
```

Valid levels: 0-4 (0 = none, 1 = 2x, 2 = 4x, 3 = 8x, 4 = 16x)

#### Set WinBoost Level
```http
POST /api/admin/set-winboost
Content-Type: application/json

{
  "userId": 123456789,
  "level": 2
}
```

Valid levels: 0-4 (same multiplier formula as SpeedBoost)

#### Set Treadmill Ownership
```http
POST /api/admin/set-treadmill-ownership
Content-Type: application/json

{
  "userId": 123456789,
  "multiplier": 25,
  "owned": true
}
```

Valid multipliers: 3, 9, or 25

#### Reset Player State
```http
POST /api/admin/reset-player-state
Content-Type: application/json

{
  "userId": 123456789,
  "preserveTreadmills": false
}
```

#### Restrict Player (Ban/Unban)
```http
POST /api/admin/restrict-player
Content-Type: application/json

{
  "userId": 123456789,
  "restricted": true,
  "reason": "Exploiting"
}
```

### Webhook Endpoints

#### Query Command Result
```http
GET /api/webhook/result/:commandId
```

Response (success):
```json
{
  "commandId": "uuid-here",
  "success": true,
  "error": null,
  "data": {
    "TotalXP": 1000000,
    "Level": 50,
    "XP": 500,
    "Wins": 100
  },
  "serverJobId": "roblox-job-id",
  "placeId": "12345",
  "processedAt": "2026-01-17T12:00:00Z",
  "receivedAt": "2026-01-17T12:00:01Z",
  "verified": true
}
```

Response (not found):
```json
{
  "error": "Command result not found",
  "commandId": "uuid-here"
}
```

#### List Recent Results
```http
GET /api/webhook/results?limit=50
```

Response:
```json
{
  "count": 50,
  "total": 123,
  "results": [...]
}
```

## Security

### HMAC-SHA256 Signatures

All commands and webhook responses use HMAC-SHA256 signatures to prevent tampering.

**Command Signature** (sent to Roblox):
```
Canonical: commandId|timestamp|action|userId|json(parameters)
Signature: HMAC-SHA256(ADMIN_COMMAND_SECRET, canonical)
```

**Webhook Signature** (received from Roblox):
```
Canonical: commandId|success|serverJobId|processedAt
Signature: HMAC-SHA256(ADMIN_WEBHOOK_SECRET, canonical)
```

### Timestamp Validation

Commands expire after 60 seconds to prevent replay attacks. Clock synchronization between dashboard server and Roblox is critical.

### Secret Rotation

Rotate secrets every 90 days:

1. Generate new secrets
2. Update Roblox ServerStorage attributes
3. Update `.env` file
4. Restart backend server
5. Clear old commands from cache

## Troubleshooting

### "No response from Roblox API"

- Check `ROBLOX_OPEN_CLOUD_API_KEY` is correct
- Verify API key has `messaging-service.publish` scope
- Check API key hasn't expired
- Verify Universe ID is correct

### "Invalid signature" (webhook)

- Check `ADMIN_WEBHOOK_SECRET` matches Roblox ServerStorage attribute **exactly**
- Secrets are case-sensitive
- No extra whitespace in `.env` file

### "Command not received by Roblox"

- Verify game is published (MessagingService requires published game)
- Check "Enable API Services" is enabled in Studio settings
- Verify AdminCommandListener script is running in game
- Check Roblox game server logs

### "Player not online"

Commands only work on online players (v1 limitation). Player must be in-game when command is sent.

## Development

### Project Structure

```
dashboard-backend/
├── src/
│   ├── index.ts                    # Main Express server
│   ├── routes/
│   │   ├── admin.ts                # Admin command endpoints
│   │   └── webhook.ts              # Webhook receiver
│   └── services/
│       └── AdminCommandSender.ts   # Command signing & publishing
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

### Adding New Admin Actions

1. Add action to `AdminCommandSender.ts`:
```typescript
export function myNewAction(userId: number, params: any): Promise<SendCommandResult> {
  return sendCommand('my_new_action', userId, params);
}
```

2. Add validation schema to `admin.ts`:
```typescript
const MyActionSchema = z.object({
  userId: UserIdSchema,
  myParam: z.string(),
});
```

3. Add endpoint to `admin.ts`:
```typescript
router.post('/admin/my-action', async (req, res) => {
  // Validate, send command, track pending, return result
});
```

4. Implement action in Roblox `AdminControlFunctions.lua`

### Testing

```bash
# Test health endpoints
curl http://localhost:3001/health
curl http://localhost:3001/api/webhook/health
curl http://localhost:3001/api/admin/health

# Send test command (replace userId)
curl -X POST http://localhost:3001/api/admin/get-player-state \
  -H "Content-Type: application/json" \
  -d '{"userId": 123456789}'

# Query result (replace commandId from previous response)
curl http://localhost:3001/api/webhook/result/uuid-here
```

## TODO

- [ ] Database integration (PostgreSQL/MongoDB) to replace in-memory storage
- [ ] WebSocket/SSE for real-time frontend updates
- [ ] Audit logging (who executed which commands)
- [ ] Rate limiting per admin user
- [ ] Admin authentication/authorization
- [ ] Command queue for offline players (v2 feature)
- [ ] Metrics & monitoring (Prometheus/Grafana)
- [ ] Docker containerization
- [ ] CI/CD pipeline

## Related Documentation

- **Roblox Integration**: `../ADMIN_DASHBOARD_INTEGRATION.md`
- **Discovery Document**: `../ADMIN_DASHBOARD_DISCOVERY.md`
- **Integration Summary**: `../ADMIN_INTEGRATION_SUMMARY.md`
- **Action Schema**: `../admin_actions.json`

## License

MIT
