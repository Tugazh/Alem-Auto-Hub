package servicebook

import (
	"alem-auto/internal/agent"
	"alem-auto/internal/inspection"
	"alem-auto/internal/vehicle"
)

// ServiceBookResponse is the aggregated service book for a vehicle.
type ServiceBookResponse struct {
	Vehicle        *vehicle.Vehicle       `json:"vehicle"`
	Inspections    []*inspection.Inspection `json:"inspections"`
	ServiceRecords []agent.ServiceRecord  `json:"service_records"`
}
