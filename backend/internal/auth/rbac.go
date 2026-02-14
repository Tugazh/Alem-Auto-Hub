package auth

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/inspection"
	"alem-auto/internal/vehicle"
)

// RBAC реализует проверку прав доступа
type RBAC struct {
	vehicleService   *vehicle.Service
	inspectionService *inspection.Service
}

func NewRBAC(vehicleService *vehicle.Service, inspectionService *inspection.Service) *RBAC {
	return &RBAC{
		vehicleService:   vehicleService,
		inspectionService: inspectionService,
	}
}

// CanAccessVehicle проверяет, может ли пользователь получить доступ к авто
func (r *RBAC) CanAccessVehicle(ctx context.Context, userID uuid.UUID, userRole string, vehicleID uuid.UUID) (bool, error) {
	// Платформа и админы имеют полный доступ
	if userRole == "platform" || userRole == "admin" {
		return true, nil
	}

	// Владелец может видеть свои авто
	if userRole == "owner" {
		vehicles, err := r.vehicleService.GetVehiclesByUserID(ctx, userID)
		if err != nil {
			return false, fmt.Errorf("failed to get user vehicles: %w", err)
		}

		for _, v := range vehicles {
			if v.ID == vehicleID {
				return true, nil
			}
		}

		return false, nil
	}

	// Мастер может видеть авто, которые он осматривал в своем центре
	if userRole == "mechanic" {
		// Получаем центры мастера
		// TODO: реализовать через inspection service
		_ = userID
		_ = vehicleID
		return false, fmt.Errorf("mechanic access check not implemented")
	}

	return false, nil
}

// CanAccessInspection проверяет, может ли пользователь получить доступ к осмотру
func (r *RBAC) CanAccessInspection(ctx context.Context, userID uuid.UUID, userRole string, inspectionID uuid.UUID) (bool, error) {
	// Платформа и админы имеют полный доступ
	if userRole == "platform" || userRole == "admin" {
		return true, nil
	}

	// Получаем осмотр
	insp, err := r.inspectionService.GetInspectionByID(ctx, inspectionID)
	if err != nil {
		return false, fmt.Errorf("failed to get inspection: %w", err)
	}
	if insp == nil {
		return false, nil
	}

	// Владелец может видеть осмотры своих авто
	if userRole == "owner" {
		return r.CanAccessVehicle(ctx, userID, userRole, insp.VehicleID)
	}

	// Мастер может видеть осмотры своего центра
	if userRole == "mechanic" {
		// Проверяем, является ли пользователь мастером в этом центре
		// TODO: реализовать проверку через inspection service
		return insp.CreatedByUserID == userID, nil
	}

	return false, nil
}

// CanCreateInspection проверяет, может ли пользователь создать осмотр
func (r *RBAC) CanCreateInspection(ctx context.Context, userID uuid.UUID, userRole string, vehicleID uuid.UUID) (bool, error) {
	// Только мастера, админы и платформа могут создавать осмотры
	if userRole == "mechanic" || userRole == "admin" || userRole == "platform" {
		return true, nil
	}

	return false, nil
}
