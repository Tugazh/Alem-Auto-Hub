package catalog

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

// Make methods

func (s *Service) GetAllMakes(ctx context.Context) ([]*Make, error) {
	return s.repo.GetAllMakes(ctx)
}

func (s *Service) GetMakeByID(ctx context.Context, id string) (*Make, error) {
	return s.repo.GetMakeByID(ctx, id)
}

func (s *Service) UpsertMake(ctx context.Context, m *Make) error {
	return s.repo.UpsertMake(ctx, m)
}

// Model methods

func (s *Service) GetModelsByMakeID(ctx context.Context, makeID string) ([]*Model, error) {
	// Проверяем существование марки
	_, err := s.repo.GetMakeByID(ctx, makeID)
	if err != nil {
		return nil, fmt.Errorf("failed to get make: %w", err)
	}

	return s.repo.GetModelsByMakeID(ctx, makeID)
}

func (s *Service) GetModelByID(ctx context.Context, id string) (*Model, error) {
	return s.repo.GetModelByID(ctx, id)
}

func (s *Service) UpsertModel(ctx context.Context, m *Model) error {
	// Проверяем существование марки
	_, err := s.repo.GetMakeByID(ctx, m.MakeID)
	if err != nil {
		return fmt.Errorf("make not found: %w", err)
	}

	return s.repo.UpsertModel(ctx, m)
}

// Generation methods

func (s *Service) CreateGeneration(ctx context.Context, g *Generation) error {
	if g.ID == uuid.Nil {
		g.ID = uuid.New()
	}

	// Проверяем существование модели
	_, err := s.repo.GetModelByID(ctx, g.ModelID)
	if err != nil {
		return fmt.Errorf("model not found: %w", err)
	}

	return s.repo.CreateGeneration(ctx, g)
}

func (s *Service) GetGenerationsByModelID(ctx context.Context, modelID string) ([]*Generation, error) {
	return s.repo.GetGenerationsByModelID(ctx, modelID)
}

// VehiclePlatform methods

func (s *Service) CreatePlatform(ctx context.Context, p *VehiclePlatform) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}

	if p.GenerationID != nil {
		// Проверяем существование поколения
		generations, err := s.repo.GetGenerationsByModelID(ctx, "")
		if err != nil {
			return fmt.Errorf("generation not found: %w", err)
		}
		_ = generations // TODO: проверить конкретное поколение
	}

	return s.repo.CreatePlatform(ctx, p)
}

func (s *Service) GetPlatformByID(ctx context.Context, id uuid.UUID) (*VehiclePlatform, error) {
	return s.repo.GetPlatformByID(ctx, id)
}

func (s *Service) GetPlatformsByGenerationID(ctx context.Context, generationID uuid.UUID) ([]*VehiclePlatform, error) {
	return s.repo.GetPlatformsByGenerationID(ctx, generationID)
}

// Component methods

func (s *Service) CreateComponent(ctx context.Context, c *Component) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}

	if c.VehiclePlatformID != nil {
		// Проверяем существование платформы
		_, err := s.repo.GetPlatformByID(ctx, *c.VehiclePlatformID)
		if err != nil {
			return fmt.Errorf("platform not found: %w", err)
		}
	}

	if c.ParentID != nil {
		// Проверяем существование родительского компонента
		_, err := s.repo.GetComponentByID(ctx, *c.ParentID)
		if err != nil {
			return fmt.Errorf("parent component not found: %w", err)
		}
	}

	return s.repo.CreateComponent(ctx, c)
}

func (s *Service) GetComponentByID(ctx context.Context, id uuid.UUID) (*Component, error) {
	return s.repo.GetComponentByID(ctx, id)
}

func (s *Service) GetComponentTree(ctx context.Context, platformID uuid.UUID) ([]*Component, error) {
	// Проверяем существование платформы
	_, err := s.repo.GetPlatformByID(ctx, platformID)
	if err != nil {
		return nil, fmt.Errorf("platform not found: %w", err)
	}

	return s.repo.GetComponentTree(ctx, platformID)
}

func (s *Service) GetComponentsByPlatformID(ctx context.Context, platformID uuid.UUID) ([]*Component, error) {
	return s.repo.GetComponentsByPlatformID(ctx, platformID)
}
