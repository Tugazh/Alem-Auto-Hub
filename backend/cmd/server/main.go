package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"alem-auto/config"
	"alem-auto/internal/agent"
	"alem-auto/internal/api"
	"alem-auto/internal/auth"
	"alem-auto/internal/booking"
	"alem-auto/internal/catalog"
	"alem-auto/internal/database"
	"alem-auto/internal/fines"
	"alem-auto/internal/inspection"
	"alem-auto/internal/knowledge"
	"alem-auto/internal/logger"
	"alem-auto/internal/media"
	"alem-auto/internal/metrics"
	"alem-auto/internal/servicebook"
	"alem-auto/internal/vehicle"
	"alem-auto/internal/warehouse"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	// Загружаем конфигурацию
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Инициализируем structured logger
	env := "production"
	if cfg.Server.Host == "localhost" || cfg.Server.Host == "0.0.0.0" {
		env = "development"
	}
	appLogger := logger.InitLogger(env)
	appLogger.Info("Starting Alem Auto application", "env", env)

	// Подключаемся к БД (опционально для основных сервисов)
	db, err := database.New(cfg.Database)
	if err != nil {
		appLogger.Warn("Failed to connect to database", "error", err, "note", "some features will be unavailable")
		db = nil
	}
	if db != nil {
		defer db.Close()
	}

	// GORM соединение (опционально для agent)
	gormDB, err := database.NewGorm(cfg.Database)
	if err != nil {
		log.Printf("Warning: Failed to connect GORM database: %v (agent persistence disabled)", err)
		gormDB = nil
	}

	// Инициализируем S3 клиент
	var s3Client *media.S3Client
	if cfg.S3.AccessKeyID != "" {
		s3Client, err = media.NewS3Client(cfg.S3)
		if err != nil {
			log.Printf("Warning: Failed to initialize S3 client: %v", err)
		}
	}

	// Инициализируем сервисы (с nil-проверками)
	var catalogService *catalog.Service
	var vehicleService *vehicle.Service
	var inspectionService *inspection.Service
	var mediaService *media.Service
	var authService *auth.Service
	var finesService *fines.Service
	var bookingService *booking.Service
	var warehouseService *warehouse.Service
	var servicebookService *servicebook.Service

	if db != nil {
		catalogRepo := catalog.NewRepository(db)
		catalogService = catalog.NewService(catalogRepo)

		vehicleRepo := vehicle.NewRepository(db)
		vehicleService = vehicle.NewService(vehicleRepo, catalogService)

		inspectionRepo := inspection.NewRepository(db)
		inspectionService = inspection.NewService(inspectionRepo, vehicleService)

		mediaRepo := media.NewRepository(db)
		mediaService = media.NewService(mediaRepo, s3Client, cfg.S3)

		authRepo := auth.NewRepository(db)
		authService = auth.NewService(authRepo, cfg.Auth)

		finesRepo := fines.NewRepository(db)
		finesService = fines.NewService(finesRepo)

		bookingRepo := booking.NewRepository(db)
		bookingService = booking.NewService(bookingRepo, vehicleService, inspectionService)

		warehouseRepo := warehouse.NewRepository(db)
		warehouseService = warehouse.NewService(warehouseRepo)
	}

	// Agent сервис (работает без БД, но без сохранения)
	var agentRepo *agent.Repository
	var knowledgeRepo *knowledge.Repository
	var knowledgeService *knowledge.Service
	if gormDB != nil {
		agentRepo, err = agent.NewRepository(gormDB)
		if err != nil {
			log.Printf("Warning: Failed to init agent repository: %v", err)
		}

		knowledgeRepo, err = knowledge.NewRepository(gormDB)
		if err != nil {
			log.Printf("Warning: Failed to init knowledge repository: %v", err)
		}
	}

	var geminiClient *agent.GeminiClient
	if cfg.AI.GeminiAPIKey != "" {
		geminiClient, err = agent.NewGeminiClient(
			context.Background(),
			cfg.AI.GeminiAPIKey,
			cfg.AI.GeminiModel,
		)
		if err != nil {
			log.Printf("Warning: Failed to init gemini client: %v", err)
		}
	}
	if geminiClient != nil {
		defer geminiClient.Client.Close()
	}

	if knowledgeRepo != nil && geminiClient != nil {
		knowledgeService = knowledge.NewService(knowledgeRepo, geminiClient)
	}

	agentService := agent.NewChatService(agentRepo, geminiClient, knowledgeService)

	if db != nil {
		servicebookService = servicebook.NewService(vehicleService, inspectionService, agentRepo)
	}

	// Настраиваем роутинг с middleware
	router := api.SetupRoutes(
		authService,
		catalogService,
		vehicleService,
		inspectionService,
		mediaService,
		finesService,
		bookingService,
		warehouseService,
		servicebookService,
		cfg.Mock.CarsJSONPath,
		agentService,
	)

	// Добавляем structured logging middleware
	router.Use(logger.StructuredLogger(appLogger))

	// Добавляем Prometheus metrics middleware
	router.Use(metrics.MetricsMiddleware())

	// Добавляем /metrics endpoint для Prometheus
	router.GET("/metrics", func(c *gin.Context) {
		promhttp.Handler().ServeHTTP(c.Writer, c.Request)
	})

	// Настраиваем HTTP сервер
	srv := &http.Server{
		Addr:         fmt.Sprintf("%s:%s", cfg.Server.Host, cfg.Server.Port),
		Handler:      router,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
	}

	// Запускаем сервер в горутине
	go func() {
		log.Printf("Server starting on %s:%s", cfg.Server.Host, cfg.Server.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Ожидаем сигнал для graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}
