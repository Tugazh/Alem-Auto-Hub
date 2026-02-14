package catalog

import (
	"context"
	"database/sql"
	"encoding/json"
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

// Make methods

func (r *Repository) GetAllMakes(ctx context.Context) ([]*Make, error) {
	query := `
		SELECT id, name, cyrillic_name, numeric_id, country, year_from, year_to, 
		       popular, code, created_at, updated_at
		FROM makes
		ORDER BY name
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to query makes: %w", err)
	}
	defer rows.Close()

	var makes []*Make
	for rows.Next() {
		m := &Make{}
		err := rows.Scan(
			&m.ID, &m.Name, &m.CyrillicName, &m.NumericID, &m.Country,
			&m.YearFrom, &m.YearTo, &m.Popular, &m.Code, &m.CreatedAt, &m.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan make: %w", err)
		}
		makes = append(makes, m)
	}

	return makes, rows.Err()
}

func (r *Repository) GetMakeByID(ctx context.Context, id string) (*Make, error) {
	query := `
		SELECT id, name, cyrillic_name, numeric_id, country, year_from, year_to, 
		       popular, code, created_at, updated_at
		FROM makes
		WHERE id = $1
	`

	m := &Make{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&m.ID, &m.Name, &m.CyrillicName, &m.NumericID, &m.Country,
		&m.YearFrom, &m.YearTo, &m.Popular, &m.Code, &m.CreatedAt, &m.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get make: %w", err)
	}

	return m, nil
}

func (r *Repository) UpsertMake(ctx context.Context, m *Make) error {
	query := `
		INSERT INTO makes (id, name, cyrillic_name, numeric_id, country, year_from, year_to, popular, code)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			cyrillic_name = EXCLUDED.cyrillic_name,
			numeric_id = EXCLUDED.numeric_id,
			country = EXCLUDED.country,
			year_from = EXCLUDED.year_from,
			year_to = EXCLUDED.year_to,
			popular = EXCLUDED.popular,
			code = EXCLUDED.code,
			updated_at = NOW()
	`

	_, err := r.db.ExecContext(ctx, query,
		m.ID, m.Name, m.CyrillicName, m.NumericID, m.Country,
		m.YearFrom, m.YearTo, m.Popular, m.Code,
	)
	if err != nil {
		return fmt.Errorf("failed to upsert make: %w", err)
	}

	return nil
}

// Model methods

func (r *Repository) GetModelsByMakeID(ctx context.Context, makeID string) ([]*Model, error) {
	query := `
		SELECT id, make_id, name, cyrillic_name, year_from, year_to, class, code, created_at, updated_at
		FROM models
		WHERE make_id = $1
		ORDER BY name
	`

	rows, err := r.db.QueryContext(ctx, query, makeID)
	if err != nil {
		return nil, fmt.Errorf("failed to query models: %w", err)
	}
	defer rows.Close()

	var models []*Model
	for rows.Next() {
		m := &Model{}
		err := rows.Scan(
			&m.ID, &m.MakeID, &m.Name, &m.CyrillicName, &m.YearFrom,
			&m.YearTo, &m.Class, &m.Code, &m.CreatedAt, &m.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan model: %w", err)
		}
		models = append(models, m)
	}

	return models, rows.Err()
}

func (r *Repository) GetModelByID(ctx context.Context, id string) (*Model, error) {
	query := `
		SELECT id, make_id, name, cyrillic_name, year_from, year_to, class, code, created_at, updated_at
		FROM models
		WHERE id = $1
	`

	m := &Model{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&m.ID, &m.MakeID, &m.Name, &m.CyrillicName, &m.YearFrom,
		&m.YearTo, &m.Class, &m.Code, &m.CreatedAt, &m.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get model: %w", err)
	}

	return m, nil
}

func (r *Repository) UpsertModel(ctx context.Context, m *Model) error {
	query := `
		INSERT INTO models (id, make_id, name, cyrillic_name, year_from, year_to, class, code)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO UPDATE SET
			make_id = EXCLUDED.make_id,
			name = EXCLUDED.name,
			cyrillic_name = EXCLUDED.cyrillic_name,
			year_from = EXCLUDED.year_from,
			year_to = EXCLUDED.year_to,
			class = EXCLUDED.class,
			code = EXCLUDED.code,
			updated_at = NOW()
	`

	_, err := r.db.ExecContext(ctx, query,
		m.ID, m.MakeID, m.Name, m.CyrillicName, m.YearFrom, m.YearTo, m.Class, m.Code,
	)
	if err != nil {
		return fmt.Errorf("failed to upsert model: %w", err)
	}

	return nil
}

// Generation methods

func (r *Repository) CreateGeneration(ctx context.Context, g *Generation) error {
	query := `
		INSERT INTO generations (id, model_id, name, year_from, year_to)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err := r.db.ExecContext(ctx, query, g.ID, g.ModelID, g.Name, g.YearFrom, g.YearTo)
	if err != nil {
		return fmt.Errorf("failed to create generation: %w", err)
	}

	return nil
}

func (r *Repository) GetGenerationsByModelID(ctx context.Context, modelID string) ([]*Generation, error) {
	query := `
		SELECT id, model_id, name, year_from, year_to, created_at
		FROM generations
		WHERE model_id = $1
		ORDER BY year_from
	`

	rows, err := r.db.QueryContext(ctx, query, modelID)
	if err != nil {
		return nil, fmt.Errorf("failed to query generations: %w", err)
	}
	defer rows.Close()

	var generations []*Generation
	for rows.Next() {
		g := &Generation{}
		err := rows.Scan(&g.ID, &g.ModelID, &g.Name, &g.YearFrom, &g.YearTo, &g.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan generation: %w", err)
		}
		generations = append(generations, g)
	}

	return generations, rows.Err()
}

// VehiclePlatform methods

func (r *Repository) CreatePlatform(ctx context.Context, p *VehiclePlatform) error {
	query := `
		INSERT INTO vehicle_platforms (id, generation_id, name, body_type, engine_code, trim_level)
		VALUES ($1, $2, $3, $4, $5, $6)
	`

	_, err := r.db.ExecContext(ctx, query, p.ID, p.GenerationID, p.Name, p.BodyType, p.EngineCode, p.TrimLevel)
	if err != nil {
		return fmt.Errorf("failed to create platform: %w", err)
	}

	return nil
}

func (r *Repository) GetPlatformByID(ctx context.Context, id uuid.UUID) (*VehiclePlatform, error) {
	query := `
		SELECT id, generation_id, name, body_type, engine_code, trim_level, created_at
		FROM vehicle_platforms
		WHERE id = $1
	`

	p := &VehiclePlatform{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&p.ID, &p.GenerationID, &p.Name, &p.BodyType, &p.EngineCode, &p.TrimLevel, &p.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get platform: %w", err)
	}

	return p, nil
}

func (r *Repository) GetPlatformsByGenerationID(ctx context.Context, generationID uuid.UUID) ([]*VehiclePlatform, error) {
	query := `
		SELECT id, generation_id, name, body_type, engine_code, trim_level, created_at
		FROM vehicle_platforms
		WHERE generation_id = $1
		ORDER BY name
	`

	rows, err := r.db.QueryContext(ctx, query, generationID)
	if err != nil {
		return nil, fmt.Errorf("failed to query platforms: %w", err)
	}
	defer rows.Close()

	var platforms []*VehiclePlatform
	for rows.Next() {
		p := &VehiclePlatform{}
		err := rows.Scan(&p.ID, &p.GenerationID, &p.Name, &p.BodyType, &p.EngineCode, &p.TrimLevel, &p.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan platform: %w", err)
		}
		platforms = append(platforms, p)
	}

	return platforms, rows.Err()
}

// Component methods

func (r *Repository) CreateComponent(ctx context.Context, c *Component) error {
	var metadataJSON []byte
	if c.Metadata != nil {
		var err error
		metadataJSON, err = json.Marshal(c.Metadata)
		if err != nil {
			return fmt.Errorf("failed to marshal metadata: %w", err)
		}
	}

	query := `
		INSERT INTO components (id, vehicle_platform_id, parent_id, code, name, side, position, is_leaf, metadata)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	_, err := r.db.ExecContext(ctx, query,
		c.ID, c.VehiclePlatformID, c.ParentID, c.Code, c.Name, c.Side, c.Position, c.IsLeaf, metadataJSON,
	)
	if err != nil {
		return fmt.Errorf("failed to create component: %w", err)
	}

	return nil
}

func (r *Repository) GetComponentByID(ctx context.Context, id uuid.UUID) (*Component, error) {
	query := `
		SELECT id, vehicle_platform_id, parent_id, code, name, side, position, is_leaf, metadata, created_at
		FROM components
		WHERE id = $1
	`

	c := &Component{}
	var metadataJSON []byte
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&c.ID, &c.VehiclePlatformID, &c.ParentID, &c.Code, &c.Name,
		&c.Side, &c.Position, &c.IsLeaf, &metadataJSON, &c.CreatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get component: %w", err)
	}

	if len(metadataJSON) > 0 {
		if err := json.Unmarshal(metadataJSON, &c.Metadata); err != nil {
			return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
		}
	}

	return c, nil
}

// GetComponentTree получает дерево компонентов для платформы (рекурсивный CTE)
func (r *Repository) GetComponentTree(ctx context.Context, platformID uuid.UUID) ([]*Component, error) {
	query := `
		WITH RECURSIVE component_tree AS (
			-- Базовый случай: корневые компоненты (без parent_id)
			SELECT id, vehicle_platform_id, parent_id, code, name, side, position, is_leaf, metadata, created_at, 0 as level
			FROM components
			WHERE vehicle_platform_id = $1 AND parent_id IS NULL
			
			UNION ALL
			
			-- Рекурсивный случай: дочерние компоненты
			SELECT c.id, c.vehicle_platform_id, c.parent_id, c.code, c.name, c.side, c.position, c.is_leaf, c.metadata, c.created_at, ct.level + 1
			FROM components c
			INNER JOIN component_tree ct ON c.parent_id = ct.id
			WHERE c.vehicle_platform_id = $1
		)
		SELECT id, vehicle_platform_id, parent_id, code, name, side, position, is_leaf, metadata, created_at
		FROM component_tree
		ORDER BY level, code
	`

	rows, err := r.db.QueryContext(ctx, query, platformID)
	if err != nil {
		return nil, fmt.Errorf("failed to query component tree: %w", err)
	}
	defer rows.Close()

	var components []*Component
	componentMap := make(map[uuid.UUID]*Component)

	for rows.Next() {
		c := &Component{}
		var metadataJSON []byte
		err := rows.Scan(
			&c.ID, &c.VehiclePlatformID, &c.ParentID, &c.Code, &c.Name,
			&c.Side, &c.Position, &c.IsLeaf, &metadataJSON, &c.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan component: %w", err)
		}

		if len(metadataJSON) > 0 {
			if err := json.Unmarshal(metadataJSON, &c.Metadata); err != nil {
				return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
			}
		}

		componentMap[c.ID] = c
		components = append(components, c)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Построение дерева
	var roots []*Component
	for _, c := range components {
		if c.ParentID == nil {
			roots = append(roots, c)
		} else {
			parent, ok := componentMap[*c.ParentID]
			if ok {
				if parent.Children == nil {
					parent.Children = []*Component{}
				}
				parent.Children = append(parent.Children, c)
			}
		}
	}

	return roots, nil
}

func (r *Repository) GetComponentsByPlatformID(ctx context.Context, platformID uuid.UUID) ([]*Component, error) {
	query := `
		SELECT id, vehicle_platform_id, parent_id, code, name, side, position, is_leaf, metadata, created_at
		FROM components
		WHERE vehicle_platform_id = $1
		ORDER BY code
	`

	rows, err := r.db.QueryContext(ctx, query, platformID)
	if err != nil {
		return nil, fmt.Errorf("failed to query components: %w", err)
	}
	defer rows.Close()

	var components []*Component
	for rows.Next() {
		c := &Component{}
		var metadataJSON []byte
		err := rows.Scan(
			&c.ID, &c.VehiclePlatformID, &c.ParentID, &c.Code, &c.Name,
			&c.Side, &c.Position, &c.IsLeaf, &metadataJSON, &c.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan component: %w", err)
		}

		if len(metadataJSON) > 0 {
			if err := json.Unmarshal(metadataJSON, &c.Metadata); err != nil {
				return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
			}
		}

		components = append(components, c)
	}

	return components, rows.Err()
}
