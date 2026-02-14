---
name: Vehicle Passport System Architecture
overview: Создание архитектуры цифрового паспорта автомобиля с историей осмотров, иерархией деталей, 3D-моделями и медиа. Модульный монолит на Go с PostgreSQL и AWS S3.
todos:
  - id: setup-project
    content: "Инициализировать Go проект: создать структуру директорий, go.mod, базовые конфигурационные файлы"
    status: completed
  - id: database-schema
    content: "Создать SQL миграции для всех таблиц: makes, models, generations, vehicle_platforms, components, vehicles, inspections, component_observations, assets, asset_links, users, service_centers"
    status: completed
    dependencies:
      - setup-project
  - id: database-connection
    content: Настроить подключение к PostgreSQL, создать connection pool и базовые репозитории
    status: completed
    dependencies:
      - database-schema
  - id: catalog-service
    content: "Реализовать Catalog Service: CRUD для марок/моделей/поколений, иерархия компонентов с рекурсивными запросами"
    status: completed
    dependencies:
      - database-connection
  - id: vehicle-service
    content: "Реализовать Vehicle Service: создание/получение авто, связь с платформами, текущее состояние компонентов"
    status: completed
    dependencies:
      - database-connection
      - catalog-service
  - id: inspection-service
    content: "Реализовать Inspection Service: создание осмотров, добавление наблюдений по деталям, история визитов"
    status: completed
    dependencies:
      - database-connection
      - vehicle-service
  - id: media-service
    content: "Реализовать Media Service: интеграция с AWS S3, загрузка файлов, pre-signed URLs, метаданные в БД"
    status: completed
    dependencies:
      - database-connection
  - id: asset-linking
    content: "Реализовать систему связывания медиа (asset_links): привязка фото/3D к авто, осмотрам, компонентам"
    status: completed
    dependencies:
      - media-service
      - inspection-service
  - id: auth-rbac
    content: "Реализовать аутентификацию и RBAC: JWT токены, middleware для проверки прав доступа (владелец/мастер/центр/платформа)"
    status: completed
    dependencies:
      - database-connection
  - id: api-handlers
    content: "Создать HTTP handlers и роутинг для всех сервисов: catalog, vehicle, inspection, media endpoints"
    status: completed
    dependencies:
      - catalog-service
      - vehicle-service
      - inspection-service
      - media-service
      - auth-rbac
  - id: catalog-importer
    content: "Создать импортер данных из cars.json: парсинг JSON, загрузка марок и моделей в БД с сохранением всех полей (cyrillic_name, country, class, popular, numeric_id)"
    status: completed
    dependencies:
      - catalog-service
      - database-connection
  - id: seed-data
    content: "Создать seed данные: 3-5 популярных моделей с иерархией компонентов (50-200 компонентов на модель)"
    status: completed
    dependencies:
      - catalog-service
      - catalog-importer
  - id: config-management
    content: "Настроить управление конфигурацией: env vars, конфиг для БД, S3, сервера, JWT секреты"
    status: completed
    dependencies:
      - setup-project
---

# Архитектура системы цифрового паспорта автомобиля

## Обзор архитектуры

Система состоит из 4 основных слоев данных:

1. **Каталог** — справочники марок/моделей/поколений и иерархия компонентов
2. **Экземпляры авто** — конкретные машины пользователей (VIN, госномер, пробег)
3. **Осмотры/визиты** — история посещений с замерами и состоянием деталей
4. **Медиа и 3D** — фото/видео/3D-модели, хранящиеся в S3

## Структура проекта

```
alem-auto/
├── cmd/
│   ├── server/
│   │   └── main.go              # Точка входа сервера
│   └── importer/
│       └── main.go              # Импортер данных из cars.json
├── internal/
│   ├── catalog/                 # Catalog Service
│   │   ├── service.go
│   │   ├── repository.go
│   │   ├── models.go
│   │   └── importer.go          # Импорт из cars.json
│   ├── vehicle/                 # Vehicle Service
│   │   ├── service.go
│   │   ├── repository.go
│   │   └── models.go
│   ├── inspection/              # Inspection Service
│   │   ├── service.go
│   │   ├── repository.go
│   │   └── models.go
│   ├── media/                   # Media/Asset Service
│   │   ├── service.go
│   │   ├── s3_client.go
│   │   └── models.go
│   ├── auth/                    # Authentication & Authorization
│   │   ├── middleware.go
│   │   └── rbac.go
│   ├── database/
│   │   ├── migrations/          # SQL миграции
│   │   └── connection.go
│   └── api/
│       ├── handlers/            # HTTP handlers
│       └── routes.go
├── pkg/
│   └── models/                  # Общие модели
├── migrations/                  # SQL миграции (альтернатива)
├── config/
│   └── config.go
├── go.mod
└── README.md
```

