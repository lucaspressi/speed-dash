# 🎨 Lovable Frontend Configuration Guide

Complete configuration values for connecting your Lovable.dev frontend to the Speed Dash admin backend.

---

## 📋 Required Environment Variables

Add these to your Lovable project's environment variables:

```bash
# Backend API URL (change to your production URL when deploying)
VITE_API_BASE_URL=http://localhost:3000/api

# Roblox Universe ID (get from Studio - see instructions below)
VITE_ROBLOX_UNIVERSE_ID=YOUR_UNIVERSE_ID_HERE

# HMAC Secret for request signing (KEEP SECRET!)
VITE_ADMIN_HMAC_SECRET=a3dcba4a2f5d282f7c9156cb856e1c71495152a1ccfea468deaa7663880218e9

# Webhook Secret for validating Roblox webhooks (KEEP SECRET!)
VITE_WEBHOOK_SECRET=2236a11bd7eb4bf425068a4d18e7964552a85bc51f597f69ffda02fa57e38ff0
```

---

## 🔐 Generated Secrets

**ADMIN_HMAC_SECRET:**
```
a3dcba4a2f5d282f7c9156cb856e1c71495152a1ccfea468deaa7663880218e9
```

**WEBHOOK_SECRET:**
```
2236a11bd7eb4bf425068a4d18e7964552a85bc51f597f69ffda02fa57e38ff0
```

⚠️ **SECURITY WARNING:** These secrets are for development. For production, generate new secrets with:
```bash
openssl rand -hex 32  # Generate new ADMIN_HMAC_SECRET
openssl rand -hex 32  # Generate new WEBHOOK_SECRET
```

---

## 🎮 Getting Your Universe ID

### Method 1: Run UniverseIDFinder Script (Recommended)

1. Open your `build.rbxl` file in Roblox Studio
2. Open the `UniverseIDFinder.server.lua` script in the project root
3. Copy its contents
4. Create a new Script in ServerScriptService
5. Paste the code
6. Press **F5** to run the game
7. Check the **Output** window
8. Look for the line: `ROBLOX_UNIVERSE_ID=123456789`
9. Copy that number

### Method 2: Use this Quick Script

In Roblox Studio Output, paste this:
```lua
print("Universe ID: " .. game.GameId)
```

---

## 🚀 Backend Setup

Before your Lovable frontend can connect, ensure the backend is running:

### 1. Configure Backend `.env`

Create `/admin-dashboard/.env` (copy from `.env.example`):

```bash
# From UniverseIDFinder script
ROBLOX_UNIVERSE_ID=YOUR_UNIVERSE_ID_HERE

# From https://create.roblox.com/credentials
ROBLOX_API_KEY=YOUR_API_KEY_HERE

# Security secrets (use the generated ones above)
ADMIN_HMAC_SECRET=a3dcba4a2f5d282f7c9156cb856e1c71495152a1ccfea468deaa7663880218e9
WEBHOOK_SECRET=2236a11bd7eb4bf425068a4d18e7964552a85bc51f597f69ffda02fa57e38ff0

# Server config
MESSAGING_TOPIC=AdminCommands
PORT=3000
NODE_ENV=development
```

### 2. Install Dependencies

```bash
cd admin-dashboard
npm install
```

### 3. Start Backend Server

```bash
npm run dev
```

Backend will be available at: `http://localhost:3000`

---

## 📡 Lovable API Integration

### TypeScript Service Client

Create `src/services/adminAPI.ts` in your Lovable project:

