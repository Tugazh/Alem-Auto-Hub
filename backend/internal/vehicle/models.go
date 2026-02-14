package vehicle

import (
	"time"

	"github.com/google/uuid"
)

// Vehicle представляет конкретный автомобиль
type Vehicle struct {
	ID              uuid.UUID  `json:"id"`
	VIN             *string    `json:"vin,omitempty"`
	LicensePlate    *string    `json:"license_plate,omitempty"`
	Year            *int       `json:"year,omitempty"`
	OdometerKm      int        `json:"odometer_km"`
	VehiclePlatformID *uuid.UUID `json:"vehicle_platform_id,omitempty"`
	EngineCode      *string    `json:"engine_code,omitempty"`
	TrimLevel       *string    `json:"trim_level,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// VehicleOwner представляет владельца автомобиля
type VehicleOwner struct {
	ID         uuid.UUID  `json:"id"`
	VehicleID  uuid.UUID  `json:"vehicle_id"`
	UserID     uuid.UUID  `json:"user_id"`
	OwnedFrom  time.Time  `json:"owned_from"`
	OwnedTo    *time.Time `json:"owned_to,omitempty"`
	IsCurrent  bool       `json:"is_current"`
	CreatedAt  time.Time  `json:"created_at"`
}

// ComponentState представляет текущее состояние компонента
type ComponentState struct {
	VehicleID       uuid.UUID `json:"vehicle_id"`
	ComponentID     uuid.UUID `json:"component_id"`
	LastInspectionID *uuid.UUID `json:"last_inspection_id,omitempty"`
	Status          string    `json:"status"` // ok, attention, replace, not_checked
	ConditionGrade  *string   `json:"condition_grade,omitempty"`
	LastUpdatedAt   time.Time `json:"last_updated_at"`
}

// VehicleState представляет полное состояние автомобиля со всеми компонентами
type VehicleState struct {
	Vehicle    *Vehicle          `json:"vehicle"`
	Components []*ComponentState `json:"components"`
}
