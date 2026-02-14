package auth

import (
	"context"
	"fmt"
	"time"

	"alem-auto/config"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type Service struct {
	repo *Repository
	cfg  config.AuthConfig
}

func NewService(repo *Repository, cfg config.AuthConfig) *Service {
	return &Service{
		repo: repo,
		cfg:  cfg,
	}
}

// Register создает нового пользователя
func (s *Service) Register(ctx context.Context, req *RegisterRequest) (*User, error) {
	// Проверяем, не существует ли уже пользователь с таким email
	existing, err := s.repo.GetUserByEmail(ctx, req.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to check existing user: %w", err)
	}
	if existing != nil {
		return nil, fmt.Errorf("user with email %s already exists", req.Email)
	}

	// Хешируем пароль
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Устанавливаем роль по умолчанию
	role := req.Role
	if role == "" {
		role = "owner"
	}

	// Валидация роли
	validRoles := map[string]bool{
		"owner":    true,
		"mechanic": true,
		"admin":    true,
		"platform": true,
	}
	if !validRoles[role] {
		return nil, fmt.Errorf("invalid role: %s", role)
	}

	user := &User{
		ID:           uuid.New(),
		Email:        req.Email,
		PasswordHash: string(passwordHash),
		Name:         &req.Name,
		Role:         role,
	}

	err = s.repo.CreateUser(ctx, user)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	// Не возвращаем хеш пароля
	user.PasswordHash = ""
	return user, nil
}

// Login аутентифицирует пользователя и возвращает JWT токен
func (s *Service) Login(ctx context.Context, req *LoginRequest) (*TokenResponse, error) {
	user, err := s.repo.GetUserByEmail(ctx, req.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("invalid credentials")
	}

	// Проверяем пароль
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password))
	if err != nil {
		return nil, fmt.Errorf("invalid credentials")
	}

	// Генерируем JWT токен
	token, expiresAt, err := s.generateToken(user)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	// Не возвращаем хеш пароля
	user.PasswordHash = ""

	return &TokenResponse{
		Token:     token,
		ExpiresAt: expiresAt,
		User:      user,
	}, nil
}

// ValidateToken валидирует JWT токен и возвращает claims
func (s *Service) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// Проверяем алгоритм
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.cfg.JWTSecret), nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, fmt.Errorf("invalid token")
}

// GetUserByID получает пользователя по ID
func (s *Service) GetUserByID(ctx context.Context, id uuid.UUID) (*User, error) {
	user, err := s.repo.GetUserByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if user != nil {
		user.PasswordHash = ""
	}
	return user, nil
}

// generateToken генерирует JWT токен для пользователя
func (s *Service) generateToken(user *User) (string, time.Time, error) {
	expiresAt := time.Now().Add(s.cfg.JWTExpiration)

	claims := &Claims{
		UserID: user.ID,
		Email:  user.Email,
		Role:   user.Role,
	}
	claims.RegisteredClaims = jwt.RegisteredClaims{
		ExpiresAt: jwt.NewNumericDate(expiresAt),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		NotBefore: jwt.NewNumericDate(time.Now()),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.cfg.JWTSecret))
	if err != nil {
		return "", time.Time{}, fmt.Errorf("failed to sign token: %w", err)
	}

	return tokenString, expiresAt, nil
}
