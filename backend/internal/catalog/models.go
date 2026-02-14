package catalog

import (
	"time"

	"github.com/google/uuid"
)

// Make представляет марку автомобиля
type Make struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	CyrillicName *string   `json:"cyrillic_name,omitempty"`
	NumericID   *int64    `json:"numeric_id,omitempty"`
	Country     *string   `json:"country,omitempty"`
	YearFrom    *int      `json:"year_from,omitempty"`
	YearTo      *int      `json:"year_to,omitempty"`
	Popular     bool      `json:"popular"`
	Code        *string   `json:"code,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Model представляет модель автомобиля
type Model struct {
	ID          string    `json:"id"`
	MakeID      string    `json:"make_id"`
	Name        string    `json:"name"`
	CyrillicName *string   `json:"cyrillic_name,omitempty"`
	YearFrom    *int      `json:"year_from,omitempty"`
	YearTo      *int      `json:"year_to,omitempty"`
	Class       *string   `json:"class,omitempty"`
	Code        *string   `json:"code,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Generation представляет поколение модели
type Generation struct {
	ID        uuid.UUID `json:"id"`
	ModelID   string    `json:"model_id"`
	Name      string    `json:"name"`
	YearFrom  *int      `json:"year_from,omitempty"`
	YearTo    *int      `json:"year_to,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}

// VehiclePlatform представляет платформу/модификацию
type VehiclePlatform struct {
	ID          uuid.UUID `json:"id"`
	GenerationID *uuid.UUID `json:"generation_id,omitempty"`
	Name        string    `json:"name"`
	BodyType    *string   `json:"body_type,omitempty"`
	EngineCode  *string   `json:"engine_code,omitempty"`
	TrimLevel   *string   `json:"trim_level,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

// Component представляет компонент/деталь в иерархии
type Component struct {
	ID               uuid.UUID              `json:"id"`
	VehiclePlatformID *uuid.UUID             `json:"vehicle_platform_id,omitempty"`
	ParentID         *uuid.UUID             `json:"parent_id,omitempty"`
	Code             string                  `json:"code"`
	Name             string                  `json:"name"`
	Side             *string                 `json:"side,omitempty"`
	Position         *string                 `json:"position,omitempty"`
	IsLeaf           bool                    `json:"is_leaf"`
	Metadata         map[string]interface{}   `json:"metadata,omitempty"`
	CreatedAt        time.Time               `json:"created_at"`
	Children         []*Component            `json:"children,omitempty"` // для дерева
}

// ComponentTree представляет дерево компонентов
type ComponentTree struct {
	Root      *Component `json:"root"`
	PlatformID uuid.UUID `json:"platform_id"`
}
