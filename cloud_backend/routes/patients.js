const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { authorize, checkPatientAccess } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();

// Validation middleware
const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }
  next();
};

/**
 * @swagger
 * components:
 *   schemas:
 *     Patient:
 *       type: object
 *       required:
 *         - first_name
 *         - last_name
 *         - phone_number
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         first_name:
 *           type: string
 *           maxLength: 100
 *         last_name:
 *           type: string
 *           maxLength: 100
 *         date_of_birth:
 *           type: string
 *           format: date
 *         age:
 *           type: integer
 *           minimum: 0
 *           maximum: 150
 *         gender:
 *           type: string
 *           enum: [male, female, other]
 *         phone_number:
 *           type: string
 *           maxLength: 20
 *         email:
 *           type: string
 *           format: email
 *         address:
 *           type: string
 *         emergency_contact:
 *           type: string
 *           maxLength: 100
 *         emergency_phone:
 *           type: string
 *           maxLength: 20
 *         medical_history:
 *           type: string
 *         allergies:
 *           type: string
 *         blood_group:
 *           type: string
 *           enum: [A+, A-, B+, B-, AB+, AB-, O+, O-]
 *         height_cm:
 *           type: integer
 *           minimum: 50
 *           maximum: 300
 *         weight_kg:
 *           type: number
 *           minimum: 1
 *           maximum: 500
 */

// Input validation rules
const patientValidation = [
  body('first_name')
    .trim()
    .notEmpty()
    .withMessage('First name is required')
    .isLength({ max: 100 })
    .withMessage('First name must be less than 100 characters'),
  
  body('last_name')
    .trim()
    .notEmpty()
    .withMessage('Last name is required')
    .isLength({ max: 100 })
    .withMessage('Last name must be less than 100 characters'),
  
  body('phone_number')
    .trim()
    .notEmpty()
    .withMessage('Phone number is required')
    .matches(/^[+]?[\d\s-()]+$/)
    .withMessage('Invalid phone number format')
    .isLength({ max: 20 })
    .withMessage('Phone number must be less than 20 characters'),
  
  body('email')
    .optional()
    .isEmail()
    .withMessage('Invalid email format')
    .normalizeEmail(),
  
  body('date_of_birth')
    .optional()
    .isISO8601()
    .withMessage('Invalid date format'),
  
  body('age')
    .optional()
    .isInt({ min: 0, max: 150 })
    .withMessage('Age must be between 0 and 150'),
  
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other'])
    .withMessage('Gender must be male, female, or other'),
  
  body('blood_group')
    .optional()
    .isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])
    .withMessage('Invalid blood group'),
  
  body('height_cm')
    .optional()
    .isInt({ min: 50, max: 300 })
    .withMessage('Height must be between 50 and 300 cm'),
  
  body('weight_kg')
    .optional()
    .isFloat({ min: 1, max: 500 })
    .withMessage('Weight must be between 1 and 500 kg')
];

/**
 * @swagger
 * /api/v1/patients:
 *   get:
 *     summary: Get all patients
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *         description: Number of patients per page
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search term for name or phone
 *     responses:
 *       200:
 *         description: List of patients retrieved successfully
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */
router.get('/', [
  authorize(['admin', 'doctor']),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('search').optional().trim().isLength({ max: 100 }).withMessage('Search term too long'),
  validateRequest
], async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';
    
    let whereClause = 'WHERE p.is_active = true';
    let queryParams = [];
    
    // Add search filter
    if (search) {
      whereClause += ` AND (
        p.first_name ILIKE $${queryParams.length + 1} OR 
        p.last_name ILIKE $${queryParams.length + 1} OR 
        p.phone_number ILIKE $${queryParams.length + 1}
      )`;
      queryParams.push(`%${search}%`);
    }
    
    // If user is a doctor, only show their patients
    if (req.user.role === 'doctor') {
      whereClause += ` AND EXISTS (
        SELECT 1 FROM appointments a 
        JOIN doctors d ON d.id = a.doctor_id 
        WHERE a.patient_id = p.id AND d.user_id = $${queryParams.length + 1}
      )`;
      queryParams.push(req.user.id);
    }
    
    // Get total count
    const countResult = await dbQuery(`
      SELECT COUNT(*) as total 
      FROM patients p 
      ${whereClause}
    `, queryParams);
    
    const total = parseInt(countResult.rows[0].total);
    
    // Get patients
    const result = await dbQuery(`
      SELECT 
        p.id, p.first_name, p.last_name, p.date_of_birth, p.age,
        p.gender, p.phone_number, p.email, p.address,
        p.emergency_contact, p.emergency_phone, p.medical_history,
        p.allergies, p.blood_group, p.height_cm, p.weight_kg,
        p.occupation, p.marital_status, p.insurance_number,
        p.profile_image_url, p.created_at, p.updated_at
      FROM patients p
      ${whereClause}
      ORDER BY p.created_at DESC
      LIMIT $${queryParams.length + 1} OFFSET $${queryParams.length + 2}
    `, [...queryParams, limit, offset]);
    
    const patients = result.rows;
    
    res.json({
      patients,
      pagination: {
        current_page: page,
        total_pages: Math.ceil(total / limit),
        total_count: total,
        limit
      }
    });
    
  } catch (error) {
    logger.error('Error fetching patients:', error);
    res.status(500).json({
      error: 'Failed to fetch patients',
      message: error.message
    });
  }
});

