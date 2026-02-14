package media

import (
	"time"

	"github.com/google/uuid"
)

// Asset представляет метаданные файла
type Asset struct {
	ID             uuid.UUID `json:"id"`
	StorageProvider string    `json:"storage_provider"` // s3, r2, gcs, minio
	Bucket         string    `json:"bucket"`
	ObjectKey      string    `json:"object_key"`
	ContentType    *string   `json:"content_type,omitempty"`
	SizeBytes      *int64    `json:"size_bytes,omitempty"`
	SHA256         *string   `json:"sha256,omitempty"`
	Version        int       `json:"version"`
	OwnerScope     string    `json:"owner_scope"` // catalog, vehicle, inspection
	CreatedAt      time.Time `json:"created_at"`
}

// AssetLink представляет связь медиа с сущностью
type AssetLink struct {
	ID       uuid.UUID `json:"id"`
	AssetID  uuid.UUID `json:"asset_id"`
	LinkType string    `json:"link_type"` // vehicle, inspection, component, component_observation
	LinkID   uuid.UUID `json:"link_id"`
	CreatedAt time.Time `json:"created_at"`
}

// UploadRequest представляет запрос на загрузку файла
type UploadRequest struct {
	ContentType string    `json:"content_type"`
	SizeBytes   int64     `json:"size_bytes"`
	OwnerScope  string    `json:"owner_scope"`
	FileName    string    `json:"file_name"`
}

// UploadResponse представляет ответ с pre-signed URL для загрузки
type UploadResponse struct {
	AssetID      uuid.UUID `json:"asset_id"`
	UploadURL    string    `json:"upload_url"`
	ExpiresIn    int       `json:"expires_in"` // секунды
}

// DownloadResponse представляет ответ с pre-signed URL для скачивания
type DownloadResponse struct {
	DownloadURL string    `json:"download_url"`
	ExpiresIn   int       `json:"expires_in"` // секунды
}
