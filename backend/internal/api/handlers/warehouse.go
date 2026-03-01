package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/warehouse"
)

type WarehouseHandler struct {
	service *warehouse.Service
}

func NewWarehouseHandler(service *warehouse.Service) *WarehouseHandler {
	return &WarehouseHandler{service: service}
}

// ListItems returns warehouse items (paginated).
func (h *WarehouseHandler) ListItems(c *gin.Context) {
	limit, _ := parseInt(c.DefaultQuery("limit", "50"))
	offset, _ := parseInt(c.DefaultQuery("offset", "0"))
	if limit <= 0 {
		limit = 50
	}
	list, err := h.service.ListItems(c.Request.Context(), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, list)
}

// CreateItem creates a new warehouse item.
func (h *WarehouseHandler) CreateItem(c *gin.Context) {
	var req warehouse.CreateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	item, err := h.service.CreateItem(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, item)
}

// GetItem returns a single item by ID.
func (h *WarehouseHandler) GetItem(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	item, err := h.service.GetItemByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if item == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, item)
}

// UpdateItem updates an item.
func (h *WarehouseHandler) UpdateItem(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	var req warehouse.UpdateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	item, err := h.service.UpdateItem(c.Request.Context(), id, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if item == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, item)
}

// GetStock returns stock for an item.
func (h *WarehouseHandler) GetStock(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	stock, err := h.service.GetStock(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if stock == nil {
		c.JSON(http.StatusOK, gin.H{"item_id": id, "quantity": 0})
		return
	}
	c.JSON(http.StatusOK, stock)
}

// AdjustStock adjusts stock (in/out/adjust).
func (h *WarehouseHandler) AdjustStock(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	var req warehouse.AdjustStockRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	stock, err := h.service.AdjustStock(c.Request.Context(), id, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, stock)
}

// ListMovements returns stock movements (optional filter by item_id).
func (h *WarehouseHandler) ListMovements(c *gin.Context) {
	limit, _ := parseInt(c.DefaultQuery("limit", "50"))
	offset, _ := parseInt(c.DefaultQuery("offset", "0"))
	if limit <= 0 {
		limit = 50
	}
	var itemID *uuid.UUID
	if v := c.Query("item_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			itemID = &id
		}
	}
	list, err := h.service.ListMovements(c.Request.Context(), itemID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, list)
}
