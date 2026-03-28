package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MarketHandler struct {
	mu    sync.Mutex
	items map[string]MarketItem
	order []string
}

type MarketItem struct {
	ID          string            `json:"id"`
	Title       string            `json:"title"`
	Description string            `json:"description"`
	Price       float64           `json:"price"`
	Category    string            `json:"category"`
	SellerID    string            `json:"sellerId"`
	Images      []string          `json:"images"`
	Available   bool              `json:"available"`
	ViewCount   int               `json:"viewCount"`
	FavoriteCnt int               `json:"favoriteCount"`
	Condition   string            `json:"condition"`
	Brand       string            `json:"brand"`
	Location    string            `json:"location"`
	Specs       map[string]string `json:"specifications"`
	CreatedAt   time.Time         `json:"createdAt"`
}

type MarketCreateRequest struct {
	Title       string   `json:"title" binding:"required"`
	Description string   `json:"description" binding:"required"`
	Price       float64  `json:"price" binding:"required"`
	Category    string   `json:"category" binding:"required"`
	Images      []string `json:"images"`
}

func NewMarketHandler() *MarketHandler {
	items := []MarketItem{
		{
			ID:          "product-001",
			Title:       "BMW X5 (G05) Front Brake Pads",
			Description: "Premium ceramic brake pads for BMW X5 2020-2023.",
			Price:       249.99,
			Category:    "parts",
			SellerID:    "seller-001",
			Images: []string{
				"https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800",
			},
			Available:   true,
			ViewCount:   234,
			FavoriteCnt: 18,
			Condition:   "new",
			Brand:       "Brembo",
			Location:    "Almaty, Kazakhstan",
			Specs: map[string]string{
				"width":    "155mm",
				"material": "ceramic",
			},
			CreatedAt: time.Now().AddDate(0, 0, -12),
		},
		{
			ID:          "product-002",
			Title:       "Toyota Camry Hybrid Battery",
			Description: "High-performance hybrid battery for Toyota Camry 2018-2020.",
			Price:       2499.99,
			Category:    "parts",
			SellerID:    "seller-002",
			Images: []string{
				"https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800",
			},
			Available:   true,
			ViewCount:   892,
			FavoriteCnt: 64,
			Condition:   "new",
			Brand:       "Toyota Genuine",
			Location:    "Astana, Kazakhstan",
			Specs: map[string]string{
				"voltage": "201.6V",
			},
			CreatedAt: time.Now().AddDate(0, 0, -6),
		},
	}

	itemsMap := make(map[string]MarketItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &MarketHandler{items: itemsMap, order: order}
}

func (h *MarketHandler) List(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	category := c.Query("category")
	result := make([]MarketItem, 0, len(h.order))
	for _, id := range h.order {
		item := h.items[id]
		if category != "" && item.Category != category {
			continue
		}
		result = append(result, item)
	}

	c.JSON(http.StatusOK, result)
}

func (h *MarketHandler) Get(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *MarketHandler) Create(c *gin.Context) {
	var req MarketCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	id := uuid.NewString()
	item := MarketItem{
		ID:          id,
		Title:       req.Title,
		Description: req.Description,
		Price:       req.Price,
		Category:    req.Category,
		SellerID:    "seller-mock",
		Images:      req.Images,
		Available:   true,
		Condition:   "new",
		Brand:       "Generic",
		Location:    "Kazakhstan",
		Specs:       map[string]string{},
		CreatedAt:   time.Now(),
	}

	h.items[id] = item
	h.order = append(h.order, id)

	c.JSON(http.StatusCreated, item)
}

func (h *MarketHandler) Update(c *gin.Context) {
	var req struct {
		Title       *string  `json:"title"`
		Description *string  `json:"description"`
		Price       *float64 `json:"price"`
		Available   *bool    `json:"available"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
		return
	}

	if req.Title != nil {
		item.Title = *req.Title
	}
	if req.Description != nil {
		item.Description = *req.Description
	}
	if req.Price != nil {
		item.Price = *req.Price
	}
	if req.Available != nil {
		item.Available = *req.Available
	}

	h.items[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *MarketHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.items[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "product not found"})
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
