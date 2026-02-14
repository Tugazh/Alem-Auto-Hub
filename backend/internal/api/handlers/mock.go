package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"sync"

	"github.com/gin-gonic/gin"
)

type MockCarModel struct {
	ID           string  `json:"id"`
	MarkID       string  `json:"mark_id"`
	Name         string  `json:"name"`
	CyrillicName *string `json:"cyrillic_name,omitempty"`
	YearFrom     *int    `json:"year_from,omitempty"`
	YearTo       *int    `json:"year_to,omitempty"`
	Class        *string `json:"class,omitempty"`
	UpdatedAt    *string `json:"updated_at,omitempty"`
}

type MockCarMake struct {
	ID           string         `json:"id"`
	Name         string         `json:"name"`
	CyrillicName *string        `json:"cyrillic_name,omitempty"`
	NumericID    *int64         `json:"numeric_id,omitempty"`
	YearFrom     *int           `json:"year_from,omitempty"`
	YearTo       *int           `json:"year_to,omitempty"`
	Popular      *int           `json:"popular,omitempty"`
	Country      *string        `json:"country,omitempty"`
	UpdatedAt    *string        `json:"updated_at,omitempty"`
	Models       []MockCarModel `json:"models,omitempty"`
}

type MockCarsResponse struct {
	Total  int           `json:"total"`
	Offset int           `json:"offset"`
	Limit  int           `json:"limit"`
	Items  []MockCarMake `json:"items"`
}

type MockHandler struct {
	carsPath string
	mu       sync.RWMutex
	cars     []MockCarMake
	loaded   bool
	loadErr  error
}

func NewMockHandler(carsPath string) *MockHandler {
	return &MockHandler{carsPath: carsPath}
}

// GetCars returns mock car makes/models from a JSON file.
// Query params: limit, offset
func (h *MockHandler) GetCars(c *gin.Context) {
	cars, err := h.loadCars()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	offset := parseIntQuery(c, "offset", 0)
	limit := parseIntQuery(c, "limit", 0)

	if offset < 0 {
		offset = 0
	}
	if offset > len(cars) {
		offset = len(cars)
	}

	items := cars[offset:]
	if limit > 0 {
		end := offset + limit
		if end > len(cars) {
			end = len(cars)
		}
		items = cars[offset:end]
	}

	appliedLimit := limit
	if appliedLimit == 0 {
		appliedLimit = len(items)
	}

	c.JSON(http.StatusOK, MockCarsResponse{
		Total:  len(cars),
		Offset: offset,
		Limit:  appliedLimit,
		Items:  items,
	})
}

func (h *MockHandler) loadCars() ([]MockCarMake, error) {
	h.mu.RLock()
	if h.loaded {
		defer h.mu.RUnlock()
		return h.cars, h.loadErr
	}
	h.mu.RUnlock()

	h.mu.Lock()
	defer h.mu.Unlock()
	if h.loaded {
		return h.cars, h.loadErr
	}

	data, err := os.ReadFile(h.carsPath)
	if err != nil {
		h.loadErr = err
		h.loaded = true
		return nil, err
	}

	var cars []MockCarMake
	if err := json.Unmarshal(data, &cars); err != nil {
		h.loadErr = err
		h.loaded = true
		return nil, err
	}

	h.cars = cars
	h.loaded = true
	return cars, nil
}

func parseIntQuery(c *gin.Context, key string, fallback int) int {
	value := c.Query(key)
	if value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}
