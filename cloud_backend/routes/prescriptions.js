const express = require('express');
const { param, body, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { authorize } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();
const validateRequest = (req, res, next) => { const e = validationResult(req); if (!e.isEmpty()) return res.status(400).json({ error: 'Validation failed', details: e.array() }); next(); };

// GET /api/v1/prescriptions
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, patient_id, doctor_id, status } = req.query;
    const offset = (page - 1) * limit;
    let where = 'WHERE 1=1';
    const params = [];

    if (req.user.role === 'doctor') {
      const dr = await dbQuery('SELECT id FROM doctors WHERE user_id = $1', [req.user.id]);
      if (dr.rows.length > 0) { params.push(dr.rows[0].id); where += ` AND p.doctor_id = $${params.length}`; }
    } else if (req.user.role === 'patient') {
      const pt = await dbQuery('SELECT id FROM patients WHERE user_id = $1', [req.user.id]);
      if (pt.rows.length > 0) { params.push(pt.rows[0].id); where += ` AND p.patient_id = $${params.length}`; }
    }
    if (patient_id) { params.push(patient_id); where += ` AND p.patient_id = $${params.length}`; }
    if (doctor_id) { params.push(doctor_id); where += ` AND p.doctor_id = $${params.length}`; }
    if (status) { params.push(status); where += ` AND p.status = $${params.length}`; }

    params.push(limit, offset);
    const result = await dbQuery(`
      SELECT p.*, d.name as doctor_name, d.specialization,
             pt.first_name || ' ' || pt.last_name as patient_name
      FROM prescriptions p
      JOIN doctors d ON d.id = p.doctor_id
      JOIN patients pt ON pt.id = p.patient_id
      ${where} ORDER BY p.prescription_date DESC
      LIMIT $${params.length - 1} OFFSET $${params.length}
    `, params);

    // Get medications for each prescription
    for (let rx of result.rows) {
      const meds = await dbQuery('SELECT * FROM medications WHERE prescription_id = $1', [rx.id]);
      rx.medications = meds.rows;
    }

    res.json({ prescriptions: result.rows });
  } catch (error) { logger.error('Error fetching prescriptions:', error); res.status(500).json({ error: 'Failed to fetch prescriptions' }); }
});

// POST /api/v1/prescriptions — create prescription with medications
router.post('/', [authorize(['doctor', 'admin']), body('patient_id').isUUID(), body('diagnosis').notEmpty(), validateRequest], async (req, res) => {
  try {
    const { patient_id, appointment_id, diagnosis, notes, follow_up_date, is_emergency, medications } = req.body;

    const dr = await dbQuery('SELECT id FROM doctors WHERE user_id = $1', [req.user.id]);
    const doctor_id = dr.rows[0]?.id;
    if (!doctor_id) return res.status(400).json({ error: 'Doctor profile not found' });

    const rxResult = await dbQuery(`
      INSERT INTO prescriptions (patient_id, doctor_id, appointment_id, prescription_date, diagnosis, notes, follow_up_date, is_emergency)
      VALUES ($1, $2, $3, CURRENT_DATE, $4, $5, $6, $7) RETURNING *
    `, [patient_id, doctor_id, appointment_id, diagnosis, notes, follow_up_date, is_emergency || false]);

    const prescription = rxResult.rows[0];

    // Insert medications
    if (medications && medications.length > 0) {
      for (const med of medications) {
        await dbQuery(`
          INSERT INTO medications (prescription_id, name, generic_name, dosage, frequency, duration, form, quantity, instructions, price)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        `, [prescription.id, med.name, med.generic_name, med.dosage, med.frequency, med.duration, med.form || 'tablet', med.quantity || 1, med.instructions, med.price]);
      }
    }

    const io = req.app.get('io');
    if (io) io.emit('new-prescription', { prescription_id: prescription.id, patient_id });

    res.status(201).json({ message: 'Prescription created', prescription });
  } catch (error) { logger.error('Error creating prescription:', error); res.status(500).json({ error: 'Failed to create prescription' }); }
});

// GET /api/v1/prescriptions/:id
router.get('/:id', [param('id').isUUID(), validateRequest], async (req, res) => {
  try {
    const result = await dbQuery(`
      SELECT p.*, d.name as doctor_name, d.specialization, pt.first_name || ' ' || pt.last_name as patient_name
      FROM prescriptions p JOIN doctors d ON d.id = p.doctor_id JOIN patients pt ON pt.id = p.patient_id
      WHERE p.id = $1
    `, [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Prescription not found' });

    const meds = await dbQuery('SELECT * FROM medications WHERE prescription_id = $1', [req.params.id]);
    result.rows[0].medications = meds.rows;

    res.json({ prescription: result.rows[0] });
  } catch (error) { logger.error('Error fetching prescription:', error); res.status(500).json({ error: 'Failed to fetch prescription' }); }
});

module.exports = router;
