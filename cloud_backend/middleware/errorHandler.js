const logger = require('../config/logger');

// Custom error class for API errors
class ApiError extends Error {
  constructor(statusCode, message, isOperational = true, stack = '') {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.error({
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.id
  });

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new ApiError(404, message);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = new ApiError(400, message);
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message);
    error = new ApiError(400, message);
  }

  // PostgreSQL errors
  if (err.code) {
    switch (err.code) {
      case '23505': // unique_violation
        error = new ApiError(409, 'Duplicate entry - resource already exists');
        break;
      case '23502': // not_null_violation
        error = new ApiError(400, 'Required field is missing');
        break;
      case '23503': // foreign_key_violation
        error = new ApiError(400, 'Referenced resource does not exist');
        break;
      case '23514': // check_violation
        error = new ApiError(400, 'Data violates database constraints');
        break;
      case '42601': // syntax_error
        error = new ApiError(500, 'Database query error');
        break;
      case '42703': // undefined_column
        error = new ApiError(500, 'Database schema error');
        break;
      case '28P01': // invalid_password
        error = new ApiError(401, 'Authentication failed');
        break;
      case '3D000': // invalid_catalog_name
        error = new ApiError(500, 'Database connection error');
        break;
    }
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new ApiError(401, message);
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new ApiError(401, message);
  }

  // Multer errors (file upload)
  if (err.code === 'LIMIT_FILE_SIZE') {
    const message = 'File too large';
    error = new ApiError(400, message);
  }

  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    const message = 'Unexpected file field';
    error = new ApiError(400, message);
  }

  // Rate limiting errors
  if (err.statusCode === 429) {
    const message = 'Too many requests, please try again later';
    error = new ApiError(429, message);
  }

  // Default to 500 server error
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  // Don't leak error details in production
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  const errorResponse = {
    success: false,
    error: {
      message,
      ...(isDevelopment && { stack: err.stack }),
      ...(isDevelopment && { details: err })
    }
  };

  // Additional error context for development
  if (isDevelopment) {
    errorResponse.error.url = req.url;
    errorResponse.error.method = req.method;
    errorResponse.error.timestamp = new Date().toISOString();
  }

  res.status(statusCode).json(errorResponse);
};

// Async error wrapper to catch async errors
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// 404 handler for undefined routes
const notFound = (req, res, next) => {
  const error = new ApiError(404, `Route ${req.originalUrl} not found`);
  next(error);
};

// Validation error formatter
const formatValidationErrors = (errors) => {
  return errors.map(error => ({
    field: error.param,
    message: error.msg,
    value: error.value
  }));
};

// Database connection error handler
const handleDatabaseError = (error) => {
  logger.error('Database connection error:', error);
  
  if (error.code === 'ECONNREFUSED') {
    return new ApiError(503, 'Database service unavailable');
  }
  
  if (error.code === 'ENOTFOUND') {
    return new ApiError(503, 'Database host not found');
  }
  
  if (error.code === 'ETIMEDOUT') {
    return new ApiError(503, 'Database connection timeout');
  }
  
  return new ApiError(500, 'Database error occurred');
};

// Health check error handler
const handleHealthCheckError = (error) => {
  logger.error('Health check failed:', error);
  return {
    status: 'unhealthy',
    timestamp: new Date().toISOString(),
    error: error.message
  };
};

// Graceful error handling for critical errors
const handleCriticalError = (error, source = 'unknown') => {
  logger.error(`Critical error from ${source}:`, error);
  
  // Perform cleanup operations
  // Close database connections, clear caches, etc.
  
  // Graceful shutdown
  process.exit(1);
};

// Error types for better error classification
const ErrorTypes = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  AUTHENTICATION_ERROR: 'AUTHENTICATION_ERROR',
  AUTHORIZATION_ERROR: 'AUTHORIZATION_ERROR',
  NOT_FOUND_ERROR: 'NOT_FOUND_ERROR',
  CONFLICT_ERROR: 'CONFLICT_ERROR',
  RATE_LIMIT_ERROR: 'RATE_LIMIT_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
  EXTERNAL_SERVICE_ERROR: 'EXTERNAL_SERVICE_ERROR',
  INTERNAL_ERROR: 'INTERNAL_ERROR'
};

// Create specific error instances
const createValidationError = (message, field = null) => {
  const error = new ApiError(400, message);
  error.type = ErrorTypes.VALIDATION_ERROR;
  error.field = field;
  return error;
};

const createNotFoundError = (resource = 'Resource') => {
  const error = new ApiError(404, `${resource} not found`);
  error.type = ErrorTypes.NOT_FOUND_ERROR;
  return error;
};

const createUnauthorizedError = (message = 'Authentication required') => {
  const error = new ApiError(401, message);
  error.type = ErrorTypes.AUTHENTICATION_ERROR;
  return error;
};

const createForbiddenError = (message = 'Access denied') => {
  const error = new ApiError(403, message);
  error.type = ErrorTypes.AUTHORIZATION_ERROR;
  return error;
};

const createConflictError = (message = 'Resource conflict') => {
  const error = new ApiError(409, message);
  error.type = ErrorTypes.CONFLICT_ERROR;
  return error;
};

const createRateLimitError = (message = 'Rate limit exceeded') => {
  const error = new ApiError(429, message);
  error.type = ErrorTypes.RATE_LIMIT_ERROR;
  return error;
};

const createInternalError = (message = 'Internal server error') => {
  const error = new ApiError(500, message);
  error.type = ErrorTypes.INTERNAL_ERROR;
  return error;
};

module.exports = {
  ApiError,
  errorHandler,
  asyncHandler,
  notFound,
  formatValidationErrors,
  handleDatabaseError,
  handleHealthCheckError,
  handleCriticalError,
  ErrorTypes,
  createValidationError,
  createNotFoundError,
  createUnauthorizedError,
  createForbiddenError,
  createConflictError,
  createRateLimitError,
  createInternalError
};
