package handlers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/auth"
	"alem-auto/internal/fines"
)

type FinesHandler struct {
	service *fines.Service
}

func NewFinesHandler(service *fines.Service) *FinesHandler {
	return &FinesHandler{service: service}
}

// CreateFine creates a new fine for the current user.
func (h *FinesHandler) CreateFine(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	var req fines.CreateFineRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	f, err := h.service.Create(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, f)
}

// ListFines returns fines for the current user with optional filters.
func (h *FinesHandler) ListFines(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	filter := fines.ListFinesFilter{
		Limit:  50,
		Offset: 0,
	}
	if v := c.Query("vehicle_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.VehicleID = &id
		}
	}
	if v := c.Query("status"); v != "" {
		filter.Status = &v
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

// GetFine returns a single fine by ID (only if owned by current user).
func (h *FinesHandler) GetFine(c *gin.Context) {
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
	f, err := h.service.GetByID(c.Request.Context(), id, userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if f == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, f)
}

// UpdateFine updates a fine (e.g. mark as paid).
func (h *FinesHandler) UpdateFine(c *gin.Context) {
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
	var req fines.UpdateFineRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	f, err := h.service.Update(c.Request.Context(), id, userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if f == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, f)
}

// DeleteFine deletes a fine (only if owned by current user).
func (h *FinesHandler) DeleteFine(c *gin.Context) {
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

func parseInt(s string) (int, error) {
	var n int
	_, err := fmt.Sscanf(s, "%d", &n)
	return n, err
}

