package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ReviewHandler struct {
	mu    sync.Mutex
	items map[string]ReviewItem
	order []string
}

type ReviewItem struct {
	ID        string    `json:"id"`
	ProductID string    `json:"productId"`
	UserName  string    `json:"userName"`
	Rating    int       `json:"rating"`
	Comment   string    `json:"comment"`
	CreatedAt time.Time `json:"createdAt"`
}

type ReviewCreateRequest struct {
	ProductID string `json:"productId" binding:"required"`
	UserName  string `json:"userName" binding:"required"`
	Rating    int    `json:"rating" binding:"required"`
	Comment   string `json:"comment" binding:"required"`
}

func NewReviewHandler() *ReviewHandler {
	items := []ReviewItem{
		{
			ID:        "review-001",
			ProductID: "product-001",
			UserName:  "Айжан",
			Rating:    5,
			Comment:   "Отличные колодки, быстрая доставка.",
			CreatedAt: time.Now().AddDate(0, 0, -2),
		},
		{
			ID:        "review-002",
			ProductID: "product-001",
			UserName:  "Нурлан",
			Rating:    4,
			Comment:   "Все ок, но упаковка могла быть лучше.",
			CreatedAt: time.Now().AddDate(0, 0, -5),
		},
	}

	itemsMap := make(map[string]ReviewItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &ReviewHandler{items: itemsMap, order: order}
}

func (h *ReviewHandler) List(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	productID := c.Query("productId")
	result := make([]ReviewItem, 0, len(h.order))
	for _, id := range h.order {
		item := h.items[id]
		if productID != "" && item.ProductID != productID {
			continue
		}
		result = append(result, item)
	}

	c.JSON(http.StatusOK, result)
}

func (h *ReviewHandler) Create(c *gin.Context) {
	var req ReviewCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item := ReviewItem{
		ID:        uuid.NewString(),
		ProductID: req.ProductID,
		UserName:  req.UserName,
		Rating:    req.Rating,
		Comment:   req.Comment,
		CreatedAt: time.Now(),
	}

	h.items[item.ID] = item
	h.order = append(h.order, item.ID)

	c.JSON(http.StatusCreated, item)
}
