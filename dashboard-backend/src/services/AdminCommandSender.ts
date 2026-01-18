/**
 * AdminCommandSender.ts
 * Publishes admin commands to Roblox game servers via Open Cloud MessagingService API
 */

import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import axios from 'axios';

// ==================== CONFIGURATION ====================

const ROBLOX_OPEN_CLOUD_API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY || '';
const ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID || '';
const ADMIN_COMMAND_SECRET = process.env.ADMIN_COMMAND_SECRET || '';
const MESSAGING_TOPIC = 'AdminCommands';

if (!ROBLOX_OPEN_CLOUD_API_KEY) {
  console.error('[AdminCommandSender] ⚠️ WARNING: ROBLOX_OPEN_CLOUD_API_KEY not configured!');
}

if (!ROBLOX_UNIVERSE_ID) {
  console.error('[AdminCommandSender] ⚠️ WARNING: ROBLOX_UNIVERSE_ID not configured!');
}

if (!ADMIN_COMMAND_SECRET || ADMIN_COMMAND_SECRET === 'CHANGE_ME_IN_PRODUCTION') {
  console.error('[AdminCommandSender] ⚠️ WARNING: ADMIN_COMMAND_SECRET not configured!');
  console.error('[AdminCommandSender] This must match the AdminCommandSecret in Roblox ServerStorage attributes');
}

// ==================== TYPES ====================

interface AdminCommand {
  commandId: string;
  timestamp: number;
  action: string;
  userId: number;
  parameters: Record<string, any>;
  signature: string;
}

interface CommandPayload {
  action: string;
  userId: number;
  parameters?: Record<string, any>;
}

interface SendCommandResult {
  success: boolean;
  commandId?: string;
  error?: string;
  details?: any;
}

// ==================== SIGNATURE GENERATION ====================

/**
 * Builds canonical string for signing (must match Roblox-side format exactly)
 * Format: commandId|timestamp|action|userId|json(parameters)
 */
function buildCanonicalPayload(command: Omit<AdminCommand, 'signature'>): string {
  const paramsJson = command.parameters && Object.keys(command.parameters).length > 0
    ? JSON.stringify(command.parameters, Object.keys(command.parameters).sort())
    : '{}';

  return [
    command.commandId,
    command.timestamp.toString(),
    command.action,
    command.userId.toString(),
    paramsJson,
  ].join('|');
}

/**
 * Generates HMAC-SHA256 signature for command
 */
function signCommand(command: Omit<AdminCommand, 'signature'>): string {
  const canonical = buildCanonicalPayload(command);

  const signature = crypto
    .createHmac('sha256', ADMIN_COMMAND_SECRET)
    .update(canonical)
    .digest('hex');

  return signature;
}

// ==================== COMMAND BUILDER ====================

/**
 * Creates a signed admin command ready for publishing
 */
function buildCommand(payload: CommandPayload): AdminCommand {
  const commandId = uuidv4();
  const timestamp = Math.floor(Date.now() / 1000); // Unix timestamp

  const unsignedCommand = {
    commandId,
    timestamp,
    action: payload.action,
    userId: payload.userId,
    parameters: payload.parameters || {},
  };

  const signature = signCommand(unsignedCommand);

  return {
    ...unsignedCommand,
    signature,
  };
}

// ==================== ROBLOX OPEN CLOUD API ====================

/**
 * Publishes a command to Roblox MessagingService via Open Cloud API
 * Docs: https://create.roblox.com/docs/cloud/reference/MessagingService
 */
async function publishToMessagingService(command: AdminCommand): Promise<SendCommandResult> {
  if (!ROBLOX_OPEN_CLOUD_API_KEY || !ROBLOX_UNIVERSE_ID) {
    return {
      success: false,
      error: 'Missing Roblox Open Cloud configuration (API key or Universe ID)',
    };
  }

  const url = `https://apis.roblox.com/messaging-service/v1/universes/${ROBLOX_UNIVERSE_ID}/topics/${MESSAGING_TOPIC}`;

  const payload = {
    message: JSON.stringify(command),
  };

  try {
    const response = await axios.post(url, payload, {
      headers: {
        'x-api-key': ROBLOX_OPEN_CLOUD_API_KEY,
        'Content-Type': 'application/json',
      },
      timeout: 10000, // 10 second timeout
    });

    if (response.status === 200) {
      console.log(`[AdminCommandSender] ✅ Published command: ${command.commandId}`);
      console.log(`[AdminCommandSender]    Action: ${command.action}`);
      console.log(`[AdminCommandSender]    UserId: ${command.userId}`);

      return {
        success: true,
        commandId: command.commandId,
      };
    } else {
      console.error(`[AdminCommandSender] ❌ Unexpected response: ${response.status}`);
      return {
        success: false,
        commandId: command.commandId,
        error: `Unexpected status code: ${response.status}`,
        details: response.data,
      };
    }
  } catch (error: any) {
    console.error(`[AdminCommandSender] ❌ Failed to publish command: ${command.commandId}`);

    if (error.response) {
      // Roblox API returned an error
      console.error(`[AdminCommandSender]    Status: ${error.response.status}`);
      console.error(`[AdminCommandSender]    Error:`, error.response.data);

      return {
        success: false,
        commandId: command.commandId,
        error: `Roblox API error: ${error.response.status}`,
        details: error.response.data,
      };
    } else if (error.request) {
      // Request was made but no response received
      console.error(`[AdminCommandSender]    No response from Roblox API`);

      return {
        success: false,
        commandId: command.commandId,
        error: 'No response from Roblox API (network error)',
      };
    } else {
      // Something else went wrong
      console.error(`[AdminCommandSender]    Error:`, error.message);

      return {
        success: false,
        commandId: command.commandId,
        error: error.message,
      };
    }
  }
}

