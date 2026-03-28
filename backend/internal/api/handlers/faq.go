package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type FAQHandler struct{}

type FAQItem struct {
	ID       string `json:"id"`
	Question string `json:"question"`
	Answer   string `json:"answer"`
}

func NewFAQHandler() *FAQHandler {
	return &FAQHandler{}
}

func (h *FAQHandler) List(c *gin.Context) {
	items := []FAQItem{
		{ID: "faq-001", Question: "Как восстановить пароль?", Answer: "Перейдите в настройки безопасности и выберите смену пароля."},
		{ID: "faq-002", Question: "Как включить 2FA?", Answer: "В настройках безопасности включите двухфакторную аутентификацию."},
		{ID: "faq-003", Question: "Как связаться с поддержкой?", Answer: "Напишите в чат поддержки или на support@alemauto.kz."},
	}

	c.JSON(http.StatusOK, items)
}
