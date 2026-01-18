/**
 * index.ts
 * Main Express server for Speed Dash Admin Dashboard backend
 */

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import webhookRouter from './routes/webhook';
import adminRouter from './routes/admin';
import telemetryRouter from './routes/telemetry';

// Load environment variables
dotenv.config();

// ==================== CONFIGURATION ====================

const PORT = process.env.PORT || 3001;
const NODE_ENV = process.env.NODE_ENV || 'development';

// ==================== EXPRESS APP ====================

const app = express();

// ==================== MIDDLEWARE ====================

// CORS - Allow frontend to make requests
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:5173', // Vite default port
  credentials: true,
}));

// JSON body parser
app.use(express.json());

// Request logging
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// ==================== ROUTES ====================

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    environment: NODE_ENV,
    timestamp: Date.now(),
  });
});

// Webhook routes (receive responses from Roblox)
app.use('/api', webhookRouter);

// Admin routes (send commands to Roblox)
app.use('/api', adminRouter);

// Telemetry routes (receive and query logs from Roblox)
app.use('/api', telemetryRouter);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not found',
    path: req.path,
  });
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('[Server Error]', err);
  res.status(500).json({
    error: 'Internal server error',
    message: NODE_ENV === 'development' ? err.message : undefined,
  });
});

// ==================== START SERVER ====================

app.listen(PORT, () => {
  console.log('');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Speed Dash Admin Dashboard Backend');
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`  Environment: ${NODE_ENV}`);
  console.log(`  Port: ${PORT}`);
  console.log(`  Server: http://localhost:${PORT}`);
  console.log('');
  console.log('  API Endpoints:');
  console.log('    GET  /health                           - Server health check');
  console.log('    GET  /api/webhook/health               - Webhook configuration status');
  console.log('    POST /api/webhook                      - Receive command results from Roblox');
  console.log('    GET  /api/webhook/result/:commandId    - Query command result');
  console.log('    GET  /api/webhook/results              - List recent results');
  console.log('    GET  /api/admin/health                 - Admin sender status');
  console.log('    POST /api/admin/get-player-state       - Get player data');
  console.log('    POST /api/admin/set-player-speed       - Set Speed (TotalXP)');
  console.log('    POST /api/admin/set-player-level-xp    - Set Level & XP');
  console.log('    POST /api/admin/set-player-wins        - Set Wins');
  console.log('    POST /api/admin/set-speedboost         - Set SpeedBoost level');
  console.log('    POST /api/admin/set-winboost           - Set WinBoost level');
  console.log('    POST /api/admin/set-treadmill-ownership - Grant/revoke treadmill');
  console.log('    POST /api/admin/reset-player-state     - Reset player to defaults');
  console.log('    POST /api/admin/restrict-player        - Ban/unban player');
  console.log('    GET  /api/telemetry/health             - Telemetry system status');
  console.log('    POST /api/telemetry                    - Receive single log from Roblox');
  console.log('    POST /api/telemetry/batch              - Receive multiple logs');
  console.log('    GET  /api/telemetry/logs               - Query logs (filter by level, category)');
  console.log('    GET  /api/telemetry/summary            - Get log statistics');
  console.log('');
  console.log('  Configuration:');
  console.log(`    ROBLOX_OPEN_CLOUD_API_KEY: ${process.env.ROBLOX_OPEN_CLOUD_API_KEY ? '✅ Set' : '❌ Missing'}`);
  console.log(`    ROBLOX_UNIVERSE_ID: ${process.env.ROBLOX_UNIVERSE_ID ? '✅ Set' : '❌ Missing'}`);
  console.log(`    ADMIN_COMMAND_SECRET: ${process.env.ADMIN_COMMAND_SECRET ? '✅ Set' : '❌ Missing'}`);
  console.log(`    ADMIN_WEBHOOK_SECRET: ${process.env.ADMIN_WEBHOOK_SECRET ? '✅ Set' : '❌ Missing'}`);
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[Server] SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('[Server] SIGINT received, shutting down gracefully...');
  process.exit(0);
});
