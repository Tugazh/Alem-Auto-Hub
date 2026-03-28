package handlers

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CartHandler struct {
	mu    sync.Mutex
	items map[string]CartItem
	order []string
}

type CartItem struct {
	ID        string  `json:"id"`
	ProductID string  `json:"productId"`
	Title     string  `json:"title"`
	Price     float64 `json:"price"`
	Quantity  int     `json:"quantity"`
	ImageURL  string  `json:"imageUrl"`
}

type CartCreateRequest struct {
	ProductID string  `json:"productId" binding:"required"`
	Title     string  `json:"title" binding:"required"`
	Price     float64 `json:"price" binding:"required"`
	Quantity  int     `json:"quantity"`
	ImageURL  string  `json:"imageUrl"`
}

type CartUpdateRequest struct {
	Quantity int `json:"quantity"`
}

func NewCartHandler() *CartHandler {
	items := []CartItem{
		{
			ID:        "cart-001",
			ProductID: "product-001",
			Title:     "BMW X5 (G05) Front Brake Pads",
			Price:     249.99,
			Quantity:  1,
			ImageURL:  "https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800",
		},
	}

	itemsMap := make(map[string]CartItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &CartHandler{items: itemsMap, order: order}
}

func (h *CartHandler) List(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]CartItem, 0, len(h.order))
	for _, id := range h.order {
		if item, ok := h.items[id]; ok {
			result = append(result, item)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *CartHandler) Add(c *gin.Context) {
	var req CartCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item := CartItem{
		ID:        uuid.NewString(),
		ProductID: req.ProductID,
		Title:     req.Title,
		Price:     req.Price,
		Quantity:  req.Quantity,
		ImageURL:  req.ImageURL,
	}

	h.items[item.ID] = item
	h.order = append(h.order, item.ID)

	c.JSON(http.StatusCreated, item)
}

func (h *CartHandler) Update(c *gin.Context) {
	var req CartUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "cart item not found"})
		return
	}

	item.Quantity = req.Quantity
	h.items[id] = item

	c.JSON(http.StatusOK, item)
}

func (h *CartHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.items[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "cart item not found"})
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
