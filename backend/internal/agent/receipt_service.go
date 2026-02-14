package agent

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/generative-ai-go/genai"
)

func (s *ChatService) ParseReceiptImage(ctx context.Context, imageBytes []byte) (*ReceiptData, error) {
	if s.gemini == nil || s.gemini.Model == nil {
		return nil, fmt.Errorf("gemini client not initialized")
	}

	prompt := "Извлеки данные чека и верни ТОЛЬКО JSON: {date, vendor, items, total}. Без текста вокруг JSON."
	resp, err := s.gemini.Model.GenerateContent(
		ctx,
		genai.Text(prompt),
		genai.ImageData("image/jpeg", imageBytes),
	)
	if err != nil {
		return nil, fmt.Errorf("receipt parse failed: %w", err)
	}

	return parseReceiptFromResponse(resp)
}

func parseReceiptFromResponse(resp *genai.GenerateContentResponse) (*ReceiptData, error) {
	if resp == nil || len(resp.Candidates) == 0 {
		return nil, fmt.Errorf("empty response from gemini")
	}

	for _, part := range resp.Candidates[0].Content.Parts {
		if text, ok := part.(genai.Text); ok {
			var data ReceiptData
			if err := json.Unmarshal([]byte(text), &data); err == nil {
				return &data, nil
			}
		}
	}

	return nil, fmt.Errorf("failed to parse receipt JSON")
}
