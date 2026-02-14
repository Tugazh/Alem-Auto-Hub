package media

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"alem-auto/internal/database"
)

type Repository struct {
	db *database.DB
}

func NewRepository(db *database.DB) *Repository {
	return &Repository{db: db}
}

// Asset methods

func (r *Repository) CreateAsset(ctx context.Context, a *Asset) error {
	query := `
		INSERT INTO assets (id, storage_provider, bucket, object_key, content_type, size_bytes, sha256, version, owner_scope)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	_, err := r.db.ExecContext(ctx, query,
		a.ID, a.StorageProvider, a.Bucket, a.ObjectKey, a.ContentType,
		a.SizeBytes, a.SHA256, a.Version, a.OwnerScope,
	)
	if err != nil {
		return fmt.Errorf("failed to create asset: %w", err)
	}

	return nil
}

func (r *Repository) GetAssetByID(ctx context.Context, id uuid.UUID) (*Asset, error) {
	query := `
		SELECT id, storage_provider, bucket, object_key, content_type, size_bytes, sha256, version, owner_scope, created_at
		FROM assets
		WHERE id = $1
	`

	a := &Asset{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&a.ID, &a.StorageProvider, &a.Bucket, &a.ObjectKey, &a.ContentType,
		&a.SizeBytes, &a.SHA256, &a.Version, &a.OwnerScope, &a.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get asset: %w", err)
	}

	return a, nil
}

func (r *Repository) GetAssetBySHA256(ctx context.Context, sha256 string) (*Asset, error) {
	query := `
		SELECT id, storage_provider, bucket, object_key, content_type, size_bytes, sha256, version, owner_scope, created_at
		FROM assets
		WHERE sha256 = $1
		ORDER BY created_at DESC
		LIMIT 1
	`

	a := &Asset{}
	err := r.db.QueryRowContext(ctx, query, sha256).Scan(
		&a.ID, &a.StorageProvider, &a.Bucket, &a.ObjectKey, &a.ContentType,
		&a.SizeBytes, &a.SHA256, &a.Version, &a.OwnerScope, &a.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get asset by sha256: %w", err)
	}

	return a, nil
}

func (r *Repository) UpdateAsset(ctx context.Context, a *Asset) error {
	query := `
		UPDATE assets
		SET content_type = $2, size_bytes = $3, sha256 = $4, version = $5
		WHERE id = $1
	`

	result, err := r.db.ExecContext(ctx, query,
		a.ID, a.ContentType, a.SizeBytes, a.SHA256, a.Version,
	)
	if err != nil {
		return fmt.Errorf("failed to update asset: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("asset not found")
	}

	return nil
}

// AssetLink methods

func (r *Repository) CreateAssetLink(ctx context.Context, al *AssetLink) error {
	query := `
		INSERT INTO asset_links (id, asset_id, link_type, link_id)
		VALUES ($1, $2, $3, $4)
	`

	_, err := r.db.ExecContext(ctx, query, al.ID, al.AssetID, al.LinkType, al.LinkID)
	if err != nil {
		return fmt.Errorf("failed to create asset link: %w", err)
	}

	return nil
}

func (r *Repository) GetAssetLinksByAssetID(ctx context.Context, assetID uuid.UUID) ([]*AssetLink, error) {
	query := `
		SELECT id, asset_id, link_type, link_id, created_at
		FROM asset_links
		WHERE asset_id = $1
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(ctx, query, assetID)
	if err != nil {
		return nil, fmt.Errorf("failed to query asset links: %w", err)
	}
	defer rows.Close()

	var links []*AssetLink
	for rows.Next() {
		al := &AssetLink{}
		err := rows.Scan(&al.ID, &al.AssetID, &al.LinkType, &al.LinkID, &al.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan asset link: %w", err)
		}
		links = append(links, al)
	}

	return links, rows.Err()
}

func (r *Repository) GetAssetLinksByLink(ctx context.Context, linkType string, linkID uuid.UUID) ([]*AssetLink, error) {
	query := `
		SELECT id, asset_id, link_type, link_id, created_at
		FROM asset_links
		WHERE link_type = $1 AND link_id = $2
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(ctx, query, linkType, linkID)
	if err != nil {
		return nil, fmt.Errorf("failed to query asset links: %w", err)
	}
	defer rows.Close()

	var links []*AssetLink
	for rows.Next() {
		al := &AssetLink{}
		err := rows.Scan(&al.ID, &al.AssetID, &al.LinkType, &al.LinkID, &al.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan asset link: %w", err)
		}
		links = append(links, al)
	}

	return links, rows.Err()
}

func (r *Repository) DeleteAssetLink(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM asset_links WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete asset link: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("asset link not found")
	}

	return nil
}
