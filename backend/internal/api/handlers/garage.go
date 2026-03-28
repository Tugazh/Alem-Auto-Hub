package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type GarageHandler struct {
	mu    sync.Mutex
	cars  map[string]GarageItem
	order []string
}

type GarageItem struct {
	ID           string     `json:"id"`
	UserID       string     `json:"userId"`
	Name         string     `json:"name"`
	Make         string     `json:"make"`
	Model        string     `json:"model"`
	Year         int        `json:"year"`
	VIN          *string    `json:"vin,omitempty"`
	PlateNumber  *string    `json:"plateNumber,omitempty"`
	Color        *string    `json:"color,omitempty"`
	Transmission *string    `json:"transmission,omitempty"`
	Drivetrain   *string    `json:"drivetrain,omitempty"`
	FuelType     *string    `json:"fuelType,omitempty"`
	EngineType   *string    `json:"engineType,omitempty"`
	Mileage      *int       `json:"mileage,omitempty"`
	ImageURL     *string    `json:"imageUrl,omitempty"`
	Model3DURL   *string    `json:"model3dUrl,omitempty"`
	Notes        *string    `json:"notes,omitempty"`
	CreatedAt    *time.Time `json:"createdAt,omitempty"`
	UpdatedAt    *time.Time `json:"updatedAt,omitempty"`
}

type GarageCreateRequest struct {
	Name        string  `json:"name" binding:"required"`
	Make        string  `json:"make" binding:"required"`
	Model       string  `json:"model" binding:"required"`
	Year        int     `json:"year" binding:"required"`
	VIN         *string `json:"vin"`
	PlateNumber *string `json:"plate_number"`
	Mileage     *int    `json:"mileage"`
	Notes       *string `json:"notes"`
}

type GarageUpdateRequest struct {
	Name    *string `json:"name"`
	Mileage *int    `json:"mileage"`
	Notes   *string `json:"notes"`
}

func NewGarageHandler() *GarageHandler {
	now := time.Now()
	userID := "user-mock-001"
	items := []GarageItem{
		{
			ID:     "vehicle-001",
			UserID: userID,
			Name:   "My BMW X5",
			Make:   "BMW",
			Model:  "X5",
			Year:   2020,
			Mileage: func() *int {
				m := 45000
				return &m
			}(),
			CreatedAt: &now,
		},
		{
			ID:     "vehicle-002",
			UserID: userID,
			Name:   "Toyota Camry",
			Make:   "Toyota",
			Model:  "Camry",
			Year:   2018,
			Mileage: func() *int {
				m := 62000
				return &m
			}(),
			CreatedAt: &now,
		},
	}

	cars := make(map[string]GarageItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		cars[item.ID] = item
		order = append(order, item.ID)
	}

	return &GarageHandler{cars: cars, order: order}
}

func (h *GarageHandler) GetGarages(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]GarageItem, 0, len(h.order))
	for _, id := range h.order {
		if item, ok := h.cars[id]; ok {
			result = append(result, item)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *GarageHandler) GetGarage(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.cars[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "garage not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *GarageHandler) CreateGarage(c *gin.Context) {
	var req GarageCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	now := time.Now()
	id := uuid.NewString()
	item := GarageItem{
		ID:          id,
		UserID:      "user-mock-001",
		Name:        req.Name,
		Make:        req.Make,
		Model:       req.Model,
		Year:        req.Year,
		VIN:         req.VIN,
		PlateNumber: req.PlateNumber,
		Mileage:     req.Mileage,
		Notes:       req.Notes,
		CreatedAt:   &now,
	}

	h.cars[id] = item
	h.order = append(h.order, id)

	c.JSON(http.StatusCreated, item)
}

func (h *GarageHandler) UpdateGarage(c *gin.Context) {
	var req GarageUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.cars[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "garage not found"})
		return
	}

	if req.Name != nil {
		item.Name = *req.Name
	}
	if req.Mileage != nil {
		item.Mileage = req.Mileage
	}
	if req.Notes != nil {
		item.Notes = req.Notes
	}

	now := time.Now()
	item.UpdatedAt = &now

	h.cars[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *GarageHandler) DeleteGarage(c *gin.Context) {
	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.cars[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "garage not found"})
		return
	}

	delete(h.cars, id)
	newOrder := make([]string, 0, len(h.order))
	for _, existing := range h.order {
		if existing != id {
			newOrder = append(newOrder, existing)
		}
	}

	h.order = newOrder
	c.Status(http.StatusNoContent)
}
