const { Pool } = require('pg');
const logger = require('./logger');

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'dr_saathi',
  user: process.env.DB_USER || 'dr_saathi_user',
  password: process.env.DB_PASSWORD,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // How long a client is allowed to remain idle
  connectionTimeoutMillis: 2000, // How long to wait when connecting a client
};

// Use connection string in production
if (process.env.DATABASE_URL) {
  dbConfig.connectionString = process.env.DATABASE_URL;
  delete dbConfig.host;
  delete dbConfig.port;
  delete dbConfig.database;
  delete dbConfig.user;
  delete dbConfig.password;
}

const pool = new Pool(dbConfig);

// Handle connection errors
pool.on('error', (err) => {
  logger.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Database initialization and schema creation
async function initialize() {
  try {
    logger.info('Connecting to database...');
    
    // Test connection
    const client = await pool.connect();
    logger.info('Database connected successfully');
    client.release();
    
    // Create tables
    await createTables();
    logger.info('Database tables initialized');
    
  } catch (error) {
    logger.error('Database initialization failed:', error);
    throw error;
  }
}

// Create all necessary tables
async function createTables() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Enable UUID extension
    await client.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
    
    // Users table (for authentication)
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'user',
        is_active BOOLEAN DEFAULT true,
        last_login TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Patients table
    await client.query(`
      CREATE TABLE IF NOT EXISTS patients (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        date_of_birth DATE,
        age INTEGER,
        gender VARCHAR(20),
        phone_number VARCHAR(20) NOT NULL,
        email VARCHAR(255),
        address TEXT,
        emergency_contact VARCHAR(100),
        emergency_phone VARCHAR(20),
        medical_history TEXT,
        allergies TEXT,
        blood_group VARCHAR(10),
        height_cm INTEGER,
        weight_kg DECIMAL(5,2),
        occupation VARCHAR(100),
        marital_status VARCHAR(20),
        insurance_company VARCHAR(200),
        insurance_policy_number VARCHAR(100),
        insurance_member_id VARCHAR(100),
        insurance_group_number VARCHAR(50),
        insurance_type VARCHAR(50), -- 'health', 'dental', 'vision', 'comprehensive'
        insurance_expiry_date DATE,
        profile_image_url TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Doctors table
    await client.query(`
      CREATE TABLE IF NOT EXISTS doctors (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        specialization VARCHAR(100) NOT NULL,
        license_number VARCHAR(50) UNIQUE NOT NULL,
        hospital VARCHAR(200),
        clinic_name VARCHAR(200),
        phone VARCHAR(20) NOT NULL,
        email VARCHAR(255) NOT NULL,
        address TEXT,
        rating DECIMAL(3,2) DEFAULT 0.0,
        experience_years INTEGER DEFAULT 0,
        profile_image_url TEXT,
        qualifications TEXT[],
        languages TEXT[],
        consultation_fee DECIMAL(10,2),
        about TEXT,
        is_verified BOOLEAN DEFAULT false,
        is_active BOOLEAN DEFAULT true,
        verification_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Doctor availability slots
    await client.query(`
      CREATE TABLE IF NOT EXISTS doctor_availability_slots (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
        day_of_week INTEGER NOT NULL, -- 0=Sunday, 1=Monday, etc.
        start_time TIME NOT NULL,
        end_time TIME NOT NULL,
        consultation_type VARCHAR(20) DEFAULT 'in_person', -- 'in_person', 'telehealth', 'both'
        is_available BOOLEAN DEFAULT true,
        max_patients INTEGER DEFAULT 10,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Appointments table
    await client.query(`
      CREATE TABLE IF NOT EXISTS appointments (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
        slot_id UUID REFERENCES doctor_availability_slots(id),
        appointment_date DATE NOT NULL,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'
        consultation_type VARCHAR(20) DEFAULT 'in_person',
        chief_complaint TEXT,
        symptoms TEXT,
        diagnosis TEXT,
        treatment_plan TEXT,
        notes TEXT,
        consultation_fee DECIMAL(10,2),
        is_paid BOOLEAN DEFAULT false,
        payment_method VARCHAR(50),
        payment_reference VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Prescriptions table
    await client.query(`
      CREATE TABLE IF NOT EXISTS prescriptions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
        appointment_id UUID REFERENCES appointments(id),
        prescription_date DATE NOT NULL,
        diagnosis TEXT NOT NULL,
        notes TEXT,
        status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'cancelled'
        follow_up_date DATE,
        is_emergency BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Medications table
    await client.query(`
      CREATE TABLE IF NOT EXISTS medications (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        prescription_id UUID NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        generic_name VARCHAR(200),
        dosage VARCHAR(100) NOT NULL,
        frequency VARCHAR(100) NOT NULL,
        duration VARCHAR(100) NOT NULL,
        form VARCHAR(50) NOT NULL, -- 'tablet', 'capsule', 'syrup', 'injection', etc.
        quantity INTEGER NOT NULL,
        instructions TEXT,
        side_effects TEXT,
        is_generic BOOLEAN DEFAULT false,
        price DECIMAL(10,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Pharmacies table
    await client.query(`
      CREATE TABLE IF NOT EXISTS pharmacies (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name VARCHAR(200) NOT NULL,
        license_number VARCHAR(50) UNIQUE NOT NULL,
        owner_name VARCHAR(200),
        phone VARCHAR(20) NOT NULL,
        email VARCHAR(255),
        address TEXT NOT NULL,
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        operating_hours JSONB,
        services TEXT[],
        is_verified BOOLEAN DEFAULT false,
        is_active BOOLEAN DEFAULT true,
        rating DECIMAL(3,2) DEFAULT 0.0,
        verification_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Prescription deliveries table
    await client.query(`
      CREATE TABLE IF NOT EXISTS prescription_deliveries (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        prescription_id UUID NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
        pharmacy_id UUID NOT NULL REFERENCES pharmacies(id) ON DELETE CASCADE,
        patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        delivery_address TEXT NOT NULL,
        delivery_phone VARCHAR(20),
        delivery_instructions TEXT,
        status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'confirmed', 'preparing', 'dispatched', 'delivered', 'cancelled'
        estimated_delivery_time TIMESTAMP,
        actual_delivery_time TIMESTAMP,
        delivery_fee DECIMAL(10,2) DEFAULT 0.00,
        total_amount DECIMAL(10,2),
        payment_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'paid', 'cod'
        delivery_person_name VARCHAR(100),
        delivery_person_phone VARCHAR(20),
        tracking_number VARCHAR(50),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // SMS reminders table
    await client.query(`
      CREATE TABLE IF NOT EXISTS sms_reminders (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        appointment_id UUID REFERENCES appointments(id),
        prescription_id UUID REFERENCES prescriptions(id),
        phone_number VARCHAR(20) NOT NULL,
        message TEXT NOT NULL,
        scheduled_time TIMESTAMP NOT NULL,
        sent_time TIMESTAMP,
        status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'cancelled'
        reminder_type VARCHAR(50) NOT NULL, -- 'appointment', 'medication', 'follow_up', 'custom'
        retry_count INTEGER DEFAULT 0,
        error_message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Medical records table
    await client.query(`
      CREATE TABLE IF NOT EXISTS medical_records (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
        appointment_id UUID REFERENCES appointments(id),
        record_type VARCHAR(50) NOT NULL, -- 'consultation', 'lab_report', 'imaging', 'discharge_summary'
        title VARCHAR(200) NOT NULL,
        content TEXT,
        file_url TEXT,
        file_type VARCHAR(50),
        file_size INTEGER,
        is_confidential BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Payment holds table (24-hour hold before release to doctor)
    await client.query(`
      CREATE TABLE IF NOT EXISTS payment_holds (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
        patient_id UUID NOT NULL REFERENCES patients(id),
        doctor_id UUID NOT NULL REFERENCES doctors(id),
        amount DECIMAL(10,2) NOT NULL,
        hold_status VARCHAR(20) NOT NULL DEFAULT 'held',
        held_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        release_at TIMESTAMP NOT NULL,
        released_at TIMESTAMP,
        refunded_at TIMESTAMP,
        refund_transaction_id VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Audit logs table
    await client.query(`
      CREATE TABLE IF NOT EXISTS audit_logs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id),
        action VARCHAR(100) NOT NULL,
        table_name VARCHAR(100),
        record_id UUID,
        old_values JSONB,
        new_values JSONB,
        ip_address INET,
        user_agent TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // System settings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS system_settings (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        key VARCHAR(100) UNIQUE NOT NULL,
        value TEXT,
        description TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Create indexes for better performance
    await client.query('CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone_number)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_patients_insurance_company ON patients(insurance_company)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_patients_insurance_policy ON patients(insurance_policy_number)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_patients_insurance_member ON patients(insurance_member_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_doctors_specialization ON doctors(specialization)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_prescriptions_doctor ON prescriptions(doctor_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_medications_prescription ON medications(prescription_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_deliveries_status ON prescription_deliveries(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_reminders_scheduled_time ON sms_reminders(scheduled_time)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_reminders_status ON sms_reminders(status)');
    
    // Create triggers for updated_at timestamps
    await client.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    `);
    
    const tablesWithUpdatedAt = [
      'users', 'patients', 'doctors', 'doctor_availability_slots', 
      'appointments', 'prescriptions', 'medications', 'pharmacies',
      'prescription_deliveries', 'sms_reminders', 'medical_records', 'system_settings'
    ];
    
    for (const table of tablesWithUpdatedAt) {
      await client.query(`
        DROP TRIGGER IF EXISTS update_${table}_updated_at ON ${table};
        CREATE TRIGGER update_${table}_updated_at 
        BEFORE UPDATE ON ${table} 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
      `);
    }
    
    await client.query('COMMIT');
    logger.info('All database tables created successfully');
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Error creating database tables:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Utility function to execute queries
async function query(text, params) {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    logger.debug('Executed query', { text, duration, rows: res.rowCount });
    return res;
  } catch (error) {
    logger.error('Query error', { text, error: error.message });
    throw error;
  }
}

// Get a client from the pool
async function getClient() {
  return pool.connect();
}

// Close the pool
async function end() {
  await pool.end();
  logger.info('Database pool closed');
}

module.exports = {
  initialize,
  query,
  getClient,
  end,
  pool
};
