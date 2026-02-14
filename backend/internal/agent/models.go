package agent

import (
	"time"

	"github.com/google/uuid"
)

type Category string

const (
	CategoryFuel    Category = "fuel"
	CategoryService Category = "service"
	CategoryParts   Category = "parts"
	CategoryFine    Category = "fine"
)

type AgentRequest struct {
	UserID  string     `json:"user_id" binding:"required"`
	Message string     `json:"message" binding:"required"`
	History []ChatTurn `json:"history,omitempty"`
}

type AgentResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type ChatTurn struct {
	Role    string `json:"role"`
	Message string `json:"message"`
}

type ReceiptItem struct {
	Name     string  `json:"name"`
	Quantity int     `json:"quantity"`
	Price    float64 `json:"price"`
}

type ReceiptData struct {
	Date   string        `json:"date"`
	Vendor string        `json:"vendor"`
	Items  []ReceiptItem `json:"items"`
	Total  float64       `json:"total"`
}

// ServiceRecord stores car expense entries.
type ServiceRecord struct {
	ID          uuid.UUID `json:"id" gorm:"type:uuid;primaryKey"`
	UserID      uuid.UUID `json:"user_id" gorm:"type:uuid;index"`
	Date        string    `json:"date"`
	Category    Category  `json:"category" gorm:"type:varchar(16)"`
	Amount      float64   `json:"amount"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
}

func (ServiceRecord) TableName() string {
	return "service_records"
}
