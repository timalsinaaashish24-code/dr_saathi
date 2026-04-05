const express = require('express');
const { param, body, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { authorize } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();
const validateRequest = (req, res, next) => { const e = validationResult(req); if (!e.isEmpty()) return res.status(400).json({ error: 'Validation failed', details: e.array() }); next(); };

// GET /api/v1/pharmacies
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, verified } = req.query;
    const offset = (page - 1) * limit;
    let where = 'WHERE is_active = true';
    const params = [];

    if (search) { params.push(`%${search}%`); where += ` AND (name ILIKE $${params.length} OR address ILIKE $${params.length})`; }
    if (verified === 'true') where += ' AND is_verified = true';

    params.push(limit, offset);
    const result = await dbQuery(`SELECT * FROM pharmacies ${where} ORDER BY name ASC LIMIT $${params.length - 1} OFFSET $${params.length}`, params);
    res.json({ pharmacies: result.rows });
  } catch (error) { logger.error('Error fetching pharmacies:', error); res.status(500).json({ error: 'Failed to fetch pharmacies' }); }
});

// POST /api/v1/pharmacies
router.post('/', [authorize(['admin']), body('name').notEmpty(), body('license_number').notEmpty(), body('phone').notEmpty(), body('address').notEmpty(), validateRequest], async (req, res) => {
  try {
    const { name, license_number, owner_name, phone, email, address, latitude, longitude, operating_hours, services } = req.body;
    const result = await dbQuery(`
      INSERT INTO pharmacies (name, license_number, owner_name, phone, email, address, latitude, longitude, operating_hours, services)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *
    `, [name, license_number, owner_name, phone, email, address, latitude, longitude, JSON.stringify(operating_hours), services]);
    res.status(201).json({ message: 'Pharmacy created', pharmacy: result.rows[0] });
  } catch (error) { logger.error('Error creating pharmacy:', error); res.status(500).json({ error: 'Failed to create pharmacy' }); }
});

// POST /api/v1/pharmacies/:id/verify
router.post('/:id/verify', [authorize(['admin']), param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const result = await dbQuery('UPDATE pharmacies SET is_verified = true, verification_date = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Pharmacy not found' });
    res.json({ message: 'Pharmacy verified', pharmacy: result.rows[0] });
  } catch (error) { logger.error('Error verifying pharmacy:', error); res.status(500).json({ error: 'Failed to verify pharmacy' }); }
});

module.exports = router;
