# 🌐 Admin Dashboard REST API Specification

Complete API documentation for connecting external frontends (Lovable, React, Vue, etc.)

---

## 🔧 Base Configuration

```
Base URL: http://localhost:3000/api
Content-Type: application/json
```

---

## 📡 Endpoints

### 1. Health Check

**GET** `/health`

Check if the API is running and configured correctly.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-17T20:30:00.000Z",
  "universeId": "123456789",
  "environment": "development"
}
```

**Status Codes:**
- `200` - API is healthy

---

### 2. Test Connection

**GET** `/messaging/test`

Test connection to Roblox Open Cloud MessagingService.

**Response (Success):**
```json
{
  "success": true,
  "message": "Connection successful",
  "universeId": "123456789"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Universe ID not found",
  "status": 404
}
```

**Status Codes:**
- `200` - Connection test completed (check `success` field)
- `500` - Server error

**Common Errors:**
- `401` - Invalid API key
- `403` - API key lacks permissions
- `404` - Invalid Universe ID (used Place ID instead?)

---

### 3. Kick Player

**POST** `/admin/kick`

Remove a player from all game servers.

**Request Body:**
```json
{
  "userId": 123456789,
  "reason": "Violation of community rules"
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | number | Yes | Roblox User ID |
| `reason` | string | No | Kick reason (default: "Kicked by admin") |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Command sent successfully
- `400` - Missing required field
- `500` - Failed to send command

---

### 4. Ban Player

**POST** `/admin/ban`

Ban a player from all game servers.

**Request Body:**
```json
{
  "userId": 123456789,
  "reason": "Cheating detected",
  "duration": 0
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | number | Yes | Roblox User ID |
| `reason` | string | No | Ban reason (default: "Banned by admin") |
| `duration` | number | No | Ban duration in seconds (0 = permanent) |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Command sent successfully
- `400` - Missing required field
- `500` - Failed to send command

---

### 5. Send Announcement

**POST** `/admin/announce`

Broadcast a message to all players in all servers.

**Request Body:**
```json
{
  "message": "Server will restart in 10 minutes for updates!",
  "duration": 15
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `message` | string | Yes | Announcement text |
| `duration` | number | No | Display duration in seconds (default: 10) |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Announcement sent
- `400` - Missing message
- `500` - Failed to send

---

### 6. Give XP

**POST** `/admin/give-xp`

Give XP to a specific player.

**Request Body:**
```json
{
  "userId": 123456789,
  "amount": 5000
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | number | Yes | Roblox User ID |
| `amount` | number | Yes | XP amount to give |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - XP given successfully
- `400` - Missing required fields
- `500` - Failed to send command

---

### 7. Set Player Level

**POST** `/admin/set-level`

Set a player's level directly.

**Request Body:**
```json
{
  "userId": 123456789,
  "level": 50
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | number | Yes | Roblox User ID |
| `level` | number | Yes | Target level (minimum: 1) |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Level set successfully
- `400` - Missing required fields
- `500` - Failed to send command

---

### 8. Shutdown Servers

**POST** `/admin/shutdown`

Gracefully shutdown all game servers with countdown.

**Request Body:**
```json
{
  "delay": 120,
  "message": "Server maintenance - updating to v2.0"
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `delay` | number | No | Countdown in seconds (default: 60) |
| `message` | string | No | Shutdown message (default: "Server maintenance") |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Shutdown initiated
- `500` - Failed to send command

---

### 9. Send Custom Message

**POST** `/messaging/send`

Send a custom message to any MessagingService topic.

**Request Body:**
```json
{
  "topic": "CustomTopic",
  "data": {
    "type": "custom_event",
    "customField": "value"
  }
}
```

**Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `topic` | string | Yes | MessagingService topic name |
| `data` | object | Yes | Custom data object |

**Response:**
```json
{
  "success": true,
  "data": {}
}
```

**Status Codes:**
- `200` - Message sent
- `400` - Missing required fields
- `500` - Failed to send

---

## 🔒 Error Responses

All endpoints return errors in this format:

```json
{
  "success": false,
  "error": "Detailed error message"
}
```

**Common Error Messages:**

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid API key` | Wrong `ROBLOX_API_KEY` | Check `.env` file |
| `Universe ID not found` | Wrong Universe ID | Run `UniverseIDFinder.server.lua` |
| `API key lacks permissions` | Missing MessagingService permission | Add permission in API key settings |
| `Missing required fields` | Invalid request body | Check API spec |

---

## 🚀 Integration Examples

### JavaScript (Fetch)

```javascript
const API_BASE = 'http://localhost:3000/api';

// Test connection
async function testConnection() {
  const response = await fetch(`${API_BASE}/messaging/test`);
  const data = await response.json();
  console.log(data);
}

// Kick player
async function kickPlayer(userId, reason) {
  const response = await fetch(`${API_BASE}/admin/kick`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId, reason })
  });
  return await response.json();
}

// Send announcement
async function announce(message, duration = 10) {
  const response = await fetch(`${API_BASE}/admin/announce`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message, duration })
  });
  return await response.json();
}
```

### TypeScript (Axios)

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000/api',
  headers: { 'Content-Type': 'application/json' }
});

// Test connection
export async function testConnection() {
  const { data } = await api.get('/messaging/test');
  return data;
}

// Kick player
export async function kickPlayer(userId: number, reason?: string) {
  const { data } = await api.post('/admin/kick', { userId, reason });
  return data;
}

// Give XP
export async function giveXP(userId: number, amount: number) {
  const { data } = await api.post('/admin/give-xp', { userId, amount });
  return data;
}
```

### React Hook

```typescript
import { useState } from 'react';
import axios from 'axios';

const API_BASE = 'http://localhost:3000/api';

export function useAdminAPI() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const request = async (endpoint: string, method = 'GET', body?: any) => {
    setLoading(true);
    setError(null);

    try {
      const { data } = await axios({
        url: `${API_BASE}${endpoint}`,
        method,
        data: body,
      });
      return data;
    } catch (err: any) {
      const message = err.response?.data?.error || err.message;
      setError(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  };

  return {
    loading,
    error,
    testConnection: () => request('/messaging/test'),
    kickPlayer: (userId: number, reason?: string) =>
      request('/admin/kick', 'POST', { userId, reason }),
    announce: (message: string, duration?: number) =>
      request('/admin/announce', 'POST', { message, duration }),
    giveXP: (userId: number, amount: number) =>
      request('/admin/give-xp', 'POST', { userId, amount }),
    setLevel: (userId: number, level: number) =>
      request('/admin/set-level', 'POST', { userId, level }),
  };
}
```

---

## 🎮 Lovable.dev Integration

Para conectar com o frontend do Lovable:

### 1. Configure as variáveis de ambiente no Lovable

```env
VITE_API_BASE_URL=http://localhost:3000/api
```

### 2. Crie um service client

```typescript
// src/services/api.ts
const API_BASE = import.meta.env.VITE_API_BASE_URL;

export const adminAPI = {
  testConnection: () =>
    fetch(`${API_BASE}/messaging/test`).then(r => r.json()),

  kickPlayer: (userId: number, reason?: string) =>
    fetch(`${API_BASE}/admin/kick`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId, reason })
    }).then(r => r.json()),

  announce: (message: string, duration = 10) =>
    fetch(`${API_BASE}/admin/announce`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, duration })
    }).then(r => r.json()),

  giveXP: (userId: number, amount: number) =>
    fetch(`${API_BASE}/admin/give-xp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId, amount })
    }).then(r => r.json()),
};
```

### 3. Use nos componentes

```tsx
import { adminAPI } from '@/services/api';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

export function AdminPanel() {
  const handleKick = async () => {
    try {
      const result = await adminAPI.kickPlayer(123456789, "Violation");
      if (result.success) {
        toast.success("Player kicked successfully");
      }
    } catch (error) {
      toast.error("Failed to kick player");
    }
  };

  return (
    <Button onClick={handleKick}>
      Kick Player
    </Button>
  );
}
```

---

## 🔄 Rate Limits

- **Limit:** 100 requests per 15 minutes per IP
- **Response when limited:**
  ```json
  {
    "error": "Too many requests from this IP, please try again later."
  }
  ```

---

## 📝 Notes

1. All timestamps are in ISO 8601 format (UTC)
2. User IDs are Roblox User IDs (not usernames)
3. Commands are sent via MessagingService - there's a slight delay
4. Server must have `AdminCommandListener.server.lua` running
5. API key must have `messaging-service:publish` permission

---

## 🆘 Support

If you encounter issues:

1. Check `/api/health` endpoint
2. Test connection with `/api/messaging/test`
3. Verify Universe ID (not Place ID!)
4. Check API key permissions
5. Ensure game listener script is running
