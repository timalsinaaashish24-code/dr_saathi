const express = require('express');
const { body, validationResult } = require('express-validator');
const { query: dbQuery } = require('../config/database');
const { generateToken, generateRefreshToken, hashPassword, comparePassword, verifyToken } = require('../middleware/auth');
const logger = require('../config/logger');

const router = express.Router();

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ error: 'Validation failed', details: errors.array() });
  next();
};

// POST /api/v1/auth/register
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('role').isIn(['patient', 'doctor', 'admin']),
  body('name').trim().notEmpty(),
  validateRequest
], async (req, res) => {
  try {
    const { email, password, role, name, phone, license_number, specialization } = req.body;

    const existing = await dbQuery('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) return res.status(409).json({ error: 'Email already registered' });

    const passwordHash = await hashPassword(password);
    const userResult = await dbQuery(
      'INSERT INTO users (email, password_hash, role) VALUES ($1, $2, $3) RETURNING id, email, role',
      [email, passwordHash, role]
    );
    const user = userResult.rows[0];

    // Create role-specific profile
    if (role === 'doctor') {
      // Verify NMC number
      if (!license_number) return res.status(400).json({ error: 'NMC license number required for doctor registration' });

      await dbQuery(
        `INSERT INTO doctors (user_id, name, specialization, license_number, phone, email)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [user.id, name, specialization || 'General Medicine', license_number, phone || '', email]
      );
    } else if (role === 'patient') {
      const nameParts = name.split(' ');
      await dbQuery(
        `INSERT INTO patients (user_id, first_name, last_name, phone_number, email)
         VALUES ($1, $2, $3, $4, $5)`,
        [user.id, nameParts[0], nameParts.slice(1).join(' ') || '', phone || '', email]
      );
    }

    const token = generateToken({ userId: user.id, role: user.role });
    const refreshToken = generateRefreshToken({ userId: user.id, role: user.role });

    logger.info(`User registered: ${user.id} (${role})`);
    res.status(201).json({ message: 'Registration successful', user, token, refreshToken });
  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
});

// POST /api/v1/auth/login
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
  validateRequest
], async (req, res) => {
  try {
    const { email, password } = req.body;

    const userResult = await dbQuery('SELECT id, email, password_hash, role, is_active FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) return res.status(401).json({ error: 'Invalid email or password' });

    const user = userResult.rows[0];
    if (!user.is_active) return res.status(401).json({ error: 'Account is deactivated' });

    const validPassword = await comparePassword(password, user.password_hash);
    if (!validPassword) return res.status(401).json({ error: 'Invalid email or password' });

    // For doctors, verify NMC is still active
    if (user.role === 'doctor') {
      const doctor = await dbQuery('SELECT is_verified, license_number FROM doctors WHERE user_id = $1', [user.id]);
      if (doctor.rows.length > 0 && !doctor.rows[0].is_verified) {
        return res.status(401).json({ error: 'Your NMC registration is pending verification. Please contact admin.' });
      }
    }

    await dbQuery('UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1', [user.id]);

    const token = generateToken({ userId: user.id, role: user.role });
    const refreshToken = generateRefreshToken({ userId: user.id, role: user.role });

    // Get profile data
    let profile = null;
    if (user.role === 'doctor') {
      const dr = await dbQuery('SELECT * FROM doctors WHERE user_id = $1', [user.id]);
      profile = dr.rows[0];
    } else if (user.role === 'patient') {
      const pt = await dbQuery('SELECT * FROM patients WHERE user_id = $1', [user.id]);
      profile = pt.rows[0];
    }

    res.json({ message: 'Login successful', user: { id: user.id, email: user.email, role: user.role }, profile, token, refreshToken });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ error: 'Login failed', message: error.message });
  }
});

// POST /api/v1/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

    const decoded = verifyToken(refreshToken);
    const userResult = await dbQuery('SELECT id, role, is_active FROM users WHERE id = $1', [decoded.userId]);
    if (userResult.rows.length === 0 || !userResult.rows[0].is_active) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const user = userResult.rows[0];
    const newToken = generateToken({ userId: user.id, role: user.role });
    res.json({ token: newToken });
  } catch (error) {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

module.exports = router;
