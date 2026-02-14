package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/auth"
	"alem-auto/internal/inspection"
)

type InspectionHandler struct {
	inspectionService *inspection.Service
}

func NewInspectionHandler(inspectionService *inspection.Service) *InspectionHandler {
	return &InspectionHandler{inspectionService: inspectionService}
}

// CreateInspection создает новый осмотр
// @Summary Create inspection
// @Tags inspection
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body inspection.Inspection true "Inspection data"
// @Success 201 {object} inspection.Inspection
// @Failure 400 {object} map[string]string
// @Router /api/v1/inspections [post]
func (h *InspectionHandler) CreateInspection(c *gin.Context) {
	userID, exists := auth.GetUserID(c)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	var i inspection.Inspection
	if err := c.ShouldBindJSON(&i); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	i.CreatedByUserID = userID.(uuid.UUID)
	err := h.inspectionService.CreateInspection(c.Request.Context(), &i)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, i)
}

// GetInspectionByID получает осмотр по ID
// @Summary Get inspection by ID
// @Tags inspection
// @Security BearerAuth
// @Produce json
// @Param id path string true "Inspection ID"
// @Success 200 {object} inspection.InspectionWithObservations
// @Failure 404 {object} map[string]string
// @Router /api/v1/inspections/{id} [get]
func (h *InspectionHandler) GetInspectionByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid inspection id"})
		return
	}

	insp, err := h.inspectionService.GetInspectionWithObservations(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if insp == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "inspection not found"})
		return
	}

	c.JSON(http.StatusOK, insp)
}

// GetInspectionsByVehicleID получает историю осмотров авто
// @Summary Get inspections by vehicle ID
// @Tags inspection
// @Security BearerAuth
// @Produce json
// @Param vehicle_id path string true "Vehicle ID"
// @Success 200 {array} inspection.Inspection
// @Router /api/v1/vehicles/{vehicle_id}/inspections [get]
func (h *InspectionHandler) GetInspectionsByVehicleID(c *gin.Context) {
	vehicleIDStr := c.Param("vehicle_id")
	vehicleID, err := uuid.Parse(vehicleIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid vehicle id"})
		return
	}

	inspections, err := h.inspectionService.GetInspectionsByVehicleID(c.Request.Context(), vehicleID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, inspections)
}

// CreateComponentObservation создает наблюдение по детали
// @Summary Create component observation
// @Tags inspection
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param inspection_id path string true "Inspection ID"
// @Param request body inspection.ComponentObservation true "Observation data"
// @Success 201 {object} inspection.ComponentObservation
// @Failure 400 {object} map[string]string
// @Router /api/v1/inspections/{inspection_id}/observations [post]
func (h *InspectionHandler) CreateComponentObservation(c *gin.Context) {
	inspectionIDStr := c.Param("inspection_id")
	inspectionID, err := uuid.Parse(inspectionIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid inspection id"})
		return
	}

	var co inspection.ComponentObservation
	if err := c.ShouldBindJSON(&co); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	co.InspectionID = inspectionID
	err = h.inspectionService.CreateComponentObservation(c.Request.Context(), &co)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, co)
}
