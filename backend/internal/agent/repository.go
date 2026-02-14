package agent

import (
	"context"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) (*Repository, error) {
	repo := &Repository{db: db}
	if err := db.AutoMigrate(&ServiceRecord{}); err != nil {
		return nil, err
	}
	return repo, nil
}

func (r *Repository) CreateServiceRecord(ctx context.Context, record *ServiceRecord) error {
	return r.db.WithContext(ctx).Create(record).Error
}

func (r *Repository) GetServiceRecordsByUser(ctx context.Context, userID uuid.UUID) ([]ServiceRecord, error) {
	var records []ServiceRecord
	if err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&records).Error; err != nil {
		return nil, err
	}
	return records, nil
}
