package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type AuthMockHandler struct{}

type AuthMockResponse struct {
	AccessToken  string       `json:"accessToken"`
	RefreshToken string       `json:"refreshToken"`
	ExpiresAt    string       `json:"expiresAt"`
	User         AuthMockUser `json:"user"`
}

type AuthMockUser struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Phone string `json:"phone"`
	Email string `json:"email"`
	Role  string `json:"role"`
}

func NewAuthMockHandler() *AuthMockHandler {
	return &AuthMockHandler{}
}

func (h *AuthMockHandler) RequestOtp(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "otp_sent"})
}

func (h *AuthMockHandler) VerifyOtp(c *gin.Context) {
	c.JSON(http.StatusOK, h.buildMockSession())
}

func (h *AuthMockHandler) Refresh(c *gin.Context) {
	c.JSON(http.StatusOK, h.buildMockSession())
}

func (h *AuthMockHandler) Logout(c *gin.Context) {
	c.Status(http.StatusNoContent)
}

func (h *AuthMockHandler) Verify(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"valid": true})
}

func (h *AuthMockHandler) buildMockSession() AuthMockResponse {
	expiresAt := time.Now().Add(45 * time.Minute).Format(time.RFC3339)
	return AuthMockResponse{
		AccessToken:  "mock_access_123456",
		RefreshToken: "mock_refresh_123456",
		ExpiresAt:    expiresAt,
		User: AuthMockUser{
			ID:    "550e8400-e29b-41d4-a716-446655440000",
			Name:  "Нуртуган Әлиев",
			Phone: "+7 707 123 45 67",
			Email: "nurtugan@example.com",
			Role:  "owner",
		},
	}
}