```typescript
const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';

interface AdminResponse {
  success: boolean;
  data?: any;
  error?: string;
}

class AdminAPI {
  private baseUrl: string;

  constructor() {
    this.baseUrl = API_BASE;
  }

  private async request(
    endpoint: string,
    method: 'GET' | 'POST' = 'GET',
    body?: any
  ): Promise<AdminResponse> {
    try {
      const options: RequestInit = {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
      };

      if (body) {
        options.body = JSON.stringify(body);
      }

      const response = await fetch(`${this.baseUrl}${endpoint}`, options);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Request failed');
      }

      return data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Health check
  async healthCheck() {
    return this.request('/health');
  }

  // Test connection to Roblox
  async testConnection() {
    return this.request('/messaging/test');
  }

  // Kick player
  async kickPlayer(userId: number, reason?: string) {
    return this.request('/admin/kick', 'POST', { userId, reason });
  }

  // Ban player
  async banPlayer(userId: number, reason?: string, duration: number = 0) {
    return this.request('/admin/ban', 'POST', { userId, reason, duration });
  }

  // Send announcement
  async sendAnnouncement(message: string, duration: number = 10) {
    return this.request('/admin/announce', 'POST', { message, duration });
  }

  // Give XP
  async giveXP(userId: number, amount: number) {
    return this.request('/admin/give-xp', 'POST', { userId, amount });
  }

  // Set level
  async setLevel(userId: number, level: number) {
    return this.request('/admin/set-level', 'POST', { userId, level });
  }

  // Shutdown servers
  async shutdownServers(delay: number = 60, message?: string) {
    return this.request('/admin/shutdown', 'POST', { delay, message });
  }

  // Send custom message
  async sendCustomMessage(topic: string, data: any) {
    return this.request('/messaging/send', 'POST', { topic, data });
  }
}

export const adminAPI = new AdminAPI();
```

### React Hook Example

Create `src/hooks/useAdminAPI.ts`:

```typescript
import { useState } from 'react';
import { adminAPI } from '@/services/adminAPI';
import { toast } from 'sonner';

export function useAdminAPI() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleRequest = async (
    requestFn: () => Promise<any>,
    successMessage?: string
  ) => {
    setLoading(true);
    setError(null);

    try {
      const result = await requestFn();

      if (result.success) {
        if (successMessage) {
          toast.success(successMessage);
        }
        return result;
      } else {
        throw new Error(result.error || 'Request failed');
      }
    } catch (err: any) {
      const message = err.message || 'An error occurred';
      setError(message);
      toast.error(message);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  return {
    loading,
    error,

    testConnection: () =>
      handleRequest(() => adminAPI.testConnection(), 'Connected to Roblox!'),

    kickPlayer: (userId: number, reason?: string) =>
      handleRequest(
        () => adminAPI.kickPlayer(userId, reason),
        `Player ${userId} kicked successfully`
      ),

    banPlayer: (userId: number, reason?: string, duration?: number) =>
      handleRequest(
        () => adminAPI.banPlayer(userId, reason, duration),
        `Player ${userId} banned successfully`
      ),

    sendAnnouncement: (message: string, duration?: number) =>
      handleRequest(
        () => adminAPI.sendAnnouncement(message, duration),
        'Announcement sent!'
      ),

    giveXP: (userId: number, amount: number) =>
      handleRequest(
        () => adminAPI.giveXP(userId, amount),
        `Gave ${amount} XP to player ${userId}`
      ),

    setLevel: (userId: number, level: number) =>
      handleRequest(
        () => adminAPI.setLevel(userId, level),
        `Set player ${userId} to level ${level}`
      ),

    shutdownServers: (delay?: number, message?: string) =>
      handleRequest(
        () => adminAPI.shutdownServers(delay, message),
        'Server shutdown initiated'
      ),
  };
}
```

### Component Example

