.PHONY: dc install lint
include .env
LOCAL_BIN:=$(CURDIR)/bin

# Установка дополнительных утилит: 
install:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.53.3
	GOBIN=$(LOCAL_BIN) go install github.com/pressly/goose/v3/cmd/goose@v3.14.0

# Запуск контейнеров:
dc:
	docker-compose up  --remove-orphans --build -d

# Линтер
lint:
	GOBIN=$(LOCAL_BIN) $(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

# Миграции
LOCAL_MIGRATION_DIR=$(MIGRATION_DIR)
LOCAL_MIGRATION_DSN="host=localhost port=$(PG_PORT) dbname=$(PG_DATABASE_NAME) user=$(PG_USER) password=$(PG_PASSWORD) sslmode=disable"

create-new-migration:
ifndef name
	$(error name is not set)
endif
	$(LOCAL_BIN)/goose -dir ${LOCAL_MIGRATION_DIR} create $(name) sql

local-migration-status:
	$(LOCAL_BIN)/goose -dir ${LOCAL_MIGRATION_DIR} postgres ${LOCAL_MIGRATION_DSN} status -v

local-migration-up:
	$(LOCAL_BIN)/goose -dir ${LOCAL_MIGRATION_DIR} postgres ${LOCAL_MIGRATION_DSN} up -v

local-migration-down:
	$(LOCAL_BIN)/goose -dir ${LOCAL_MIGRATION_DIR} postgres ${LOCAL_MIGRATION_DSN} down -v
