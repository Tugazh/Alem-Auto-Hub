package fines

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, req *CreateFineRequest) (*Fine, error) {
	if req.Amount <= 0 {
		return nil, fmt.Errorf("amount must be positive")
	}
	issuedAt, err := time.Parse("2006-01-02", req.IssuedAt)
	if err != nil {
		return nil, fmt.Errorf("invalid issued_at date, use YYYY-MM-DD: %w", err)
	}
	currency := req.Currency
	if currency == "" {
		currency = "KZT"
	}
	f := &Fine{
		ID:          uuid.New(),
		UserID:      userID,
		VehicleID:   req.VehicleID,
		Amount:      req.Amount,
		Currency:    currency,
		Description: req.Description,
		IssuedAt:    issuedAt,
		Status:      StatusPending,
	}
	if req.Article != "" {
		f.Article = &req.Article
	}
	if err := s.repo.Create(ctx, f); err != nil {
		return nil, err
	}
	return f, nil
}

func (s *Service) GetByID(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*Fine, error) {
	f, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if f == nil {
		return nil, nil
	}
	if f.UserID != userID {
		return nil, nil // not found for this user (don't leak existence)
	}
	return f, nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID, filter ListFinesFilter) ([]*Fine, error) {
	if filter.Limit <= 0 {
		filter.Limit = 50
	}
	return s.repo.ListByUserID(ctx, userID, filter)
}

func (s *Service) Update(ctx context.Context, id uuid.UUID, userID uuid.UUID, req *UpdateFineRequest) (*Fine, error) {
	f, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if f == nil || f.UserID != userID {
		return nil, nil
	}
	if req.Status != nil {
		switch *req.Status {
		case StatusPaid, StatusPending, StatusDisputed:
			f.Status = *req.Status
			if *req.Status == StatusPaid && f.PaidAt == nil {
				now := time.Now()
				f.PaidAt = &now
			}
		default:
			return nil, fmt.Errorf("invalid status")
		}
	}
	if req.PaidAt != nil {
		if t, err := time.Parse(time.RFC3339, *req.PaidAt); err == nil {
			f.PaidAt = &t
		}
	}
	if err := s.repo.Update(ctx, f); err != nil {
		return nil, err
	}
	return f, nil
}

func (s *Service) Delete(ctx context.Context, id uuid.UUID, userID uuid.UUID) error {
	f, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if f == nil || f.UserID != userID {
		return nil // no-op, not found or not owner
	}
	return s.repo.Delete(ctx, id)
}
