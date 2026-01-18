// Messaging Routes
const express = require('express');
const router = express.Router();
const robloxService = require('../services/roblox');

// Test connection
router.get('/test', async (req, res) => {
    try {
        const result = await robloxService.testConnection();
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Send custom message
router.post('/send', async (req, res) => {
    try {
        const { topic, data } = req.body;

        if (!topic) {
            return res.status(400).json({
                success: false,
                error: 'Topic is required',
            });
        }

        if (!data) {
            return res.status(400).json({
                success: false,
                error: 'Data is required',
            });
        }

        const result = await robloxService.publishMessage(topic, data);
        res.json(result);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

module.exports = router;
