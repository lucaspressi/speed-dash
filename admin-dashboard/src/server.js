// Admin Dashboard API Server for Speed Dash
// Backend-only - Frontend hosted separately (Lovable.dev)
require('dotenv').config({ path: '../.env' });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Import routes
const adminRoutes = require('./routes/admin');
const messagingRoutes = require('./routes/messaging');

// Validate environment variables
const requiredEnvVars = ['ROBLOX_UNIVERSE_ID', 'ROBLOX_API_KEY'];
const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
    console.error('❌ Missing required environment variables:');
    missingVars.forEach(varName => console.error(`   - ${varName}`));
    console.error('\n📝 Instructions:');
    console.error('1. Run UniverseIDFinder.server.lua in Roblox Studio');
    console.error('2. Copy .env.example to .env');
    console.error('3. Fill in the ROBLOX_UNIVERSE_ID and ROBLOX_API_KEY');
    console.error('4. Restart the server\n');
    process.exit(1);
}

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
        },
    },
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// CORS
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
}));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API Routes
app.use('/api/admin', adminRoutes);
app.use('/api/messaging', messagingRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        universeId: process.env.ROBLOX_UNIVERSE_ID,
        environment: process.env.NODE_ENV || 'development',
    });
});

// Root endpoint info
app.get('/', (req, res) => {
    res.json({
        name: 'Speed Dash Admin API',
        version: '1.0.0',
        status: 'running',
        endpoints: {
            health: '/api/health',
            testConnection: '/api/messaging/test',
            documentation: 'See API_SPEC.md',
        },
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        error: err.message || 'Internal server error',
    });
});

// Start server
app.listen(PORT, () => {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🎮 Speed Dash Admin API');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`✅ API running on http://localhost:${PORT}`);
    console.log(`🌐 Universe ID: ${process.env.ROBLOX_UNIVERSE_ID}`);
    console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📚 API Docs: See API_SPEC.md`);
    console.log(`🔗 Frontend: Lovable.dev (separate repo)`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\nSIGINT received, shutting down gracefully...');
    process.exit(0);
});