/**
 * @swagger
 * /api/v1/patients/{id}:
 *   get:
 *     summary: Get patient by ID
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Patient retrieved successfully
 *       404:
 *         description: Patient not found
 *       403:
 *         description: Access denied
 */
router.get('/:id', [
  param('id').isUUID().withMessage('Invalid patient ID format'),
  validateRequest,
  checkPatientAccess
], async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await dbQuery(`
      SELECT 
        p.id, p.first_name, p.last_name, p.date_of_birth, p.age,
        p.gender, p.phone_number, p.email, p.address,
        p.emergency_contact, p.emergency_phone, p.medical_history,
        p.allergies, p.blood_group, p.height_cm, p.weight_kg,
        p.occupation, p.marital_status, p.insurance_number,
        p.profile_image_url, p.created_at, p.updated_at
      FROM patients p
      WHERE p.id = $1 AND p.is_active = true
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Patient not found'
      });
    }
    
    const patient = result.rows[0];
    
    // Get recent appointments
    const appointmentsResult = await dbQuery(`
      SELECT 
        a.id, a.appointment_date, a.start_time, a.status,
        a.consultation_type, a.chief_complaint,
        d.name as doctor_name, d.specialization
      FROM appointments a
      JOIN doctors d ON d.id = a.doctor_id
      WHERE a.patient_id = $1
      ORDER BY a.appointment_date DESC, a.start_time DESC
      LIMIT 5
    `, [id]);
    
    patient.recent_appointments = appointmentsResult.rows;
    
    res.json({ patient });
    
  } catch (error) {
    logger.error('Error fetching patient:', error);
    res.status(500).json({
      error: 'Failed to fetch patient',
      message: error.message
    });
  }
});

/**
 * @swagger
 * /api/v1/patients:
 *   post:
 *     summary: Create a new patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Patient'
 *     responses:
 *       201:
 *         description: Patient created successfully
 *       400:
 *         description: Validation error
 *       409:
 *         description: Patient with phone number already exists
 */
router.post('/', [
  ...patientValidation,
  validateRequest
], async (req, res) => {
  try {
    const {
      first_name, last_name, date_of_birth, age, gender,
      phone_number, email, address, emergency_contact, emergency_phone,
      medical_history, allergies, blood_group, height_cm, weight_kg,
      occupation, marital_status, insurance_number
    } = req.body;
    
    // Check if patient with phone number already exists
    const existingPatient = await dbQuery(
      'SELECT id FROM patients WHERE phone_number = $1 AND is_active = true',
      [phone_number]
    );
    
    if (existingPatient.rows.length > 0) {
      return res.status(409).json({
        error: 'Patient with this phone number already exists'
      });
    }
    
    // Create patient
    const result = await dbQuery(`
      INSERT INTO patients (
        user_id, first_name, last_name, date_of_birth, age, gender,
        phone_number, email, address, emergency_contact, emergency_phone,
        medical_history, allergies, blood_group, height_cm, weight_kg,
        occupation, marital_status, insurance_number
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
      ) RETURNING *
    `, [
      req.user.id, first_name, last_name, date_of_birth, age, gender,
      phone_number, email, address, emergency_contact, emergency_phone,
      medical_history, allergies, blood_group, height_cm, weight_kg,
      occupation, marital_status, insurance_number
    ]);
    
    const patient = result.rows[0];
    
    logger.info(`Patient created: ${patient.id} by user: ${req.user.id}`);
    
    res.status(201).json({
      message: 'Patient created successfully',
      patient
    });
    
  } catch (error) {
    logger.error('Error creating patient:', error);
    res.status(500).json({
      error: 'Failed to create patient',
      message: error.message
    });
  }
});

/**
 * @swagger
 * /api/v1/patients/{id}:
 *   put:
 *     summary: Update patient
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Patient'
 *     responses:
 *       200:
 *         description: Patient updated successfully
 *       404:
 *         description: Patient not found
 *       403:
 *         description: Access denied
 */
router.put('/:id', [
  param('id').isUUID().withMessage('Invalid patient ID format'),
  ...patientValidation,
  validateRequest,
  checkPatientAccess
], async (req, res) => {
  try {
    const { id } = req.params;
    const {
      first_name, last_name, date_of_birth, age, gender,
      phone_number, email, address, emergency_contact, emergency_phone,
      medical_history, allergies, blood_group, height_cm, weight_kg,
      occupation, marital_status, insurance_number
    } = req.body;
    
    // Check if patient exists
    const existingPatient = await dbQuery(
      'SELECT id FROM patients WHERE id = $1 AND is_active = true',
      [id]
    );
    
    if (existingPatient.rows.length === 0) {
      return res.status(404).json({
        error: 'Patient not found'
      });
    }
    
    // Check if phone number is taken by another patient
    const phoneCheck = await dbQuery(
      'SELECT id FROM patients WHERE phone_number = $1 AND id != $2 AND is_active = true',
      [phone_number, id]
    );
    
    if (phoneCheck.rows.length > 0) {
      return res.status(409).json({
        error: 'Phone number is already taken by another patient'
      });
    }
    
    // Update patient
    const result = await dbQuery(`
      UPDATE patients SET
        first_name = $2, last_name = $3, date_of_birth = $4, age = $5, gender = $6,
        phone_number = $7, email = $8, address = $9, emergency_contact = $10, emergency_phone = $11,
        medical_history = $12, allergies = $13, blood_group = $14, height_cm = $15, weight_kg = $16,
        occupation = $17, marital_status = $18, insurance_number = $19
      WHERE id = $1 AND is_active = true
      RETURNING *
    `, [
      id, first_name, last_name, date_of_birth, age, gender,
      phone_number, email, address, emergency_contact, emergency_phone,
      medical_history, allergies, blood_group, height_cm, weight_kg,
      occupation, marital_status, insurance_number
    ]);
    
    const patient = result.rows[0];
    
    logger.info(`Patient updated: ${id} by user: ${req.user.id}`);
    
    res.json({
      message: 'Patient updated successfully',
      patient
    });
    
  } catch (error) {
    logger.error('Error updating patient:', error);
    res.status(500).json({
      error: 'Failed to update patient',
      message: error.message
    });
  }
});

/**
 * @swagger
 * /api/v1/patients/{id}:
 *   delete:
 *     summary: Delete patient (soft delete)
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Patient deleted successfully
 *       404:
 *         description: Patient not found
 *       403:
 *         description: Access denied
 */
router.delete('/:id', [
  param('id').isUUID().withMessage('Invalid patient ID format'),
  validateRequest,
  authorize(['admin']), // Only admin can delete patients
], async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if patient exists
    const existingPatient = await dbQuery(
      'SELECT id FROM patients WHERE id = $1 AND is_active = true',
      [id]
    );
    
    if (existingPatient.rows.length === 0) {
      return res.status(404).json({
        error: 'Patient not found'
      });
    }
    
    // Soft delete patient
    await dbQuery(
      'UPDATE patients SET is_active = false WHERE id = $1',
      [id]
    );
    
    logger.info(`Patient soft deleted: ${id} by user: ${req.user.id}`);
    
    res.json({
      message: 'Patient deleted successfully'
    });
    
  } catch (error) {
    logger.error('Error deleting patient:', error);
    res.status(500).json({
      error: 'Failed to delete patient',
      message: error.message
    });
  }
});

/**
 * @swagger
 * /api/v1/patients/{id}/medical-history:
 *   get:
 *     summary: Get patient medical history
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Medical history retrieved successfully
 *       404:
 *         description: Patient not found
 *       403:
 *         description: Access denied
 */
router.get('/:id/medical-history', [
  param('id').isUUID().withMessage('Invalid patient ID format'),
  validateRequest,
  checkPatientAccess
], async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get appointments with diagnoses
    const appointmentsResult = await dbQuery(`
      SELECT 
        a.id, a.appointment_date, a.start_time, a.diagnosis,
        a.treatment_plan, a.notes, a.chief_complaint, a.symptoms,
        d.name as doctor_name, d.specialization
      FROM appointments a
      JOIN doctors d ON d.id = a.doctor_id
      WHERE a.patient_id = $1 AND a.status = 'completed'
      ORDER BY a.appointment_date DESC
    `, [id]);
    
    // Get prescriptions
    const prescriptionsResult = await dbQuery(`
      SELECT 
        p.id, p.prescription_date, p.diagnosis, p.notes, p.status,
        d.name as doctor_name, d.specialization,
        json_agg(
          json_build_object(
            'name', m.name,
            'dosage', m.dosage,
            'frequency', m.frequency,
            'duration', m.duration,
            'instructions', m.instructions
          )
        ) as medications
      FROM prescriptions p
      JOIN doctors d ON d.id = p.doctor_id
      LEFT JOIN medications m ON m.prescription_id = p.id
      WHERE p.patient_id = $1
      GROUP BY p.id, p.prescription_date, p.diagnosis, p.notes, p.status, d.name, d.specialization
      ORDER BY p.prescription_date DESC
    `, [id]);
    
    // Get medical records/documents
    const recordsResult = await dbQuery(`
      SELECT 
        mr.id, mr.record_type, mr.title, mr.content,
        mr.file_url, mr.file_type, mr.created_at,
        d.name as doctor_name, d.specialization
      FROM medical_records mr
      JOIN doctors d ON d.id = mr.doctor_id
      WHERE mr.patient_id = $1
      ORDER BY mr.created_at DESC
    `, [id]);
    
    res.json({
      medical_history: {
        appointments: appointmentsResult.rows,
        prescriptions: prescriptionsResult.rows,
        records: recordsResult.rows
      }
    });
    
  } catch (error) {
    logger.error('Error fetching medical history:', error);
    res.status(500).json({
      error: 'Failed to fetch medical history',
      message: error.message
    });
  }
});

module.exports = router;
