.PHONY: help install migrate-up migrate-down migrate-create run importer test clean

help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Установить зависимости
	go mod download
	go mod tidy

migrate-up: ## Применить миграции
	@echo "Применение миграций..."
	@if command -v migrate > /dev/null; then \
		migrate -path migrations -database "postgres://$${DB_USER:-postgres}:$${DB_PASSWORD:-postgres}@$${DB_HOST:-localhost}:$${DB_PORT:-5432}/$${DB_NAME:-alem_auto}?sslmode=disable" up; \
	else \
		echo "Установите golang-migrate: go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest"; \
	fi

migrate-down: ## Откатить миграции
	@echo "Откат миграций..."
	@if command -v migrate > /dev/null; then \
		migrate -path migrations -database "postgres://$${DB_USER:-postgres}:$${DB_PASSWORD:-postgres}@$${DB_HOST:-localhost}:$${DB_PORT:-5432}/$${DB_NAME:-alem_auto}?sslmode=disable" down; \
	else \
		echo "Установите golang-migrate: go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest"; \
	fi

migrate-create: ## Создать новую миграцию (использование: make migrate-create NAME=name)
	@if command -v migrate > /dev/null; then \
		migrate create -ext sql -dir migrations -seq $(NAME); \
	else \
		echo "Установите golang-migrate: go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest"; \
	fi

run: ## Запустить сервер
	go run cmd/server/main.go

importer: ## Запустить импортер данных из cars.json
	go run cmd/importer/main.go --file=cars.json

test: ## Запустить тесты
	go test ./...

clean: ## Очистить временные файлы
	go clean
	rm -f alem-auto
