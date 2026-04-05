const express = require('express');
const { query: dbQuery } = require('../config/database');
const logger = require('../config/logger');

const router = express.Router();

// GET /api/v1/health — system health check
router.get('/', async (req, res) => {
  try {
    const dbStart = Date.now();
    await dbQuery('SELECT 1');
    const dbLatency = Date.now() - dbStart;

    const usersResult = await dbQuery('SELECT COUNT(*) as count FROM users');
    const doctorsResult = await dbQuery('SELECT COUNT(*) as count FROM doctors WHERE is_active = true');
    const patientsResult = await dbQuery('SELECT COUNT(*) as count FROM patients WHERE is_active = true');
    const appointmentsResult = await dbQuery('SELECT COUNT(*) as count FROM appointments');

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: { status: 'connected', latency_ms: dbLatency },
      counts: {
        users: +usersResult.rows[0].count,
        doctors: +doctorsResult.rows[0].count,
        patients: +patientsResult.rows[0].count,
        appointments: +appointmentsResult.rows[0].count,
      },
      memory: {
        used_mb: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        total_mb: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
      },
      version: process.env.API_VERSION || '1.0.0',
    });
  } catch (error) {
    logger.error('Health check failed:', error);
    res.status(503).json({ status: 'unhealthy', error: error.message, timestamp: new Date().toISOString() });
  }
});

module.exports = router;
