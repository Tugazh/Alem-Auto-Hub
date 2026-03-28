package handlers

import (
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type SearchHandler struct{}

type SearchPerson struct {
	ID        string  `json:"id"`
	Name      string  `json:"name"`
	Username  string  `json:"username"`
	AvatarURL *string `json:"avatarUrl,omitempty"`
}

type SearchCommunity struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Members     int    `json:"membersCount"`
	Emoji       string `json:"emoji"`
}

type SearchPost struct {
	ID        string    `json:"id"`
	Title     string    `json:"title"`
	Snippet   string    `json:"snippet"`
	CreatedAt time.Time `json:"createdAt"`
}

func NewSearchHandler() *SearchHandler {
	return &SearchHandler{}
}

func (h *SearchHandler) Search(c *gin.Context) {
	query := strings.TrimSpace(c.Query("q"))
	avatar := "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200"

	people := []SearchPerson{
		{ID: "user-001", Name: "Евгений Морозов", Username: "evgen_m", AvatarURL: &avatar},
		{ID: "user-002", Name: "Алина Нурбек", Username: "alina_drive", AvatarURL: &avatar},
	}

	communities := []SearchCommunity{
		{ID: "community-001", Name: "BMW Клуб Алматы", Description: "Владельцы BMW", Members: 79090, Emoji: "🚗"},
		{ID: "community-002", Name: "Тюнинг & Стайлинг", Description: "Доработки и дизайн", Members: 52100, Emoji: "🎨"},
	}

	posts := []SearchPost{
		{ID: "post-001", Title: "Новый сет шин", Snippet: "Ощущается как новый автомобиль...", CreatedAt: time.Now().Add(-4 * time.Hour)},
		{ID: "post-002", Title: "Чек-лист перед поездкой", Snippet: "Поделилась списком проверок...", CreatedAt: time.Now().Add(-26 * time.Hour)},
	}

	if query != "" {
		filteredPeople := make([]SearchPerson, 0)
		for _, person := range people {
			if strings.Contains(strings.ToLower(person.Name), strings.ToLower(query)) ||
				strings.Contains(strings.ToLower(person.Username), strings.ToLower(query)) {
				filteredPeople = append(filteredPeople, person)
			}
		}
		people = filteredPeople
	}

	c.JSON(http.StatusOK, gin.H{
		"query":       query,
		"people":      people,
		"communities": communities,
		"posts":       posts,
	})
}
