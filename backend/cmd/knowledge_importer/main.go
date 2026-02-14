package main

import (
	"context"
	"flag"
	"log"
	"os"

	"alem-auto/config"
	"alem-auto/internal/agent"
	"alem-auto/internal/database"
	"alem-auto/internal/knowledge"
)

func main() {
	filePath := flag.String("file", "", "Path to a UTF-8 text file to index")
	source := flag.String("source", "manual", "Source label for the document")
	flag.Parse()

	if *filePath == "" {
		log.Fatal("--file is required")
	}

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	gormDB, err := database.NewGorm(cfg.Database)
	if err != nil {
		log.Fatalf("Failed to connect database: %v", err)
	}

	geminiClient, err := agent.NewGeminiClient(context.Background(), cfg.AI.GeminiAPIKey, cfg.AI.GeminiModel)
	if err != nil {
		log.Fatalf("Failed to init gemini client: %v", err)
	}
	defer geminiClient.Client.Close()

	repo, err := knowledge.NewRepository(gormDB)
	if err != nil {
		log.Fatalf("Failed to init knowledge repository: %v", err)
	}

	service := knowledge.NewService(repo, geminiClient)

	data, err := os.ReadFile(*filePath)
	if err != nil {
		log.Fatalf("Failed to read file: %v", err)
	}

	count, err := service.IndexText(context.Background(), *source, string(data))
	if err != nil {
		log.Fatalf("Failed to index text: %v", err)
	}

	log.Printf("Indexed %d chunks from %s", count, *filePath)
}
