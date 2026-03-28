package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type AIHandler struct{}

type AIChatRequest struct {
	UserID  string `json:"user_id"`
	Message string `json:"message"`
}

type AIAnalyzeRequest struct {
	Type     string `json:"type"`
	CarModel string `json:"car_model"`
	Image    string `json:"image"`
	Symptoms string `json:"symptoms"`
}

type AIRecommendRequest struct {
	Type     string `json:"type"`
	CarModel string `json:"car_model"`
	Mileage  int    `json:"mileage"`
	Year     int    `json:"year"`
}

func NewAIHandler() *AIHandler {
	return &AIHandler{}
}

func (h *AIHandler) Chat(c *gin.Context) {
	var req AIChatRequest
	_ = c.ShouldBindJSON(&req)

	c.JSON(http.StatusOK, gin.H{
		"message":  "Я подготовил ответ на ваш запрос. Могу подсказать ближайшее СТО или чек-лист.",
		"fallback": true,
	})
}

func (h *AIHandler) Analyze(c *gin.Context) {
	var req AIAnalyzeRequest
	_ = c.ShouldBindJSON(&req)

	c.JSON(http.StatusOK, gin.H{
		"type":   req.Type,
		"result": "Предварительная оценка готова. Рекомендуем диагностику на сервисе.",
	})
}

func (h *AIHandler) Recommend(c *gin.Context) {
	var req AIRecommendRequest
	_ = c.ShouldBindJSON(&req)

	c.JSON(http.StatusOK, []gin.H{
		{"title": "Замена масла", "description": "Каждые 10 000 км"},
		{"title": "Проверка тормозов", "description": "Каждые 15 000 км"},
		{"title": "Диагностика подвески", "description": "Раз в 6 месяцев"},
	})
}
