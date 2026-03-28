package logger

import (
	"context"
	"log/slog"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var globalLogger *slog.Logger

// InitLogger initializes structured logger with environment-based configuration
func InitLogger(env string) *slog.Logger {
	var level slog.Level
	var handler slog.Handler

	// Set log level based on environment
	switch env {
	case "production":
		level = slog.LevelInfo
	case "development":
		level = slog.LevelDebug
	default:
		level = slog.LevelInfo
	}

	// Use JSON handler for production, text for development
	opts := &slog.HandlerOptions{
		Level:     level,
		AddSource: env == "development",
	}

	if env == "production" {
		handler = slog.NewJSONHandler(os.Stdout, opts)
	} else {
		handler = slog.NewTextHandler(os.Stdout, opts)
	}

	globalLogger = slog.New(handler)
	slog.SetDefault(globalLogger)

	return globalLogger
}

// GetLogger returns the global logger instance
func GetLogger() *slog.Logger {
	if globalLogger == nil {
		return InitLogger("development")
	}
	return globalLogger
}

// StructuredLogger is a Gin middleware for structured request logging
func StructuredLogger(logger *slog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Generate unique request ID
		requestID := uuid.New().String()
		c.Set("request_id", requestID)

		// Start timer
		start := time.Now()

		// Create logger with request context
		reqLogger := logger.With(
			slog.String("request_id", requestID),
			slog.String("method", c.Request.Method),
			slog.String("path", c.Request.URL.Path),
			slog.String("ip", c.ClientIP()),
			slog.String("user_agent", c.Request.UserAgent()),
		)

		// Add user_id if available from auth context
		if userID, exists := c.Get("user_id"); exists {
			reqLogger = reqLogger.With(slog.Any("user_id", userID))
		}

		// Store logger in context
		c.Set("logger", reqLogger)

		// Process request
		c.Next()

		// Calculate duration
		duration := time.Since(start)
		statusCode := c.Writer.Status()

		// Log request completion with appropriate level
		logLevel := slog.LevelInfo
		if statusCode >= 500 {
			logLevel = slog.LevelError
		} else if statusCode >= 400 {
			logLevel = slog.LevelWarn
		}

		reqLogger.Log(c.Request.Context(), logLevel, "Request completed",
			slog.Int("status", statusCode),
			slog.Int64("duration_ms", duration.Milliseconds()),
			slog.Int("response_size", c.Writer.Size()),
		)
	}
}

// GetLoggerFromContext retrieves the structured logger from Gin context
func GetLoggerFromContext(c *gin.Context) *slog.Logger {
	if logger, exists := c.Get("logger"); exists {
		return logger.(*slog.Logger)
	}
	return GetLogger()
}

// LogError logs an error with context
func LogError(ctx context.Context, msg string, err error, args ...any) {
	logger := GetLogger()
	allArgs := append([]any{slog.String("error", err.Error())}, args...)
	logger.ErrorContext(ctx, msg, allArgs...)
}

// LogInfo logs an info message with context
func LogInfo(ctx context.Context, msg string, args ...any) {
	logger := GetLogger()
	logger.InfoContext(ctx, msg, args...)
}

// LogWarn logs a warning message with context
func LogWarn(ctx context.Context, msg string, args ...any) {
	logger := GetLogger()
	logger.WarnContext(ctx, msg, args...)
}

// LogDebug logs a debug message with context
func LogDebug(ctx context.Context, msg string, args ...any) {
	logger := GetLogger()
	logger.DebugContext(ctx, msg, args...)
}
