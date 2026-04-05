-- Migration script to add insurance fields to existing patients table
-- Run this script if you have an existing patients table without insurance fields

-- Add insurance columns to patients table if they don't exist
DO $$ 
BEGIN 
    -- Add insurance_company column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_company') THEN
        ALTER TABLE patients ADD COLUMN insurance_company VARCHAR(200);
    END IF;
    
    -- Add insurance_policy_number column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_policy_number') THEN
        ALTER TABLE patients ADD COLUMN insurance_policy_number VARCHAR(100);
    END IF;
    
    -- Add insurance_member_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_member_id') THEN
        ALTER TABLE patients ADD COLUMN insurance_member_id VARCHAR(100);
    END IF;
    
    -- Add insurance_group_number column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_group_number') THEN
        ALTER TABLE patients ADD COLUMN insurance_group_number VARCHAR(50);
    END IF;
    
    -- Add insurance_type column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_type') THEN
        ALTER TABLE patients ADD COLUMN insurance_type VARCHAR(50) DEFAULT 'health';
        COMMENT ON COLUMN patients.insurance_type IS 'Values: health, dental, vision, comprehensive';
    END IF;
    
    -- Add insurance_expiry_date column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'patients' AND column_name = 'insurance_expiry_date') THEN
        ALTER TABLE patients ADD COLUMN insurance_expiry_date DATE;
    END IF;
    
    -- Remove old insurance_number column if it exists and replace with new structure
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'patients' AND column_name = 'insurance_number') THEN
        -- Migrate data from old insurance_number to new insurance_policy_number
        UPDATE patients 
        SET insurance_policy_number = insurance_number 
        WHERE insurance_number IS NOT NULL AND insurance_number != '';
        
        -- Drop the old column
        ALTER TABLE patients DROP COLUMN insurance_number;
    END IF;
    
END $$;

-- Create indexes for better performance on insurance fields
CREATE INDEX IF NOT EXISTS idx_patients_insurance_company ON patients(insurance_company);
CREATE INDEX IF NOT EXISTS idx_patients_insurance_policy ON patients(insurance_policy_number);
CREATE INDEX IF NOT EXISTS idx_patients_insurance_member ON patients(insurance_member_id);
CREATE INDEX IF NOT EXISTS idx_patients_insurance_type ON patients(insurance_type);
CREATE INDEX IF NOT EXISTS idx_patients_insurance_expiry ON patients(insurance_expiry_date);

-- Add comments for documentation
COMMENT ON COLUMN patients.insurance_company IS 'Name of the patient''s insurance company';
COMMENT ON COLUMN patients.insurance_policy_number IS 'Insurance policy number';
COMMENT ON COLUMN patients.insurance_member_id IS 'Insurance member/subscriber ID';
COMMENT ON COLUMN patients.insurance_group_number IS 'Insurance group number (optional)';
COMMENT ON COLUMN patients.insurance_type IS 'Type of insurance: health, dental, vision, comprehensive';
COMMENT ON COLUMN patients.insurance_expiry_date IS 'Insurance policy expiry date';

-- Update the updated_at column trigger to include the new fields
DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at 
    BEFORE UPDATE ON patients 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
