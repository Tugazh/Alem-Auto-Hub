package main

import (
	"context"
	"flag"
	"log"
	"os"

	"alem-auto/config"
	"alem-auto/internal/catalog"
	"alem-auto/internal/database"
)

func main() {
	var filePath string
	flag.StringVar(&filePath, "file", "cars.json", "Path to cars.json file")
	flag.Parse()

	if filePath == "" {
		log.Fatal("File path is required. Use --file=cars.json")
	}

	// Проверяем существование файла
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		log.Fatalf("File not found: %s", filePath)
	}

	// Загружаем конфигурацию
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Подключаемся к БД
	db, err := database.New(cfg.Database)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Инициализируем сервисы
	catalogRepo := catalog.NewRepository(db)
	catalogService := catalog.NewService(catalogRepo)
	importer := catalog.NewImporter(catalogService)

	// Импортируем данные
	ctx := context.Background()
	log.Printf("Starting import from %s...", filePath)
	
	if err := importer.ImportFromFile(ctx, filePath); err != nil {
		log.Fatalf("Import failed: %v", err)
	}

	log.Println("Import completed successfully!")
}
