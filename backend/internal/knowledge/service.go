package knowledge

import (
	"context"
	"fmt"
	"strings"
)

type Service struct {
	repo  *Repository
	embed Embedder
}

type Embedder interface {
	EmbedText(ctx context.Context, text string) ([]float32, error)
}

func NewService(repo *Repository, embedder Embedder) *Service {
	return &Service{repo: repo, embed: embedder}
}

func (s *Service) IndexText(ctx context.Context, source string, text string) (int, error) {
	if s.repo == nil {
		return 0, fmt.Errorf("knowledge repository not configured")
	}
	if s.embed == nil {
		return 0, fmt.Errorf("gemini client not configured")
	}

	chunks := ChunkText(text, 900, 120)
	if len(chunks) == 0 {
		return 0, nil
	}

	var stored []KnowledgeChunk
	for _, chunk := range chunks {
		embedding, err := s.embed.EmbedText(ctx, chunk)
		if err != nil {
			return len(stored), err
		}
		stored = append(stored, NewChunk(source, chunk, embedding))
	}

	if err := s.repo.CreateChunks(ctx, stored); err != nil {
		return len(stored), err
	}

	return len(stored), nil
}

func (s *Service) RetrieveContext(ctx context.Context, query string, limit int) (string, error) {
	if s.repo == nil || s.embed == nil {
		return "", nil
	}

	query = strings.TrimSpace(query)
	if query == "" {
		return "", nil
	}

	embedding, err := s.embed.EmbedText(ctx, query)
	if err != nil {
		return "", err
	}

	chunks, err := s.repo.SearchSimilar(ctx, embedding, limit)
	if err != nil {
		return "", err
	}

	keywordMatches := extractKeywords(query)
	if needsKeywordFallback(query, chunks) && len(keywordMatches) > 0 {
		strictKeywords := extractStrictTrafficKeywords(query)
		if len(strictKeywords) > 0 {
			fallbackChunks, err := s.repo.SearchByAllKeywords(ctx, strictKeywords, limit)
			if err == nil && len(fallbackChunks) > 0 {
				if containsPenaltyChunk(fallbackChunks) {
					chunks = mergeUniqueChunks(fallbackChunks, chunks, limit)
				} else {
					chunks = mergeUniqueChunks(chunks, fallbackChunks, limit)
				}
			}
		}
		fallbackChunks, err := s.repo.SearchByKeywords(ctx, keywordMatches, limit)
		if err == nil && len(fallbackChunks) > 0 {
			if containsPenaltyChunk(fallbackChunks) {
				chunks = mergeUniqueChunks(fallbackChunks, chunks, limit)
			} else {
				chunks = mergeUniqueChunks(chunks, fallbackChunks, limit)
			}
		}
	}

	if len(chunks) == 0 {
		return "", nil
	}

	var builder strings.Builder
	builder.WriteString("Факты и выдержки:\n")
	for _, chunk := range chunks {
		builder.WriteString("- ")
		builder.WriteString(chunk.Chunk)
		builder.WriteString("\n")
	}

	return builder.String(), nil
}

func extractKeywords(query string) []string {
	terms := strings.Fields(strings.ToLower(query))
	keywords := make([]string, 0, len(terms))
	for _, term := range terms {
		clean := strings.Trim(term, " ,.!?;:\"'()[]{}")
		if len(clean) < 4 {
			continue
		}
		keywords = append(keywords, clean)
	}
	return keywords
}

func needsKeywordFallback(query string, chunks []KnowledgeChunk) bool {
	query = strings.ToLower(query)
	if strings.Contains(query, "штраф") || strings.Contains(query, "красн") || strings.Contains(query, "светофор") {
		for _, chunk := range chunks {
			text := strings.ToLower(chunk.Chunk)
			if strings.Contains(text, "штраф") || strings.Contains(text, "статья 599") {
				return false
			}
		}
		return true
	}
	return false
}

func mergeUniqueChunks(primary []KnowledgeChunk, fallback []KnowledgeChunk, limit int) []KnowledgeChunk {
	if len(fallback) == 0 {
		return primary
	}
	seen := make(map[string]struct{}, len(primary))
	for _, chunk := range primary {
		seen[chunk.ID.String()] = struct{}{}
	}

	combined := make([]KnowledgeChunk, 0, len(primary)+len(fallback))
	combined = append(combined, primary...)
	for _, chunk := range fallback {
		if _, ok := seen[chunk.ID.String()]; ok {
			continue
		}
		combined = append(combined, chunk)
		if limit > 0 && len(combined) >= limit {
			break
		}
	}

	return combined
}

func containsPenaltyChunk(chunks []KnowledgeChunk) bool {
	for _, chunk := range chunks {
		text := strings.ToLower(chunk.Chunk)
		if strings.Contains(text, "штраф") || strings.Contains(text, "статья 599") {
			return true
		}
	}
	return false
}

func extractStrictTrafficKeywords(query string) []string {
	query = strings.ToLower(query)
	strict := []string{}
	if strings.Contains(query, "светофор") {
		strict = append(strict, "светофор")
	}
	if strings.Contains(query, "проезд") {
		strict = append(strict, "проезд")
	}
	if strings.Contains(query, "запрещ") {
		strict = append(strict, "запрещ")
	}
	if strings.Contains(query, "красн") && strings.Contains(query, "проезд") {
		strict = append(strict, "светофор")
	}
	if len(strict) >= 2 {
		return strict
	}
	return nil
}

func ChunkText(text string, size int, overlap int) []string {
	clean := strings.TrimSpace(text)
	if clean == "" {
		return nil
	}
	if size <= 0 {
		size = 900
	}
	if overlap < 0 {
		overlap = 0
	}

	runes := []rune(clean)
	var chunks []string
	for start := 0; start < len(runes); start += size - overlap {
		end := start + size
		if end > len(runes) {
			end = len(runes)
		}
		chunk := strings.TrimSpace(string(runes[start:end]))
		if chunk != "" {
			chunks = append(chunks, chunk)
		}
		if end == len(runes) {
			break
		}
	}

	return chunks
}
