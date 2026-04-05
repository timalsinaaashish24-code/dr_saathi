const express = require('express');
const { param, query, body, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { authorize } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();
const validateRequest = (req, res, next) => { const e = validationResult(req); if (!e.isEmpty()) return res.status(400).json({ error: 'Validation failed', details: e.array() }); next(); };

// GET /api/v1/doctors — list all doctors (admin sees all, patients see verified only)
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, specialization, status } = req.query;
    const offset = (page - 1) * limit;
    let where = 'WHERE 1=1';
    const params = [];

    if (req.user.role !== 'admin') { where += ' AND d.is_verified = true AND d.is_active = true'; }
    if (search) { params.push(`%${search}%`); where += ` AND (d.name ILIKE $${params.length} OR d.license_number ILIKE $${params.length})`; }
    if (specialization) { params.push(specialization); where += ` AND d.specialization = $${params.length}`; }
    if (status === 'pending') { where += ' AND d.is_verified = false'; }

    const countResult = await dbQuery(`SELECT COUNT(*) as total FROM doctors d ${where}`, params);
    params.push(limit, offset);
    const result = await dbQuery(`SELECT d.*, u.email as user_email, u.last_login FROM doctors d JOIN users u ON u.id = d.user_id ${where} ORDER BY d.created_at DESC LIMIT $${params.length - 1} OFFSET $${params.length}`, params);

    res.json({ doctors: result.rows, pagination: { current_page: +page, total_pages: Math.ceil(countResult.rows[0].total / limit), total_count: +countResult.rows[0].total, limit: +limit } });
  } catch (error) { logger.error('Error fetching doctors:', error); res.status(500).json({ error: 'Failed to fetch doctors' }); }
});

// GET /api/v1/doctors/:id
router.get('/:id', [param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const result = await dbQuery('SELECT d.*, u.email as user_email, u.last_login FROM doctors d JOIN users u ON u.id = d.user_id WHERE d.id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json({ doctor: result.rows[0] });
  } catch (error) { logger.error('Error fetching doctor:', error); res.status(500).json({ error: 'Failed to fetch doctor' }); }
});

// PUT /api/v1/doctors/:id — update doctor profile
router.put('/:id', [param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const { name, specialization, phone, hospital, clinic_name, about, consultation_fee } = req.body;
    const result = await dbQuery(
      `UPDATE doctors SET name = COALESCE($2, name), specialization = COALESCE($3, specialization), phone = COALESCE($4, phone), hospital = COALESCE($5, hospital), clinic_name = COALESCE($6, clinic_name), about = COALESCE($7, about), consultation_fee = COALESCE($8, consultation_fee) WHERE id = $1 RETURNING *`,
      [req.params.id, name, specialization, phone, hospital, clinic_name, about, consultation_fee]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json({ message: 'Doctor updated', doctor: result.rows[0] });
  } catch (error) { logger.error('Error updating doctor:', error); res.status(500).json({ error: 'Failed to update doctor' }); }
});

// POST /api/v1/doctors/:id/verify — admin verifies a doctor (NMC check)
router.post('/:id/verify', [authorize(['admin']), param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const result = await dbQuery(
      'UPDATE doctors SET is_verified = true, verification_date = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });

    // Log audit
    await dbQuery('INSERT INTO audit_logs (user_id, action, table_name, record_id) VALUES ($1, $2, $3, $4)', [req.user.id, 'verify_doctor', 'doctors', req.params.id]);

    logger.info(`Doctor verified: ${req.params.id} by admin: ${req.user.id}`);
    res.json({ message: 'Doctor verified successfully', doctor: result.rows[0] });
  } catch (error) { logger.error('Error verifying doctor:', error); res.status(500).json({ error: 'Failed to verify doctor' }); }
});

// POST /api/v1/doctors/:id/suspend — admin suspends a doctor
router.post('/:id/suspend', [authorize(['admin']), param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const { reason } = req.body;
    const result = await dbQuery('UPDATE doctors SET is_active = false WHERE id = $1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });

    await dbQuery('INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values) VALUES ($1, $2, $3, $4, $5)', [req.user.id, 'suspend_doctor', 'doctors', req.params.id, JSON.stringify({ reason })]);

    res.json({ message: 'Doctor suspended', doctor: result.rows[0] });
  } catch (error) { logger.error('Error suspending doctor:', error); res.status(500).json({ error: 'Failed to suspend doctor' }); }
});

// POST /api/v1/doctors/:id/reject — admin rejects a doctor
router.post('/:id/reject', [authorize(['admin']), param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const { reason } = req.body;
    await dbQuery('UPDATE doctors SET is_active = false, is_verified = false WHERE id = $1', [req.params.id]);
    await dbQuery('INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values) VALUES ($1, $2, $3, $4, $5)', [req.user.id, 'reject_doctor', 'doctors', req.params.id, JSON.stringify({ reason })]);
    res.json({ message: 'Doctor rejected' });
  } catch (error) { logger.error('Error rejecting doctor:', error); res.status(500).json({ error: 'Failed to reject doctor' }); }
});

// GET /api/v1/doctors/nmc/verify/:nmcNumber — verify NMC registration number
router.get('/nmc/verify/:nmcNumber', async (req, res) => {
  try {
    const result = await dbQuery('SELECT id, name, license_number, specialization, is_verified FROM doctors WHERE license_number = $1', [req.params.nmcNumber]);
    res.json({ valid: result.rows.length > 0 && result.rows[0].is_verified, doctor: result.rows[0] || null });
  } catch (error) { res.status(500).json({ error: 'NMC verification failed' }); }
});

module.exports = router;
