const express = require('express');
const { param, query, body, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { authorize } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();
const validateRequest = (req, res, next) => { const e = validationResult(req); if (!e.isEmpty()) return res.status(400).json({ error: 'Validation failed', details: e.array() }); next(); };

// GET /api/v1/appointments — list appointments (filtered by role)
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, status, date, doctor_id, patient_id } = req.query;
    const offset = (page - 1) * limit;
    let where = 'WHERE 1=1';
    const params = [];

    // Role-based filtering
    if (req.user.role === 'doctor') {
      const dr = await dbQuery('SELECT id FROM doctors WHERE user_id = $1', [req.user.id]);
      if (dr.rows.length > 0) { params.push(dr.rows[0].id); where += ` AND a.doctor_id = $${params.length}`; }
    } else if (req.user.role === 'patient') {
      const pt = await dbQuery('SELECT id FROM patients WHERE user_id = $1', [req.user.id]);
      if (pt.rows.length > 0) { params.push(pt.rows[0].id); where += ` AND a.patient_id = $${params.length}`; }
    }

    if (status) { params.push(status); where += ` AND a.status = $${params.length}`; }
    if (date) { params.push(date); where += ` AND a.appointment_date = $${params.length}`; }
    if (doctor_id) { params.push(doctor_id); where += ` AND a.doctor_id = $${params.length}`; }
    if (patient_id) { params.push(patient_id); where += ` AND a.patient_id = $${params.length}`; }

    const countResult = await dbQuery(`SELECT COUNT(*) as total FROM appointments a ${where}`, params);
    params.push(limit, offset);
    const result = await dbQuery(`
      SELECT a.*, d.name as doctor_name, d.specialization,
             p.first_name || ' ' || p.last_name as patient_name, p.phone_number as patient_phone
      FROM appointments a
      JOIN doctors d ON d.id = a.doctor_id
      JOIN patients p ON p.id = a.patient_id
      ${where} ORDER BY a.appointment_date DESC, a.start_time DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `, params);

    res.json({ appointments: result.rows, pagination: { current_page: +page, total_pages: Math.ceil(countResult.rows[0].total / limit), total_count: +countResult.rows[0].total } });
  } catch (error) { logger.error('Error fetching appointments:', error); res.status(500).json({ error: 'Failed to fetch appointments' }); }
});

// POST /api/v1/appointments — create appointment
router.post('/', [
  body('doctor_id').isUUID(),
  body('patient_id').isUUID(),
  body('appointment_date').isDate(),
  body('start_time').notEmpty(),
  body('end_time').notEmpty(),
  validateRequest
], async (req, res) => {
  try {
    const { doctor_id, patient_id, appointment_date, start_time, end_time, consultation_type, chief_complaint, consultation_fee } = req.body;

    const result = await dbQuery(`
      INSERT INTO appointments (patient_id, doctor_id, appointment_date, start_time, end_time, consultation_type, chief_complaint, consultation_fee, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'scheduled') RETURNING *
    `, [patient_id, doctor_id, appointment_date, start_time, end_time, consultation_type || 'telehealth', chief_complaint, consultation_fee || 0]);

    const appointment = result.rows[0];

    // Create 24-hour payment hold
    if (consultation_fee && consultation_fee > 0) {
      await dbQuery(`
        INSERT INTO payment_holds (appointment_id, patient_id, doctor_id, amount, hold_status, held_at, release_at)
        VALUES ($1, $2, $3, $4, 'held', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '24 hours')
      `, [appointment.id, patient_id, doctor_id, consultation_fee]);
    }

    // Emit WebSocket event for admin
    const io = req.app.get('io');
    if (io) io.emit('new-appointment', { appointment });

    logger.info(`Appointment created: ${appointment.id}`);
    res.status(201).json({ message: 'Appointment created', appointment });
  } catch (error) { logger.error('Error creating appointment:', error); res.status(500).json({ error: 'Failed to create appointment' }); }
});

