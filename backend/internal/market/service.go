package market

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, kind string, req *CreateItemRequest) (*Item, error) {
	if !isValidKind(kind) {
		return nil, fmt.Errorf("invalid kind")
	}
	if req.Price <= 0 {
		return nil, fmt.Errorf("price must be positive")
	}

	currency := req.Currency
	if currency == "" {
		currency = "KZT"
	}

	item := &Item{
		ID:          uuid.New(),
		UserID:      userID,
		Kind:        kind,
		Title:       req.Title,
		Description: req.Description,
		Category:    req.Category,
		Price:       req.Price,
		Currency:    currency,
		Available:   true,
	}

	if err := s.repo.Create(ctx, item); err != nil {
		return nil, err
	}
	return item, nil
}

func (s *Service) GetByID(ctx context.Context, id uuid.UUID, userID uuid.UUID, kind string) (*Item, error) {
	if !isValidKind(kind) {
		return nil, fmt.Errorf("invalid kind")
	}
	item, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if item == nil || item.UserID != userID || item.Kind != kind {
		return nil, nil
	}
	return item, nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID, kind string, filter ListItemsFilter) ([]*Item, error) {
	if !isValidKind(kind) {
		return nil, fmt.Errorf("invalid kind")
	}
	if filter.Limit <= 0 {
		filter.Limit = 50
	}
	return s.repo.ListByUserAndKind(ctx, userID, kind, filter)
}

func (s *Service) Update(ctx context.Context, id uuid.UUID, userID uuid.UUID, kind string, req *UpdateItemRequest) (*Item, error) {
	if !isValidKind(kind) {
		return nil, fmt.Errorf("invalid kind")
	}
	item, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if item == nil || item.UserID != userID || item.Kind != kind {
		return nil, nil
	}

	if req.Title != nil {
		item.Title = *req.Title
	}
	if req.Description != nil {
		item.Description = *req.Description
	}
	if req.Category != nil {
		item.Category = *req.Category
	}
	if req.Price != nil {
		if *req.Price <= 0 {
			return nil, fmt.Errorf("price must be positive")
		}
		item.Price = *req.Price
	}
	if req.Currency != nil && *req.Currency != "" {
		item.Currency = *req.Currency
	}
	if req.Available != nil {
		item.Available = *req.Available
	}

	if err := s.repo.Update(ctx, item); err != nil {
		return nil, err
	}
	return item, nil
}

func (s *Service) Delete(ctx context.Context, id uuid.UUID, userID uuid.UUID, kind string) error {
	if !isValidKind(kind) {
		return fmt.Errorf("invalid kind")
	}
	item, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if item == nil || item.UserID != userID || item.Kind != kind {
		return nil
	}
	return s.repo.Delete(ctx, id)
}

func isValidKind(kind string) bool {
	return kind == KindProduct || kind == KindService || kind == KindAd
}
