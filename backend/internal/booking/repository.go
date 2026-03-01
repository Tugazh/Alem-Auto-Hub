package booking

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

func (r *Repository) Create(ctx context.Context, b *Booking) error {
	query := `
		INSERT INTO bookings (id, service_center_id, vehicle_id, user_id, scheduled_at, status, notes, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
	`
	var notes interface{}
	if b.Notes != nil {
		notes = *b.Notes
	}
	_, err := r.db.ExecContext(ctx, query,
		b.ID, b.ServiceCenterID, b.VehicleID, b.UserID, b.ScheduledAt, b.Status, notes,
	)
	if err != nil {
		return fmt.Errorf("failed to create booking: %w", err)
	}
	return nil
}

func (r *Repository) GetByID(ctx context.Context, id uuid.UUID) (*Booking, error) {
	query := `
		SELECT id, service_center_id, vehicle_id, user_id, scheduled_at, status, notes, created_at, updated_at
		FROM bookings WHERE id = $1
	`
	b := &Booking{}
	var notes sql.NullString
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&b.ID, &b.ServiceCenterID, &b.VehicleID, &b.UserID, &b.ScheduledAt, &b.Status, &notes, &b.CreatedAt, &b.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get booking: %w", err)
	}
	if notes.Valid {
		b.Notes = &notes.String
	}
	return b, nil
}

func (r *Repository) ListByUserID(ctx context.Context, userID uuid.UUID, filter ListBookingsFilter) ([]*Booking, error) {
	query := `SELECT id, service_center_id, vehicle_id, user_id, scheduled_at, status, notes, created_at, updated_at FROM bookings WHERE user_id = $1`
	args := []interface{}{userID}
	pos := 2
	if filter.ServiceCenterID != nil {
		query += fmt.Sprintf(" AND service_center_id = $%d", pos)
		args = append(args, *filter.ServiceCenterID)
		pos++
	}
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
	if filter.From != nil {
		query += fmt.Sprintf(" AND scheduled_at >= $%d", pos)
		args = append(args, *filter.From)
		pos++
	}
	if filter.To != nil {
		query += fmt.Sprintf(" AND scheduled_at <= $%d", pos)
		args = append(args, *filter.To)
		pos++
	}
	query += " ORDER BY scheduled_at DESC"
	limit := 50
	if filter.Limit > 0 {
		limit = filter.Limit
	}
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", pos, pos+1)
	args = append(args, limit, filter.Offset)

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to list bookings: %w", err)
	}
	defer rows.Close()

	var list []*Booking
	for rows.Next() {
		b := &Booking{}
		var notes sql.NullString
		err := rows.Scan(
			&b.ID, &b.ServiceCenterID, &b.VehicleID, &b.UserID, &b.ScheduledAt, &b.Status, &notes, &b.CreatedAt, &b.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan booking: %w", err)
		}
		if notes.Valid {
			b.Notes = &notes.String
		}
		list = append(list, b)
	}
	return list, rows.Err()
}

func (r *Repository) Update(ctx context.Context, b *Booking) error {
	query := `
		UPDATE bookings SET scheduled_at = $2, status = $3, notes = $4, updated_at = NOW()
		WHERE id = $1
	`
	var notes interface{}
	if b.Notes != nil {
		notes = *b.Notes
	}
	_, err := r.db.ExecContext(ctx, query, b.ID, b.ScheduledAt, b.Status, notes)
	if err != nil {
		return fmt.Errorf("failed to update booking: %w", err)
	}
	return nil
}

func (r *Repository) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, "DELETE FROM bookings WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete booking: %w", err)
	}
	return nil
}
