# Alem Auto - Цифровой паспорт автомобиля

Система для ведения цифрового паспорта автомобиля с историей осмотров, иерархией деталей, 3D-моделями и медиа.

## Архитектура

Система построена как модульный монолит на Go с PostgreSQL и AWS S3, состоящий из 4 основных сервисов:

1. **Catalog Service** - справочники марок/моделей/поколений и иерархия компонентов
2. **Vehicle Service** - конкретные машины пользователей
3. **Inspection Service** - история осмотров и визитов
4. **Media Service** - управление медиа и 3D-моделями в S3

## Требования

- Go 1.21+
- PostgreSQL 14+
- AWS S3 (или MinIO для локальной разработки)

## Установка

1. Клонируйте репозиторий
2. Установите зависимости:
```bash
go mod download
```

3. Настройте переменные окружения (см. `.env.example`)
4. Запустите миграции:
```bash
make migrate-up
```

5. Импортируйте каталог марок и моделей:
```bash
go run cmd/importer/main.go --file=cars.json
```

6. Запустите сервер:
```bash
go run cmd/server/main.go
```

## Структура проекта

```
alem-auto/
├── cmd/
│   ├── server/          # HTTP сервер
│   └── importer/        # Импортер данных из cars.json
├── internal/
│   ├── catalog/         # Catalog Service
│   ├── vehicle/         # Vehicle Service
│   ├── inspection/      # Inspection Service
│   ├── media/           # Media Service
│   ├── auth/            # Аутентификация и авторизация
│   ├── database/        # Подключение к БД и миграции
│   └── api/             # HTTP handlers и роутинг
├── config/              # Конфигурация
└── migrations/          # SQL миграции
```

## API Endpoints

### Catalog
- `GET /api/v1/catalog/makes` - список марок
- `GET /api/v1/catalog/models?make_id=X` - модели марки
- `GET /api/v1/catalog/platforms?generation_id=X` - платформы
- `GET /api/v1/catalog/components?platform_id=X` - дерево компонентов

### Mock
- `GET /api/v1/mock/cars?limit=50&offset=0` - мок-справочник марок/моделей из `cars.json`

### Vehicles
- `POST /api/v1/vehicles` - создать авто
- `GET /api/v1/vehicles/:id` - получить авто
- `GET /api/v1/vehicles/:id/state` - текущее состояние компонентов
- `PUT /api/v1/vehicles/:id` - обновить авто

### Inspections
- `POST /api/v1/inspections` - создать осмотр
- `GET /api/v1/inspections/:id` - получить осмотр
- `POST /api/v1/inspections/:id/observations` - добавить наблюдение
- `GET /api/v1/vehicles/:id/inspections` - история осмотров

### Media
- `POST /api/v1/media/upload` - загрузить файл
- `GET /api/v1/media/:id` - получить метаданные
- `GET /api/v1/media/:id/download` - получить pre-signed URL
- `POST /api/v1/media/:id/link` - привязать медиа к сущности

### Agent (AI)
- `POST /api/v1/agent/message` - AI-маршрутизатор (intents: ADD_EXPENSE, ASK_ADVICE, GENERAL_CHAT)

## Лицензия

MIT
