package main

import (
    "context"
    "fmt"
    "log"
    "alem-auto/config"
    "github.com/google/generative-ai-go/genai"
    "google.golang.org/api/option"
    "google.golang.org/api/iterator"
)

func main() {
    cfg, _ := config.Load()
    ctx := context.Background()
    client, err := genai.NewClient(ctx, option.WithAPIKey(cfg.AI.GeminiAPIKey))
    if err != nil { log.Fatal(err) }
    iter := client.ListModels(ctx)
    for {
        m, err := iter.Next()
        if err == iterator.Done { break }
        if err != nil { log.Fatal(err) }
        fmt.Println(m.Name)
    }
}
