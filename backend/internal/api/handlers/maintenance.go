package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MaintenanceHandler struct {
	mu    sync.Mutex
	items map[string]MaintenanceItem
	order []string
}

type MaintenanceItem struct {
	ID            string     `json:"id"`
	GarageID      string     `json:"garageId"`
	Type          string     `json:"type"`
	Status        string     `json:"status"`
	ScheduledDate time.Time  `json:"scheduledDate"`
	CompletedDate *time.Time `json:"completedDate,omitempty"`
	EstimatedCost *float64   `json:"estimatedCost,omitempty"`
	ActualCost    *float64   `json:"actualCost,omitempty"`
	Notes         *string    `json:"notes,omitempty"`
	Service       *string    `json:"serviceProvider,omitempty"`
	CreatedAt     *time.Time `json:"createdAt,omitempty"`
	UpdatedAt     *time.Time `json:"updatedAt,omitempty"`
}

type MaintenanceCreateRequest struct {
	GarageID      string   `json:"garage_id" binding:"required"`
	Type          string   `json:"type" binding:"required"`
	ScheduledDate string   `json:"scheduled_date" binding:"required"`
	Notes         *string  `json:"notes"`
	Cost          *float64 `json:"cost"`
}

type MaintenanceUpdateRequest struct {
	CompletedDate *string  `json:"completed_date"`
	Status        *string  `json:"status"`
	ActualCost    *float64 `json:"actual_cost"`
	Notes         *string  `json:"notes"`
}

func NewMaintenanceHandler() *MaintenanceHandler {
	now := time.Now()
	items := []MaintenanceItem{
		{
			ID:            "maint-001",
			GarageID:      "vehicle-001",
			Type:          "oil_change",
			Status:        "completed",
			ScheduledDate: now.AddDate(0, 0, -30),
			CompletedDate: func() *time.Time {
				value := now.AddDate(0, 0, -32)
				return &value
			}(),
			EstimatedCost: func() *float64 {
				v := 180.0
				return &v
			}(),
			ActualCost: func() *float64 {
				v := 175.0
				return &v
			}(),
			Notes: func() *string {
				v := "BMW X5: Full synthetic 5W-30, new oil filter"
				return &v
			}(),
			Service: func() *string {
				v := "BMW Service Center"
				return &v
			}(),
			CreatedAt: &now,
		},
		{
			ID:            "maint-002",
			GarageID:      "vehicle-001",
			Type:          "tire_rotation",
			Status:        "pending",
			ScheduledDate: now.AddDate(0, 0, 7),
			EstimatedCost: func() *float64 {
				v := 120.0
				return &v
			}(),
			Notes: func() *string {
				v := "BMW X5: Tire rotation and wheel alignment check"
				return &v
			}(),
			Service: func() *string {
				v := "BMW Service Center"
				return &v
			}(),
			CreatedAt: &now,
		},
		{
			ID:            "maint-003",
			GarageID:      "vehicle-002",
			Type:          "brake_inspection",
			Status:        "overdue",
			ScheduledDate: now.AddDate(0, 0, -5),
			EstimatedCost: func() *float64 {
				v := 150.0
				return &v
			}(),
			Notes: func() *string {
				v := "Toyota Camry 2018: Hybrid brake system inspection"
				return &v
			}(),
			Service: func() *string {
				v := "Toyota Service"
				return &v
			}(),
			CreatedAt: &now,
		},
	}

	itemsMap := make(map[string]MaintenanceItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &MaintenanceHandler{items: itemsMap, order: order}
}

func (h *MaintenanceHandler) GetMaintenanceList(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	garageID := c.Query("garage_id")
	status := c.Query("status")

	result := make([]MaintenanceItem, 0, len(h.order))
	for _, id := range h.order {
		item, ok := h.items[id]
		if !ok {
			continue
		}
		if garageID != "" && item.GarageID != garageID {
			continue
		}
		if status != "" && item.Status != status {
			continue
		}
		result = append(result, item)
	}

	c.JSON(http.StatusOK, result)
}

func (h *MaintenanceHandler) GetMaintenance(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "maintenance not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *MaintenanceHandler) CreateMaintenance(c *gin.Context) {
	var req MaintenanceCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	scheduled, err := time.Parse(time.RFC3339, req.ScheduledDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid scheduled_date"})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	now := time.Now()
	id := uuid.NewString()
	item := MaintenanceItem{
		ID:            id,
		GarageID:      req.GarageID,
		Type:          req.Type,
		Status:        "pending",
		ScheduledDate: scheduled,
		EstimatedCost: req.Cost,
		Notes:         req.Notes,
		CreatedAt:     &now,
	}

	h.items[id] = item
	h.order = append(h.order, id)

	c.JSON(http.StatusCreated, item)
}

func (h *MaintenanceHandler) UpdateMaintenance(c *gin.Context) {
	var req MaintenanceUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "maintenance not found"})
		return
	}

	if req.Status != nil {
		item.Status = *req.Status
	}
	if req.ActualCost != nil {
		item.ActualCost = req.ActualCost
	}
	if req.Notes != nil {
		item.Notes = req.Notes
	}
	if req.CompletedDate != nil {
		parsed, err := time.Parse(time.RFC3339, *req.CompletedDate)
		if err == nil {
			item.CompletedDate = &parsed
		}
	}

	now := time.Now()
	item.UpdatedAt = &now

	h.items[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *MaintenanceHandler) DeleteMaintenance(c *gin.Context) {
	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.items[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "maintenance not found"})
		return
	}

	delete(h.items, id)
	newOrder := make([]string, 0, len(h.order))
	for _, existing := range h.order {
		if existing != id {
			newOrder = append(newOrder, existing)
		}
	}

	h.order = newOrder
	c.Status(http.StatusNoContent)
}

func (h *MaintenanceHandler) GetSchedule(c *gin.Context) {
	garageID := c.Query("garage_id")

	response := gin.H{
		"garageId":        garageID,
		"nextServiceDate": time.Now().AddDate(0, 1, 0).Format(time.RFC3339),
		"items": []gin.H{
			{
				"type":    "oil_change",
				"dueInKm": 1200,
			},
			{
				"type":    "tire_rotation",
				"dueInKm": 2500,
			},
		},
	}

	c.JSON(http.StatusOK, response)
}
