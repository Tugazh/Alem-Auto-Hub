package market

import (
	"time"

	"github.com/google/uuid"
)

const (
	KindProduct = "product"
	KindService = "service"
	KindAd      = "ad"
)

// Item represents a marketplace entity (product/service/ad).
type Item struct {
	ID          uuid.UUID `json:"id"`
	UserID      uuid.UUID `json:"user_id"`
	Kind        string    `json:"kind"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Category    string    `json:"category"`
	Price       float64   `json:"price"`
	Currency    string    `json:"currency"`
	Available   bool      `json:"available"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type CreateItemRequest struct {
	Title       string   `json:"title" binding:"required"`
	Description string   `json:"description" binding:"required"`
	Category    string   `json:"category" binding:"required"`
	Price       float64  `json:"price" binding:"required,gt=0"`
	Currency    string   `json:"currency"`
	Images      []string `json:"images,omitempty"`
}

type UpdateItemRequest struct {
	Title       *string  `json:"title,omitempty"`
	Description *string  `json:"description,omitempty"`
	Category    *string  `json:"category,omitempty"`
	Price       *float64 `json:"price,omitempty"`
	Currency    *string  `json:"currency,omitempty"`
	Available   *bool    `json:"available,omitempty"`
}

type ListItemsFilter struct {
	Category *string
	Search   *string
	Limit    int
	Offset   int
}
