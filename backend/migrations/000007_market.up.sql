-- Market module (AAH-39/40/41): products, services, ads
CREATE TYPE market_item_kind AS ENUM ('product', 'service', 'ad');

CREATE TABLE market_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kind market_item_kind NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(120) NOT NULL,
    price NUMERIC(12,2) NOT NULL CHECK (price > 0),
    currency VARCHAR(10) NOT NULL DEFAULT 'KZT',
    available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_market_items_user_id ON market_items(user_id);
CREATE INDEX idx_market_items_kind ON market_items(kind);
CREATE INDEX idx_market_items_category ON market_items(category);
CREATE INDEX idx_market_items_created_at ON market_items(created_at);

CREATE TRIGGER update_market_items_updated_at BEFORE UPDATE ON market_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
