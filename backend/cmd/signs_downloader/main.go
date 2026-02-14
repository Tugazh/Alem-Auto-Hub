package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"

	"alem-auto/internal/signs"
)

type manifestItem struct {
	URL    string `json:"url"`
	File   string `json:"file"`
	Size   int64  `json:"size"`
	SHA256 string `json:"sha256"`
}

type manifest struct {
	SourceURL    string         `json:"source_url"`
	DownloadedAt string         `json:"downloaded_at"`
	Items        []manifestItem `json:"items"`
}

func main() {
	sourceURL := flag.String("url", "https://adilet.zan.kz/rus/docs/V2300033003", "Page URL to scrape")
	outputDir := flag.String("out", "data/signs", "Directory to store downloaded images")
	manifestPath := flag.String("manifest", "", "Path to write manifest JSON (defaults to <out>/manifest.json)")
	dryRun := flag.Bool("dry-run", false, "Only list images without downloading")
	timeoutSeconds := flag.Int("timeout", 20, "HTTP timeout in seconds")
	flag.Parse()

	client := &http.Client{Timeout: time.Duration(*timeoutSeconds) * time.Second}

	html, err := fetchHTML(client, *sourceURL)
	if err != nil {
		log.Fatalf("Failed to fetch page: %v", err)
	}

	imageURLs := signs.ExtractImageURLs(html)
	if len(imageURLs) == 0 {
		log.Fatal("No image URLs found on the page")
	}

	log.Printf("Found %d images", len(imageURLs))

	if *dryRun {
		for _, imageURL := range imageURLs {
			log.Printf("%s", imageURL)
		}
		return
	}

	if err := os.MkdirAll(*outputDir, 0o755); err != nil {
		log.Fatalf("Failed to create output directory: %v", err)
	}

	if *manifestPath == "" {
		*manifestPath = filepath.Join(*outputDir, "manifest.json")
	}

	nameCounts := make(map[string]int)
	items := make([]manifestItem, 0, len(imageURLs))

	for _, imageURL := range imageURLs {
		filename, err := filenameForURL(imageURL, nameCounts)
		if err != nil {
			log.Fatalf("Failed to parse filename for %s: %v", imageURL, err)
		}

		destination := filepath.Join(*outputDir, filename)
		fileInfo, hash, err := ensureDownloaded(client, imageURL, destination)
		if err != nil {
			log.Fatalf("Failed to download %s: %v", imageURL, err)
		}

		items = append(items, manifestItem{
			URL:    imageURL,
			File:   filename,
			Size:   fileInfo.Size(),
			SHA256: hash,
		})
	}

	manifestData := manifest{
		SourceURL:    *sourceURL,
		DownloadedAt: time.Now().Format(time.RFC3339),
		Items:        items,
	}

	if err := writeManifest(*manifestPath, manifestData); err != nil {
		log.Fatalf("Failed to write manifest: %v", err)
	}

	log.Printf("Saved %d files to %s", len(items), *outputDir)
	log.Printf("Manifest written to %s", *manifestPath)
}

func fetchHTML(client *http.Client, sourceURL string) (string, error) {
	response, err := client.Get(sourceURL)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status: %s", response.Status)
	}

	body, err := io.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func filenameForURL(rawURL string, nameCounts map[string]int) (string, error) {
	parsed, err := url.Parse(rawURL)
	if err != nil {
		return "", err
	}

	name := filepath.Base(parsed.Path)
	if name == "." || name == "/" || name == "" {
		return "", fmt.Errorf("invalid filename")
	}

	clean := strings.TrimSpace(name)
	if clean == "" {
		return "", fmt.Errorf("empty filename")
	}

	count := nameCounts[clean]
	nameCounts[clean] = count + 1
	if count == 0 {
		return clean, nil
	}

	ext := filepath.Ext(clean)
	base := strings.TrimSuffix(clean, ext)
	return fmt.Sprintf("%s_%d%s", base, count, ext), nil
}

func ensureDownloaded(client *http.Client, imageURL, destination string) (os.FileInfo, string, error) {
	if info, err := os.Stat(destination); err == nil {
		hash, err := sha256ForFile(destination)
		return info, hash, err
	}

	tempPath := destination + ".tmp"
	file, err := os.Create(tempPath)
	if err != nil {
		return nil, "", err
	}
	defer file.Close()

	response, err := client.Get(imageURL)
	if err != nil {
		return nil, "", err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, "", fmt.Errorf("unexpected status: %s", response.Status)
	}

	hasher := sha256.New()
	writer := io.MultiWriter(file, hasher)
	if _, err := io.Copy(writer, response.Body); err != nil {
		return nil, "", err
	}

	if err := file.Sync(); err != nil {
		return nil, "", err
	}
	if err := file.Close(); err != nil {
		return nil, "", err
	}

	if err := os.Rename(tempPath, destination); err != nil {
		return nil, "", err
	}

	info, err := os.Stat(destination)
	if err != nil {
		return nil, "", err
	}

	return info, hex.EncodeToString(hasher.Sum(nil)), nil
}

func sha256ForFile(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hasher := sha256.New()
	if _, err := io.Copy(hasher, file); err != nil {
		return "", err
	}

	return hex.EncodeToString(hasher.Sum(nil)), nil
}

func writeManifest(path string, data manifest) error {
	payload, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(path, payload, 0o644)
}
