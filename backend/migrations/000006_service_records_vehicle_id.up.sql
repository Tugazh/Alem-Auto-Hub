-- Service records: ensure table exists and add vehicle_id for service book (AAH-36)
-- Table may already exist from GORM AutoMigrate; if not, create it with vehicle_id
CREATE TABLE IF NOT EXISTS service_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date VARCHAR(255) NOT NULL,
    category VARCHAR(16) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_service_records_user_id ON service_records(user_id);
ALTER TABLE service_records ADD COLUMN IF NOT EXISTS vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_service_records_vehicle_id ON service_records(vehicle_id);
