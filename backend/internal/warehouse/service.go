package warehouse

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

func (s *Service) CreateItem(ctx context.Context, req *CreateItemRequest) (*Item, error) {
	existing, _ := s.repo.GetItemBySKU(ctx, req.SKU)
	if existing != nil {
		return nil, fmt.Errorf("item with sku %s already exists", req.SKU)
	}
	unit := req.Unit
	if unit == "" {
		unit = "pcs"
	}
	if req.MinQuantity < 0 {
		req.MinQuantity = 0
	}
	item := &Item{
		ID:          uuid.New(),
		SKU:         req.SKU,
		Name:        req.Name,
		Description: req.Description,
		Unit:        unit,
		MinQuantity: req.MinQuantity,
	}
	if err := s.repo.CreateItem(ctx, item); err != nil {
		return nil, err
	}
	// Create initial stock row with 0
	stock := &Stock{ID: uuid.New(), ItemID: item.ID, Quantity: 0}
	if err := s.repo.CreateStock(ctx, stock); err != nil {
		return nil, err
	}
	return item, nil
}

func (s *Service) GetItemByID(ctx context.Context, id uuid.UUID) (*Item, error) {
	return s.repo.GetItemByID(ctx, id)
}

func (s *Service) ListItems(ctx context.Context, limit, offset int) ([]*Item, error) {
	return s.repo.ListItems(ctx, limit, offset)
}

func (s *Service) UpdateItem(ctx context.Context, id uuid.UUID, req *UpdateItemRequest) (*Item, error) {
	item, err := s.repo.GetItemByID(ctx, id)
	if err != nil || item == nil {
		return nil, err
	}
	if req.Name != nil {
		item.Name = *req.Name
	}
	if req.Description != nil {
		item.Description = *req.Description
	}
	if req.Unit != nil {
		item.Unit = *req.Unit
	}
	if req.MinQuantity != nil {
		if *req.MinQuantity < 0 {
			*req.MinQuantity = 0
		}
		item.MinQuantity = *req.MinQuantity
	}
	if err := s.repo.UpdateItem(ctx, item); err != nil {
		return nil, err
	}
	return item, nil
}

func (s *Service) DeleteItem(ctx context.Context, id uuid.UUID) error {
	_, err := s.repo.GetItemByID(ctx, id)
	if err != nil {
		return err
	}
	return s.repo.DeleteItem(ctx, id)
}

func (s *Service) GetStock(ctx context.Context, itemID uuid.UUID) (*Stock, error) {
	return s.repo.GetStockByItemID(ctx, itemID)
}

func (s *Service) AdjustStock(ctx context.Context, itemID uuid.UUID, req *AdjustStockRequest) (*Stock, error) {
	item, err := s.repo.GetItemByID(ctx, itemID)
	if err != nil || item == nil {
		return nil, fmt.Errorf("item not found")
	}
	switch req.Type {
	case MovementTypeIn, MovementTypeOut, MovementTypeAdjust:
		// ok
	default:
		return nil, fmt.Errorf("invalid movement type")
	}
	stock, err := s.repo.GetStockByItemID(ctx, itemID)
	if err != nil {
		return nil, err
	}
	if stock == nil {
		stock = &Stock{ID: uuid.New(), ItemID: itemID, Quantity: 0}
		if err := s.repo.CreateStock(ctx, stock); err != nil {
			return nil, err
		}
	}
	newQty := stock.Quantity + req.QuantityDelta
	if newQty < 0 {
		return nil, fmt.Errorf("insufficient stock: have %d, requested change %d", stock.Quantity, req.QuantityDelta)
	}
	if err := s.repo.UpdateStockQuantity(ctx, itemID, newQty); err != nil {
		return nil, err
	}
	m := &Movement{
		ID:            uuid.New(),
		ItemID:        itemID,
		QuantityDelta: req.QuantityDelta,
		Type:          req.Type,
		Reference:     req.Reference,
	}
	if err := s.repo.CreateMovement(ctx, m); err != nil {
		return nil, err
	}
	stock.Quantity = newQty
	return stock, nil
}

func (s *Service) ListMovements(ctx context.Context, itemID *uuid.UUID, limit, offset int) ([]*Movement, error) {
	return s.repo.ListMovements(ctx, itemID, limit, offset)
}
