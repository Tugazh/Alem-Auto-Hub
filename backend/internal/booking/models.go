package booking

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusScheduled = "scheduled"
	StatusCompleted = "completed"
	StatusCancelled = "cancelled"
	StatusNoShow    = "no_show"
)

// Booking represents an appointment at a service center.
type Booking struct {
	ID               uuid.UUID  `json:"id"`
	ServiceCenterID  uuid.UUID  `json:"service_center_id"`
	VehicleID        uuid.UUID  `json:"vehicle_id"`
	UserID           uuid.UUID  `json:"user_id"`
	ScheduledAt      time.Time  `json:"scheduled_at"`
	Status           string     `json:"status"`
	Notes            *string    `json:"notes,omitempty"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

// CreateBookingRequest is the request body for creating a booking.
type CreateBookingRequest struct {
	ServiceCenterID uuid.UUID `json:"service_center_id" binding:"required"`
	VehicleID       uuid.UUID `json:"vehicle_id" binding:"required"`
	ScheduledAt     string    `json:"scheduled_at" binding:"required"` // ISO datetime
	Notes           string    `json:"notes"`
}

// UpdateBookingRequest is the request body for updating a booking (e.g. status, notes).
type UpdateBookingRequest struct {
	Status *string `json:"status,omitempty"` // scheduled, completed, cancelled, no_show
	Notes  *string `json:"notes,omitempty"`
}

// ListBookingsFilter holds query filters for listing bookings.
type ListBookingsFilter struct {
	ServiceCenterID *uuid.UUID
	VehicleID       *uuid.UUID
	Status          *string
	From            *time.Time
	To              *time.Time
	Limit           int
	Offset          int
}
