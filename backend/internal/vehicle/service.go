package vehicle

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/catalog"
)

type Service struct {
	repo         *Repository
	catalogService *catalog.Service
}

func NewService(repo *Repository, catalogService *catalog.Service) *Service {
	return &Service{
		repo:         repo,
		catalogService: catalogService,
	}
}

func (s *Service) CreateVehicle(ctx context.Context, v *Vehicle) error {
	if v.ID == uuid.Nil {
		v.ID = uuid.New()
	}

	// Проверяем существование платформы, если указана
	if v.VehiclePlatformID != nil {
		_, err := s.catalogService.GetPlatformByID(ctx, *v.VehiclePlatformID)
		if err != nil {
			return fmt.Errorf("platform not found: %w", err)
		}
	}

	// Проверяем уникальность VIN, если указан
	if v.VIN != nil && *v.VIN != "" {
		existing, err := s.repo.GetVehicleByVIN(ctx, *v.VIN)
		if err != nil {
			return fmt.Errorf("failed to check VIN: %w", err)
		}
		if existing != nil {
			return fmt.Errorf("vehicle with VIN %s already exists", *v.VIN)
		}
	}

	return s.repo.CreateVehicle(ctx, v)
}

func (s *Service) GetVehicleByID(ctx context.Context, id uuid.UUID) (*Vehicle, error) {
	return s.repo.GetVehicleByID(ctx, id)
}

func (s *Service) GetVehicleByVIN(ctx context.Context, vin string) (*Vehicle, error) {
	return s.repo.GetVehicleByVIN(ctx, vin)
}

func (s *Service) UpdateVehicle(ctx context.Context, v *Vehicle) error {
	// Проверяем существование авто
	existing, err := s.repo.GetVehicleByID(ctx, v.ID)
	if err != nil {
		return fmt.Errorf("failed to get vehicle: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("vehicle not found")
	}

	// Проверяем уникальность VIN, если он изменился
	if v.VIN != nil && *v.VIN != "" && (existing.VIN == nil || *existing.VIN != *v.VIN) {
		vinVehicle, err := s.repo.GetVehicleByVIN(ctx, *v.VIN)
		if err != nil {
			return fmt.Errorf("failed to check VIN: %w", err)
		}
		if vinVehicle != nil && vinVehicle.ID != v.ID {
			return fmt.Errorf("vehicle with VIN %s already exists", *v.VIN)
		}
	}

	// Проверяем существование платформы, если указана
	if v.VehiclePlatformID != nil {
		_, err := s.catalogService.GetPlatformByID(ctx, *v.VehiclePlatformID)
		if err != nil {
			return fmt.Errorf("platform not found: %w", err)
		}
	}

	return s.repo.UpdateVehicle(ctx, v)
}

func (s *Service) UpdateOdometer(ctx context.Context, vehicleID uuid.UUID, odometerKm int) error {
	if odometerKm < 0 {
		return fmt.Errorf("odometer cannot be negative")
	}

	return s.repo.UpdateOdometer(ctx, vehicleID, odometerKm)
}

func (s *Service) GetVehicleState(ctx context.Context, vehicleID uuid.UUID) (*VehicleState, error) {
	vehicle, err := s.repo.GetVehicleByID(ctx, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to get vehicle: %w", err)
	}
	if vehicle == nil {
		return nil, fmt.Errorf("vehicle not found")
	}

	components, err := s.repo.GetVehicleComponentState(ctx, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to get component state: %w", err)
	}

	return &VehicleState{
		Vehicle:    vehicle,
		Components: components,
	}, nil
}

func (s *Service) GetVehiclesByUserID(ctx context.Context, userID uuid.UUID) ([]*Vehicle, error) {
	return s.repo.GetVehiclesByUserID(ctx, userID)
}

func (s *Service) CreateVehicleOwner(ctx context.Context, vo *VehicleOwner) error {
	if vo.ID == uuid.Nil {
		vo.ID = uuid.New()
	}

	// Проверяем существование авто
	_, err := s.repo.GetVehicleByID(ctx, vo.VehicleID)
	if err != nil {
		return fmt.Errorf("vehicle not found: %w", err)
	}

	return s.repo.CreateVehicleOwner(ctx, vo)
}

func (s *Service) GetCurrentOwnersByVehicleID(ctx context.Context, vehicleID uuid.UUID) ([]*VehicleOwner, error) {
	return s.repo.GetCurrentOwnersByVehicleID(ctx, vehicleID)
}
