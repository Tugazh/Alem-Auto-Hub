package knowledge

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) (*Repository, error) {
	repo := &Repository{db: db}
	if err := db.AutoMigrate(&KnowledgeChunk{}); err != nil {
		return nil, err
	}
	return repo, nil
}

func (r *Repository) CreateChunks(ctx context.Context, chunks []KnowledgeChunk) error {
	if len(chunks) == 0 {
		return nil
	}
	return r.db.WithContext(ctx).Create(&chunks).Error
}

func (r *Repository) SearchSimilar(ctx context.Context, embedding []float32, limit int) ([]KnowledgeChunk, error) {
	if limit <= 0 {
		limit = 5
	}

	rows := []KnowledgeChunk{}
	vectorLiteral := formatVector(embedding)

	err := r.db.WithContext(ctx).
		Raw(
			"SELECT id, source, chunk, embedding, created_at FROM knowledge_base ORDER BY embedding <-> ?::vector LIMIT ?",
			vectorLiteral,
			limit,
		).
		Scan(&rows).Error
	if err != nil {
		return nil, fmt.Errorf("failed to search knowledge base: %w", err)
	}

	return rows, nil
}

func (r *Repository) SearchByKeywords(ctx context.Context, keywords []string, limit int) ([]KnowledgeChunk, error) {
	if len(keywords) == 0 {
		return nil, nil
	}
	if limit <= 0 {
		limit = 5
	}

	query := r.db.WithContext(ctx).Model(&KnowledgeChunk{})
	for i, keyword := range keywords {
		like := fmt.Sprintf("%%%s%%", keyword)
		if i == 0 {
			query = query.Where("chunk ILIKE ?", like)
		} else {
			query = query.Or("chunk ILIKE ?", like)
		}
	}

	rows := []KnowledgeChunk{}
	if err := query.
		Order("source = 'koap_full' DESC").
		Limit(limit).
		Find(&rows).Error; err != nil {
		return nil, fmt.Errorf("failed to search knowledge base by keywords: %w", err)
	}

	return rows, nil
}

func (r *Repository) SearchByAllKeywords(ctx context.Context, keywords []string, limit int) ([]KnowledgeChunk, error) {
	if len(keywords) == 0 {
		return nil, nil
	}
	if limit <= 0 {
		limit = 5
	}

	query := r.db.WithContext(ctx).Model(&KnowledgeChunk{})
	for _, keyword := range keywords {
		like := fmt.Sprintf("%%%s%%", keyword)
		query = query.Where("chunk ILIKE ?", like)
	}

	rows := []KnowledgeChunk{}
	if err := query.
		Order("source = 'koap_full' DESC").
		Limit(limit).
		Find(&rows).Error; err != nil {
		return nil, fmt.Errorf("failed to search knowledge base by all keywords: %w", err)
	}

	return rows, nil
}

func formatVector(embedding []float32) string {
	if len(embedding) == 0 {
		return "[]"
	}

	buf := make([]byte, 0, len(embedding)*8)
	buf = append(buf, '[')
	for i, v := range embedding {
		if i > 0 {
			buf = append(buf, ',')
		}
		buf = append(buf, []byte(fmt.Sprintf("%f", v))...)
	}
	buf = append(buf, ']')
	return string(buf)
}

func NewChunk(source, text string, embedding []float32) KnowledgeChunk {
	return KnowledgeChunk{
		ID:        uuid.New(),
		Source:    source,
		Chunk:     text,
		Embedding: ToVector(embedding),
	}
}
