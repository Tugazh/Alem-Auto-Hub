DROP INDEX IF EXISTS idx_service_records_vehicle_id;
ALTER TABLE service_records DROP COLUMN IF EXISTS vehicle_id;
