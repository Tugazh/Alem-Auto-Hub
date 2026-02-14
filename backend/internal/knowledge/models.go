package knowledge

import (
	"time"

	"github.com/google/uuid"
	"github.com/pgvector/pgvector-go"
)

type KnowledgeChunk struct {
	ID        uuid.UUID       `json:"id" gorm:"type:uuid;primaryKey"`
	Source    string          `json:"source" gorm:"index"`
	Chunk     string          `json:"chunk" gorm:"type:text"`
	Embedding pgvector.Vector `json:"embedding" gorm:"type:vector(768)"`
	CreatedAt time.Time       `json:"created_at"`
}

func (KnowledgeChunk) TableName() string {
	return "knowledge_base"
}
