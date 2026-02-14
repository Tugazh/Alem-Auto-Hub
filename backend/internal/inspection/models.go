package inspection

import (
	"time"

	"github.com/google/uuid"
)

// ServiceCenter представляет автобокс/сервис
type ServiceCenter struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	Address   *string   `json:"address,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}

// ServiceCenterUser представляет пользователя сервиса (мастер/админ)
type ServiceCenterUser struct {
	ID             uuid.UUID `json:"id"`
	ServiceCenterID uuid.UUID `json:"service_center_id"`
	UserID         uuid.UUID `json:"user_id"`
	Role           string    `json:"role"` // mechanic, admin
	CreatedAt      time.Time `json:"created_at"`
}

// Inspection представляет визит/осмотр
type Inspection struct {
	ID               uuid.UUID `json:"id"`
	VehicleID        uuid.UUID `json:"vehicle_id"`
	ServiceCenterID  uuid.UUID `json:"service_center_id"`
	CreatedByUserID  uuid.UUID `json:"created_by_user_id"`
	OdometerKm       *int      `json:"odometer_km,omitempty"`
	Notes            *string   `json:"notes,omitempty"`
	CreatedAt        time.Time `json:"created_at"`
}

// ComponentObservation представляет наблюдение по детали
type ComponentObservation struct {
	ID             uuid.UUID              `json:"id"`
	InspectionID   uuid.UUID             `json:"inspection_id"`
	ComponentID    uuid.UUID             `json:"component_id"`
	Status         string                `json:"status"` // ok, attention, replace, not_checked
	ConditionGrade *string               `json:"condition_grade,omitempty"` // 0-100 или A/B/C/D
	Comment        *string               `json:"comment,omitempty"`
	MeasuredValues map[string]interface{} `json:"measured_values,omitempty"` // толщина колодки, остаток протектора, люфт, давление и т.д.
	CreatedAt      time.Time             `json:"created_at"`
}

// InspectionWithObservations представляет осмотр со всеми наблюдениями
type InspectionWithObservations struct {
	Inspection   *Inspection              `json:"inspection"`
	Observations []*ComponentObservation  `json:"observations"`
}
