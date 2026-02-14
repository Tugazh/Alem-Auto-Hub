package handlers

import (
	"net/http"

	"alem-auto/internal/catalog"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CatalogHandler struct {
	catalogService *catalog.Service
}

func NewCatalogHandler(catalogService *catalog.Service) *CatalogHandler {
	return &CatalogHandler{catalogService: catalogService}
}

// GetMakes получает список всех марок
// @Summary Get all makes
// @Tags catalog
// @Produce json
// @Success 200 {array} catalog.Make
// @Router /api/v1/catalog/makes [get]
func (h *CatalogHandler) GetMakes(c *gin.Context) {
	makes, err := h.catalogService.GetAllMakes(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, makes)
}

// GetMakeByID получает марку по ID
// @Summary Get make by ID
// @Tags catalog
// @Produce json
// @Param id path string true "Make ID"
// @Success 200 {object} catalog.Make
// @Failure 404 {object} map[string]string
// @Router /api/v1/catalog/makes/{id} [get]
func (h *CatalogHandler) GetMakeByID(c *gin.Context) {
	id := c.Param("id")
	make, err := h.catalogService.GetMakeByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if make == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "make not found"})
		return
	}

	c.JSON(http.StatusOK, make)
}

// GetModels получает список моделей по ID марки
// @Summary Get models by make ID
// @Tags catalog
// @Produce json
// @Param make_id query string true "Make ID"
// @Success 200 {array} catalog.Model
// @Router /api/v1/catalog/models [get]
func (h *CatalogHandler) GetModels(c *gin.Context) {
	makeID := c.Query("make_id")
	if makeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "make_id is required"})
		return
	}

	models, err := h.catalogService.GetModelsByMakeID(c.Request.Context(), makeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, models)
}

// GetModelByID получает модель по ID
// @Summary Get model by ID
// @Tags catalog
// @Produce json
// @Param id path string true "Model ID"
// @Success 200 {object} catalog.Model
// @Failure 404 {object} map[string]string
// @Router /api/v1/catalog/models/{id} [get]
func (h *CatalogHandler) GetModelByID(c *gin.Context) {
	id := c.Param("id")
	model, err := h.catalogService.GetModelByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if model == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "model not found"})
		return
	}

	c.JSON(http.StatusOK, model)
}

// GetGenerations получает список поколений по ID модели
// @Summary Get generations by model ID
// @Tags catalog
// @Produce json
// @Param model_id query string true "Model ID"
// @Success 200 {array} catalog.Generation
// @Router /api/v1/catalog/generations [get]
func (h *CatalogHandler) GetGenerations(c *gin.Context) {
	modelID := c.Query("model_id")
	if modelID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "model_id is required"})
		return
	}

	generations, err := h.catalogService.GetGenerationsByModelID(c.Request.Context(), modelID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, generations)
}

// GetPlatforms получает список платформ по ID поколения
// @Summary Get platforms by generation ID
// @Tags catalog
// @Produce json
// @Param generation_id query string true "Generation ID"
// @Success 200 {array} catalog.VehiclePlatform
// @Router /api/v1/catalog/platforms [get]
func (h *CatalogHandler) GetPlatforms(c *gin.Context) {
	generationIDStr := c.Query("generation_id")
	if generationIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "generation_id is required"})
		return
	}

	generationID, err := uuid.Parse(generationIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid generation_id"})
		return
	}

	platforms, err := h.catalogService.GetPlatformsByGenerationID(c.Request.Context(), generationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, platforms)
}

// GetComponents получает дерево компонентов по ID платформы
// @Summary Get component tree by platform ID
// @Tags catalog
// @Produce json
// @Param platform_id query string true "Platform ID"
// @Success 200 {array} catalog.Component
// @Router /api/v1/catalog/components [get]
func (h *CatalogHandler) GetComponents(c *gin.Context) {
	platformIDStr := c.Query("platform_id")
	if platformIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "platform_id is required"})
		return
	}

	platformID, err := uuid.Parse(platformIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid platform_id"})
		return
	}

	components, err := h.catalogService.GetComponentTree(c.Request.Context(), platformID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, components)
}
