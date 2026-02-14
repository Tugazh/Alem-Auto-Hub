package vehicle

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

// Vehicle methods

func (r *Repository) CreateVehicle(ctx context.Context, v *Vehicle) error {
	query := `
		INSERT INTO vehicles (id, vin, license_plate, year, odometer_km, vehicle_platform_id, engine_code, trim_level)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	_, err := r.db.ExecContext(ctx, query,
		v.ID, v.VIN, v.LicensePlate, v.Year, v.OdometerKm,
		v.VehiclePlatformID, v.EngineCode, v.TrimLevel,
	)
	if err != nil {
		return fmt.Errorf("failed to create vehicle: %w", err)
	}

	return nil
}

func (r *Repository) GetVehicleByID(ctx context.Context, id uuid.UUID) (*Vehicle, error) {
	query := `
		SELECT id, vin, license_plate, year, odometer_km, vehicle_platform_id, engine_code, trim_level, created_at, updated_at
		FROM vehicles
		WHERE id = $1
	`

	v := &Vehicle{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&v.ID, &v.VIN, &v.LicensePlate, &v.Year, &v.OdometerKm,
		&v.VehiclePlatformID, &v.EngineCode, &v.TrimLevel, &v.CreatedAt, &v.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicle: %w", err)
	}

	return v, nil
}

func (r *Repository) GetVehicleByVIN(ctx context.Context, vin string) (*Vehicle, error) {
	query := `
		SELECT id, vin, license_plate, year, odometer_km, vehicle_platform_id, engine_code, trim_level, created_at, updated_at
		FROM vehicles
		WHERE vin = $1
	`

	v := &Vehicle{}
	err := r.db.QueryRowContext(ctx, query, vin).Scan(
		&v.ID, &v.VIN, &v.LicensePlate, &v.Year, &v.OdometerKm,
		&v.VehiclePlatformID, &v.EngineCode, &v.TrimLevel, &v.CreatedAt, &v.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicle by VIN: %w", err)
	}

	return v, nil
}

func (r *Repository) UpdateVehicle(ctx context.Context, v *Vehicle) error {
	query := `
		UPDATE vehicles
		SET vin = $2, license_plate = $3, year = $4, odometer_km = $5,
		    vehicle_platform_id = $6, engine_code = $7, trim_level = $8, updated_at = NOW()
		WHERE id = $1
	`

	result, err := r.db.ExecContext(ctx, query,
		v.ID, v.VIN, v.LicensePlate, v.Year, v.OdometerKm,
		v.VehiclePlatformID, v.EngineCode, v.TrimLevel,
	)
	if err != nil {
		return fmt.Errorf("failed to update vehicle: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("vehicle not found")
	}

	return nil
}

func (r *Repository) UpdateOdometer(ctx context.Context, vehicleID uuid.UUID, odometerKm int) error {
	query := `
		UPDATE vehicles
		SET odometer_km = $2, updated_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.ExecContext(ctx, query, vehicleID, odometerKm)
	if err != nil {
		return fmt.Errorf("failed to update odometer: %w", err)
	}

	return nil
}

// VehicleOwner methods

func (r *Repository) CreateVehicleOwner(ctx context.Context, vo *VehicleOwner) error {
	query := `
		INSERT INTO vehicle_owners (id, vehicle_id, user_id, owned_from, owned_to, is_current)
		VALUES ($1, $2, $3, $4, $5, $6)
	`

	_, err := r.db.ExecContext(ctx, query,
		vo.ID, vo.VehicleID, vo.UserID, vo.OwnedFrom, vo.OwnedTo, vo.IsCurrent,
	)
	if err != nil {
		return fmt.Errorf("failed to create vehicle owner: %w", err)
	}

	return nil
}

func (r *Repository) GetCurrentOwnersByVehicleID(ctx context.Context, vehicleID uuid.UUID) ([]*VehicleOwner, error) {
	query := `
		SELECT id, vehicle_id, user_id, owned_from, owned_to, is_current, created_at
		FROM vehicle_owners
		WHERE vehicle_id = $1 AND is_current = TRUE
		ORDER BY owned_from DESC
	`

	rows, err := r.db.QueryContext(ctx, query, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to query vehicle owners: %w", err)
	}
	defer rows.Close()

	var owners []*VehicleOwner
	for rows.Next() {
		vo := &VehicleOwner{}
		err := rows.Scan(
			&vo.ID, &vo.VehicleID, &vo.UserID, &vo.OwnedFrom,
			&vo.OwnedTo, &vo.IsCurrent, &vo.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan vehicle owner: %w", err)
		}
		owners = append(owners, vo)
	}

	return owners, rows.Err()
}

func (r *Repository) GetVehiclesByUserID(ctx context.Context, userID uuid.UUID) ([]*Vehicle, error) {
	query := `
		SELECT v.id, v.vin, v.license_plate, v.year, v.odometer_km, 
		       v.vehicle_platform_id, v.engine_code, v.trim_level, v.created_at, v.updated_at
		FROM vehicles v
		INNER JOIN vehicle_owners vo ON v.id = vo.vehicle_id
		WHERE vo.user_id = $1 AND vo.is_current = TRUE
		ORDER BY v.created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to query vehicles by user: %w", err)
	}
	defer rows.Close()

	var vehicles []*Vehicle
	for rows.Next() {
		v := &Vehicle{}
		err := rows.Scan(
			&v.ID, &v.VIN, &v.LicensePlate, &v.Year, &v.OdometerKm,
			&v.VehiclePlatformID, &v.EngineCode, &v.TrimLevel, &v.CreatedAt, &v.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan vehicle: %w", err)
		}
		vehicles = append(vehicles, v)
	}

	return vehicles, rows.Err()
}

// ComponentState methods

func (r *Repository) GetVehicleComponentState(ctx context.Context, vehicleID uuid.UUID) ([]*ComponentState, error) {
	query := `
		SELECT vehicle_id, component_id, last_inspection_id, status, condition_grade, last_updated_at
		FROM vehicle_component_state
		WHERE vehicle_id = $1
		ORDER BY last_updated_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to query component state: %w", err)
	}
	defer rows.Close()

	var states []*ComponentState
	for rows.Next() {
		cs := &ComponentState{}
		err := rows.Scan(
			&cs.VehicleID, &cs.ComponentID, &cs.LastInspectionID,
			&cs.Status, &cs.ConditionGrade, &cs.LastUpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan component state: %w", err)
		}
		states = append(states, cs)
	}

	return states, rows.Err()
}

func (r *Repository) UpsertComponentState(ctx context.Context, cs *ComponentState) error {
	query := `
		INSERT INTO vehicle_component_state (vehicle_id, component_id, last_inspection_id, status, condition_grade, last_updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (vehicle_id, component_id) DO UPDATE SET
			last_inspection_id = EXCLUDED.last_inspection_id,
			status = EXCLUDED.status,
			condition_grade = EXCLUDED.condition_grade,
			last_updated_at = NOW()
	`

	_, err := r.db.ExecContext(ctx, query,
		cs.VehicleID, cs.ComponentID, cs.LastInspectionID, cs.Status, cs.ConditionGrade,
	)
	if err != nil {
		return fmt.Errorf("failed to upsert component state: %w", err)
	}

	return nil
}
