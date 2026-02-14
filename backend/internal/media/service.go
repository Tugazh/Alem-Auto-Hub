package media

import (
	"context"
	"crypto/sha256"
	"fmt"
	"path/filepath"
	"time"

	"github.com/google/uuid"
	"alem-auto/config"
)

type Service struct {
	repo     *Repository
	s3Client *S3Client
	cfg      config.S3Config
}

func NewService(repo *Repository, s3Client *S3Client, cfg config.S3Config) *Service {
	return &Service{
		repo:     repo,
		s3Client: s3Client,
		cfg:      cfg,
	}
}

// PrepareUpload подготавливает загрузку файла и возвращает pre-signed URL
func (s *Service) PrepareUpload(ctx context.Context, req *UploadRequest) (*UploadResponse, error) {
	// Валидация owner_scope
	validScopes := map[string]bool{
		"catalog":    true,
		"vehicle":    true,
		"inspection": true,
	}
	if !validScopes[req.OwnerScope] {
		return nil, fmt.Errorf("invalid owner_scope: %s", req.OwnerScope)
	}

	// Генерируем уникальный ключ для объекта
	assetID := uuid.New()
	ext := filepath.Ext(req.FileName)
	objectKey := fmt.Sprintf("%s/%s/%s%s", req.OwnerScope, assetID.String(), assetID.String(), ext)

	// Создаем запись об ассете в БД
	asset := &Asset{
		ID:             assetID,
		StorageProvider: "s3",
		Bucket:         s.cfg.Bucket,
		ObjectKey:      objectKey,
		ContentType:    &req.ContentType,
		SizeBytes:      &req.SizeBytes,
		Version:        1,
		OwnerScope:     req.OwnerScope,
	}

	err := s.repo.CreateAsset(ctx, asset)
	if err != nil {
		return nil, fmt.Errorf("failed to create asset: %w", err)
	}

	// Генерируем pre-signed URL для загрузки
	expiresIn := 15 * time.Minute
	uploadURL, err := s.s3Client.GeneratePresignedUploadURL(ctx, objectKey, req.ContentType, expiresIn)
	if err != nil {
		return nil, fmt.Errorf("failed to generate upload URL: %w", err)
	}

	return &UploadResponse{
		AssetID:   assetID,
		UploadURL: uploadURL,
		ExpiresIn: int(expiresIn.Seconds()),
	}, nil
}

// ConfirmUpload подтверждает успешную загрузку и обновляет метаданные
func (s *Service) ConfirmUpload(ctx context.Context, assetID uuid.UUID, sha256Hash string) error {
	asset, err := s.repo.GetAssetByID(ctx, assetID)
	if err != nil {
		return fmt.Errorf("failed to get asset: %w", err)
	}
	if asset == nil {
		return fmt.Errorf("asset not found")
	}

	// Получаем метаданные из S3
	metadata, err := s.s3Client.GetObjectMetadata(context.Background(), asset.ObjectKey)
	if err != nil {
		return fmt.Errorf("failed to get object metadata: %w", err)
	}

	// Обновляем ассет с реальными данными
	sizeBytes := int64(*metadata.ContentLength)
	asset.SizeBytes = &sizeBytes
	asset.SHA256 = &sha256Hash

	// Проверяем, нет ли уже файла с таким SHA256 (дедупликация)
	existing, err := s.repo.GetAssetBySHA256(ctx, sha256Hash)
	if err == nil && existing != nil && existing.ID != assetID {
		// Файл уже существует, можно использовать существующий
		// TODO: удалить дубликат или пометить как ссылку
	}

	return s.repo.UpdateAsset(ctx, asset)
}

// GetDownloadURL возвращает pre-signed URL для скачивания файла
func (s *Service) GetDownloadURL(ctx context.Context, assetID uuid.UUID, expiresIn time.Duration) (*DownloadResponse, error) {
	asset, err := s.repo.GetAssetByID(ctx, assetID)
	if err != nil {
		return nil, fmt.Errorf("failed to get asset: %w", err)
	}
	if asset == nil {
		return nil, fmt.Errorf("asset not found")
	}

	downloadURL, err := s.s3Client.GeneratePresignedDownloadURL(ctx, asset.ObjectKey, expiresIn)
	if err != nil {
		return nil, fmt.Errorf("failed to generate download URL: %w", err)
	}

	return &DownloadResponse{
		DownloadURL: downloadURL,
		ExpiresIn:   int(expiresIn.Seconds()),
	}, nil
}

// GetAsset возвращает метаданные ассета
func (s *Service) GetAsset(ctx context.Context, assetID uuid.UUID) (*Asset, error) {
	return s.repo.GetAssetByID(ctx, assetID)
}

// LinkAsset связывает ассет с сущностью
func (s *Service) LinkAsset(ctx context.Context, assetID uuid.UUID, linkType string, linkID uuid.UUID) error {
	// Валидация link_type
	validLinkTypes := map[string]bool{
		"vehicle":              true,
		"inspection":           true,
		"component":            true,
		"component_observation": true,
	}
	if !validLinkTypes[linkType] {
		return fmt.Errorf("invalid link_type: %s", linkType)
	}

	// Проверяем существование ассета
	_, err := s.repo.GetAssetByID(ctx, assetID)
	if err != nil {
		return fmt.Errorf("asset not found: %w", err)
	}

	assetLink := &AssetLink{
		ID:       uuid.New(),
		AssetID:  assetID,
		LinkType: linkType,
		LinkID:   linkID,
	}

	return s.repo.CreateAssetLink(ctx, assetLink)
}

// GetAssetLinks возвращает все связи ассета
func (s *Service) GetAssetLinks(ctx context.Context, assetID uuid.UUID) ([]*AssetLink, error) {
	return s.repo.GetAssetLinksByAssetID(ctx, assetID)
}

// GetAssetsByLink возвращает все ассеты, связанные с сущностью
func (s *Service) GetAssetsByLink(ctx context.Context, linkType string, linkID uuid.UUID) ([]*Asset, error) {
	links, err := s.repo.GetAssetLinksByLink(ctx, linkType, linkID)
	if err != nil {
		return nil, fmt.Errorf("failed to get asset links: %w", err)
	}

	var assets []*Asset
	for _, link := range links {
		asset, err := s.repo.GetAssetByID(ctx, link.AssetID)
		if err != nil {
			continue // Пропускаем несуществующие ассеты
		}
		if asset != nil {
			assets = append(assets, asset)
		}
	}

	return assets, nil
}

// DeleteAsset удаляет ассет и его связи
func (s *Service) DeleteAsset(ctx context.Context, assetID uuid.UUID) error {
	asset, err := s.repo.GetAssetByID(ctx, assetID)
	if err != nil {
		return fmt.Errorf("failed to get asset: %w", err)
	}
	if asset == nil {
		return fmt.Errorf("asset not found")
	}

	// Удаляем объект из S3
	err = s.s3Client.DeleteObject(ctx, asset.ObjectKey)
	if err != nil {
		return fmt.Errorf("failed to delete object from S3: %w", err)
	}

	// Удаляем связи (опционально, можно оставить для истории)
	// TODO: удалить связи или пометить как удаленные

	return nil
}

// CalculateSHA256 вычисляет SHA256 хэш (для примера, обычно делается на клиенте)
func CalculateSHA256(data []byte) string {
	hash := sha256.Sum256(data)
	return fmt.Sprintf("%x", hash)
}
