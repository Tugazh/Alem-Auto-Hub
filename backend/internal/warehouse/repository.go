package warehouse

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/database"
)

type Repository struct {
	db *database.DB
}

func NewRepository(db *database.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) CreateItem(ctx context.Context, item *Item) error {
	query := `
		INSERT INTO warehouse_items (id, sku, name, description, unit, min_quantity, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
	`
	_, err := r.db.ExecContext(ctx, query,
		item.ID, item.SKU, item.Name, item.Description, item.Unit, item.MinQuantity,
	)
	if err != nil {
		return fmt.Errorf("failed to create item: %w", err)
	}
	return nil
}

func (r *Repository) GetItemByID(ctx context.Context, id uuid.UUID) (*Item, error) {
	query := `SELECT id, sku, name, description, unit, min_quantity, created_at, updated_at FROM warehouse_items WHERE id = $1`
	item := &Item{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&item.ID, &item.SKU, &item.Name, &item.Description, &item.Unit, &item.MinQuantity, &item.CreatedAt, &item.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get item: %w", err)
	}
	return item, nil
}

func (r *Repository) GetItemBySKU(ctx context.Context, sku string) (*Item, error) {
	query := `SELECT id, sku, name, description, unit, min_quantity, created_at, updated_at FROM warehouse_items WHERE sku = $1`
	item := &Item{}
	err := r.db.QueryRowContext(ctx, query, sku).Scan(
		&item.ID, &item.SKU, &item.Name, &item.Description, &item.Unit, &item.MinQuantity, &item.CreatedAt, &item.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get item by sku: %w", err)
	}
	return item, nil
}

func (r *Repository) ListItems(ctx context.Context, limit, offset int) ([]*Item, error) {
	if limit <= 0 {
		limit = 50
	}
	query := `SELECT id, sku, name, description, unit, min_quantity, created_at, updated_at FROM warehouse_items ORDER BY sku LIMIT $1 OFFSET $2`
	rows, err := r.db.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list items: %w", err)
	}
	defer rows.Close()
	var list []*Item
	for rows.Next() {
		item := &Item{}
		err := rows.Scan(&item.ID, &item.SKU, &item.Name, &item.Description, &item.Unit, &item.MinQuantity, &item.CreatedAt, &item.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("scan item: %w", err)
		}
		list = append(list, item)
	}
	return list, rows.Err()
}

func (r *Repository) UpdateItem(ctx context.Context, item *Item) error {
	query := `
		UPDATE warehouse_items SET name = $2, description = $3, unit = $4, min_quantity = $5, updated_at = NOW()
		WHERE id = $1
	`
	_, err := r.db.ExecContext(ctx, query, item.ID, item.Name, item.Description, item.Unit, item.MinQuantity)
	if err != nil {
		return fmt.Errorf("failed to update item: %w", err)
	}
	return nil
}

func (r *Repository) DeleteItem(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM warehouse_items WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete item: %w", err)
	}
	return nil
}

func (r *Repository) GetStockByItemID(ctx context.Context, itemID uuid.UUID) (*Stock, error) {
	query := `SELECT id, item_id, quantity, updated_at FROM warehouse_stock WHERE item_id = $1`
	s := &Stock{}
	err := r.db.QueryRowContext(ctx, query, itemID).Scan(&s.ID, &s.ItemID, &s.Quantity, &s.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get stock: %w", err)
	}
	return s, nil
}

func (r *Repository) CreateStock(ctx context.Context, s *Stock) error {
	query := `INSERT INTO warehouse_stock (id, item_id, quantity, updated_at) VALUES ($1, $2, $3, NOW())`
	_, err := r.db.ExecContext(ctx, query, s.ID, s.ItemID, s.Quantity)
	if err != nil {
		return fmt.Errorf("failed to create stock: %w", err)
	}
	return nil
}

func (r *Repository) UpdateStockQuantity(ctx context.Context, itemID uuid.UUID, quantity int) error {
	query := `UPDATE warehouse_stock SET quantity = $2, updated_at = NOW() WHERE item_id = $1`
	_, err := r.db.ExecContext(ctx, query, itemID, quantity)
	if err != nil {
		return fmt.Errorf("failed to update stock: %w", err)
	}
	return nil
}

func (r *Repository) CreateMovement(ctx context.Context, m *Movement) error {
	query := `INSERT INTO warehouse_movements (id, item_id, quantity_delta, type, reference, created_at) VALUES ($1, $2, $3, $4, $5, NOW())`
	var ref interface{}
	if m.Reference != nil {
		ref = *m.Reference
	}
	_, err := r.db.ExecContext(ctx, query, m.ID, m.ItemID, m.QuantityDelta, m.Type, ref)
	if err != nil {
		return fmt.Errorf("failed to create movement: %w", err)
	}
	return nil
}

func (r *Repository) ListMovements(ctx context.Context, itemID *uuid.UUID, limit, offset int) ([]*Movement, error) {
	if limit <= 0 {
		limit = 50
	}
	query := `SELECT id, item_id, quantity_delta, type, reference, created_at FROM warehouse_movements`
	args := []interface{}{limit, offset}
	if itemID != nil {
		query = `SELECT id, item_id, quantity_delta, type, reference, created_at FROM warehouse_movements WHERE item_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`
		args = []interface{}{*itemID, limit, offset}
	} else {
		query += ` ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	}
	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list movements: %w", err)
	}
	defer rows.Close()
	var list []*Movement
	for rows.Next() {
		m := &Movement{}
		var ref sql.NullString
		err := rows.Scan(&m.ID, &m.ItemID, &m.QuantityDelta, &m.Type, &ref, &m.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("scan movement: %w", err)
		}
		if ref.Valid {
			m.Reference = &ref.String
		}
		list = append(list, m)
	}
	return list, rows.Err()
}