// ==================== PUBLIC API ====================

/**
 * Sends an admin command to Roblox game servers
 *
 * @param action - The admin action to execute (e.g., "get_player_state")
 * @param userId - Target player's Roblox UserId
 * @param parameters - Action-specific parameters
 * @returns Promise with send result
 */
export async function sendCommand(
  action: string,
  userId: number,
  parameters?: Record<string, any>
): Promise<SendCommandResult> {
  console.log(`[AdminCommandSender] 📤 Sending command: ${action} for user ${userId}`);

  // Build and sign command
  const command = buildCommand({ action, userId, parameters });

  // Publish to Roblox
  const result = await publishToMessagingService(command);

  return result;
}

/**
 * Health check for command sender configuration
 */
export function getHealth() {
  return {
    configured: !!(ROBLOX_OPEN_CLOUD_API_KEY && ROBLOX_UNIVERSE_ID && ADMIN_COMMAND_SECRET),
    hasApiKey: !!ROBLOX_OPEN_CLOUD_API_KEY,
    hasUniverseId: !!ROBLOX_UNIVERSE_ID,
    hasSecret: !!ADMIN_COMMAND_SECRET && ADMIN_COMMAND_SECRET !== 'CHANGE_ME_IN_PRODUCTION',
    messagingTopic: MESSAGING_TOPIC,
  };
}

// ==================== CONVENIENCE FUNCTIONS ====================

/**
 * Get player state
 */
export function getPlayerState(userId: number): Promise<SendCommandResult> {
  return sendCommand('get_player_state', userId);
}

/**
 * Set player's Speed (TotalXP)
 */
export function setPlayerSpeed(userId: number, totalXP: number): Promise<SendCommandResult> {
  return sendCommand('set_player_speed_totalxp', userId, { totalXP });
}

/**
 * Set player's Level and XP
 */
export function setPlayerLevelXP(userId: number, level: number, xp: number): Promise<SendCommandResult> {
  return sendCommand('set_player_level_xp', userId, { level, xp });
}

/**
 * Set player's Wins
 */
export function setPlayerWins(userId: number, wins: number): Promise<SendCommandResult> {
  return sendCommand('set_player_wins', userId, { wins });
}

/**
 * Set SpeedBoost level (0-4)
 */
export function setSpeedBoost(userId: number, level: number): Promise<SendCommandResult> {
  return sendCommand('set_speedboost_level', userId, { level });
}

/**
 * Set WinBoost level (0-4)
 */
export function setWinBoost(userId: number, level: number): Promise<SendCommandResult> {
  return sendCommand('set_winboost_level', userId, { level });
}

/**
 * Set treadmill ownership
 */
export function setTreadmillOwnership(
  userId: number,
  multiplier: 3 | 9 | 25,
  owned: boolean
): Promise<SendCommandResult> {
  return sendCommand('set_treadmill_ownership', userId, { multiplier, owned });
}

/**
 * Reset player state
 */
export function resetPlayerState(userId: number, preserveTreadmills?: boolean): Promise<SendCommandResult> {
  return sendCommand('reset_player_state', userId, { preserveTreadmills: preserveTreadmills ?? false });
}

/**
 * Restrict/unrestrict player (ban)
 */
export function restrictPlayer(
  userId: number,
  restricted: boolean,
  reason?: string
): Promise<SendCommandResult> {
  return sendCommand('restrict_player', userId, { restricted, reason });
}

// ==================== EXPORT ====================

export default {
  sendCommand,
  getHealth,
  getPlayerState,
  setPlayerSpeed,
  setPlayerLevelXP,
  setPlayerWins,
  setSpeedBoost,
  setWinBoost,
  setTreadmillOwnership,
  resetPlayerState,
  restrictPlayer,
};
