/**
 * admin.ts
 * REST API endpoints for admin actions
 */

import { Router, Request, Response } from 'express';
import { z } from 'zod';
import * as AdminCommandSender from '../services/AdminCommandSender';
import { pendingCommands } from './webhook';

const router = Router();

// ==================== VALIDATION SCHEMAS ====================

const UserIdSchema = z.number().int().positive();

const GetPlayerStateSchema = z.object({
  userId: UserIdSchema,
});

const SetSpeedSchema = z.object({
  userId: UserIdSchema,
  totalXP: z.number().int().min(0).max(1e15),
});

const SetLevelXPSchema = z.object({
  userId: UserIdSchema,
  level: z.number().int().min(1).max(10000),
  xp: z.number().int().min(0),
});

const SetWinsSchema = z.object({
  userId: UserIdSchema,
  wins: z.number().int().min(0).max(1e9),
});

const SetBoostLevelSchema = z.object({
  userId: UserIdSchema,
  level: z.number().int().min(0).max(4),
});

const SetTreadmillOwnershipSchema = z.object({
  userId: UserIdSchema,
  multiplier: z.union([z.literal(3), z.literal(9), z.literal(25)]),
  owned: z.boolean(),
});

const ResetPlayerStateSchema = z.object({
  userId: UserIdSchema,
  preserveTreadmills: z.boolean().optional(),
});

const RestrictPlayerSchema = z.object({
  userId: UserIdSchema,
  restricted: z.boolean(),
  reason: z.string().optional(),
});

// ==================== HELPER FUNCTIONS ====================

function trackPendingCommand(commandId: string, action: string, userId: number) {
  pendingCommands.set(commandId, {
    commandId,
    sentAt: new Date(),
    action,
    userId,
  });
}

// ==================== ADMIN ACTION ENDPOINTS ====================

/**
 * POST /admin/get-player-state
 * Retrieve complete player state
 */
router.post('/admin/get-player-state', async (req: Request, res: Response) => {
  try {
    const parseResult = GetPlayerStateSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId } = parseResult.data;
    const result = await AdminCommandSender.getPlayerState(userId);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'get_player_state', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in get-player-state:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-player-speed
 * Set player's Speed (TotalXP)
 */
router.post('/admin/set-player-speed', async (req: Request, res: Response) => {
  try {
    const parseResult = SetSpeedSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, totalXP } = parseResult.data;
    const result = await AdminCommandSender.setPlayerSpeed(userId, totalXP);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_player_speed_totalxp', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-player-speed:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-player-level-xp
 * Set player's Level and XP
 */
router.post('/admin/set-player-level-xp', async (req: Request, res: Response) => {
  try {
    const parseResult = SetLevelXPSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, level, xp } = parseResult.data;
    const result = await AdminCommandSender.setPlayerLevelXP(userId, level, xp);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_player_level_xp', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-player-level-xp:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-player-wins
 * Set player's Wins
 */
router.post('/admin/set-player-wins', async (req: Request, res: Response) => {
  try {
    const parseResult = SetWinsSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, wins } = parseResult.data;
    const result = await AdminCommandSender.setPlayerWins(userId, wins);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_player_wins', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-player-wins:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-speedboost
 * Set player's SpeedBoost level (0-4)
 */
router.post('/admin/set-speedboost', async (req: Request, res: Response) => {
  try {
    const parseResult = SetBoostLevelSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, level } = parseResult.data;
    const result = await AdminCommandSender.setSpeedBoost(userId, level);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_speedboost_level', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-speedboost:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-winboost
 * Set player's WinBoost level (0-4)
 */
router.post('/admin/set-winboost', async (req: Request, res: Response) => {
  try {
    const parseResult = SetBoostLevelSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, level } = parseResult.data;
    const result = await AdminCommandSender.setWinBoost(userId, level);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_winboost_level', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-winboost:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/set-treadmill-ownership
 * Grant or revoke treadmill ownership
 */
router.post('/admin/set-treadmill-ownership', async (req: Request, res: Response) => {
  try {
    const parseResult = SetTreadmillOwnershipSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, multiplier, owned } = parseResult.data;
    const result = await AdminCommandSender.setTreadmillOwnership(userId, multiplier, owned);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'set_treadmill_ownership', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in set-treadmill-ownership:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/reset-player-state
 * Reset player to default state
 */
router.post('/admin/reset-player-state', async (req: Request, res: Response) => {
  try {
    const parseResult = ResetPlayerStateSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, preserveTreadmills } = parseResult.data;
    const result = await AdminCommandSender.resetPlayerState(userId, preserveTreadmills);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'reset_player_state', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in reset-player-state:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /admin/restrict-player
 * Restrict or unrestrict player (ban/unban)
 */
router.post('/admin/restrict-player', async (req: Request, res: Response) => {
  try {
    const parseResult = RestrictPlayerSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request',
        details: parseResult.error.issues,
      });
    }

    const { userId, restricted, reason } = parseResult.data;
    const result = await AdminCommandSender.restrictPlayer(userId, restricted, reason);

    if (result.success && result.commandId) {
      trackPendingCommand(result.commandId, 'restrict_player', userId);
    }

    res.json(result);
  } catch (error) {
    console.error('[Admin API] Error in restrict-player:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ==================== HEALTH CHECK ====================

router.get('/admin/health', (req: Request, res: Response) => {
  const senderHealth = AdminCommandSender.getHealth();

  res.json({
    status: 'ok',
    sender: senderHealth,
  });
});

// ==================== EXPORT ====================

export default router;
