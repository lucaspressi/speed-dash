/**
 * webhook.ts
 * Receives and processes admin command responses from Roblox game servers
 */

import { Router, Request, Response } from 'express';
import crypto from 'crypto';
import { z } from 'zod';

const router = Router();

// ==================== CONFIGURATION ====================

const WEBHOOK_SECRET = process.env.ADMIN_WEBHOOK_SECRET || '';

if (!WEBHOOK_SECRET || WEBHOOK_SECRET === 'CHANGE_ME_IN_PRODUCTION') {
  console.error('[Webhook] ⚠️ WARNING: ADMIN_WEBHOOK_SECRET not configured!');
  console.error('[Webhook] Set environment variable: ADMIN_WEBHOOK_SECRET');
}

// ==================== TYPES ====================

const WebhookResponseSchema = z.object({
  commandId: z.string().uuid(),
  success: z.boolean(),
  error: z.string().nullable(),
  data: z.record(z.any()).nullable(),
  serverJobId: z.string(),
  placeId: z.string(),
  processedAt: z.number().int(),
  signature: z.string(),
});

type WebhookResponse = z.infer<typeof WebhookResponseSchema>;

interface CommandResult {
  commandId: string;
  success: boolean;
  error: string | null;
  data: Record<string, any> | null;
  serverJobId: string;
  placeId: string;
  processedAt: Date;
  receivedAt: Date;
  verified: boolean;
}

// ==================== SIGNATURE VALIDATION ====================

function verifyWebhookSignature(response: WebhookResponse): boolean {
  if (!WEBHOOK_SECRET) {
    console.error('[Webhook] Cannot verify signature: secret not configured');
    return false;
  }

  // Canonical format: commandId|success|serverJobId|processedAt
  const canonical = [
    response.commandId,
    response.success.toString(),
    response.serverJobId,
    response.processedAt.toString(),
  ].join('|');

  // Calculate expected signature
  const expectedSignature = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(canonical)
    .digest('hex');

  // Constant-time comparison to prevent timing attacks
  try {
    return crypto.timingSafeEqual(
      Buffer.from(response.signature),
      Buffer.from(expectedSignature)
    );
  } catch (error) {
    // Signatures have different lengths
    return false;
  }
}

// ==================== IN-MEMORY STORE (Replace with Database) ====================

// TODO: Replace with PostgreSQL/MongoDB/Redis
const commandResults = new Map<string, CommandResult>();
const pendingCommands = new Map<string, {
  commandId: string;
  sentAt: Date;
  action: string;
  userId: number;
}>();

// Cleanup old results every 5 minutes
setInterval(() => {
  const now = Date.now();
  const maxAge = 24 * 60 * 60 * 1000; // 24 hours

  for (const [commandId, result] of commandResults.entries()) {
    if (now - result.receivedAt.getTime() > maxAge) {
      commandResults.delete(commandId);
    }
  }

  console.log(`[Webhook] Cleanup: ${commandResults.size} results in memory`);
}, 5 * 60 * 1000);

// ==================== WEBHOOK ENDPOINT ====================

router.post('/webhook', async (req: Request, res: Response) => {
  const receivedAt = new Date();

  try {
    // Parse and validate request body
    const parseResult = WebhookResponseSchema.safeParse(req.body);

    if (!parseResult.success) {
      console.error('[Webhook] Invalid payload:', parseResult.error);
      return res.status(400).json({
        error: 'Invalid payload',
        details: parseResult.error.issues,
      });
    }

    const response = parseResult.data;

    console.log(`[Webhook] 📥 Received response for command: ${response.commandId}`);

    // Verify signature
    const verified = verifyWebhookSignature(response);

    if (!verified) {
      console.error(`[Webhook] ❌ Signature verification failed for: ${response.commandId}`);
      return res.status(401).json({
        error: 'Invalid signature',
      });
    }

    console.log(`[Webhook] ✅ Signature verified for: ${response.commandId}`);

    // Store result
    const result: CommandResult = {
      commandId: response.commandId,
      success: response.success,
      error: response.error,
      data: response.data,
      serverJobId: response.serverJobId,
      placeId: response.placeId,
      processedAt: new Date(response.processedAt * 1000),
      receivedAt,
      verified,
    };

    commandResults.set(response.commandId, result);

    // Log result
    if (response.success) {
      console.log(`[Webhook] ✅ Command succeeded: ${response.commandId}`);
      console.log(`[Webhook]    Server: ${response.serverJobId}`);
      console.log(`[Webhook]    Data:`, JSON.stringify(response.data, null, 2));
    } else {
      console.error(`[Webhook] ❌ Command failed: ${response.commandId}`);
      console.error(`[Webhook]    Error: ${response.error}`);
      console.error(`[Webhook]    Server: ${response.serverJobId}`);
    }

    // TODO: Store in database
    // await db.commandResults.create({ data: result });

    // TODO: Notify frontend via WebSocket/SSE
    // io.emit('command-result', result);

    // TODO: Update pending command status
    pendingCommands.delete(response.commandId);

    // Respond to Roblox server
    res.json({
      received: true,
      commandId: response.commandId,
      timestamp: Date.now(),
    });
  } catch (error) {
    console.error('[Webhook] Unexpected error:', error);
    res.status(500).json({
      error: 'Internal server error',
    });
  }
});

// ==================== QUERY ENDPOINT (for frontend) ====================

router.get('/webhook/result/:commandId', (req: Request, res: Response) => {
  const { commandId } = req.params;

  const result = commandResults.get(commandId);

  if (!result) {
    return res.status(404).json({
      error: 'Command result not found',
      commandId,
    });
  }

  res.json(result);
});

// ==================== LIST RECENT RESULTS ====================

router.get('/webhook/results', (req: Request, res: Response) => {
  const limit = parseInt(req.query.limit as string) || 50;
  const results = Array.from(commandResults.values())
    .sort((a, b) => b.receivedAt.getTime() - a.receivedAt.getTime())
    .slice(0, limit);

  res.json({
    count: results.length,
    total: commandResults.size,
    results,
  });
});

// ==================== HEALTH CHECK ====================

router.get('/webhook/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    configured: !!WEBHOOK_SECRET && WEBHOOK_SECRET !== 'CHANGE_ME_IN_PRODUCTION',
    resultsInMemory: commandResults.size,
    pendingCommands: pendingCommands.size,
  });
});

// ==================== EXPORT ====================

export default router;

// Export for use in command sender
export { pendingCommands };
