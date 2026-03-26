package market

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"alem-auto/internal/database"
	"github.com/google/uuid"
)

type Repository struct {
	db *database.DB
}

func NewRepository(db *database.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) Create(ctx context.Context, item *Item) error {
	query := `
		INSERT INTO market_items (
			id, user_id, kind, title, description, category, price, currency, available, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
	`
	_, err := r.db.ExecContext(
		ctx,
		query,
		item.ID,
		item.UserID,
		item.Kind,
		item.Title,
		item.Description,
		item.Category,
		item.Price,
		item.Currency,
		item.Available,
	)
	if err != nil {
		return fmt.Errorf("failed to create market item: %w", err)
	}
	return nil
}

func (r *Repository) GetByID(ctx context.Context, id uuid.UUID) (*Item, error) {
	query := `
		SELECT id, user_id, kind, title, description, category, price, currency, available, created_at, updated_at
		FROM market_items
		WHERE id = $1
	`
	item := &Item{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&item.ID,
		&item.UserID,
		&item.Kind,
		&item.Title,
		&item.Description,
		&item.Category,
		&item.Price,
		&item.Currency,
		&item.Available,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get market item: %w", err)
	}
	return item, nil
}

func (r *Repository) ListByUserAndKind(ctx context.Context, userID uuid.UUID, kind string, filter ListItemsFilter) ([]*Item, error) {
	query := `
		SELECT id, user_id, kind, title, description, category, price, currency, available, created_at, updated_at
		FROM market_items
		WHERE user_id = $1 AND kind = $2
	`
	args := []interface{}{userID, kind}
	pos := 3

	if filter.Category != nil && *filter.Category != "" {
		query += fmt.Sprintf(" AND category = $%d", pos)
		args = append(args, *filter.Category)
		pos++
	}

	if filter.Search != nil && *filter.Search != "" {
		query += fmt.Sprintf(" AND (LOWER(title) LIKE $%d OR LOWER(description) LIKE $%d)", pos, pos)
		args = append(args, "%"+strings.ToLower(*filter.Search)+"%")
		pos++
	}

	query += " ORDER BY created_at DESC"

	limit := 50
	if filter.Limit > 0 {
		limit = filter.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", pos, pos+1)
	args = append(args, limit, filter.Offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list market items: %w", err)
	}
	defer rows.Close()

	var list []*Item
	for rows.Next() {
		item := &Item{}
		err := rows.Scan(
			&item.ID,
			&item.UserID,
			&item.Kind,
			&item.Title,
			&item.Description,
			&item.Category,
			&item.Price,
			&item.Currency,
			&item.Available,
			&item.CreatedAt,
			&item.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan market item: %w", err)
		}
		list = append(list, item)
	}

	return list, rows.Err()
}

func (r *Repository) Update(ctx context.Context, item *Item) error {
	query := `
		UPDATE market_items
		SET title = $2, description = $3, category = $4, price = $5, currency = $6, available = $7, updated_at = NOW()
		WHERE id = $1
	`
	_, err := r.db.ExecContext(
		ctx,
		query,
		item.ID,
		item.Title,
		item.Description,
		item.Category,
		item.Price,
		item.Currency,
		item.Available,
	)
	if err != nil {
		return fmt.Errorf("failed to update market item: %w", err)
	}
	return nil
}

func (r *Repository) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM market_items WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete market item: %w", err)
	}
	return nil
}
