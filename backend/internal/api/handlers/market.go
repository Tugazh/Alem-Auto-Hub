package handlers

import (
	"net/http"

	"alem-auto/internal/auth"
	"alem-auto/internal/market"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MarketHandler struct {
	service *market.Service
}

func NewMarketHandler(service *market.Service) *MarketHandler {
	return &MarketHandler{service: service}
}

func (h *MarketHandler) ListProducts(c *gin.Context) {
	h.listByKind(c, market.KindProduct)
}

func (h *MarketHandler) CreateProduct(c *gin.Context) {
	h.createByKind(c, market.KindProduct)
}

func (h *MarketHandler) GetProduct(c *gin.Context) {
	h.getByKind(c, market.KindProduct)
}

func (h *MarketHandler) UpdateProduct(c *gin.Context) {
	h.updateByKind(c, market.KindProduct)
}

func (h *MarketHandler) DeleteProduct(c *gin.Context) {
	h.deleteByKind(c, market.KindProduct)
}

func (h *MarketHandler) ListServices(c *gin.Context) {
	h.listByKind(c, market.KindService)
}

func (h *MarketHandler) CreateService(c *gin.Context) {
	h.createByKind(c, market.KindService)
}

func (h *MarketHandler) GetService(c *gin.Context) {
	h.getByKind(c, market.KindService)
}

func (h *MarketHandler) UpdateService(c *gin.Context) {
	h.updateByKind(c, market.KindService)
}

func (h *MarketHandler) DeleteService(c *gin.Context) {
	h.deleteByKind(c, market.KindService)
}

func (h *MarketHandler) ListAds(c *gin.Context) {
	h.listByKind(c, market.KindAd)
}

func (h *MarketHandler) CreateAd(c *gin.Context) {
	h.createByKind(c, market.KindAd)
}

func (h *MarketHandler) GetAd(c *gin.Context) {
	h.getByKind(c, market.KindAd)
}

func (h *MarketHandler) UpdateAd(c *gin.Context) {
	h.updateByKind(c, market.KindAd)
}

func (h *MarketHandler) DeleteAd(c *gin.Context) {
	h.deleteByKind(c, market.KindAd)
}

func (h *MarketHandler) listByKind(c *gin.Context, kind string) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	filter := market.ListItemsFilter{Limit: 50, Offset: 0}
	if v := c.Query("category"); v != "" {
		filter.Category = &v
	}
	if v := c.Query("search"); v != "" {
		filter.Search = &v
	}
	if v := c.DefaultQuery("limit", "50"); v != "" {
		if l, err := parseInt(v); err == nil && l > 0 {
			filter.Limit = l
		}
	}
	if v := c.Query("offset"); v != "" {
		if o, err := parseInt(v); err == nil && o >= 0 {
			filter.Offset = o
		}
	}

	list, err := h.service.List(c.Request.Context(), userID.(uuid.UUID), kind, filter)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, list)
}

func (h *MarketHandler) createByKind(c *gin.Context, kind string) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	var req market.CreateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	item, err := h.service.Create(c.Request.Context(), userID.(uuid.UUID), kind, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, item)
}

func (h *MarketHandler) getByKind(c *gin.Context, kind string) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	item, err := h.service.GetByID(c.Request.Context(), id, userID.(uuid.UUID), kind)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if item == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, item)
}

func (h *MarketHandler) updateByKind(c *gin.Context, kind string) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	var req market.UpdateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	item, err := h.service.Update(c.Request.Context(), id, userID.(uuid.UUID), kind, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if item == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, item)
}

func (h *MarketHandler) deleteByKind(c *gin.Context, kind string) {
	userID, ok := auth.GetUserID(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	if err := h.service.Delete(c.Request.Context(), id, userID.(uuid.UUID), kind); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusNoContent, nil)
}
