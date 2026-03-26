CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    patient_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_activity_logs_patient_id ON activity_logs (patient_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_type ON activity_logs (type);