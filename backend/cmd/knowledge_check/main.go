package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"alem-auto/config"
	"alem-auto/internal/agent"
	"alem-auto/internal/database"
	"alem-auto/internal/knowledge"
)

type sourceCount struct {
	Source string
	Count  int64
}

func main() {
	query := flag.String("query", "", "Optional query to test retrieval")
	limit := flag.Int("limit", 4, "Number of chunks to retrieve")
	flag.Parse()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	gormDB, err := database.NewGorm(cfg.Database)
	if err != nil {
		log.Fatalf("Failed to connect database: %v", err)
	}

	var counts []sourceCount
	err = gormDB.Model(&knowledge.KnowledgeChunk{}).
		Select("source, COUNT(*) as count").
		Group("source").
		Order("source").
		Scan(&counts).Error
	if err != nil {
		log.Fatalf("Failed to query knowledge sources: %v", err)
	}

	if len(counts) == 0 {
		log.Println("No knowledge chunks found in the database.")
	} else {
		log.Println("Knowledge sources in database:")
		for _, row := range counts {
			log.Printf("- %s: %d chunks", row.Source, row.Count)
		}
	}

	if *query == "" {
		return
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

	contextBlock, err := service.RetrieveContext(context.Background(), *query, *limit)
	if err != nil {
		log.Fatalf("Failed to retrieve context: %v", err)
	}

	if contextBlock == "" {
		fmt.Println("No relevant chunks found for query.")
		return
	}

	fmt.Println("Retrieved chunks:")
	fmt.Println(contextBlock)
}
