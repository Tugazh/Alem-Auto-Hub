package handlers

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type SocialHandler struct {
	mu       sync.Mutex
	posts    map[string]SocialPost
	comments map[string][]SocialComment
	order    []string
}

type SocialAuthor struct {
	ID        string  `json:"id"`
	Name      string  `json:"name"`
	AvatarURL *string `json:"avatarUrl,omitempty"`
	Username  *string `json:"username,omitempty"`
}

type SocialPost struct {
	ID           string       `json:"id"`
	UserID       string       `json:"userId"`
	Content      string       `json:"content"`
	Author       SocialAuthor `json:"author"`
	MediaURLs    []string     `json:"mediaUrls"`
	Tags         []string     `json:"tags"`
	LikeCount    int          `json:"likeCount"`
	CommentCount int          `json:"commentCount"`
	ShareCount   int          `json:"shareCount"`
	IsLiked      bool         `json:"isLiked"`
	CreatedAt    time.Time    `json:"createdAt"`
	UpdatedAt    *time.Time   `json:"updatedAt,omitempty"`
}

type SocialComment struct {
	ID        string       `json:"id"`
	PostID    string       `json:"postId"`
	UserID    string       `json:"userId"`
	Content   string       `json:"content"`
	Author    SocialAuthor `json:"author"`
	LikeCount int          `json:"likeCount"`
	CreatedAt time.Time    `json:"createdAt"`
}

type SocialCreateRequest struct {
	Content   string   `json:"content" binding:"required"`
	MediaURLs []string `json:"media_urls"`
	Tags      []string `json:"tags"`
}

type SocialCommentRequest struct {
	Content string `json:"content" binding:"required"`
}

func NewSocialHandler() *SocialHandler {
	avatar1 := "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200"
	avatar2 := "https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200"
	username1 := "evgen_m"
	username2 := "alina_drive"

	author1 := SocialAuthor{
		ID:        "user-001",
		Name:      "Евгений Морозов",
		AvatarURL: &avatar1,
		Username:  &username1,
	}
	author2 := SocialAuthor{
		ID:        "user-002",
		Name:      "Алина Нурбек",
		AvatarURL: &avatar2,
		Username:  &username2,
	}

	posts := []SocialPost{
		{
			ID:           "post-001",
			UserID:       author1.ID,
			Content:      "Новый сет шин для зимы — ощущается как новый автомобиль! Кто что посоветует по уходу?",
			Author:       author1,
			MediaURLs:    []string{"https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800"},
			Tags:         []string{"wheels", "winter"},
			LikeCount:    128,
			CommentCount: 2,
			ShareCount:   6,
			IsLiked:      false,
			CreatedAt:    time.Now().Add(-4 * time.Hour),
		},
		{
			ID:           "post-002",
			UserID:       author2.ID,
			Content:      "Проверила подвеску перед поездкой — все ок. Делюсь чек-листом в комментариях!",
			Author:       author2,
			MediaURLs:    []string{"https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800"},
			Tags:         []string{"service", "roadtrip"},
			LikeCount:    89,
			CommentCount: 1,
			ShareCount:   4,
			IsLiked:      true,
			CreatedAt:    time.Now().Add(-26 * time.Hour),
		},
	}

	items := make(map[string]SocialPost)
	order := make([]string, 0, len(posts))
	for _, post := range posts {
		items[post.ID] = post
		order = append(order, post.ID)
	}

	comments := map[string][]SocialComment{
		"post-001": {
			{
				ID:        uuid.NewString(),
				PostID:    "post-001",
				UserID:    author2.ID,
				Content:   "Отлично смотрится! Попробуй еще проверить давление раз в неделю.",
				Author:    author2,
				LikeCount: 3,
				CreatedAt: time.Now().Add(-2 * time.Hour),
			},
		},
		"post-002": {
			{
				ID:        uuid.NewString(),
				PostID:    "post-002",
				UserID:    author1.ID,
				Content:   "Ждем чек-лист! Это супер полезно.",
				Author:    author1,
				LikeCount: 1,
				CreatedAt: time.Now().Add(-20 * time.Hour),
			},
		},
	}

	return &SocialHandler{posts: items, comments: comments, order: order}
}

func (h *SocialHandler) ListPosts(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	result := make([]SocialPost, 0, len(h.order))
	for _, id := range h.order {
		if item, ok := h.posts[id]; ok {
			result = append(result, item)
		}
	}

	c.JSON(http.StatusOK, result)
}

func (h *SocialHandler) GetPost(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.posts[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func (h *SocialHandler) CreatePost(c *gin.Context) {
	var req SocialCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	author := SocialAuthor{ID: "user-001", Name: "Евгений Морозов"}
	post := SocialPost{
		ID:           uuid.NewString(),
		UserID:       author.ID,
		Content:      req.Content,
		Author:       author,
		MediaURLs:    req.MediaURLs,
		Tags:         req.Tags,
		LikeCount:    0,
		CommentCount: 0,
		ShareCount:   0,
		IsLiked:      false,
		CreatedAt:    time.Now(),
	}

	h.posts[post.ID] = post
	h.order = append([]string{post.ID}, h.order...)

	c.JSON(http.StatusCreated, post)
}

func (h *SocialHandler) LikePost(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	id := c.Param("id")
	item, ok := h.posts[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		return
	}

	if item.IsLiked {
		item.IsLiked = false
		if item.LikeCount > 0 {
			item.LikeCount--
		}
	} else {
		item.IsLiked = true
		item.LikeCount++
	}
	updated := time.Now()
	item.UpdatedAt = &updated
	h.posts[id] = item

	c.JSON(http.StatusOK, item)
}

func (h *SocialHandler) AddComment(c *gin.Context) {
	var req SocialCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.mu.Lock()
	defer h.mu.Unlock()

	postID := c.Param("id")
	post, ok := h.posts[postID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		return
	}

	author := SocialAuthor{ID: "user-002", Name: "Алина Нурбек"}
	comment := SocialComment{
		ID:        uuid.NewString(),
		PostID:    postID,
		UserID:    author.ID,
		Content:   req.Content,
		Author:    author,
		LikeCount: 0,
		CreatedAt: time.Now(),
	}

	h.comments[postID] = append([]SocialComment{comment}, h.comments[postID]...)
	post.CommentCount = post.CommentCount + 1
	updated := time.Now()
	post.UpdatedAt = &updated
	h.posts[postID] = post

	c.JSON(http.StatusCreated, comment)
}

func (h *SocialHandler) ListComments(c *gin.Context) {
	h.mu.Lock()
	defer h.mu.Unlock()

	postID := c.Param("id")
	comments := h.comments[postID]
	if comments == nil {
		comments = []SocialComment{}
	}

	c.JSON(http.StatusOK, comments)
}

func (h *SocialHandler) UploadMedia(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"url": "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800"})
}
