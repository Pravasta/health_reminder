CREATE TABLE IF NOT EXISTS infusions (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    infusion_name VARCHAR(255) NOT NULL,
    tpm INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NOT NULL,
    stopped_at TIMESTAMP,
    status VARCHAR(50) NOT NULL CHECK (status IN ('scheduled', 'running', 'stopped', 'completed')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_infusions_patient_id ON infusions(patient_id);
CREATE INDEX IF NOT EXISTS idx_infusions_status ON infusions(status);