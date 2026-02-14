package inspection

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/vehicle"
)

type Service struct {
	repo          *Repository
	vehicleService *vehicle.Service
}

func NewService(repo *Repository, vehicleService *vehicle.Service) *Service {
	return &Service{
		repo:          repo,
		vehicleService: vehicleService,
	}
}

// ServiceCenter methods

func (s *Service) CreateServiceCenter(ctx context.Context, sc *ServiceCenter) error {
	if sc.ID == uuid.Nil {
		sc.ID = uuid.New()
	}

	return s.repo.CreateServiceCenter(ctx, sc)
}

func (s *Service) GetServiceCenterByID(ctx context.Context, id uuid.UUID) (*ServiceCenter, error) {
	return s.repo.GetServiceCenterByID(ctx, id)
}

func (s *Service) CreateServiceCenterUser(ctx context.Context, scu *ServiceCenterUser) error {
	if scu.ID == uuid.Nil {
		scu.ID = uuid.New()
	}

	// Проверяем существование сервисного центра
	_, err := s.repo.GetServiceCenterByID(ctx, scu.ServiceCenterID)
	if err != nil {
		return fmt.Errorf("service center not found: %w", err)
	}

	// Валидация роли
	if scu.Role != "mechanic" && scu.Role != "admin" {
		return fmt.Errorf("invalid role: %s", scu.Role)
	}

	return s.repo.CreateServiceCenterUser(ctx, scu)
}

func (s *Service) GetServiceCenterUsersByCenterID(ctx context.Context, centerID uuid.UUID) ([]*ServiceCenterUser, error) {
	return s.repo.GetServiceCenterUsersByCenterID(ctx, centerID)
}

func (s *Service) GetServiceCenterUsersByUserID(ctx context.Context, userID uuid.UUID) ([]*ServiceCenterUser, error) {
	return s.repo.GetServiceCenterUsersByUserID(ctx, userID)
}

// Inspection methods

func (s *Service) CreateInspection(ctx context.Context, i *Inspection) error {
	if i.ID == uuid.Nil {
		i.ID = uuid.New()
	}

	// Проверяем существование авто
	_, err := s.vehicleService.GetVehicleByID(ctx, i.VehicleID)
	if err != nil {
		return fmt.Errorf("vehicle not found: %w", err)
	}

	// Проверяем существование сервисного центра
	_, err = s.repo.GetServiceCenterByID(ctx, i.ServiceCenterID)
	if err != nil {
		return fmt.Errorf("service center not found: %w", err)
	}

	// Обновляем пробег авто, если указан
	if i.OdometerKm != nil {
		err = s.vehicleService.UpdateOdometer(ctx, i.VehicleID, *i.OdometerKm)
		if err != nil {
			return fmt.Errorf("failed to update odometer: %w", err)
		}
	}

	return s.repo.CreateInspection(ctx, i)
}

func (s *Service) GetInspectionByID(ctx context.Context, id uuid.UUID) (*Inspection, error) {
	return s.repo.GetInspectionByID(ctx, id)
}

func (s *Service) GetInspectionWithObservations(ctx context.Context, id uuid.UUID) (*InspectionWithObservations, error) {
	inspection, err := s.repo.GetInspectionByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get inspection: %w", err)
	}
	if inspection == nil {
		return nil, fmt.Errorf("inspection not found")
	}

	observations, err := s.repo.GetComponentObservationsByInspectionID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get observations: %w", err)
	}

	return &InspectionWithObservations{
		Inspection:   inspection,
		Observations: observations,
	}, nil
}

func (s *Service) GetInspectionsByVehicleID(ctx context.Context, vehicleID uuid.UUID) ([]*Inspection, error) {
	return s.repo.GetInspectionsByVehicleID(ctx, vehicleID)
}

func (s *Service) GetInspectionsByServiceCenterID(ctx context.Context, centerID uuid.UUID) ([]*Inspection, error) {
	return s.repo.GetInspectionsByServiceCenterID(ctx, centerID)
}

// ComponentObservation methods

func (s *Service) CreateComponentObservation(ctx context.Context, co *ComponentObservation) error {
	if co.ID == uuid.Nil {
		co.ID = uuid.New()
	}

	// Проверяем существование осмотра
	_, err := s.repo.GetInspectionByID(ctx, co.InspectionID)
	if err != nil {
		return fmt.Errorf("inspection not found: %w", err)
	}

	// Валидация статуса
	validStatuses := map[string]bool{
		"ok":         true,
		"attention":  true,
		"replace":    true,
		"not_checked": true,
	}
	if !validStatuses[co.Status] {
		return fmt.Errorf("invalid status: %s", co.Status)
	}

	err = s.repo.CreateComponentObservation(ctx, co)
	if err != nil {
		return err
	}

	// Обновляем материализованное состояние компонента
	err = s.updateVehicleComponentState(ctx, co)
	if err != nil {
		// Логируем ошибку, но не прерываем создание наблюдения
		// TODO: добавить логирование
		_ = err
	}

	return nil
}

func (s *Service) GetComponentObservationsByInspectionID(ctx context.Context, inspectionID uuid.UUID) ([]*ComponentObservation, error) {
	return s.repo.GetComponentObservationsByInspectionID(ctx, inspectionID)
}

func (s *Service) GetComponentObservationsByComponentID(ctx context.Context, componentID uuid.UUID) ([]*ComponentObservation, error) {
	return s.repo.GetComponentObservationsByComponentID(ctx, componentID)
}

// updateVehicleComponentState обновляет материализованное состояние компонента
func (s *Service) updateVehicleComponentState(ctx context.Context, co *ComponentObservation) error {
	// Получаем vehicle_id из inspection
	inspection, err := s.repo.GetInspectionByID(ctx, co.InspectionID)
	if err != nil {
		return fmt.Errorf("failed to get inspection: %w", err)
	}
	if inspection == nil {
		return fmt.Errorf("inspection not found")
	}

	// Обновляем состояние через vehicle service
	// Это будет реализовано в vehicle service
	_ = inspection
	_ = co
	// TODO: вызвать метод обновления состояния в vehicle service

	return nil
}
