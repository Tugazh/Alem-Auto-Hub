package catalog

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"time"
)

// CarData представляет структуру данных из cars.json
type CarData struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	CyrillicName *string   `json:"cyrillic_name"`
	NumericID   *int64    `json:"numeric_id"`
	YearFrom    *int      `json:"year_from"`
	YearTo      *int      `json:"year_to"`
	Popular     int       `json:"popular"`
	Country     *string   `json:"country"`
	UpdatedAt   string    `json:"updated_at"`
	Models      []ModelData `json:"models"`
}

// ModelData представляет модель из cars.json
type ModelData struct {
	ID          string  `json:"id"`
	MarkID      string  `json:"mark_id"`
	Name        string  `json:"name"`
	CyrillicName *string `json:"cyrillic_name"`
	YearFrom    *int    `json:"year_from"`
	YearTo      *int    `json:"year_to"`
	Class       *string `json:"class"`
	UpdatedAt   string  `json:"updated_at"`
}

// Importer импортирует данные из cars.json
type Importer struct {
	service *Service
}

func NewImporter(service *Service) *Importer {
	return &Importer{service: service}
}

// ImportFromFile импортирует данные из JSON файла
func (i *Importer) ImportFromFile(ctx context.Context, filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file: %w", err)
	}
	defer file.Close()

	return i.ImportFromReader(ctx, file)
}

// ImportFromReader импортирует данные из io.Reader
func (i *Importer) ImportFromReader(ctx context.Context, reader io.Reader) error {
	decoder := json.NewDecoder(reader)

	// Читаем открывающую скобку массива
	_, err := decoder.Token()
	if err != nil {
		return fmt.Errorf("failed to read array start: %w", err)
	}

	var makesCount, modelsCount int
	var lastLogTime time.Time

	// Читаем элементы массива
	for decoder.More() {
		var carData CarData
		if err := decoder.Decode(&carData); err != nil {
			return fmt.Errorf("failed to decode car data: %w", err)
		}

		// Импортируем марку
		make := &Make{
			ID:          carData.ID,
			Name:        carData.Name,
			CyrillicName: carData.CyrillicName,
			NumericID:   carData.NumericID,
			Country:     carData.Country,
			YearFrom:    carData.YearFrom,
			YearTo:      carData.YearTo,
			Popular:     carData.Popular != 0,
		}

		err := i.service.UpsertMake(ctx, make)
		if err != nil {
			return fmt.Errorf("failed to upsert make %s: %w", carData.ID, err)
		}
		makesCount++

		// Импортируем модели
		for _, modelData := range carData.Models {
			model := &Model{
				ID:          modelData.ID,
				MakeID:      modelData.MarkID,
				Name:        modelData.Name,
				CyrillicName: modelData.CyrillicName,
				YearFrom:    modelData.YearFrom,
				YearTo:      modelData.YearTo,
				Class:       modelData.Class,
			}

			err := i.service.UpsertModel(ctx, model)
			if err != nil {
				return fmt.Errorf("failed to upsert model %s: %w", modelData.ID, err)
			}
			modelsCount++
		}

		// Логируем прогресс каждые 5 секунд
		if time.Since(lastLogTime) > 5*time.Second {
			fmt.Printf("Imported %d makes, %d models...\n", makesCount, modelsCount)
			lastLogTime = time.Now()
		}
	}

	// Читаем закрывающую скобку массива
	_, err = decoder.Token()
	if err != nil {
		return fmt.Errorf("failed to read array end: %w", err)
	}

	fmt.Printf("Import completed: %d makes, %d models\n", makesCount, modelsCount)
	return nil
}
