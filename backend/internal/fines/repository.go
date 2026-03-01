package fines

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

func (r *Repository) Create(ctx context.Context, f *Fine) error {
	query := `
		INSERT INTO fines (id, user_id, vehicle_id, amount, currency, article, description, issued_at, paid_at, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
	`
	var vehicleID, article, paidAt interface{}
	if f.VehicleID != nil {
		vehicleID = *f.VehicleID
	}
	if f.Article != nil {
		article = *f.Article
	}
	if f.PaidAt != nil {
		paidAt = *f.PaidAt
	}
	_, err := r.db.ExecContext(ctx, query,
		f.ID, f.UserID, vehicleID, f.Amount, f.Currency, article, f.Description, f.IssuedAt, paidAt, f.Status,
	)
	if err != nil {
		return fmt.Errorf("failed to create fine: %w", err)
	}
	return nil
}

func (r *Repository) GetByID(ctx context.Context, id uuid.UUID) (*Fine, error) {
	query := `
		SELECT id, user_id, vehicle_id, amount, currency, article, description, issued_at, paid_at, status, created_at, updated_at
		FROM fines WHERE id = $1
	`
	f := &Fine{}
	var vehicleID sql.NullString
	var article sql.NullString
	var paidAt sql.NullTime
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&f.ID, &f.UserID, &vehicleID, &f.Amount, &f.Currency, &article, &f.Description,
		&f.IssuedAt, &paidAt, &f.Status, &f.CreatedAt, &f.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get fine: %w", err)
	}
	if vehicleID.Valid {
		if v, err := uuid.Parse(vehicleID.String); err == nil {
			f.VehicleID = &v
		}
	}
	if article.Valid {
		f.Article = &article.String
	}
	if paidAt.Valid {
		t := paidAt.Time
		f.PaidAt = &t
	}
	return f, nil
}

func (r *Repository) ListByUserID(ctx context.Context, userID uuid.UUID, filter ListFinesFilter) ([]*Fine, error) {
	query := `
		SELECT id, user_id, vehicle_id, amount, currency, article, description, issued_at, paid_at, status, created_at, updated_at
		FROM fines WHERE user_id = $1
	`
	args := []interface{}{userID}
	pos := 2
	if filter.VehicleID != nil {
		query += fmt.Sprintf(" AND vehicle_id = $%d", pos)
		args = append(args, *filter.VehicleID)
		pos++
	}
	if filter.Status != nil {
		query += fmt.Sprintf(" AND status = $%d", pos)
		args = append(args, *filter.Status)
		pos++
	}
	query += " ORDER BY issued_at DESC, created_at DESC"
	limit := 50
	if filter.Limit > 0 {
		limit = filter.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", pos, pos+1)
	args = append(args, limit, filter.Offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list fines: %w", err)
	}
	defer rows.Close()

	var list []*Fine
	for rows.Next() {
		f := &Fine{}
		var vehicleID sql.NullString
		var article sql.NullString
		var paidAt sql.NullTime
		err := rows.Scan(
			&f.ID, &f.UserID, &vehicleID, &f.Amount, &f.Currency, &article, &f.Description,
			&f.IssuedAt, &paidAt, &f.Status, &f.CreatedAt, &f.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan fine: %w", err)
		}
		if vehicleID.Valid {
			if v, err := uuid.Parse(vehicleID.String); err == nil {
				f.VehicleID = &v
			}
		}
		if article.Valid {
			f.Article = &article.String
		}
		if paidAt.Valid {
			t := paidAt.Time
			f.PaidAt = &t
		}
		list = append(list, f)
	}
	return list, rows.Err()
}

func (r *Repository) Update(ctx context.Context, f *Fine) error {
	query := `
		UPDATE fines SET amount = $2, currency = $3, article = $4, description = $5, issued_at = $6, paid_at = $7, status = $8, updated_at = NOW()
		WHERE id = $1
	`
	var article, paidAt interface{}
	if f.Article != nil {
		article = *f.Article
	}
	if f.PaidAt != nil {
		paidAt = *f.PaidAt
	}
	_, err := r.db.ExecContext(ctx, query,
		f.ID, f.Amount, f.Currency, article, f.Description, f.IssuedAt, paidAt, f.Status,
	)
	if err != nil {
		return fmt.Errorf("failed to update fine: %w", err)
	}
	return nil
}

func (r *Repository) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM fines WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete fine: %w", err)
	}
	return nil
}

