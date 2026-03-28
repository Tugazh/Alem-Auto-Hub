package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type OrderHandler struct {
	mu    sync.Mutex
	items map[string]OrderItem
	order []string
}

type OrderItem struct {
	ID        string     `json:"id"`
	Status    string     `json:"status"`
	Total     float64    `json:"total"`
	CreatedAt time.Time  `json:"createdAt"`
	Items     []CartItem `json:"items"`
}

type OrderCreateRequest struct {
	Items []CartItem `json:"items"`
	Total float64    `json:"total"`
}

func NewOrderHandler() *OrderHandler {
	items := []OrderItem{
		{
			ID:        "order-001",
			Status:    "paid",
			Total:     249.99,
			CreatedAt: time.Now().AddDate(0, 0, -3),
			Items: []CartItem{
				{
					ID:        "cart-001",
					ProductID: "product-001",
					Title:     "BMW X5 (G05) Front Brake Pads",
					Price:     249.99,
					Quantity:  1,
					ImageURL:  "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800",
				},
			},
		},
	}

	itemsMap := make(map[string]OrderItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &OrderHandler{items: itemsMap, order: order}
}

func (h *OrderHandler) List(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]OrderItem, 0, len(h.order))
	for _, id := range h.order {
		if item, ok := h.items[id]; ok {
			result = append(result, item)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *OrderHandler) Get(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *OrderHandler) Create(c *gin.Context) {
	var req OrderCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item := OrderItem{
		ID:        uuid.NewString(),
		Status:    "created",
		Total:     req.Total,
		CreatedAt: time.Now(),
		Items:     req.Items,
	}

	h.items[item.ID] = item
	h.order = append(h.order, item.ID)

	c.JSON(http.StatusCreated, item)
}

func (h *OrderHandler) UpdateStatus(c *gin.Context) {
	id := c.Param("id")
	status := c.Query("status")
	if status == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status required"})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}

	item.Status = status
	h.items[id] = item

	c.JSON(http.StatusOK, item)
}
