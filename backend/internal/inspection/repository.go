package inspection

import (
	"context"
	"database/sql"
	"encoding/json"
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

// ServiceCenter methods

func (r *Repository) CreateServiceCenter(ctx context.Context, sc *ServiceCenter) error {
	query := `
		INSERT INTO service_centers (id, name, address)
		VALUES ($1, $2, $3)
	`

	_, err := r.db.ExecContext(ctx, query, sc.ID, sc.Name, sc.Address)
	if err != nil {
		return fmt.Errorf("failed to create service center: %w", err)
	}

	return nil
}

func (r *Repository) GetServiceCenterByID(ctx context.Context, id uuid.UUID) (*ServiceCenter, error) {
	query := `
		SELECT id, name, address, created_at
		FROM service_centers
		WHERE id = $1
	`

	sc := &ServiceCenter{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&sc.ID, &sc.Name, &sc.Address, &sc.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get service center: %w", err)
	}

	return sc, nil
}

// ServiceCenterUser methods

func (r *Repository) CreateServiceCenterUser(ctx context.Context, scu *ServiceCenterUser) error {
	query := `
		INSERT INTO service_center_users (id, service_center_id, user_id, role)
		VALUES ($1, $2, $3, $4)
	`

	_, err := r.db.ExecContext(ctx, query, scu.ID, scu.ServiceCenterID, scu.UserID, scu.Role)
	if err != nil {
		return fmt.Errorf("failed to create service center user: %w", err)
	}

	return nil
}

func (r *Repository) GetServiceCenterUsersByCenterID(ctx context.Context, centerID uuid.UUID) ([]*ServiceCenterUser, error) {
	query := `
		SELECT id, service_center_id, user_id, role, created_at
		FROM service_center_users
		WHERE service_center_id = $1
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(ctx, query, centerID)
	if err != nil {
		return nil, fmt.Errorf("failed to query service center users: %w", err)
	}
	defer rows.Close()

	var users []*ServiceCenterUser
	for rows.Next() {
		scu := &ServiceCenterUser{}
		err := rows.Scan(&scu.ID, &scu.ServiceCenterID, &scu.UserID, &scu.Role, &scu.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan service center user: %w", err)
		}
		users = append(users, scu)
	}

	return users, rows.Err()
}

func (r *Repository) GetServiceCenterUsersByUserID(ctx context.Context, userID uuid.UUID) ([]*ServiceCenterUser, error) {
	query := `
		SELECT id, service_center_id, user_id, role, created_at
		FROM service_center_users
		WHERE user_id = $1
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to query service center users: %w", err)
	}
	defer rows.Close()

	var users []*ServiceCenterUser
	for rows.Next() {
		scu := &ServiceCenterUser{}
		err := rows.Scan(&scu.ID, &scu.ServiceCenterID, &scu.UserID, &scu.Role, &scu.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan service center user: %w", err)
		}
		users = append(users, scu)
	}

	return users, rows.Err()
}

// Inspection methods

func (r *Repository) CreateInspection(ctx context.Context, i *Inspection) error {
	query := `
		INSERT INTO inspections (id, vehicle_id, service_center_id, created_by_user_id, odometer_km, notes)
		VALUES ($1, $2, $3, $4, $5, $6)
	`

	_, err := r.db.ExecContext(ctx, query,
		i.ID, i.VehicleID, i.ServiceCenterID, i.CreatedByUserID, i.OdometerKm, i.Notes,
	)
	if err != nil {
		return fmt.Errorf("failed to create inspection: %w", err)
	}

	return nil
}

func (r *Repository) GetInspectionByID(ctx context.Context, id uuid.UUID) (*Inspection, error) {
	query := `
		SELECT id, vehicle_id, service_center_id, created_by_user_id, odometer_km, notes, created_at
		FROM inspections
		WHERE id = $1
	`

	i := &Inspection{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&i.ID, &i.VehicleID, &i.ServiceCenterID, &i.CreatedByUserID,
		&i.OdometerKm, &i.Notes, &i.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get inspection: %w", err)
	}

	return i, nil
}

