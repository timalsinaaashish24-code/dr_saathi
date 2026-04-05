const express = require('express');
const { query: dbQuery } = require('../config/database');
const { authorize } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();

// All admin routes require admin role
router.use(authorize(['admin']));

// GET /api/v1/admin/dashboard — full dashboard summary
router.get('/dashboard', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const last30Days = new Date(Date.now() - 30 * 86400000).toISOString();

    // User counts
    const users = await dbQuery("SELECT role, COUNT(*) as count FROM users WHERE is_active = true GROUP BY role");
    const userCounts = {};
    users.rows.forEach(r => { userCounts[r.role] = +r.count; });

    // Doctor stats
    const doctorStats = await dbQuery(`
      SELECT COUNT(*) as total,
        SUM(CASE WHEN is_verified = true THEN 1 ELSE 0 END) as verified,
        SUM(CASE WHEN is_verified = false AND is_active = true THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN is_active = false THEN 1 ELSE 0 END) as suspended
      FROM doctors
    `);

    // Appointment stats
    const aptStats = await dbQuery(`
      SELECT COUNT(*) as total,
        SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) as scheduled,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled,
        SUM(CASE WHEN appointment_date = $1 THEN 1 ELSE 0 END) as today
      FROM appointments
    `, [today]);

    // Revenue
    const revenue = await dbQuery(`
      SELECT COALESCE(SUM(consultation_fee), 0) as total_revenue,
        COALESCE(SUM(CASE WHEN appointment_date >= $1 THEN consultation_fee ELSE 0 END), 0) as last_30_days
      FROM appointments WHERE status = 'completed' AND is_paid = true
    `, [last30Days]);

    // Payment holds
    const holds = await dbQuery(`
      SELECT hold_status, COUNT(*) as count, COALESCE(SUM(amount), 0) as total
      FROM payment_holds GROUP BY hold_status
    `);
    const holdStats = {};
    holds.rows.forEach(r => { holdStats[r.hold_status] = { count: +r.count, amount: +r.total }; });

    // Recent audit log
    const auditLog = await dbQuery(`
      SELECT al.*, u.email as user_email FROM audit_logs al
      LEFT JOIN users u ON u.id = al.user_id
      ORDER BY al.created_at DESC LIMIT 10
    `);

    res.json({
      users: userCounts,
      doctors: doctorStats.rows[0],
      appointments: aptStats.rows[0],
      revenue: revenue.rows[0],
      payment_holds: holdStats,
      recent_audit_log: auditLog.rows,
      timestamp: new Date().toISOString(),
    });
  } catch (error) { logger.error('Admin dashboard error:', error); res.status(500).json({ error: 'Failed to load dashboard' }); }
});

// GET /api/v1/admin/analytics/users — user analytics over time
router.get('/analytics/users', async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const since = new Date(Date.now() - period * 86400000).toISOString();

    const dailyGrowth = await dbQuery(`
      SELECT DATE(created_at) as date, COUNT(*) as new_users, role
      FROM users WHERE created_at >= $1
      GROUP BY DATE(created_at), role ORDER BY date ASC
    `, [since]);

    const totalUsers = await dbQuery('SELECT COUNT(*) as count FROM users WHERE is_active = true');
    const activeUsers = await dbQuery('SELECT COUNT(*) as count FROM users WHERE last_login >= $1', [since]);

    res.json({ daily_growth: dailyGrowth.rows, total_users: +totalUsers.rows[0].count, active_users: +activeUsers.rows[0].count });
  } catch (error) { logger.error('User analytics error:', error); res.status(500).json({ error: 'Failed to load analytics' }); }
});

// GET /api/v1/admin/analytics/appointments — appointment analytics
router.get('/analytics/appointments', async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const since = new Date(Date.now() - period * 86400000).toISOString().split('T')[0];

    const daily = await dbQuery(`
      SELECT appointment_date as date, status, COUNT(*) as count
      FROM appointments WHERE appointment_date >= $1
      GROUP BY appointment_date, status ORDER BY appointment_date ASC
    `, [since]);

    const byDoctor = await dbQuery(`
      SELECT d.name, COUNT(*) as consultations
      FROM appointments a JOIN doctors d ON d.id = a.doctor_id
      WHERE a.appointment_date >= $1 AND a.status = 'completed'
      GROUP BY d.name ORDER BY consultations DESC LIMIT 10
    `, [since]);

    const bySpecialization = await dbQuery(`
      SELECT d.specialization, COUNT(*) as count
      FROM appointments a JOIN doctors d ON d.id = a.doctor_id
      WHERE a.appointment_date >= $1
      GROUP BY d.specialization ORDER BY count DESC
    `, [since]);

    res.json({ daily: daily.rows, by_doctor: byDoctor.rows, by_specialization: bySpecialization.rows });
  } catch (error) { logger.error('Appointment analytics error:', error); res.status(500).json({ error: 'Failed to load analytics' }); }
});

// GET /api/v1/admin/analytics/revenue — revenue analytics
router.get('/analytics/revenue', async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const since = new Date(Date.now() - period * 86400000).toISOString().split('T')[0];

    const dailyRevenue = await dbQuery(`
      SELECT appointment_date as date, SUM(consultation_fee) as revenue, COUNT(*) as appointments
      FROM appointments WHERE status = 'completed' AND is_paid = true AND appointment_date >= $1
      GROUP BY appointment_date ORDER BY appointment_date ASC
    `, [since]);

    // 30% admin, 70% doctor split
    const totalRevenue = await dbQuery(`
      SELECT COALESCE(SUM(consultation_fee), 0) as total FROM appointments
      WHERE status = 'completed' AND is_paid = true AND appointment_date >= $1
    `, [since]);
    const total = +totalRevenue.rows[0].total;

    res.json({
      daily: dailyRevenue.rows,
      summary: { total_revenue: total, admin_share: total * 0.30, doctor_share: total * 0.70 },
    });
  } catch (error) { logger.error('Revenue analytics error:', error); res.status(500).json({ error: 'Failed to load analytics' }); }
});

