-- Fines (AAH-30)
CREATE TYPE fine_status AS ENUM ('pending', 'paid', 'disputed');

CREATE TABLE fines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(10) NOT NULL DEFAULT 'KZT',
    article VARCHAR(100),
    description TEXT,
    issued_at DATE NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE,
    status fine_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_fines_user_id ON fines(user_id);
CREATE INDEX idx_fines_vehicle_id ON fines(vehicle_id);
CREATE INDEX idx_fines_status ON fines(status);
CREATE INDEX idx_fines_issued_at ON fines(issued_at);

CREATE TRIGGER update_fines_updated_at BEFORE UPDATE ON fines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
