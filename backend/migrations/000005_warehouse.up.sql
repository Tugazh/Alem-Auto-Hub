-- Warehouse (AAH-32) - global platform warehouse
CREATE TABLE warehouse_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit VARCHAR(50) NOT NULL DEFAULT 'pcs',
    min_quantity INTEGER NOT NULL DEFAULT 0 CHECK (min_quantity >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE warehouse_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL UNIQUE REFERENCES warehouse_items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TYPE warehouse_movement_type AS ENUM ('in', 'out', 'adjust');

CREATE TABLE warehouse_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES warehouse_items(id) ON DELETE CASCADE,
    quantity_delta INTEGER NOT NULL,
    type warehouse_movement_type NOT NULL,
    reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_warehouse_items_sku ON warehouse_items(sku);
CREATE INDEX idx_warehouse_stock_item_id ON warehouse_stock(item_id);
CREATE INDEX idx_warehouse_movements_item_id ON warehouse_movements(item_id);
CREATE INDEX idx_warehouse_movements_created_at ON warehouse_movements(created_at);

CREATE TRIGGER update_warehouse_items_updated_at BEFORE UPDATE ON warehouse_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_warehouse_stock_updated_at BEFORE UPDATE ON warehouse_stock
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
