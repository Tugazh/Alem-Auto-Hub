package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/auth"
	"alem-auto/internal/vehicle"
)

type VehicleHandler struct {
	vehicleService *vehicle.Service
}

func NewVehicleHandler(vehicleService *vehicle.Service) *VehicleHandler {
	return &VehicleHandler{vehicleService: vehicleService}
}

// CreateVehicle создает новое авто
// @Summary Create vehicle
// @Tags vehicle
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body vehicle.Vehicle true "Vehicle data"
// @Success 201 {object} vehicle.Vehicle
// @Failure 400 {object} map[string]string
// @Router /api/v1/vehicles [post]
func (h *VehicleHandler) CreateVehicle(c *gin.Context) {
	var v vehicle.Vehicle
	if err := c.ShouldBindJSON(&v); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.vehicleService.CreateVehicle(c.Request.Context(), &v)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, v)
}

// GetVehicleByID получает авто по ID
// @Summary Get vehicle by ID
// @Tags vehicle
// @Security BearerAuth
// @Produce json
// @Param id path string true "Vehicle ID"
// @Success 200 {object} vehicle.Vehicle
// @Failure 404 {object} map[string]string
// @Router /api/v1/vehicles/{id} [get]
func (h *VehicleHandler) GetVehicleByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle id"})
		return
	}

	v, err := h.vehicleService.GetVehicleByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if v == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "vehicle not found"})
		return
	}

	c.JSON(http.StatusOK, v)
}

// UpdateVehicle обновляет авто
// @Summary Update vehicle
// @Tags vehicle
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "Vehicle ID"
// @Param request body vehicle.Vehicle true "Vehicle data"
// @Success 200 {object} vehicle.Vehicle
// @Failure 400 {object} map[string]string
// @Router /api/v1/vehicles/{id} [put]
func (h *VehicleHandler) UpdateVehicle(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle id"})
		return
	}

	var v vehicle.Vehicle
	if err := c.ShouldBindJSON(&v); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	v.ID = id
	err = h.vehicleService.UpdateVehicle(c.Request.Context(), &v)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, v)
}

// GetVehicleState получает текущее состояние всех компонентов авто
// @Summary Get vehicle state
// @Tags vehicle
// @Security BearerAuth
// @Produce json
// @Param id path string true "Vehicle ID"
// @Success 200 {object} vehicle.VehicleState
// @Failure 404 {object} map[string]string
// @Router /api/v1/vehicles/{id}/state [get]
func (h *VehicleHandler) GetVehicleState(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle id"})
		return
	}

	state, err := h.vehicleService.GetVehicleState(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if state == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "vehicle not found"})
		return
	}

	c.JSON(http.StatusOK, state)
}

// GetMyVehicles получает список авто текущего пользователя
// @Summary Get my vehicles
// @Tags vehicle
// @Security BearerAuth
// @Produce json
// @Success 200 {array} vehicle.Vehicle
// @Router /api/v1/vehicles/my [get]
func (h *VehicleHandler) GetMyVehicles(c *gin.Context) {
	userID, exists := auth.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	vehicles, err := h.vehicleService.GetVehiclesByUserID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, vehicles)
}
