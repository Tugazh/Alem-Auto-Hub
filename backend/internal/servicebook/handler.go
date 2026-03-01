package servicebook

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/auth"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// GetServiceBook returns the service book for a vehicle (inspections + service records).
// GET /api/v1/vehicles/:id/service-book
func (h *Handler) GetServiceBook(c *gin.Context) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}
	userRole, _ := auth.GetUserRole(c)
	roleStr, _ := userRole.(string)

	idStr := c.Param("id")
	vehicleID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle id"})
		return
	}

	resp, err := h.service.GetServiceBook(c.Request.Context(), vehicleID, userID.(uuid.UUID), roleStr)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if resp == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, resp)
}
