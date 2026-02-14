package handlers

import (
	"net/http"
	"strings"

	"alem-auto/internal/agent"

	"github.com/gin-gonic/gin"
	"github.com/google/generative-ai-go/genai"
)

type AgentHandler struct {
	service *agent.ChatService
}

func NewAgentHandler(service *agent.ChatService) *AgentHandler {
	return &AgentHandler{service: service}
}

// HandleMessage handles AI routing for user requests.
func (h *AgentHandler) HandleMessage(c *gin.Context) {
	if h.service == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "agent service is not configured"})
		return
	}

	var req agent.AgentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	chatHistory := toGeminiHistory(req.History)
	resp, err := h.service.ProcessUserMessage(
		c.Request.Context(),
		req.UserID,
		req.Message,
		chatHistory,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, agent.AgentResponse{Message: resp})
}

func toGeminiHistory(history []agent.ChatTurn) []*genai.Content {
	if len(history) == 0 {
		return nil
	}

	converted := make([]*genai.Content, 0, len(history))
	for _, turn := range history {
		role := strings.ToLower(turn.Role)
		if role != "model" && role != "assistant" {
			role = "user"
		}
		if role == "assistant" {
			role = "model"
		}

		converted = append(converted, &genai.Content{
			Role:  role,
			Parts: []genai.Part{genai.Text(turn.Message)},
		})
	}

	return converted
}
