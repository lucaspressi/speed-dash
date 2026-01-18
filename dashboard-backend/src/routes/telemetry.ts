/**
 * telemetry.ts
 * Receives and stores telemetry/logs from Roblox game servers
 */

import express, { Request, Response } from 'express';
import fs from 'fs/promises';
import path from 'path';

const router = express.Router();

// ==================== CONFIGURATION ====================

const LOGS_DIR = path.join(__dirname, '../../logs');
const MAX_LOGS_PER_FILE = 1000;
const MAX_LOG_FILES = 10; // Keep last 10 files

// ==================== TYPES ====================

interface TelemetryLog {
  timestamp: number;
  level: 'info' | 'warn' | 'error' | 'debug';
  category: string;
  message: string;
  context?: Record<string, any>;
  serverId?: string;
  placeId?: number;
  jobId?: string;
}

// ==================== HELPER FUNCTIONS ====================

async function ensureLogsDir() {
  try {
    await fs.access(LOGS_DIR);
  } catch {
    await fs.mkdir(LOGS_DIR, { recursive: true });
  }
}

async function getCurrentLogFile(): Promise<string> {
  const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
  return path.join(LOGS_DIR, `telemetry-${date}.json`);
}

async function appendLog(log: TelemetryLog) {
  await ensureLogsDir();

  const logFile = await getCurrentLogFile();

  let logs: TelemetryLog[] = [];

  // Read existing logs
  try {
    const content = await fs.readFile(logFile, 'utf-8');
    logs = JSON.parse(content);
  } catch {
    // File doesn't exist or is invalid, start fresh
    logs = [];
  }

  // Add new log
  logs.push(log);

  // Rotate if too large
  if (logs.length > MAX_LOGS_PER_FILE) {
    const rotatedFile = path.join(
      LOGS_DIR,
      `telemetry-${Date.now()}.json`
    );
    await fs.writeFile(rotatedFile, JSON.stringify(logs.slice(0, -100), null, 2));
    logs = logs.slice(-100); // Keep last 100
  }

  // Write back
  await fs.writeFile(logFile, JSON.stringify(logs, null, 2));

  // Cleanup old files
  await cleanupOldLogs();
}

async function cleanupOldLogs() {
  try {
    const files = await fs.readdir(LOGS_DIR);
    const logFiles = files
      .filter(f => f.startsWith('telemetry-') && f.endsWith('.json'))
      .sort()
      .reverse();

    // Delete files beyond MAX_LOG_FILES
    for (let i = MAX_LOG_FILES; i < logFiles.length; i++) {
      await fs.unlink(path.join(LOGS_DIR, logFiles[i]));
    }
  } catch (err) {
    console.error('Failed to cleanup old logs:', err);
  }
}

async function readLogs(options: {
  level?: string;
  category?: string;
  limit?: number;
  since?: number;
}): Promise<TelemetryLog[]> {
  await ensureLogsDir();

  const files = await fs.readdir(LOGS_DIR);
  const logFiles = files
    .filter(f => f.startsWith('telemetry-') && f.endsWith('.json'))
    .sort()
    .reverse()
    .slice(0, 3); // Read last 3 files max

  let allLogs: TelemetryLog[] = [];

  for (const file of logFiles) {
    try {
      const content = await fs.readFile(path.join(LOGS_DIR, file), 'utf-8');
      const logs = JSON.parse(content);
      allLogs = allLogs.concat(logs);
    } catch (err) {
      console.error(`Failed to read ${file}:`, err);
    }
  }

  // Apply filters
  let filtered = allLogs;

  if (options.level) {
    filtered = filtered.filter(log => log.level === options.level);
  }

  if (options.category) {
    filtered = filtered.filter(log =>
      log.category.toLowerCase().includes(options.category!.toLowerCase())
    );
  }

  if (options.since) {
    filtered = filtered.filter(log => log.timestamp >= options.since!);
  }

  // Sort by timestamp descending (newest first)
  filtered.sort((a, b) => b.timestamp - a.timestamp);

  // Apply limit
  if (options.limit) {
    filtered = filtered.slice(0, options.limit);
  }

  return filtered;
}

// ==================== ROUTES ====================

/**
 * POST /api/telemetry
 * Receive telemetry from Roblox game server
 */
