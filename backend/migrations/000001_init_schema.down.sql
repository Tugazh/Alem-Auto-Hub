-- Удаление триггеров
DROP TRIGGER IF EXISTS update_vehicles_updated_at ON vehicles;
DROP TRIGGER IF EXISTS update_models_updated_at ON models;
DROP TRIGGER IF EXISTS update_makes_updated_at ON makes;

-- Удаление функций
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Удаление таблиц (в обратном порядке из-за зависимостей)
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS asset_links;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS vehicle_component_state;
DROP TABLE IF EXISTS component_observations;
DROP TABLE IF EXISTS inspections;
DROP TABLE IF EXISTS service_center_users;
DROP TABLE IF EXISTS service_centers;
DROP TABLE IF EXISTS vehicle_owners;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS components;
DROP TABLE IF EXISTS vehicle_platforms;
DROP TABLE IF EXISTS generations;
DROP TABLE IF EXISTS models;
DROP TABLE IF EXISTS makes;

-- Удаление типов
DROP TYPE IF EXISTS asset_link_type;
DROP TYPE IF EXISTS asset_owner_scope;
DROP TYPE IF EXISTS storage_provider;
DROP TYPE IF EXISTS service_center_role;
DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS component_status;
