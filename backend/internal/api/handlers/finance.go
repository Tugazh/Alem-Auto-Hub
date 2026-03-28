package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type FinanceHandler struct {
	mu         sync.Mutex
	expenses   map[string]FinanceExpense
	order      []string
	categories []string
}

type FinanceExpense struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Category    string    `json:"category"`
	Amount      float64   `json:"amount"`
	OccurredAt  time.Time `json:"occurredAt"`
	Description string    `json:"description"`
}

type FinanceCreateRequest struct {
	Title       string  `json:"title" binding:"required"`
	Category    string  `json:"category" binding:"required"`
	Amount      float64 `json:"amount" binding:"required"`
	OccurredAt  string  `json:"occurredAt"`
	Description string  `json:"description"`
}

func NewFinanceHandler() *FinanceHandler {
	items := []FinanceExpense{
		{
			ID:          "expense-001",
			Title:       "Замена масла",
			Category:    "Сервис",
			Amount:      12000,
			OccurredAt:  time.Now().AddDate(0, 0, -5),
			Description: "Oil • 45 л",
		},
		{
			ID:          "expense-002",
			Title:       "Заправка",
			Category:    "Топливо",
			Amount:      15000,
			OccurredAt:  time.Now().AddDate(0, 0, -12),
			Description: "AI-92",
		},
	}

	itemsMap := make(map[string]FinanceExpense)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	return &FinanceHandler{
		expenses:   itemsMap,
		order:      order,
		categories: []string{"Сервис", "Топливо", "Страхование", "Штрафы"},
	}
}

func (h *FinanceHandler) ListExpenses(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]FinanceExpense, 0, len(h.order))
	for _, id := range h.order {
		if item, ok := h.expenses[id]; ok {
			result = append(result, item)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *FinanceHandler) CreateExpense(c *gin.Context) {
	var req FinanceCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	occurred := time.Now()
	if req.OccurredAt != "" {
		if parsed, err := time.Parse(time.RFC3339, req.OccurredAt); err == nil {
			occurred = parsed
		}
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item := FinanceExpense{
		ID:          uuid.NewString(),
		Title:       req.Title,
		Category:    req.Category,
		Amount:      req.Amount,
		OccurredAt:  occurred,
		Description: req.Description,
	}

	h.expenses[item.ID] = item
	h.order = append(h.order, item.ID)

	c.JSON(http.StatusCreated, item)
}

func (h *FinanceHandler) Categories(c *gin.Context) {
	c.JSON(http.StatusOK, h.categories)
}

func (h *FinanceHandler) Export(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "ready",
		"url":    "https://storage.example.com/export/finance.csv",
	})
}
