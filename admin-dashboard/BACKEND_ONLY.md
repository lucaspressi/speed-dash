# 🔧 Backend API Only

This is a **backend-only** REST API server. No frontend files are included.

## 📁 Structure

```
admin-dashboard/
├── src/
│   ├── server.js           # Main Express server
│   ├── routes/
│   │   ├── admin.js        # Admin command routes
│   │   └── messaging.js    # MessagingService routes
│   └── services/
│       └── roblox.js       # Roblox Open Cloud service
├── API_SPEC.md             # Complete REST API documentation
├── LOVABLE_CONFIG.md       # Frontend integration guide
├── README.md               # Setup instructions
└── package.json            # Dependencies

```

## 🎨 Frontend

The frontend is built and hosted separately using **Lovable.dev**.

- Frontend repo: *[Will be synced soon]*
- Integration guide: See `LOVABLE_CONFIG.md`
- API documentation: See `API_SPEC.md`

## 🚀 Running the Backend

```bash
# Install dependencies
npm install

# Configure environment
cp ../.env.example ../.env
# Edit .env with your Universe ID and API key

# Start server
npm run dev
```

Server runs on: `http://localhost:3000`

## 📡 API Endpoints

All endpoints are prefixed with `/api`:

- `GET /api/health` - Health check
- `GET /api/messaging/test` - Test Roblox connection
- `POST /api/admin/kick` - Kick player
- `POST /api/admin/ban` - Ban player
- `POST /api/admin/announce` - Send announcement
- `POST /api/admin/give-xp` - Give XP
- `POST /api/admin/set-level` - Set level
- `POST /api/admin/shutdown` - Shutdown servers
- `POST /api/messaging/send` - Send custom message

## 🔗 Connecting Frontend

The Lovable frontend connects to this backend via REST API calls.

**Required environment variables for frontend:**
```bash
VITE_API_BASE_URL=http://localhost:3000/api
VITE_ROBLOX_UNIVERSE_ID=<your-universe-id>
VITE_ADMIN_HMAC_SECRET=<generated-secret>
VITE_WEBHOOK_SECRET=<generated-secret>
```

See `LOVABLE_CONFIG.md` for complete integration guide.

## ✅ What's Included

✅ Express.js REST API server
✅ Roblox Open Cloud integration
✅ MessagingService communication
✅ Security middleware (helmet, rate limiting, CORS)
✅ Complete API documentation
✅ TypeScript examples for frontend

## ❌ What's NOT Included

❌ HTML/CSS/JS frontend files
❌ Web UI or dashboard interface
❌ Static file serving

Frontend is handled by Lovable.dev (separate repo).
