package fines

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusPending  = "pending"
	StatusPaid     = "paid"
	StatusDisputed = "disputed"
)

// Fine represents a traffic or administrative fine.
type Fine struct {
	ID          uuid.UUID  `json:"id"`
	UserID      uuid.UUID  `json:"user_id"`
	VehicleID   *uuid.UUID `json:"vehicle_id,omitempty"`
	Amount      float64    `json:"amount"`
	Currency    string     `json:"currency"`
	Article     *string    `json:"article,omitempty"`
	Description string     `json:"description"`
	IssuedAt    time.Time  `json:"issued_at"`
	PaidAt      *time.Time `json:"paid_at,omitempty"`
	Status      string     `json:"status"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

// CreateFineRequest is the request body for creating a fine.
type CreateFineRequest struct {
	VehicleID   *uuid.UUID `json:"vehicle_id,omitempty"`
	Amount      float64    `json:"amount" binding:"required,gt=0"`
	Currency    string     `json:"currency"`
	Article     string     `json:"article"`
	Description string     `json:"description" binding:"required"`
	IssuedAt    string     `json:"issued_at" binding:"required"` // ISO date YYYY-MM-DD
}

// UpdateFineRequest is the request body for updating a fine (e.g. mark paid).
type UpdateFineRequest struct {
	Status *string `json:"status,omitempty"` // paid, disputed
	PaidAt *string `json:"paid_at,omitempty"` // ISO datetime, set when status=paid
}

// ListFinesFilter holds query filters for listing fines.
type ListFinesFilter struct {
	VehicleID *uuid.UUID
	Status    *string
	Limit     int
	Offset    int
}
