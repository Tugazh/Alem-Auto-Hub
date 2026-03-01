DROP TRIGGER IF EXISTS update_warehouse_stock_updated_at ON warehouse_stock;
DROP TRIGGER IF EXISTS update_warehouse_items_updated_at ON warehouse_items;
DROP TABLE IF EXISTS warehouse_movements;
DROP TABLE IF EXISTS warehouse_stock;
DROP TABLE IF EXISTS warehouse_items;
DROP TYPE IF EXISTS warehouse_movement_type;