## Схема базы данных

### Основные таблицы

#### 1. Каталог (Catalog)

**`makes`** — марки

- `id` (используем из cars.json, например "ABARTH"), `name`, `cyrillic_name`, `numeric_id`, `country`, `year_from`, `year_to`, `popular` (boolean), `code`, `created_at`, `updated_at`

**`models`** — модели

- `id` (используем из cars.json, например "ABARTH_500"), `make_id`, `name`, `cyrillic_name`, `year_from`, `year_to`, `class` (A/B/C/S/etc), `code`, `created_at`, `updated_at`

**`generations`** — поколения

- `id`, `model_id`, `name`, `year_from`, `year_to`, `created_at`

**`vehicle_platforms`** — платформы/модификации

- `id`, `generation_id`, `name`, `body_type`, `engine_code`, `trim_level`, `created_at`

**`components`** — иерархия компонентов/деталей (дерево)

- `id`, `vehicle_platform_id` (nullable для общих компонентов)
- `parent_id` (nullable, ссылка на `components.id`)
- `code` (стабильный идентификатор, например `brakes.pad.front.left`)
- `name`, `side` (left/right/front/rear/none), `position` (front/rear/etc)
- `is_leaf` (boolean: деталь vs узел)
- `metadata` (jsonb для дополнительных полей)
- `created_at`

#### 2. Экземпляры авто (Vehicle Instance)

**`vehicles`** — конкретные машины

- `id`, `vin`, `license_plate`, `year`, `odometer_km`
- `vehicle_platform_id` (связь с каталогом)
- `engine_code`, `trim_level`
- `created_at`, `updated_at`

**`vehicle_owners`** — владельцы

- `id`, `vehicle_id`, `user_id`, `owned_from`, `owned_to` (nullable)
- `is_current` (boolean)

#### 3. Осмотры (Inspections)

**`service_centers`** — автобоксы/сервисы

- `id`, `name`, `address`, `created_at`

**`service_center_users`** — пользователи сервисов (мастера/админы)

- `id`, `service_center_id`, `user_id`, `role` (mechanic/admin)
- `created_at`

**`inspections`** — визиты/осмотры

- `id`, `vehicle_id`, `service_center_id`, `created_by_user_id`
- `odometer_km`, `notes`, `created_at`

**`component_observations`** — наблюдения по деталям

- `id`, `inspection_id`, `component_id`
- `status` (enum: ok/attention/replace/not_checked)
- `condition_grade` (integer 0-100 или text A/B/C/D)
- `comment`, `measured_values` (jsonb: толщина колодки, остаток протектора, люфт, давление)
- `created_at`

**`vehicle_component_state`** — материализованное текущее состояние (опционально, для быстрых запросов)

- `vehicle_id`, `component_id`, `last_inspection_id`
- `status`, `condition_grade`, `last_updated_at`

#### 4. Медиа и 3D (Media/Assets)

**`assets`** — метаданные файлов

- `id`, `storage_provider` (s3/r2/gcs/minio)
- `bucket`, `object_key`, `content_type`
- `size_bytes`, `sha256`, `version`
- `owner_scope` (catalog/vehicle/inspection)
- `created_at`

**`asset_links`** — связки медиа с сущностями

- `id`, `asset_id`, `link_type` (vehicle/inspection/component/component_observation)
- `link_id` (ID связанной сущности)
- `created_at`

#### 5. Пользователи и доступ

**`users`** — пользователи системы

- `id`, `email`, `password_hash`, `name`, `role` (owner/mechanic/admin/platform)
- `created_at`

**`user_sessions`** — сессии (опционально, если JWT не используется)

- `id`, `user_id`, `token`, `expires_at`

## Ключевые решения

### 1. Иерархия компонентов

- Использование `parent_id` для построения дерева
- Рекурсивные CTE запросы для получения полного пути компонента
- Кэширование дерева в памяти для популярных платформ

### 2. Хранение состояния деталей

- **Event-sourcing подход**: храним все наблюдения, текущее состояние вычисляем
- Опциональная материализация `vehicle_component_state` для быстрых запросов
- История изменений доступна через `component_observations`

### 3. Медиа и 3D

