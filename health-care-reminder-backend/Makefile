include .env
export

DATABASE_URL=postgres://$(DATABASE_USER):$(DATABASE_PASSWORD)@$(DATABASE_HOST):$(DATABASE_PORT)/$(DATABASE_NAME)?sslmode=disable

# =====================
# DATABASE
# =====================

db-create:
	psql -h $(DATABASE_HOST) -p $(DATABASE_PORT) -U $(DATABASE_USER) -c "CREATE DATABASE $(DATABASE_NAME);"

db-drop:
	psql -h $(DATABASE_HOST) -p $(DATABASE_PORT) -U $(DATABASE_USER) -c "DROP DATABASE IF EXISTS $(DATABASE_NAME);"

# =====================
# MIGRATIONS
# =====================

# Buat file migration baru: make migrate-create name=create_patients
migrate-create:
	migrate create -ext sql -dir internal/infrastructure/migrations -seq $(name)

migrate-up:
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations up

migrate-down:
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations down

# Rollback N step: make migrate-down-n n=1
migrate-down-n:
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations down $(n)

migrate-force:
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations force $(version)

migrate-fresh:
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations drop -f
	migrate -database "$(DATABASE_URL)" -path internal/infrastructure/migrations up

# =====================
# DOCKER
# =====================

# Development: app dengan hot-reload (Air) + database
docker-dev:
	docker compose --profile dev up -d

docker-dev-build:
	docker compose --profile dev up -d --build

docker-dev-logs:
	docker compose --profile dev logs -f app-dev

# Production: app + database
docker-up:
	docker compose --profile production up -d

docker-rebuild:
	docker compose --profile production up -d --build

docker-down:
	docker compose --profile dev --profile production down

docker-logs:
	docker compose logs -f

# Jalankan hanya database (untuk development lokal dengan make run)
docker-db:
	docker compose up postgres -d

docker-db-stop:
	docker compose stop postgres

# =====================
# RUN SERVER
# =====================

run:
	go run cmd/main.go

run-dev:
	air

# =====================
# BUILD
# =====================

build:
	go build -o bin/health-care-reminder cmd/main.go

# =====================
# TESTS
# =====================

test:
	go test -v ./...

test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# =====================
# DEPENDENCIES
# =====================

deps:
	go mod download
	go mod tidy

# =====================
# CLEAN
# =====================

clean:
	rm -rf bin/
	rm -f coverage.out
