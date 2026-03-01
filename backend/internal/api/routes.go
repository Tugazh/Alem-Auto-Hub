package api

import (
	"alem-auto/internal/agent"
	"alem-auto/internal/api/handlers"
	"alem-auto/internal/auth"
	"alem-auto/internal/booking"
	"alem-auto/internal/catalog"
	"alem-auto/internal/fines"
	"alem-auto/internal/inspection"
	"alem-auto/internal/media"
	"alem-auto/internal/servicebook"
	"alem-auto/internal/vehicle"
	"alem-auto/internal/warehouse"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	authService *auth.Service,
	catalogService *catalog.Service,
	vehicleService *vehicle.Service,
	inspectionService *inspection.Service,
	mediaService *media.Service,
	finesService *fines.Service,
	bookingService *booking.Service,
	warehouseService *warehouse.Service,
	servicebookService *servicebook.Service,
	mockCarsPath string,
	agentService *agent.ChatService,
) *gin.Engine {
	router := gin.Default()

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// API v1
	v1 := router.Group("/api/v1")
	{
		agentHandler := handlers.NewAgentHandler(agentService)
		agentGroup := v1.Group("/agent")
		{
			agentGroup.POST("/message", agentHandler.HandleMessage)
		}

		// Mock routes (public)
		mockHandler := handlers.NewMockHandler(mockCarsPath)
		mockGroup := v1.Group("/mock")
		{
			mockGroup.GET("/cars", mockHandler.GetCars)
		}

		// Auth routes (public)
		authHandler := handlers.NewAuthHandler(authService)
		authGroup := v1.Group("/auth")
		{
			authGroup.POST("/register", authHandler.Register)
			authGroup.POST("/login", authHandler.Login)
			authGroup.GET("/profile", auth.AuthMiddleware(authService), authHandler.GetProfile)
		}

		// Catalog routes (public)
		catalogHandler := handlers.NewCatalogHandler(catalogService)
		catalogGroup := v1.Group("/catalog")
		{
			catalogGroup.GET("/makes", catalogHandler.GetMakes)
			catalogGroup.GET("/makes/:id", catalogHandler.GetMakeByID)
			catalogGroup.GET("/models", catalogHandler.GetModels)
			catalogGroup.GET("/models/:id", catalogHandler.GetModelByID)
			catalogGroup.GET("/generations", catalogHandler.GetGenerations)
			catalogGroup.GET("/platforms", catalogHandler.GetPlatforms)
			catalogGroup.GET("/components", catalogHandler.GetComponents)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(auth.AuthMiddleware(authService))
		{
			// Vehicle routes
			vehicleHandler := handlers.NewVehicleHandler(vehicleService)
			vehiclesGroup := protected.Group("/vehicles")
			{
				vehiclesGroup.POST("", vehicleHandler.CreateVehicle)
				vehiclesGroup.GET("/my", vehicleHandler.GetMyVehicles)
				if servicebookService != nil {
					servicebookHandler := servicebook.NewHandler(servicebookService)
					vehiclesGroup.GET("/:id/service-book", servicebookHandler.GetServiceBook)
				}
				vehiclesGroup.GET("/:id", vehicleHandler.GetVehicleByID)
				vehiclesGroup.PUT("/:id", vehicleHandler.UpdateVehicle)
				vehiclesGroup.GET("/:id/state", vehicleHandler.GetVehicleState)
			}

			// Inspection routes
			inspectionHandler := handlers.NewInspectionHandler(inspectionService)
			inspectionsGroup := protected.Group("/inspections")
			{
				inspectionsGroup.POST("", inspectionHandler.CreateInspection)
				inspectionsGroup.GET("/:id", inspectionHandler.GetInspectionByID)
				inspectionsGroup.POST("/:inspection_id/observations", inspectionHandler.CreateComponentObservation)
			}

			// Vehicle inspections
			protected.GET("/vehicles/:id/inspections", inspectionHandler.GetInspectionsByVehicleID)

			// Fines routes (only when DB available)
			if finesService != nil {
				finesHandler := handlers.NewFinesHandler(finesService)
				finesGroup := protected.Group("/fines")
				{
					finesGroup.POST("", finesHandler.CreateFine)
					finesGroup.GET("", finesHandler.ListFines)
					finesGroup.GET("/:id", finesHandler.GetFine)
					finesGroup.PUT("/:id", finesHandler.UpdateFine)
					finesGroup.DELETE("/:id", finesHandler.DeleteFine)
				}
			}

			// Booking routes (only when DB available)
			if bookingService != nil {
				bookingHandler := handlers.NewBookingHandler(bookingService)
				bookingsGroup := protected.Group("/bookings")
				{
					bookingsGroup.POST("", bookingHandler.CreateBooking)
					bookingsGroup.GET("", bookingHandler.ListBookings)
					bookingsGroup.GET("/:id", bookingHandler.GetBooking)
					bookingsGroup.PATCH("/:id", bookingHandler.UpdateBooking)
					bookingsGroup.DELETE("/:id", bookingHandler.DeleteBooking)
				}
			}

			// Warehouse routes (admin/mechanic only, only when DB available)
			if warehouseService != nil {
				warehouseHandler := handlers.NewWarehouseHandler(warehouseService)
				warehouseGroup := protected.Group("/warehouse")
				warehouseGroup.Use(auth.RequireRole("admin", "mechanic"))
				{
					warehouseGroup.GET("/items", warehouseHandler.ListItems)
					warehouseGroup.POST("/items", warehouseHandler.CreateItem)
					warehouseGroup.GET("/items/:id", warehouseHandler.GetItem)
					warehouseGroup.PUT("/items/:id", warehouseHandler.UpdateItem)
					warehouseGroup.GET("/items/:id/stock", warehouseHandler.GetStock)
					warehouseGroup.POST("/items/:id/stock", warehouseHandler.AdjustStock)
					warehouseGroup.GET("/movements", warehouseHandler.ListMovements)
				}
			}

			// Media routes
			mediaHandler := handlers.NewMediaHandler(mediaService)
			mediaGroup := protected.Group("/media")
			{
				mediaGroup.POST("/upload", mediaHandler.PrepareUpload)
				mediaGroup.POST("/:id/confirm", mediaHandler.ConfirmUpload)
				mediaGroup.GET("/:id", mediaHandler.GetAsset)
				mediaGroup.GET("/:id/download", mediaHandler.GetDownloadURL)
				mediaGroup.POST("/:id/link", mediaHandler.LinkAsset)
			}
		}
	}

	return router
}