- Все файлы в S3, в БД только метаданные
- Pre-signed URLs для безопасной загрузки/скачивания
- Поддержка glTF/GLB форматов для 3D
- Версионирование через поле `version` в `assets`

### 4. Доступ к данным

- RBAC на уровне API handlers
- Владелец видит только свои авто
- Мастер видит только осмотры своего центра
- Центр видит свою операционку
- Платформа — полный доступ по ролям

## API Endpoints (основные)

### Catalog Service

- `GET /api/v1/catalog/makes` — список марок
- `GET /api/v1/catalog/models?make_id=X` — модели марки
- `GET /api/v1/catalog/platforms?generation_id=X` — платформы
- `GET /api/v1/catalog/components?platform_id=X` — дерево компонентов

### Vehicle Service

- `POST /api/v1/vehicles` — создать авто
- `GET /api/v1/vehicles/:id` — получить авто
- `GET /api/v1/vehicles/:id/state` — текущее состояние всех компонентов
- `PUT /api/v1/vehicles/:id` — обновить авто

### Inspection Service

- `POST /api/v1/inspections` — создать осмотр
- `GET /api/v1/inspections/:id` — получить осмотр
- `POST /api/v1/inspections/:id/observations` — добавить наблюдение по детали
- `GET /api/v1/vehicles/:id/inspections` — история осмотров авто

### Media Service

- `POST /api/v1/media/upload` — загрузить файл (возвращает pre-signed URL)
- `GET /api/v1/media/:id` — получить метаданные
- `GET /api/v1/media/:id/download` — получить pre-signed URL для скачивания
- `POST /api/v1/media/:id/link` — привязать медиа к сущности

## Технологии

- **Backend**: Go 1.21+
- **Database**: PostgreSQL 14+
- **ORM/Migrations**: `golang-migrate` или `sqlc` для type-safe SQL
- **HTTP Framework**: `gin` или `chi`
- **S3 Client**: `aws-sdk-go-v2`
- **Auth**: JWT tokens
- **Config**: `viper` или env vars

## Миграции

Использовать `golang-migrate` для версионирования схемы:

- `000001_init_schema.up.sql` — создание всех таблиц
- `000001_init_schema.down.sql` — откат

## Конфигурация

```go
type Config struct {
    Server   ServerConfig
    Database DatabaseConfig
    S3       S3Config
    Auth     AuthConfig
}

type S3Config struct {
    Region          string
    Bucket          string
    AccessKeyID     string
    SecretAccessKey string
    Endpoint        string // для локальной разработки с MinIO
}
```

## Импорт данных из cars.json

Файл `cars.json` содержит полный каталог марок и моделей в следующем формате:

```json
[
  {
    "id": "ABARTH",
    "name": "Abarth",
    "cyrillic_name": "Абарт",
    "numeric_id": 14894297,
    "year_from": 2008,
    "year_to": 2026,
    "popular": 0,
    "country": "Италия",
    "updated_at": "2025-07-26 22:33:37",
    "models": [
      {
        "id": "ABARTH_500",
        "mark_id": "ABARTH",
        "name": "500",
        "cyrillic_name": "500",
        "year_from": 2008,
        "year_to": 2025,
        "class": "A",
        "updated_at": "2025-07-26 16:51:00"
      }
    ]
  }
]
```

**Импортер должен:**

- Парсить JSON файл (52k+ строк)
- Загружать марки в таблицу `makes` с сохранением всех полей
- Загружать модели в таблицу `models` с привязкой к маркам
- Обрабатывать дубликаты (upsert по `id`)
- Логировать прогресс для больших файлов
- Поддерживать инкрементальные обновления

**Команда импорта:**

```bash
go run cmd/importer/main.go --file=cars.json
```

## Следующие шаги (v1 MVP)

1. **Импорт каталога**: загрузить все марки и модели из cars.json
2. **Уровень детализации v1**: выбрать 50-200 компонентов для популярных моделей
3. **Дерево компонентов**: создать для 3-5 популярных моделей (Toyota Camry, BMW 3 Series, etc.)
4. **Core loop**: визит → заполнение → отображение в приложении
5. **Медиа**: фото деталей + комментарии мастера
6. **3D**: подключить позже как "витрину"

## Вопросы для уточнения

- Нужна ли поддержка мультитенантности на уровне БД (разделение данных по организациям)?
- Какой формат аутентификации предпочтителен (JWT, OAuth2, session-based)?
- Нужна ли поддержка реального времени (WebSocket) для уведомлений?
- Планируется ли мобильное приложение (iOS/Android) или только веб?