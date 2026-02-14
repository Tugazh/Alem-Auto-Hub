package agent

import (
	"context"
	"fmt"
	"strings"

	"alem-auto/internal/knowledge"

	"github.com/google/generative-ai-go/genai"
	"github.com/google/uuid"
)

type ChatService struct {
	repo      *Repository
	gemini    *GeminiClient
	knowledge *knowledge.Service
}

func NewChatService(repo *Repository, gemini *GeminiClient, knowledgeService *knowledge.Service) *ChatService {
	return &ChatService{repo: repo, gemini: gemini, knowledge: knowledgeService}
}

func (s *ChatService) ProcessUserMessage(
	ctx context.Context,
	userID string,
	message string,
	history []*genai.Content,
) (string, error) {
	if s.gemini == nil || s.gemini.Model == nil {
		return "", fmt.Errorf("gemini client not initialized")
	}

	session := s.gemini.Model.StartChat()
	if len(history) > 0 {
		session.History = history
	}

	basePrompt := "Ответь прямо и по делу. " +
		"Не упоминай источники, тексты или документы. " +
		"Не используй фразы вроде 'в предоставленной информации'. " +
		"Если есть сомнения, добавь уточнение после ответа, а не вместо него."

	prompt := basePrompt + "\n\nВопрос пользователя:\n" + message
	if s.knowledge != nil {
		contextBlock, err := s.knowledge.RetrieveContext(ctx, message, 4)
		if err == nil && contextBlock != "" {
			prompt = basePrompt + "\n\n" + contextBlock +
				"\n\nВопрос пользователя:\n" + message
		}
	}

	resp, err := session.SendMessage(ctx, genai.Text(prompt))
	if err != nil {
		return "", fmt.Errorf("failed to send message: %w", err)
	}

	finalText, err := s.handleResponse(ctx, session, userID, resp)
	if err != nil {
		return "", err
	}

	return finalText, nil
}

func (s *ChatService) handleResponse(
	ctx context.Context,
	session *genai.ChatSession,
	userID string,
	resp *genai.GenerateContentResponse,
) (string, error) {
	if resp == nil || len(resp.Candidates) == 0 {
		return "", fmt.Errorf("empty response from gemini")
	}

	for _, part := range resp.Candidates[0].Content.Parts {
		switch typed := part.(type) {
		case genai.FunctionCall:
			if typed.Name == "add_service_record" {
				result, err := s.handleAddServiceRecord(ctx, userID, typed.Args)
				if err != nil {
					return "", err
				}

				followUp, err := session.SendMessage(ctx, genai.FunctionResponse{
					Name:     "add_service_record",
					Response: result,
				})
				if err != nil {
					return "", fmt.Errorf("failed to send function response: %w", err)
				}

				return extractText(followUp)
			}
		case genai.Text:
			return string(typed), nil
		}
	}

	return extractText(resp)
}

func (s *ChatService) handleAddServiceRecord(
	ctx context.Context,
	userID string,
	args map[string]interface{},
) (map[string]interface{}, error) {
	parsedUserID, err := uuid.Parse(userID)
	if err != nil {
		return nil, fmt.Errorf("invalid user_id: %w", err)
	}

	category := strings.TrimSpace(toString(args["category"]))
	amount := toFloat(args["amount"])
	description := strings.TrimSpace(toString(args["description"]))
	date := strings.TrimSpace(toString(args["date"]))

	if category == "" || amount <= 0 || description == "" || date == "" {
		return nil, fmt.Errorf("missing required fields in function call")
	}

	record := &ServiceRecord{
		ID:          uuid.New(),
		UserID:      parsedUserID,
		Date:        date,
		Category:    Category(category),
		Amount:      amount,
		Description: description,
	}

	if s.repo == nil {
		return map[string]interface{}{"status": "skipped", "reason": "repository not available"}, nil
	}

	if err := s.repo.CreateServiceRecord(ctx, record); err != nil {
		return nil, fmt.Errorf("failed to save service record: %w", err)
	}

	return map[string]interface{}{"status": "success"}, nil
}

func extractText(resp *genai.GenerateContentResponse) (string, error) {
	if resp == nil || len(resp.Candidates) == 0 {
		return "", fmt.Errorf("empty response from gemini")
	}
	for _, part := range resp.Candidates[0].Content.Parts {
		if text, ok := part.(genai.Text); ok {
			return string(text), nil
		}
	}
	return "", fmt.Errorf("no text in gemini response")
}

func toString(value interface{}) string {
	switch typed := value.(type) {
	case string:
		return typed
	case fmt.Stringer:
		return typed.String()
	case []byte:
		return string(typed)
	default:
		return ""
	}
}

func toFloat(value interface{}) float64 {
	switch typed := value.(type) {
	case float64:
		return typed
	case float32:
		return float64(typed)
	case int:
		return float64(typed)
	case int64:
		return float64(typed)
	case string:
		var parsed float64
		if _, err := fmt.Sscanf(typed, "%f", &parsed); err == nil {
			return parsed
		}
	}
	return 0
}
