package config

import (
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	S3       S3Config
	Auth     AuthConfig
	Mock     MockConfig
	AI       AIConfig
}

type ServerConfig struct {
	Port         string
	Host         string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
}

type DatabaseConfig struct {
	Host            string
	Port            string
	User            string
	Password        string
	DBName          string
	SSLMode         string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

type S3Config struct {
	Region          string
	Bucket          string
	AccessKeyID     string
	SecretAccessKey string
	Endpoint        string // для локальной разработки с MinIO
	UseSSL          bool
}

type AuthConfig struct {
	JWTSecret     string
	JWTExpiration time.Duration
}

type MockConfig struct {
	CarsJSONPath string
}

type AIConfig struct {
	GeminiAPIKey string
	GeminiModel  string
}

func Load() (*Config, error) {
	// Загружаем .env файл если он существует (не критично если его нет)
	_ = godotenv.Load()

	cfg := &Config{
		Server: ServerConfig{
			Port:         getEnv("SERVER_PORT", "8080"),
			Host:         getEnv("SERVER_HOST", "0.0.0.0"),
			ReadTimeout:  parseDuration(getEnv("SERVER_READ_TIMEOUT", "15s")),
			WriteTimeout: parseDuration(getEnv("SERVER_WRITE_TIMEOUT", "15s")),
		},
		Database: DatabaseConfig{
			Host:            getEnv("DB_HOST", "localhost"),
			Port:            getEnv("DB_PORT", "5432"),
			User:            getEnv("DB_USER", "postgres"),
			Password:        getEnv("DB_PASSWORD", "postgres"),
			DBName:          getEnv("DB_NAME", "alem_auto"),
			SSLMode:         getEnv("DB_SSLMODE", "disable"),
			MaxOpenConns:    parseInt(getEnv("DB_MAX_OPEN_CONNS", "25")),
			MaxIdleConns:    parseInt(getEnv("DB_MAX_IDLE_CONNS", "5")),
			ConnMaxLifetime: parseDuration(getEnv("DB_CONN_MAX_LIFETIME", "5m")),
		},
		S3: S3Config{
			Region:          getEnv("S3_REGION", "us-east-1"),
			Bucket:          getEnv("S3_BUCKET", ""),
			AccessKeyID:     getEnv("S3_ACCESS_KEY_ID", ""),
			SecretAccessKey: getEnv("S3_SECRET_ACCESS_KEY", ""),
			Endpoint:        getEnv("S3_ENDPOINT", ""),
			UseSSL:          parseBool(getEnv("S3_USE_SSL", "true")),
		},
		Auth: AuthConfig{
			JWTSecret:     getEnv("JWT_SECRET", "change-me-in-production"),
			JWTExpiration: parseDuration(getEnv("JWT_EXPIRATION", "24h")),
		},
		Mock: MockConfig{
			CarsJSONPath: getEnv("CARS_JSON_PATH", "cars.json"),
		},
		AI: AIConfig{
			GeminiAPIKey: getEnv("GEMINI_API_KEY", ""),
			GeminiModel:  getEnv("GEMINI_MODEL", "gemini-1.5-flash"),
		},
	}

	// Валидация обязательных полей
	if cfg.S3.Bucket == "" {
		cfg.S3.Bucket = "default-bucket" // Для тестирования без S3
	}
	if cfg.S3.AccessKeyID == "" {
		cfg.S3.AccessKeyID = "test" // Для тестирования без S3
	}
	if cfg.S3.SecretAccessKey == "" {
		cfg.S3.SecretAccessKey = "test" // Для тестирования без S3
	}

	return cfg, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func parseInt(s string) int {
	val, err := strconv.Atoi(s)
	if err != nil {
		return 0
	}
	return val
}

func parseBool(s string) bool {
	val, err := strconv.ParseBool(s)
	if err != nil {
		return true
	}
	return val
}

func parseDuration(s string) time.Duration {
	d, err := time.ParseDuration(s)
	if err != nil {
		return time.Second * 15
	}
	return d
}
