-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
CREATE TYPE component_status AS ENUM ('ok', 'attention', 'replace', 'not_checked');
CREATE TYPE user_role AS ENUM ('owner', 'mechanic', 'admin', 'platform');
CREATE TYPE service_center_role AS ENUM ('mechanic', 'admin');
CREATE TYPE storage_provider AS ENUM ('s3', 'r2', 'gcs', 'minio');
CREATE TYPE asset_owner_scope AS ENUM ('catalog', 'vehicle', 'inspection');
CREATE TYPE asset_link_type AS ENUM ('vehicle', 'inspection', 'component', 'component_observation');

-- 1. Каталог (Catalog)

-- Марки
CREATE TABLE makes (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cyrillic_name VARCHAR(255),
    numeric_id BIGINT,
    country VARCHAR(100),
    year_from INTEGER,
    year_to INTEGER,
    popular BOOLEAN DEFAULT FALSE,
    code VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_makes_popular ON makes(popular);
CREATE INDEX idx_makes_country ON makes(country);

-- Модели
CREATE TABLE models (
    id VARCHAR(100) PRIMARY KEY,
    make_id VARCHAR(100) NOT NULL REFERENCES makes(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    cyrillic_name VARCHAR(255),
    year_from INTEGER,
    year_to INTEGER,
    class VARCHAR(10), -- A, B, C, S, etc.
    code VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_models_make_id ON models(make_id);
CREATE INDEX idx_models_class ON models(class);

-- Поколения
CREATE TABLE generations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_id VARCHAR(100) NOT NULL REFERENCES models(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    year_from INTEGER,
    year_to INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_generations_model_id ON generations(model_id);

-- Платформы/модификации
CREATE TABLE vehicle_platforms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    generation_id UUID REFERENCES generations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    body_type VARCHAR(50),
    engine_code VARCHAR(100),
    trim_level VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vehicle_platforms_generation_id ON vehicle_platforms(generation_id);

-- Компоненты (иерархия деталей)
CREATE TABLE components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_platform_id UUID REFERENCES vehicle_platforms(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES components(id) ON DELETE CASCADE,
    code VARCHAR(255) NOT NULL, -- стабильный идентификатор, например brakes.pad.front.left
    name VARCHAR(255) NOT NULL,
    side VARCHAR(20), -- left, right, front, rear, none
    position VARCHAR(50), -- front, rear, etc.
    is_leaf BOOLEAN DEFAULT FALSE, -- деталь vs узел
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_components_vehicle_platform_id ON components(vehicle_platform_id);
CREATE INDEX idx_components_parent_id ON components(parent_id);
CREATE INDEX idx_components_code ON components(code);
CREATE INDEX idx_components_platform_parent ON components(vehicle_platform_id, parent_id);

-- 2. Экземпляры авто (Vehicle Instance)

-- Конкретные машины
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vin VARCHAR(17) UNIQUE,
    license_plate VARCHAR(20),
    year INTEGER,
    odometer_km INTEGER DEFAULT 0,
    vehicle_platform_id UUID REFERENCES vehicle_platforms(id),
    engine_code VARCHAR(100),
    trim_level VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vehicles_vin ON vehicles(vin);
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX idx_vehicles_platform_id ON vehicles(vehicle_platform_id);

-- Владельцы
CREATE TABLE vehicle_owners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- будет ссылаться на users.id
    owned_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    owned_to TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_vehicle_owners_vehicle_id ON vehicle_owners(vehicle_id);
CREATE INDEX idx_vehicle_owners_user_id ON vehicle_owners(user_id);
CREATE INDEX idx_vehicle_owners_current ON vehicle_owners(vehicle_id, is_current) WHERE is_current = TRUE;

-- 3. Осмотры (Inspections)

-- Автобоксы/сервисы
CREATE TABLE service_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Пользователи сервисов (мастера/админы)
CREATE TABLE service_center_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_center_id UUID NOT NULL REFERENCES service_centers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- будет ссылаться на users.id
    role service_center_role NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(service_center_id, user_id)
);

CREATE INDEX idx_service_center_users_center_id ON service_center_users(service_center_id);
CREATE INDEX idx_service_center_users_user_id ON service_center_users(user_id);

-- Визиты/осмотры
CREATE TABLE inspections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    service_center_id UUID NOT NULL REFERENCES service_centers(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL, -- будет ссылаться на users.id
    odometer_km INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_inspections_vehicle_id ON inspections(vehicle_id);
CREATE INDEX idx_inspections_service_center_id ON inspections(service_center_id);
CREATE INDEX idx_inspections_created_by ON inspections(created_by_user_id);
CREATE INDEX idx_inspections_created_at ON inspections(created_at DESC);

-- Наблюдения по деталям
CREATE TABLE component_observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inspection_id UUID NOT NULL REFERENCES inspections(id) ON DELETE CASCADE,
    component_id UUID NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    status component_status NOT NULL,
    condition_grade VARCHAR(10), -- 0-100 или A/B/C/D
    comment TEXT,
    measured_values JSONB, -- толщина колодки, остаток протектора, люфт, давление и т.д.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_component_observations_inspection_id ON component_observations(inspection_id);
CREATE INDEX idx_component_observations_component_id ON component_observations(component_id);
CREATE INDEX idx_component_observations_status ON component_observations(status);

-- Материализованное текущее состояние (опционально, для быстрых запросов)
CREATE TABLE vehicle_component_state (
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    component_id UUID NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    last_inspection_id UUID REFERENCES inspections(id),
    status component_status,
    condition_grade VARCHAR(10),
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (vehicle_id, component_id)
);

CREATE INDEX idx_vehicle_component_state_vehicle_id ON vehicle_component_state(vehicle_id);
CREATE INDEX idx_vehicle_component_state_component_id ON vehicle_component_state(component_id);
CREATE INDEX idx_vehicle_component_state_status ON vehicle_component_state(status);

-- 4. Медиа и 3D (Media/Assets)

-- Метаданные файлов
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    storage_provider storage_provider NOT NULL,
    bucket VARCHAR(255) NOT NULL,
    object_key VARCHAR(1000) NOT NULL,
    content_type VARCHAR(255),
    size_bytes BIGINT,
    sha256 VARCHAR(64),
    version INTEGER DEFAULT 1,
    owner_scope asset_owner_scope NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_assets_storage_provider ON assets(storage_provider);
CREATE INDEX idx_assets_owner_scope ON assets(owner_scope);
CREATE INDEX idx_assets_sha256 ON assets(sha256);

-- Связки медиа с сущностями
CREATE TABLE asset_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    link_type asset_link_type NOT NULL,
    link_id UUID NOT NULL, -- ID связанной сущности (vehicle, inspection, component, component_observation)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_asset_links_asset_id ON asset_links(asset_id);
CREATE INDEX idx_asset_links_link_type_id ON asset_links(link_type, link_id);
CREATE INDEX idx_asset_links_link_type ON asset_links(link_type);

-- 5. Пользователи и доступ

-- Пользователи системы
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    role user_role NOT NULL DEFAULT 'owner',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Сессии (опционально, если JWT не используется)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Функции для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггеры для автоматического обновления updated_at
CREATE TRIGGER update_makes_updated_at BEFORE UPDATE ON makes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_models_updated_at BEFORE UPDATE ON models
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
