package servicebook

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/agent"
	"alem-auto/internal/inspection"
	"alem-auto/internal/vehicle"
)

type Service struct {
	vehicleService    *vehicle.Service
	inspectionService *inspection.Service
	agentRepo         *agent.Repository
}

func NewService(
	vehicleService *vehicle.Service,
	inspectionService *inspection.Service,
	agentRepo *agent.Repository,
) *Service {
	return &Service{
		vehicleService:    vehicleService,
		inspectionService: inspectionService,
		agentRepo:         agentRepo,
	}
}

// GetServiceBook returns the service book for a vehicle. Only the vehicle owner or mechanic/admin can access.
func (s *Service) GetServiceBook(ctx context.Context, vehicleID uuid.UUID, userID uuid.UUID, userRole string) (*ServiceBookResponse, error) {
	veh, err := s.vehicleService.GetVehicleByID(ctx, vehicleID)
	if err != nil {
		return nil, err
	}
	if veh == nil {
		return nil, nil
	}
	// Allow mechanic and admin to view any vehicle's service book; otherwise require ownership
	if userRole != "mechanic" && userRole != "admin" && userRole != "platform" {
		owners, err := s.vehicleService.GetCurrentOwnersByVehicleID(ctx, vehicleID)
		if err != nil {
			return nil, err
		}
		owned := false
		for _, o := range owners {
			if o.UserID == userID {
				owned = true
				break
			}
		}
		if !owned {
			return nil, nil // not found for this user
		}
	}

	inspections, err := s.inspectionService.GetInspectionsByVehicleID(ctx, vehicleID)
	if err != nil {
		return nil, fmt.Errorf("failed to get inspections: %w", err)
	}

	var serviceRecords []agent.ServiceRecord
	if s.agentRepo != nil {
		serviceRecords, err = s.agentRepo.GetServiceRecordsByVehicleID(ctx, vehicleID)
		if err != nil {
			return nil, fmt.Errorf("failed to get service records: %w", err)
		}
	}
	if serviceRecords == nil {
		serviceRecords = []agent.ServiceRecord{}
	}

	return &ServiceBookResponse{
		Vehicle:        veh,
		Inspections:    inspections,
		ServiceRecords: serviceRecords,
	}, nil
}