// GET /api/v1/admin/doctors/pending — pending doctor verifications
router.get('/doctors/pending', async (req, res) => {
  try {
    const result = await dbQuery(`
      SELECT d.*, u.email as user_email, u.created_at as applied_at
      FROM doctors d JOIN users u ON u.id = d.user_id
      WHERE d.is_verified = false AND d.is_active = true
      ORDER BY u.created_at ASC
    `);
    res.json({ pending_doctors: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch pending doctors' }); }
});

// GET /api/v1/admin/payments/holds — active payment holds
router.get('/payments/holds', async (req, res) => {
  try {
    const result = await dbQuery(`
      SELECT ph.*, p.first_name || ' ' || p.last_name as patient_name, d.name as doctor_name
      FROM payment_holds ph
      JOIN patients p ON p.id = ph.patient_id
      JOIN doctors d ON d.id = ph.doctor_id
      ORDER BY ph.held_at DESC
    `);
    res.json({ holds: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch payment holds' }); }
});

// GET /api/v1/admin/payments/refunds — all refunds
router.get('/payments/refunds', async (req, res) => {
  try {
    const result = await dbQuery(`
      SELECT ph.*, p.first_name || ' ' || p.last_name as patient_name
      FROM payment_holds ph
      JOIN patients p ON p.id = ph.patient_id
      WHERE ph.hold_status = 'refunded'
      ORDER BY ph.refunded_at DESC
    `);
    res.json({ refunds: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch refunds' }); }
});

// GET /api/v1/admin/audit-log — audit trail
router.get('/audit-log', async (req, res) => {
  try {
    const { page = 1, limit = 50, action } = req.query;
    const offset = (page - 1) * limit;
    let where = 'WHERE 1=1';
    const params = [];

    if (action) { params.push(action); where += ` AND al.action = $${params.length}`; }

    params.push(limit, offset);
    const result = await dbQuery(`
      SELECT al.*, u.email as user_email, u.role as user_role
      FROM audit_logs al LEFT JOIN users u ON u.id = al.user_id
      ${where} ORDER BY al.created_at DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `, params);

    res.json({ audit_log: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch audit log' }); }
});

// GET /api/v1/admin/regional-coverage — doctor distribution by region
router.get('/regional-coverage', async (req, res) => {
  try {
    const result = await dbQuery(`
      SELECT COALESCE(address, 'Unknown') as region,
        COUNT(*) as total_doctors,
        SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END) as active_doctors
      FROM doctors GROUP BY address ORDER BY total_doctors DESC
    `);
    res.json({ coverage: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch coverage' }); }
});

// POST /api/v1/admin/announcements — create system announcement
router.post('/announcements', async (req, res) => {
  try {
    const { title, message, type, target_audience, start_date, end_date } = req.body;
    const result = await dbQuery(`
      INSERT INTO system_settings (key, value, description)
      VALUES ($1, $2, $3) RETURNING *
    `, [`announcement_${Date.now()}`, JSON.stringify({ title, message, type, target_audience, start_date, end_date, is_active: true }), title]);

    const io = req.app.get('io');
    if (io) io.emit('system-announcement', { title, message, type, target_audience });

    res.status(201).json({ message: 'Announcement created', announcement: result.rows[0] });
  } catch (error) { res.status(500).json({ error: 'Failed to create announcement' }); }
});

// GET /api/v1/admin/fee-config — get fee configuration
router.get('/fee-config', async (req, res) => {
  try {
    const result = await dbQuery("SELECT * FROM system_settings WHERE key LIKE 'fee_%'");
    if (result.rows.length === 0) {
      // Return defaults
      return res.json({
        fees: { platform_commission_rate: 30, tax_rate: 13, default_fees: {
          'General Medicine': 500, 'Cardiology': 1200, 'Pediatrics': 600,
          'Orthopedics': 1000, 'Dermatology': 800, 'ENT': 700,
          'Gynecology': 900, 'Neurology': 1500
        }}
      });
    }
    res.json({ fees: result.rows });
  } catch (error) { res.status(500).json({ error: 'Failed to fetch fee config' }); }
});

// PUT /api/v1/admin/fee-config — update fee configuration
router.put('/fee-config', async (req, res) => {
  try {
    const { key, value } = req.body;
    await dbQuery(`
      INSERT INTO system_settings (key, value) VALUES ($1, $2)
      ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = CURRENT_TIMESTAMP
    `, [key, JSON.stringify(value)]);

    await dbQuery('INSERT INTO audit_logs (user_id, action, table_name, new_values) VALUES ($1, $2, $3, $4)',
      [req.user.id, 'update_fee_config', 'system_settings', JSON.stringify({ key, value })]);

    res.json({ message: 'Fee configuration updated' });
  } catch (error) { res.status(500).json({ error: 'Failed to update fee config' }); }
});

// POST /api/v1/admin/release-holds — manually release expired payment holds
router.post('/release-holds', async (req, res) => {
  try {
    const result = await dbQuery(`
      UPDATE payment_holds SET hold_status = 'released', released_at = CURRENT_TIMESTAMP
      WHERE hold_status = 'held' AND release_at <= CURRENT_TIMESTAMP
    `);
    res.json({ message: 'Payment holds released', released_count: result.rowCount });
  } catch (error) { res.status(500).json({ error: 'Failed to release holds' }); }
});

module.exports = router;
