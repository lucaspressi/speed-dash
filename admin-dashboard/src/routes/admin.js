// Admin Routes
const express = require('express');
const router = express.Router();
const robloxService = require('../services/roblox');

// Kick player
router.post('/kick', async (req, res) => {
    try {
        const { userId, reason } = req.body;

        if (!userId) {
            return res.status(400).json({
                success: false,
                error: 'userId is required',
            });
        }

        const result = await robloxService.kickPlayer(userId, reason);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Ban player
router.post('/ban', async (req, res) => {
    try {
        const { userId, reason, duration } = req.body;

        if (!userId) {
            return res.status(400).json({
                success: false,
                error: 'userId is required',
            });
        }

        const result = await robloxService.banPlayer(userId, reason, duration);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Send announcement
router.post('/announce', async (req, res) => {
    try {
        const { message, duration } = req.body;

        if (!message) {
            return res.status(400).json({
                success: false,
                error: 'message is required',
            });
        }

        const result = await robloxService.sendAnnouncement(message, duration);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Give XP
router.post('/give-xp', async (req, res) => {
    try {
        const { userId, amount } = req.body;

        if (!userId || !amount) {
            return res.status(400).json({
                success: false,
                error: 'userId and amount are required',
            });
        }

        const result = await robloxService.giveXP(userId, amount);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Set level
router.post('/set-level', async (req, res) => {
    try {
        const { userId, level } = req.body;

        if (!userId || !level) {
            return res.status(400).json({
                success: false,
                error: 'userId and level are required',
            });
        }

        const result = await robloxService.setLevel(userId, level);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Shutdown servers
router.post('/shutdown', async (req, res) => {
    try {
        const { delay, message } = req.body;

        const result = await robloxService.shutdownServers(delay, message);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

module.exports = router;
