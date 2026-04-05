const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { query } = require('../config/database');
const logger = require('../config/logger');

// Generate JWT token
function generateToken(payload, expiresIn = process.env.JWT_EXPIRES_IN || '24h') {
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
}

// Generate refresh token
function generateRefreshToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET, { 
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' 
  });
}

// Verify JWT token
function verifyToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
}

// Hash password
async function hashPassword(password) {
  const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
  return await bcrypt.hash(password, saltRounds);
}

// Compare password
async function comparePassword(password, hashedPassword) {
  return await bcrypt.compare(password, hashedPassword);
}

// Authentication middleware
async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Access denied. No token provided or invalid format.',
        code: 'NO_TOKEN'
      });
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    if (!token) {
      return res.status(401).json({
        error: 'Access denied. Token is empty.',
        code: 'EMPTY_TOKEN'
      });
    }
    
    // Verify token
    const decoded = verifyToken(token);
    
    // Check if user still exists and is active
    const userResult = await query(
      'SELECT id, email, role, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Access denied. User not found.',
        code: 'USER_NOT_FOUND'
      });
    }
    
    const user = userResult.rows[0];
    
    if (!user.is_active) {
      return res.status(401).json({
        error: 'Access denied. User account is deactivated.',
        code: 'USER_DEACTIVATED'
      });
    }
    
    // Add user info to request object
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role
    };
    
    // Update last login timestamp
    await query(
      'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
      [user.id]
    );
    
    next();
    
  } catch (error) {
    logger.error('Authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Access denied. Invalid token.',
        code: 'INVALID_TOKEN'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Access denied. Token has expired.',
        code: 'TOKEN_EXPIRED'
      });
    }
    
    return res.status(500).json({
      error: 'Internal server error during authentication.',
      code: 'AUTH_ERROR'
    });
  }
}

// Role-based authorization middleware
function authorize(roles = []) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Access denied. User not authenticated.',
        code: 'NOT_AUTHENTICATED'
      });
    }
    
    // If no roles specified, just check if user is authenticated
    if (roles.length === 0) {
      return next();
    }
    
    // Convert single role to array
    if (typeof roles === 'string') {
      roles = [roles];
    }
    
    // Check if user has required role
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Access denied. Insufficient permissions.',
        code: 'INSUFFICIENT_PERMISSIONS',
        requiredRoles: roles,
        userRole: req.user.role
      });
    }
    
    next();
  };
}

// Optional authentication middleware (doesn't fail if no token)
async function optionalAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // Continue without user context
    }
    
    const token = authHeader.substring(7);
    
    if (!token) {
      return next(); // Continue without user context
    }
    
    // Verify token
    const decoded = verifyToken(token);
    
    // Check if user still exists and is active
    const userResult = await query(
      'SELECT id, email, role, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );
    
    if (userResult.rows.length > 0 && userResult.rows[0].is_active) {
      const user = userResult.rows[0];
      req.user = {
        id: user.id,
        email: user.email,
        role: user.role
      };
    }
    
    next();
    
  } catch (error) {
    // Log error but continue without user context
    logger.debug('Optional auth failed:', error.message);
    next();
  }
}

// Check if current user owns the resource or is admin
function checkOwnership(resourceUserIdField = 'user_id') {
  return (req, res, next) => {
    const resourceUserId = req.body[resourceUserIdField] || req.params[resourceUserIdField];
    
    // Admin can access any resource
    if (req.user.role === 'admin') {
      return next();
    }
    
    // User can only access their own resources
    if (req.user.id !== resourceUserId) {
      return res.status(403).json({
        error: 'Access denied. You can only access your own resources.',
        code: 'OWNERSHIP_VIOLATION'
      });
    }
    
    next();
  };
}

// Rate limiting for authentication endpoints
const authLimiter = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: {
    error: 'Too many authentication attempts. Please try again later.',
    code: 'TOO_MANY_AUTH_ATTEMPTS'
  },
  standardHeaders: true,
  legacyHeaders: false,
};

// Validate API key (for external integrations)
async function validateApiKey(req, res, next) {
  try {
    const apiKey = req.headers['x-api-key'];
    
    if (!apiKey) {
      return res.status(401).json({
        error: 'API key required',
        code: 'API_KEY_REQUIRED'
      });
    }
    
    // In a real implementation, you'd validate against a database
    // For now, check against environment variable
    if (apiKey !== process.env.API_KEY) {
      return res.status(401).json({
        error: 'Invalid API key',
        code: 'INVALID_API_KEY'
      });
    }
    
    next();
  } catch (error) {
    logger.error('API key validation error:', error);
    return res.status(500).json({
      error: 'Internal server error during API key validation',
      code: 'API_KEY_ERROR'
    });
  }
}

// Extract user ID from various sources
function extractUserId(req) {
  return req.user?.id || req.params.userId || req.body.userId || req.query.userId;
}

// Check if user has permission to access patient data
async function checkPatientAccess(req, res, next) {
  try {
    const patientId = req.params.patientId || req.body.patient_id;
    const userId = req.user.id;
    
    // Admin can access any patient
    if (req.user.role === 'admin') {
      return next();
    }
    
    // Check if user is the patient themselves
    const patientResult = await query(
      'SELECT user_id FROM patients WHERE id = $1',
      [patientId]
    );
    
    if (patientResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Patient not found',
        code: 'PATIENT_NOT_FOUND'
      });
    }
    
    const patient = patientResult.rows[0];
    
    // Patient can access their own data
    if (patient.user_id === userId) {
      return next();
    }
    
    // Check if user is a doctor with access to this patient
    if (req.user.role === 'doctor') {
      const doctorAccessResult = await query(`
        SELECT 1 FROM appointments a
        JOIN doctors d ON d.id = a.doctor_id
        WHERE a.patient_id = $1 AND d.user_id = $2
        LIMIT 1
      `, [patientId, userId]);
      
      if (doctorAccessResult.rows.length > 0) {
        return next();
      }
    }
    
    return res.status(403).json({
      error: 'Access denied. No permission to access this patient data.',
      code: 'PATIENT_ACCESS_DENIED'
    });
    
  } catch (error) {
    logger.error('Patient access check error:', error);
    return res.status(500).json({
      error: 'Internal server error during patient access check',
      code: 'PATIENT_ACCESS_ERROR'
    });
  }
}

module.exports = {
  generateToken,
  generateRefreshToken,
  verifyToken,
  hashPassword,
  comparePassword,
  authenticate,
  authorize,
  optionalAuth,
  checkOwnership,
  authLimiter,
  validateApiKey,
  extractUserId,
  checkPatientAccess
};
