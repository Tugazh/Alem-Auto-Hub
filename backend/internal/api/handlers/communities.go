package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CommunityHandler struct {
	mu      sync.Mutex
	items   map[string]CommunityItem
	order   []string
	members map[string][]CommunityMember
}

type CommunityItem struct {
	ID           string    `json:"id"`
	Name         string    `json:"name"`
	Description  string    `json:"description"`
	Emoji        string    `json:"emoji"`
	MembersCount int       `json:"membersCount"`
	IsJoined     bool      `json:"isJoined"`
	IsVerified   bool      `json:"isVerified"`
	CoverURL     *string   `json:"coverUrl,omitempty"`
	CreatedAt    time.Time `json:"createdAt"`
}

type CommunityMember struct {
	ID        string  `json:"id"`
	Name      string  `json:"name"`
	AvatarURL *string `json:"avatarUrl,omitempty"`
}

type CommunityCreateRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description" binding:"required"`
	Emoji       string `json:"emoji"`
}

type CommunityUpdateRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Emoji       string `json:"emoji"`
}

func NewCommunityHandler() *CommunityHandler {
	cover := "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200"
	items := []CommunityItem{
		{
			ID:           "community-001",
			Name:         "BMW Клуб Алматы",
			Description:  "Официальное сообщество владельцев BMW в Алматы.",
			Emoji:        "🚗",
			MembersCount: 79090,
			IsJoined:     true,
			IsVerified:   true,
			CoverURL:     &cover,
			CreatedAt:    time.Now().AddDate(0, -2, 0),
		},
		{
			ID:           "community-002",
			Name:         "Тюнинг & Стайлинг",
			Description:  "Обсуждаем доработки, дизайн, детейлинг.",
			Emoji:        "🎨",
			MembersCount: 52100,
			IsJoined:     false,
			IsVerified:   false,
			CreatedAt:    time.Now().AddDate(0, -3, 0),
		},
	}

	itemsMap := make(map[string]CommunityItem)
	order := make([]string, 0, len(items))
	for _, item := range items {
		itemsMap[item.ID] = item
		order = append(order, item.ID)
	}

	avatar := "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200"
	members := map[string][]CommunityMember{
		"community-001": {
			{ID: "user-001", Name: "Евгений Морозов", AvatarURL: &avatar},
			{ID: "user-002", Name: "Алина Нурбек", AvatarURL: &avatar},
		},
		"community-002": {
			{ID: "user-003", Name: "Айдар Кара", AvatarURL: &avatar},
		},
	}

	return &CommunityHandler{items: itemsMap, order: order, members: members}
}

func (h *CommunityHandler) List(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	filter := c.Query("filter")
	result := make([]CommunityItem, 0, len(h.order))
	for _, id := range h.order {
		item, ok := h.items[id]
		if !ok {
			continue
		}
		if filter == "mine" && !item.IsJoined {
			continue
		}
		result = append(result, item)
	}

	c.JSON(http.StatusOK, result)
}

func (h *CommunityHandler) Get(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "community not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *CommunityHandler) Create(c *gin.Context) {
	var req CommunityCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	item := CommunityItem{
		ID:           uuid.NewString(),
		Name:         req.Name,
		Description:  req.Description,
		Emoji:        req.Emoji,
		MembersCount: 1,
		IsJoined:     true,
		IsVerified:   false,
		CreatedAt:    time.Now(),
	}

	h.items[item.ID] = item
	h.order = append([]string{item.ID}, h.order...)

	c.JSON(http.StatusCreated, item)
}

func (h *CommunityHandler) Update(c *gin.Context) {
	var req CommunityUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	id := c.Param("id")
	h.mu.Lock()
	defer h.mu.Unlock()

	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "community not found"})
		return
	}

	if req.Name != "" {
		item.Name = req.Name
	}
	if req.Description != "" {
		item.Description = req.Description
	}
	if req.Emoji != "" {
		item.Emoji = req.Emoji
	}

	h.items[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *CommunityHandler) Join(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "community not found"})
		return
	}

	if !item.IsJoined {
		item.IsJoined = true
		item.MembersCount++
	}

	h.items[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *CommunityHandler) Leave(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.items[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "community not found"})
		return
	}

	if item.IsJoined {
		item.IsJoined = false
		if item.MembersCount > 0 {
			item.MembersCount--
		}
	}

	h.items[id] = item
	c.JSON(http.StatusOK, item)
}

func (h *CommunityHandler) Members(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	members := h.members[id]
	if members == nil {
		members = []CommunityMember{}
	}

	c.JSON(http.StatusOK, members)
}
