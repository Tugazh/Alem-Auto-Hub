package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/auth"
	"alem-auto/internal/booking"
)

type BookingHandler struct {
	service *booking.Service
}

func NewBookingHandler(service *booking.Service) *BookingHandler {
	return &BookingHandler{service: service}
}

// CreateBooking creates a new booking for the current user.
func (h *BookingHandler) CreateBooking(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	var req booking.CreateBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	b, err := h.service.Create(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, b)
}

// ListBookings returns bookings for the current user with optional filters.
func (h *BookingHandler) ListBookings(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	filter := booking.ListBookingsFilter{Limit: 50, Offset: 0}
	if v := c.Query("service_center_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.ServiceCenterID = &id
		}
	}
	if v := c.Query("vehicle_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.VehicleID = &id
		}
	}
	if v := c.Query("status"); v != "" {
		filter.Status = &v
	}
	if v := c.Query("from"); v != "" {
		if t, err := time.Parse(time.RFC3339, v); err == nil {
			filter.From = &t
		}
	}
	if v := c.Query("to"); v != "" {
		if t, err := time.Parse(time.RFC3339, v); err == nil {
			filter.To = &t
		}
	}
	if v := c.DefaultQuery("limit", "50"); v != "" {
		if l, err := parseInt(v); err == nil && l > 0 {
			filter.Limit = l
		}
	}
	if v := c.Query("offset"); v != "" {
		if o, err := parseInt(v); err == nil && o >= 0 {
			filter.Offset = o
		}
	}
	list, err := h.service.List(c.Request.Context(), userID.(uuid.UUID), filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, list)
}

// GetBooking returns a single booking by ID (only if owned by current user).
func (h *BookingHandler) GetBooking(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	b, err := h.service.GetByID(c.Request.Context(), id, userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if b == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, b)
}

// UpdateBooking updates a booking (e.g. status, notes).
func (h *BookingHandler) UpdateBooking(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	var req booking.UpdateBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	b, err := h.service.Update(c.Request.Context(), id, userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if b == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, b)
}

// DeleteBooking deletes a booking (only if owned by current user).
func (h *BookingHandler) DeleteBooking(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	if err := h.service.Delete(c.Request.Context(), id, userID.(uuid.UUID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusNoContent, nil)
}
