package handlers

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
)

type SettingsHandler struct {
	mu       sync.Mutex
	settings SettingsData
}

type SettingsData struct {
	City          string               `json:"city"`
	Language      string               `json:"language"`
	Notifications NotificationSettings `json:"notifications"`
	Security      SecuritySettings     `json:"security"`
}

type NotificationSettings struct {
	Push    bool `json:"push"`
	Service bool `json:"service"`
	Promo   bool `json:"promo"`
	Email   bool `json:"email"`
}

type SecuritySettings struct {
	TwoFactorEnabled bool `json:"twoFactorEnabled"`
}

type NotificationsUpdateRequest struct {
	Push    *bool `json:"push"`
	Service *bool `json:"service"`
	Promo   *bool `json:"promo"`
	Email   *bool `json:"email"`
}

type TwoFactorRequest struct {
	Enabled bool `json:"enabled"`
}

func NewSettingsHandler() *SettingsHandler {
	return &SettingsHandler{
		settings: SettingsData{
			City:     "Алматы",
			Language: "ru",
			Notifications: NotificationSettings{
				Push:    true,
				Service: true,
				Promo:   false,
				Email:   true,
			},
			Security: SecuritySettings{
				TwoFactorEnabled: false,
			},
		},
	}
}

func (h *SettingsHandler) GetSettings(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	c.JSON(http.StatusOK, h.settings)
}

func (h *SettingsHandler) UpdateSettings(c *gin.Context) {
	var req SettingsData
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	h.settings = req
	c.JSON(http.StatusOK, h.settings)
}

func (h *SettingsHandler) UpdateNotifications(c *gin.Context) {
	var req NotificationsUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	settings := h.settings.Notifications
	if req.Push != nil {
		settings.Push = *req.Push
	}
	if req.Service != nil {
		settings.Service = *req.Service
	}
	if req.Promo != nil {
		settings.Promo = *req.Promo
	}
	if req.Email != nil {
		settings.Email = *req.Email
	}

	h.settings.Notifications = settings
	c.JSON(http.StatusOK, h.settings)
}

func (h *SettingsHandler) ChangePassword(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h *SettingsHandler) UpdateTwoFactor(c *gin.Context) {
	var req TwoFactorRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	h.settings.Security.TwoFactorEnabled = req.Enabled
	c.JSON(http.StatusOK, h.settings)
}
