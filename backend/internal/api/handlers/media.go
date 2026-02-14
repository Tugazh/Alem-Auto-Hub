package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"alem-auto/internal/media"
)

type MediaHandler struct {
	mediaService *media.Service
}

func NewMediaHandler(mediaService *media.Service) *MediaHandler {
	return &MediaHandler{mediaService: mediaService}
}

// PrepareUpload подготавливает загрузку файла
// @Summary Prepare file upload
// @Tags media
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body media.UploadRequest true "Upload request"
// @Success 200 {object} media.UploadResponse
// @Failure 400 {object} map[string]string
// @Router /api/v1/media/upload [post]
func (h *MediaHandler) PrepareUpload(c *gin.Context) {
	var req media.UploadRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := h.mediaService.PrepareUpload(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// ConfirmUpload подтверждает успешную загрузку
// @Summary Confirm file upload
// @Tags media
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "Asset ID"
// @Param sha256 body string true "SHA256 hash"
// @Success 200 {object} media.Asset
// @Failure 400 {object} map[string]string
// @Router /api/v1/media/{id}/confirm [post]
func (h *MediaHandler) ConfirmUpload(c *gin.Context) {
	idStr := c.Param("id")
	assetID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid asset id"})
		return
	}

	var req struct {
		SHA256 string `json:"sha256" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.mediaService.ConfirmUpload(c.Request.Context(), assetID, req.SHA256)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	asset, err := h.mediaService.GetAsset(c.Request.Context(), assetID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, asset)
}

// GetAsset получает метаданные ассета
// @Summary Get asset metadata
// @Tags media
// @Security BearerAuth
// @Produce json
// @Param id path string true "Asset ID"
// @Success 200 {object} media.Asset
// @Failure 404 {object} map[string]string
// @Router /api/v1/media/{id} [get]
func (h *MediaHandler) GetAsset(c *gin.Context) {
	idStr := c.Param("id")
	assetID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid asset id"})
		return
	}

	asset, err := h.mediaService.GetAsset(c.Request.Context(), assetID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if asset == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "asset not found"})
		return
	}

	c.JSON(http.StatusOK, asset)
}

// GetDownloadURL получает pre-signed URL для скачивания
// @Summary Get download URL
// @Tags media
// @Security BearerAuth
// @Produce json
// @Param id path string true "Asset ID"
// @Param expires_in query int false "Expiration in seconds" default(3600)
// @Success 200 {object} media.DownloadResponse
// @Failure 404 {object} map[string]string
// @Router /api/v1/media/{id}/download [get]
func (h *MediaHandler) GetDownloadURL(c *gin.Context) {
	idStr := c.Param("id")
	assetID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid asset id"})
		return
	}

	expiresIn := 3600 * time.Second
	if expiresInStr := c.Query("expires_in"); expiresInStr != "" {
		if parsed, err := time.ParseDuration(expiresInStr + "s"); err == nil {
			expiresIn = parsed
		}
	}

	response, err := h.mediaService.GetDownloadURL(c.Request.Context(), assetID, expiresIn)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// LinkAsset связывает ассет с сущностью
// @Summary Link asset to entity
// @Tags media
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "Asset ID"
// @Param request body map[string]string true "Link data" example({"link_type": "vehicle", "link_id": "uuid"})
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Router /api/v1/media/{id}/link [post]
func (h *MediaHandler) LinkAsset(c *gin.Context) {
	idStr := c.Param("id")
	assetID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid asset id"})
		return
	}

	var req struct {
		LinkType string    `json:"link_type" binding:"required"`
		LinkID   uuid.UUID `json:"link_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.mediaService.LinkAsset(c.Request.Context(), assetID, req.LinkType, req.LinkID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "asset linked successfully"})
}
