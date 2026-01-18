// Roblox Open Cloud API Service
const axios = require('axios');

const ROBLOX_API_BASE = 'https://apis.roblox.com';
const UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID;
const API_KEY = process.env.ROBLOX_API_KEY;

class RobloxService {
    constructor() {
        this.client = axios.create({
            baseURL: ROBLOX_API_BASE,
            headers: {
                'x-api-key': API_KEY,
                'Content-Type': 'application/json',
            },
            timeout: 10000,
        });
    }

    /**
     * Send a message to all game servers via MessagingService
     * @param {string} topic - Topic name (e.g., "AdminCommands")
     * @param {object} data - Data to send
     * @returns {Promise<object>}
     */
    async publishMessage(topic, data) {
        try {
            const url = `/messaging-service/v1/universes/${UNIVERSE_ID}/topics/${topic}`;

            const response = await this.client.post(url, {
                message: JSON.stringify(data),
            });

            console.log(`✅ Message published to topic "${topic}"`);
            return { success: true, data: response.data };
        } catch (error) {
            console.error('❌ Failed to publish message:', error.response?.data || error.message);

            // Provide helpful error messages
            if (error.response?.status === 401) {
                throw new Error('Invalid API key. Check ROBLOX_API_KEY in .env');
            } else if (error.response?.status === 403) {
                throw new Error('API key lacks MessagingService permissions');
            } else if (error.response?.status === 404) {
                throw new Error('Universe ID not found. Did you use Place ID instead of Universe ID?');
            }

            throw new Error(error.response?.data?.message || error.message);
        }
    }

    /**
     * Send admin command to game servers
     * @param {string} command - Command type (e.g., "kick", "ban", "announce")
     * @param {object} params - Command parameters
     * @returns {Promise<object>}
     */
    async sendAdminCommand(command, params) {
        const topic = process.env.MESSAGING_TOPIC || 'AdminCommands';

        const message = {
            type: 'admin_command',
            command: command,
            params: params,
            timestamp: Date.now(),
            source: 'admin_dashboard',
        };

        return await this.publishMessage(topic, message);
    }

    /**
     * Kick a player from all servers
     * @param {number} userId - Player's User ID
     * @param {string} reason - Kick reason
     * @returns {Promise<object>}
     */
    async kickPlayer(userId, reason = 'Kicked by admin') {
        return await this.sendAdminCommand('kick', {
            userId: parseInt(userId),
            reason: reason,
        });
    }

    /**
     * Ban a player (requires game to handle this)
     * @param {number} userId - Player's User ID
     * @param {string} reason - Ban reason
     * @param {number} duration - Duration in seconds (0 = permanent)
     * @returns {Promise<object>}
     */
    async banPlayer(userId, reason = 'Banned by admin', duration = 0) {
        return await this.sendAdminCommand('ban', {
            userId: parseInt(userId),
            reason: reason,
            duration: parseInt(duration),
        });
    }

    /**
     * Send announcement to all servers
     * @param {string} message - Announcement message
     * @param {number} duration - How long to show (seconds)
     * @returns {Promise<object>}
     */
    async sendAnnouncement(message, duration = 10) {
        return await this.sendAdminCommand('announce', {
            message: message,
            duration: parseInt(duration),
        });
    }

    /**
     * Give XP to a player
     * @param {number} userId - Player's User ID
     * @param {number} amount - XP amount
     * @returns {Promise<object>}
     */
    async giveXP(userId, amount) {
        return await this.sendAdminCommand('give_xp', {
            userId: parseInt(userId),
            amount: parseInt(amount),
        });
    }

    /**
     * Set player level
     * @param {number} userId - Player's User ID
     * @param {number} level - New level
     * @returns {Promise<object>}
     */
    async setLevel(userId, level) {
        return await this.sendAdminCommand('set_level', {
            userId: parseInt(userId),
            level: parseInt(level),
        });
    }

    /**
     * Shutdown all servers gracefully
     * @param {number} delay - Delay before shutdown (seconds)
     * @param {string} message - Shutdown message
     * @returns {Promise<object>}
     */
    async shutdownServers(delay = 60, message = 'Server maintenance') {
        return await this.sendAdminCommand('shutdown', {
            delay: parseInt(delay),
            message: message,
        });
    }

    /**
     * Test connection to Roblox Open Cloud
     * @returns {Promise<object>}
     */
    async testConnection() {
        try {
            // Try to publish a test message
            const topic = 'test';
            const url = `/messaging-service/v1/universes/${UNIVERSE_ID}/topics/${topic}`;

            await this.client.post(url, {
                message: JSON.stringify({ test: true }),
            });

            return {
                success: true,
                message: 'Connection successful',
                universeId: UNIVERSE_ID,
            };
        } catch (error) {
            return {
                success: false,
                message: error.message,
                status: error.response?.status,
            };
        }
    }
}

module.exports = new RobloxService();
