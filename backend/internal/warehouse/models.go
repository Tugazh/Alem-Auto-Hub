package warehouse

import (
	"time"

	"github.com/google/uuid"
)

const (
	MovementTypeIn     = "in"
	MovementTypeOut    = "out"
	MovementTypeAdjust = "adjust"
)

// Item represents a warehouse item (part/product).
type Item struct {
	ID          uuid.UUID `json:"id"`
	SKU         string    `json:"sku"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Unit        string    `json:"unit"`
	MinQuantity int       `json:"min_quantity"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Stock represents current stock level for an item.
type Stock struct {
	ID        uuid.UUID `json:"id"`
	ItemID    uuid.UUID `json:"item_id"`
	Quantity  int       `json:"quantity"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Movement represents a stock movement (in/out/adjust).
type Movement struct {
	ID            uuid.UUID `json:"id"`
	ItemID        uuid.UUID `json:"item_id"`
	QuantityDelta int       `json:"quantity_delta"` // positive for in, negative for out
	Type          string    `json:"type"`          // in, out, adjust
	Reference     *string   `json:"reference,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
}

// CreateItemRequest is the request body for creating an item.
type CreateItemRequest struct {
	SKU         string `json:"sku" binding:"required"`
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Unit        string `json:"unit"`
	MinQuantity int    `json:"min_quantity"`
}

// UpdateItemRequest is the request body for updating an item.
type UpdateItemRequest struct {
	Name        *string `json:"name,omitempty"`
	Description *string `json:"description,omitempty"`
	Unit        *string `json:"unit,omitempty"`
	MinQuantity *int    `json:"min_quantity,omitempty"`
}

// AdjustStockRequest is the request body for stock adjustment.
type AdjustStockRequest struct {
	QuantityDelta int     `json:"quantity_delta"` // positive = in, negative = out
	Type          string  `json:"type"`           // in, out, adjust
	Reference     *string `json:"reference,omitempty"`
}