```tsx
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useAdminAPI } from '@/hooks/useAdminAPI';

export function KickPlayerCard() {
  const [userId, setUserId] = useState('');
  const [reason, setReason] = useState('');
  const { loading, kickPlayer } = useAdminAPI();

  const handleKick = async () => {
    if (!userId) return;

    try {
      await kickPlayer(parseInt(userId), reason);
      setUserId('');
      setReason('');
    } catch (error) {
      // Error already handled by hook
    }
  };

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold">Kick Player</h3>

      <Input
        type="number"
        placeholder="User ID"
        value={userId}
        onChange={(e) => setUserId(e.target.value)}
      />

      <Input
        type="text"
        placeholder="Reason (optional)"
        value={reason}
        onChange={(e) => setReason(e.target.value)}
      />

      <Button
        onClick={handleKick}
        disabled={loading || !userId}
        className="w-full"
      >
        {loading ? 'Kicking...' : 'Kick Player'}
      </Button>
    </div>
  );
}
```

---

## 🧪 Testing the Connection

### 1. Test Backend Health

```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-17T20:30:00.000Z",
  "universeId": "123456789",
  "environment": "development"
}
```

### 2. Test Roblox Connection

```bash
curl http://localhost:3000/api/messaging/test
```

Expected response:
```json
{
  "success": true,
  "message": "Connection successful",
  "universeId": "123456789"
}
```

### 3. Test from Lovable Frontend

In your Lovable app, add a test button:

```tsx
import { useAdminAPI } from '@/hooks/useAdminAPI';
import { Button } from '@/components/ui/button';

export function ConnectionTest() {
  const { testConnection } = useAdminAPI();

  return (
    <Button onClick={testConnection}>
      Test Connection
    </Button>
  );
}
```

---

## 🔒 Security Best Practices

### For Development:
- ✅ Use `http://localhost:3000` for API_BASE_URL
- ✅ Keep secrets in `.env` files (never commit!)
- ✅ Use the generated secrets above

### For Production:
- 🔐 Generate NEW secrets with `openssl rand -hex 32`
- 🔐 Use HTTPS for all API calls
- 🔐 Add authentication layer (JWT/OAuth)
- 🔐 Whitelist admin IPs
- 🔐 Enable CORS only for your frontend domain
- 🔐 Use environment variables in Lovable (not hardcoded)
- 🔐 Rotate secrets regularly

---

## 📚 Additional Resources

- **Full API Documentation:** See `API_SPEC.md`
- **Backend README:** See `admin-dashboard/README.md`
- **Roblox Open Cloud:** https://create.roblox.com/docs/cloud/open-cloud
- **API Key Management:** https://create.roblox.com/credentials

---

## 🐛 Troubleshooting

### "Connection refused" error
- Ensure backend is running (`npm run dev`)
- Check `VITE_API_BASE_URL` is correct
- Verify port 3000 is not blocked

### "Universe ID not found" (404)
- You used Place ID instead of Universe ID
- Run `UniverseIDFinder.server.lua` in Studio
- Use `game.GameId` not `game.PlaceId`

### "Invalid API key" (401)
- Check API key is correct in backend `.env`
- Verify key hasn't expired
- Regenerate at https://create.roblox.com/credentials

### "API key lacks permissions" (403)
- Edit API key settings
- Enable `messaging-service:publish`
- Add your Universe ID to allowed experiences

### CORS errors
- Backend should already have CORS enabled
- Check `VITE_API_BASE_URL` matches backend URL exactly
- For production, configure CORS to allow your Lovable domain

---

## ✅ Checklist

Before deploying your Lovable frontend:

- [ ] Got Universe ID from Studio
- [ ] Created Roblox API key with MessagingService permission
- [ ] Configured backend `.env` file
- [ ] Backend server running (`npm run dev`)
- [ ] Tested `/api/health` endpoint
- [ ] Tested `/api/messaging/test` endpoint
- [ ] Added environment variables to Lovable project
- [ ] Created `adminAPI.ts` service client
- [ ] Tested connection from Lovable app
- [ ] Added `AdminCommandListener.server.lua` to game
- [ ] Tested admin commands in-game

---

## 🎉 You're Ready!

Your Lovable frontend is now configured to connect to the Speed Dash admin backend. Start building your admin dashboard UI!

For complete API reference and examples, see: `API_SPEC.md`
