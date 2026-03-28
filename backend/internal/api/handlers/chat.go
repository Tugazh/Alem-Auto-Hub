package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ChatHandler struct {
	mu       sync.Mutex
	threads  map[string]ChatThread
	messages map[string][]ChatMessage
	order    []string
}

type ChatThread struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	LastMessage string    `json:"lastMessage"`
	UpdatedAt   time.Time `json:"updatedAt"`
	UnreadCount int       `json:"unreadCount"`
}

type ChatMessage struct {
	ID        string    `json:"id"`
	ChatID    string    `json:"chatId"`
	SenderID  string    `json:"senderId"`
	Sender    string    `json:"sender"`
	Content   string    `json:"content"`
	IsMine    bool      `json:"isMine"`
	CreatedAt time.Time `json:"createdAt"`
}

type ChatMessageRequest struct {
	Content string `json:"content" binding:"required"`
}

func NewChatHandler() *ChatHandler {
	thread := ChatThread{
		ID:          "chat-001",
		Title:       "Сервис Alem Auto",
		LastMessage: "Запись подтверждена, ждем вас завтра.",
		UpdatedAt:   time.Now().Add(-2 * time.Hour),
		UnreadCount: 1,
	}

	threads := map[string]ChatThread{thread.ID: thread}
	order := []string{thread.ID}

	messages := map[string][]ChatMessage{
		thread.ID: {
			{
				ID:        uuid.NewString(),
				ChatID:    thread.ID,
				SenderID:  "service-001",
				Sender:    "Сервис Alem Auto",
				Content:   "Запись подтверждена, ждем вас завтра.",
				IsMine:    false,
				CreatedAt: time.Now().Add(-2 * time.Hour),
			},
			{
				ID:        uuid.NewString(),
				ChatID:    thread.ID,
				SenderID:  "user-001",
				Sender:    "Вы",
				Content:   "Спасибо! До встречи.",
				IsMine:    true,
				CreatedAt: time.Now().Add(-90 * time.Minute),
			},
		},
	}

	return &ChatHandler{threads: threads, messages: messages, order: order}
}

func (h *ChatHandler) ListThreads(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]ChatThread, 0, len(h.order))
	for _, id := range h.order {
		if thread, ok := h.threads[id]; ok {
			result = append(result, thread)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *ChatHandler) ListMessages(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	chatID := c.Param("id")
	messages := h.messages[chatID]
	if messages == nil {
		messages = []ChatMessage{}
	}

	c.JSON(http.StatusOK, messages)
}

func (h *ChatHandler) SendMessage(c *gin.Context) {
	var req ChatMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	chatID := c.Param("id")
	thread, ok := h.threads[chatID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "chat not found"})
		return
	}

	message := ChatMessage{
		ID:        uuid.NewString(),
		ChatID:    chatID,
		SenderID:  "user-001",
		Sender:    "Вы",
		Content:   req.Content,
		IsMine:    true,
		CreatedAt: time.Now(),
	}

	h.messages[chatID] = append(h.messages[chatID], message)
	thread.LastMessage = req.Content
	thread.UpdatedAt = time.Now()
	thread.UnreadCount = 0

	h.threads[chatID] = thread

	c.JSON(http.StatusCreated, message)
}