func (r *Repository) GetInspectionsByVehicleID(ctx context.Context, vehicleID uuid.UUID) ([]*Inspection, error) {
	query := `
		SELECT id, vehicle_id, service_center_id, created_by_user_id, odometer_km, notes, created_at
		FROM inspections
		WHERE vehicle_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to query inspections: %w", err)
	}
	defer rows.Close()

	var inspections []*Inspection
	for rows.Next() {
		i := &Inspection{}
		err := rows.Scan(
			&i.ID, &i.VehicleID, &i.ServiceCenterID, &i.CreatedByUserID,
			&i.OdometerKm, &i.Notes, &i.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan inspection: %w", err)
		}
		inspections = append(inspections, i)
	}

	return inspections, rows.Err()
}

func (r *Repository) GetInspectionsByServiceCenterID(ctx context.Context, centerID uuid.UUID) ([]*Inspection, error) {
	query := `
		SELECT id, vehicle_id, service_center_id, created_by_user_id, odometer_km, notes, created_at
		FROM inspections
		WHERE service_center_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, centerID)
	if err != nil {
		return nil, fmt.Errorf("failed to query inspections: %w", err)
	}
	defer rows.Close()

	var inspections []*Inspection
	for rows.Next() {
		i := &Inspection{}
		err := rows.Scan(
			&i.ID, &i.VehicleID, &i.ServiceCenterID, &i.CreatedByUserID,
			&i.OdometerKm, &i.Notes, &i.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan inspection: %w", err)
		}
		inspections = append(inspections, i)
	}

	return inspections, rows.Err()
}

// ComponentObservation methods

func (r *Repository) CreateComponentObservation(ctx context.Context, co *ComponentObservation) error {
	var measuredValuesJSON []byte
	if co.MeasuredValues != nil {
		var err error
		measuredValuesJSON, err = json.Marshal(co.MeasuredValues)
		if err != nil {
			return fmt.Errorf("failed to marshal measured values: %w", err)
		}
	}

	query := `
		INSERT INTO component_observations (id, inspection_id, component_id, status, condition_grade, comment, measured_values)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err := r.db.ExecContext(ctx, query,
		co.ID, co.InspectionID, co.ComponentID, co.Status,
		co.ConditionGrade, co.Comment, measuredValuesJSON,
	)
	if err != nil {
		return fmt.Errorf("failed to create component observation: %w", err)
	}

	return nil
}

func (r *Repository) GetComponentObservationsByInspectionID(ctx context.Context, inspectionID uuid.UUID) ([]*ComponentObservation, error) {
	query := `
		SELECT id, inspection_id, component_id, status, condition_grade, comment, measured_values, created_at
		FROM component_observations
		WHERE inspection_id = $1
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(ctx, query, inspectionID)
	if err != nil {
		return nil, fmt.Errorf("failed to query component observations: %w", err)
	}
	defer rows.Close()

	var observations []*ComponentObservation
	for rows.Next() {
		co := &ComponentObservation{}
		var measuredValuesJSON []byte
		err := rows.Scan(
			&co.ID, &co.InspectionID, &co.ComponentID, &co.Status,
			&co.ConditionGrade, &co.Comment, &measuredValuesJSON, &co.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan component observation: %w", err)
		}

		if len(measuredValuesJSON) > 0 {
			if err := json.Unmarshal(measuredValuesJSON, &co.MeasuredValues); err != nil {
				return nil, fmt.Errorf("failed to unmarshal measured values: %w", err)
			}
		}

		observations = append(observations, co)
	}

	return observations, rows.Err()
}

func (r *Repository) GetComponentObservationsByComponentID(ctx context.Context, componentID uuid.UUID) ([]*ComponentObservation, error) {
	query := `
		SELECT id, inspection_id, component_id, status, condition_grade, comment, measured_values, created_at
		FROM component_observations
		WHERE component_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, componentID)
	if err != nil {
		return nil, fmt.Errorf("failed to query component observations: %w", err)
	}
	defer rows.Close()

	var observations []*ComponentObservation
	for rows.Next() {
		co := &ComponentObservation{}
		var measuredValuesJSON []byte
		err := rows.Scan(
			&co.ID, &co.InspectionID, &co.ComponentID, &co.Status,
			&co.ConditionGrade, &co.Comment, &measuredValuesJSON, &co.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan component observation: %w", err)
		}

		if len(measuredValuesJSON) > 0 {
			if err := json.Unmarshal(measuredValuesJSON, &co.MeasuredValues); err != nil {
				return nil, fmt.Errorf("failed to unmarshal measured values: %w", err)
			}
		}

		observations = append(observations, co)
	}

	return observations, rows.Err()
}
