package booking

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"alem-auto/internal/inspection"
	"alem-auto/internal/vehicle"
)

type Service struct {
	repo              *Repository
	vehicleService    *vehicle.Service
	inspectionService *inspection.Service
}

func NewService(repo *Repository, vehicleService *vehicle.Service, inspectionService *inspection.Service) *Service {
	return &Service{
		repo:              repo,
		vehicleService:    vehicleService,
		inspectionService: inspectionService,
	}
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, req *CreateBookingRequest) (*Booking, error) {
	// Verify vehicle exists and user owns it (via vehicle_owners or at least has access)
	veh, err := s.vehicleService.GetVehicleByID(ctx, req.VehicleID)
	if err != nil || veh == nil {
		return nil, fmt.Errorf("vehicle not found")
	}
	// Check ownership: user must be in vehicle_owners for this vehicle
	owners, err := s.vehicleService.GetCurrentOwnersByVehicleID(ctx, req.VehicleID)
	if err != nil || len(owners) == 0 {
		return nil, fmt.Errorf("vehicle not found or access denied")
	}
	owned := false
	for _, o := range owners {
		if o.UserID == userID {
			owned = true
			break
		}
	}
	if !owned {
		return nil, fmt.Errorf("vehicle not found or access denied")
	}
	// Verify service center exists (inspection package has GetServiceCenterByID via repo; we need to expose or use inspection)
	// Inspection service doesn't expose GetServiceCenterByID. We need to add it or call repo. For simplicity we'll add a method to inspection.Service or use the repo from inspection. Checking inspection service...
	// inspection.Service has CreateServiceCenter, CreateInspection etc. We need GetServiceCenterByID. The inspection repository has it. So we need to add GetServiceCenterByID to inspection.Service and use it here.
	sc, err := s.inspectionService.GetServiceCenterByID(ctx, req.ServiceCenterID)
	if err != nil || sc == nil {
		return nil, fmt.Errorf("service center not found")
	}
	_ = sc

	scheduledAt, err := time.Parse(time.RFC3339, req.ScheduledAt)
	if err != nil {
		return nil, fmt.Errorf("invalid scheduled_at, use ISO8601: %w", err)
	}
	if scheduledAt.Before(time.Now()) {
		return nil, fmt.Errorf("scheduled_at must be in the future")
	}

	b := &Booking{
		ID:              uuid.New(),
		ServiceCenterID: req.ServiceCenterID,
		VehicleID:       req.VehicleID,
		UserID:          userID,
		ScheduledAt:     scheduledAt,
		Status:          StatusScheduled,
	}
	if req.Notes != "" {
		b.Notes = &req.Notes
	}
	if err := s.repo.Create(ctx, b); err != nil {
		return nil, err
	}
	return b, nil
}

func (s *Service) GetByID(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*Booking, error) {
	b, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if b == nil || b.UserID != userID {
		return nil, nil
	}
	return b, nil
}

func (s *Service) List(ctx context.Context, userID uuid.UUID, filter ListBookingsFilter) ([]*Booking, error) {
	if filter.Limit <= 0 {
		filter.Limit = 50
	}
	return s.repo.ListByUserID(ctx, userID, filter)
}

func (s *Service) Update(ctx context.Context, id uuid.UUID, userID uuid.UUID, req *UpdateBookingRequest) (*Booking, error) {
	b, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if b == nil || b.UserID != userID {
		return nil, nil
	}
	if req.Status != nil {
		switch *req.Status {
		case StatusScheduled, StatusCompleted, StatusCancelled, StatusNoShow:
			b.Status = *req.Status
		default:
			return nil, fmt.Errorf("invalid status")
		}
	}
	if req.Notes != nil {
		b.Notes = req.Notes
	}
	if err := s.repo.Update(ctx, b); err != nil {
		return nil, err
	}
	return b, nil
}

func (s *Service) Delete(ctx context.Context, id uuid.UUID, userID uuid.UUID) error {
	b, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if b == nil || b.UserID != userID {
		return nil
	}
	return s.repo.Delete(ctx, id)
}