// PUT /api/v1/appointments/:id/status — update status
router.put('/:id/status', [param('id').isUUID(), body('status').isIn(['scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show']), validateRequest], async (req, res) => {
  try {
    const { status, notes } = req.body;
    const result = await dbQuery('UPDATE appointments SET status = $2, notes = COALESCE($3, notes) WHERE id = $1 RETURNING *', [req.params.id, status, notes]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Appointment not found' });

    const io = req.app.get('io');
    if (io) io.emit('appointment-status-changed', { appointment: result.rows[0] });

    res.json({ message: 'Status updated', appointment: result.rows[0] });
  } catch (error) { logger.error('Error updating status:', error); res.status(500).json({ error: 'Failed to update status' }); }
});

// POST /api/v1/appointments/:id/cancel — cancel with reason + auto-refund
router.post('/:id/cancel', [param('id').isUUID(), body('reason').notEmpty(), validateRequest], async (req, res) => {
  try {
    const { reason } = req.body;
    const aptId = req.params.id;

    // Get appointment
    const apt = await dbQuery('SELECT * FROM appointments WHERE id = $1', [aptId]);
    if (apt.rows.length === 0) return res.status(404).json({ error: 'Appointment not found' });

    // Cancel appointment
    await dbQuery("UPDATE appointments SET status = 'cancelled', notes = $2 WHERE id = $1", [aptId, `Cancelled: ${reason}`]);

    // Check payment hold and process refund
    let refundResult = { status: 'no_payment' };
    const hold = await dbQuery("SELECT * FROM payment_holds WHERE appointment_id = $1 AND hold_status = 'held'", [aptId]);

    if (hold.rows.length > 0) {
      const holdRecord = hold.rows[0];
      const releaseAt = new Date(holdRecord.release_at);

      if (new Date() < releaseAt) {
        // Within 24 hours — instant refund from held funds
        await dbQuery("UPDATE payment_holds SET hold_status = 'refunded', refunded_at = CURRENT_TIMESTAMP WHERE id = $1", [holdRecord.id]);
        refundResult = { status: 'instant_refund', amount: holdRecord.amount, transaction_id: `HOLD-RFD-${Date.now()}` };
      } else {
        // Past 24 hours — bank refund needed
        await dbQuery("UPDATE payment_holds SET hold_status = 'refunded', refunded_at = CURRENT_TIMESTAMP WHERE id = $1", [holdRecord.id]);
        refundResult = { status: 'bank_refund_initiated', amount: holdRecord.amount, transaction_id: `BANK-RFD-${Date.now()}` };
      }
    }

    // Log audit
    await dbQuery('INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values) VALUES ($1, $2, $3, $4, $5)',
      [req.user.id, 'cancel_appointment', 'appointments', aptId, JSON.stringify({ reason, refund: refundResult })]);

    const io = req.app.get('io');
    if (io) io.emit('appointment-cancelled', { appointment_id: aptId, refund: refundResult });

    res.json({ message: 'Appointment cancelled', refund: refundResult });
  } catch (error) { logger.error('Error cancelling appointment:', error); res.status(500).json({ error: 'Failed to cancel appointment' }); }
});

// GET /api/v1/appointments/stats — appointment statistics (for admin/doctor dashboard)
router.get('/stats/summary', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const stats = {};

    const totalResult = await dbQuery('SELECT COUNT(*) as count FROM appointments');
    const todayResult = await dbQuery('SELECT COUNT(*) as count FROM appointments WHERE appointment_date = $1', [today]);
    const scheduledResult = await dbQuery("SELECT COUNT(*) as count FROM appointments WHERE status = 'scheduled'");
    const completedResult = await dbQuery("SELECT COUNT(*) as count FROM appointments WHERE status = 'completed'");
    const cancelledResult = await dbQuery("SELECT COUNT(*) as count FROM appointments WHERE status = 'cancelled'");

    stats.total = +totalResult.rows[0].count;
    stats.today = +todayResult.rows[0].count;
    stats.scheduled = +scheduledResult.rows[0].count;
    stats.completed = +completedResult.rows[0].count;
    stats.cancelled = +cancelledResult.rows[0].count;
    stats.success_rate = stats.total > 0 ? ((stats.completed / stats.total) * 100).toFixed(1) : 0;

    res.json({ stats });
  } catch (error) { logger.error('Error fetching stats:', error); res.status(500).json({ error: 'Failed to fetch stats' }); }
});

module.exports = router;