router.post('/telemetry', async (req: Request, res: Response) => {
  try {
    const { level, category, message, context, serverId, placeId, jobId } = req.body;

    // Validate required fields
    if (!level || !category || !message) {
      return res.status(400).json({
        error: 'Missing required fields: level, category, message',
      });
    }

    // Validate level
    if (!['info', 'warn', 'error', 'debug'].includes(level)) {
      return res.status(400).json({
        error: 'Invalid level. Must be: info, warn, error, or debug',
      });
    }

    const log: TelemetryLog = {
      timestamp: Date.now(),
      level,
      category,
      message,
      context,
      serverId,
      placeId,
      jobId,
    };

    await appendLog(log);

    // Also log to console for immediate visibility
    const emoji = {
      info: 'ℹ️',
      warn: '⚠️',
      error: '❌',
      debug: '🔍',
    }[level];

    console.log(`[TELEMETRY ${emoji}] [${category}] ${message}`);
    if (context) {
      console.log('  Context:', JSON.stringify(context, null, 2));
    }

    res.json({
      success: true,
      message: 'Log received',
    });
  } catch (err) {
    console.error('[Telemetry] Failed to save log:', err);
    res.status(500).json({
      error: 'Failed to save log',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

/**
 * POST /api/telemetry/batch
 * Receive multiple telemetry entries at once (more efficient)
 */
router.post('/telemetry/batch', async (req: Request, res: Response) => {
  try {
    const { logs } = req.body;

    if (!Array.isArray(logs)) {
      return res.status(400).json({
        error: 'logs must be an array',
      });
    }

    for (const logData of logs) {
      const { level, category, message, context, serverId, placeId, jobId } = logData;

      if (!level || !category || !message) {
        continue; // Skip invalid logs
      }

      const log: TelemetryLog = {
        timestamp: Date.now(),
        level,
        category,
        message,
        context,
        serverId,
        placeId,
        jobId,
      };

      await appendLog(log);
    }

    res.json({
      success: true,
      message: `Received ${logs.length} logs`,
    });
  } catch (err) {
    console.error('[Telemetry] Failed to save batch logs:', err);
    res.status(500).json({
      error: 'Failed to save logs',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

/**
 * GET /api/telemetry/logs
 * Retrieve logs with optional filters
 *
 * Query params:
 *   level: info|warn|error|debug
 *   category: string (partial match)
 *   limit: number (default: 100)
 *   since: timestamp (milliseconds)
 */
router.get('/telemetry/logs', async (req: Request, res: Response) => {
  try {
    const { level, category, limit, since } = req.query;

    const logs = await readLogs({
      level: level as string,
      category: category as string,
      limit: limit ? parseInt(limit as string) : 100,
      since: since ? parseInt(since as string) : undefined,
    });

    res.json({
      success: true,
      count: logs.length,
      logs,
    });
  } catch (err) {
    console.error('[Telemetry] Failed to read logs:', err);
    res.status(500).json({
      error: 'Failed to read logs',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

/**
 * GET /api/telemetry/summary
 * Get summary statistics about logs
 */
router.get('/telemetry/summary', async (req: Request, res: Response) => {
  try {
    const logs = await readLogs({ limit: 1000 });

    const summary = {
      total: logs.length,
      byLevel: {
        info: logs.filter(l => l.level === 'info').length,
        warn: logs.filter(l => l.level === 'warn').length,
        error: logs.filter(l => l.level === 'error').length,
        debug: logs.filter(l => l.level === 'debug').length,
      },
      byCategory: {} as Record<string, number>,
      recentErrors: logs
        .filter(l => l.level === 'error')
        .slice(0, 10)
        .map(l => ({
          timestamp: l.timestamp,
          category: l.category,
          message: l.message,
        })),
      oldestLog: logs.length > 0 ? logs[logs.length - 1].timestamp : null,
      newestLog: logs.length > 0 ? logs[0].timestamp : null,
    };

    // Count by category
    for (const log of logs) {
      summary.byCategory[log.category] = (summary.byCategory[log.category] || 0) + 1;
    }

    res.json({
      success: true,
      summary,
    });
  } catch (err) {
    console.error('[Telemetry] Failed to generate summary:', err);
    res.status(500).json({
      error: 'Failed to generate summary',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

/**
 * GET /api/telemetry/health
 * Health check for telemetry system
 */
router.get('/telemetry/health', async (req: Request, res: Response) => {
  try {
    await ensureLogsDir();

    const files = await fs.readdir(LOGS_DIR);
    const logFiles = files.filter(f => f.startsWith('telemetry-') && f.endsWith('.json'));

    res.json({
      status: 'ok',
      logsDirectory: LOGS_DIR,
      logFiles: logFiles.length,
      maxLogsPerFile: MAX_LOGS_PER_FILE,
      maxLogFiles: MAX_LOG_FILES,
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

export default router;
