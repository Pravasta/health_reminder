CREATE TABLE IF NOT EXISTS patients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(32) NOT NULL UNIQUE,
    gender VARCHAR(16) NOT NULL CHECK (gender IN ('male', 'female')) DEFAULT 'male',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_patients_code ON patients (code);
CREATE INDEX IF NOT EXISTS idx_patients_name ON patients (name);