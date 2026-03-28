package handlers

import "github.com/gin-gonic/gin"

type MapHandler struct{}

func NewMapHandler() *MapHandler {
	return &MapHandler{}
}

func (h *MapHandler) ListServices(c *gin.Context) {
	c.JSON(200, []gin.H{
		{
			"id":     "sto-001",
			"name":   "СТО Alem Auto",
			"lat":    43.238949,
			"lng":    76.889709,
			"rating": 4.8,
		},
		{
			"id":     "sto-002",
			"name":   "Detailing Pro",
			"lat":    51.160523,
			"lng":    71.470356,
			"rating": 4.6,
		},
	})
}
