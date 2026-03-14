# Generate Docker Compose

Generate a Docker Compose configuration for local development with common infrastructure services, health checks, persistent volumes, and convenience scripts.

## Arguments

$ARGUMENTS - `<services...>` (optional) e.g. "postgres redis minio mailhog"

## Instructions

### 1. Parse Arguments

Extract service names from `$ARGUMENTS`. If no arguments provided, auto-detect needed services by examining the project:

- Check for database connection strings in `.env*` files or config
- Check for Redis references in code
- Check for S3/MinIO references
- Check for email sending code
- Default to `postgres redis` if nothing is detected

Supported services: postgres, mysql, mongodb, redis, elasticsearch, rabbitmq, kafka, minio, mailpit (or mailhog), prometheus, grafana

If an unrecognized service is listed, warn the user and skip it.

### 2. Detect Application Type

Examine the project to determine:
- Runtime (Node.js, Python, Go, Java, Rust)
- Framework (Next.js, Express, FastAPI, Gin, Spring Boot)
- Default port (3000, 4000, 8000, 8080, etc.)
- Package manager (pnpm, npm, yarn, pip, go)
- Existing Dockerfile (use it if present)

Check for: `package.json`, `go.mod`, `requirements.txt`, `pyproject.toml`, `pom.xml`, `Cargo.toml`.

### 3. Service Templates

Use the following templates for each requested service. All services include health checks, named volumes, and proper networking.

#### Application Service

```yaml
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "${APP_PORT:-3000}:3000"
    volumes:
      - .:/app
      - /app/node_modules  # Anonymous volume to preserve container's node_modules
    env_file:
      - .env
    environment:
      - NODE_ENV=development
    depends_on:
      # Auto-populated based on selected services with health check conditions
    restart: unless-stopped
    command: pnpm dev  # Adjust based on detected runtime
```

Adjust the command, volumes, and port based on detected runtime:
- **Node.js**: `pnpm dev` or `npm run dev`, mount source with `/app/node_modules` exclusion
- **Python**: `uvicorn app.main:app --reload --host 0.0.0.0`, mount source with `/app/.venv` exclusion
- **Go**: `air` (hot reload with cosmtrek/air) or `go run ./cmd/server`, mount source
- **Java**: `./mvnw spring-boot:run`, mount source with `/app/target` exclusion

If no Dockerfile exists, use an appropriate dev image directly (e.g., `node:20-alpine` with a working_dir and command).

#### PostgreSQL

```yaml
  postgres:
    image: postgres:16-alpine
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-appdb}
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-appdb}"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 10s
    restart: unless-stopped
```

#### MySQL

```yaml
  mysql:
    image: mysql:8.0
    ports:
      - "${MYSQL_PORT:-3306}:3306"
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE:-appdb}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_USER: ${MYSQL_USER:-appuser}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-apppassword}
    volumes:
      - mysqldata:/var/lib/mysql
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped
```

#### MongoDB

```yaml
  mongodb:
    image: mongo:7
    ports:
      - "${MONGO_PORT:-27017}:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-root}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-rootpassword}
      MONGO_INITDB_DATABASE: ${MONGO_DB:-appdb}
    volumes:
      - mongodata:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh --quiet
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 20s
    restart: unless-stopped
```

#### Redis

```yaml
  redis:
    image: redis:7-alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped
```

#### Elasticsearch

```yaml
  elasticsearch:
    image: elasticsearch:8.12.0
    ports:
      - "${ES_PORT:-9200}:9200"
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - esdata:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped
```

#### RabbitMQ

```yaml
  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "${RABBITMQ_PORT:-5672}:5672"
      - "${RABBITMQ_MGMT_PORT:-15672}:15672"
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-guest}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD:-guest}
    volumes:
      - rabbitmqdata:/var/lib/rabbitmq
    healthcheck:
      test: rabbitmq-diagnostics -q ping
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 15s
    restart: unless-stopped
```

#### Kafka (with Zookeeper)

```yaml
  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    volumes:
      - zookeeperdata:/var/lib/zookeeper/data
    healthcheck:
      test: echo ruok | nc localhost 2181 | grep imok
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    ports:
      - "${KAFKA_PORT:-9092}:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - kafkadata:/var/lib/kafka/data
    depends_on:
      zookeeper:
        condition: service_healthy
    healthcheck:
      test: kafka-broker-api-versions --bootstrap-server localhost:9092
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 20s
    restart: unless-stopped
```

#### MinIO (S3-compatible)

```yaml
  minio:
    image: minio/minio:latest
    ports:
      - "${MINIO_PORT:-9000}:9000"
      - "${MINIO_CONSOLE_PORT:-9001}:9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD:-minioadmin}
    volumes:
      - miniodata:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
```

#### MailPit (Email testing)

```yaml
  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "${MAILPIT_SMTP_PORT:-1025}:1025"
      - "${MAILPIT_UI_PORT:-8025}:8025"
    volumes:
      - mailpitdata:/data
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8025/"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped
```

#### Prometheus

```yaml
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "${PROMETHEUS_PORT:-9090}:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheusdata:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
```

#### Grafana

```yaml
  grafana:
    image: grafana/grafana:latest
    ports:
      - "${GRAFANA_PORT:-3001}:3000"
    environment:
      GF_SECURITY_ADMIN_USER: ${GRAFANA_USER:-admin}
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
    volumes:
      - grafanadata:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
    depends_on:
      - prometheus
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
```

### 4. Compose the docker-compose.yml

Assemble the final `docker-compose.yml` by:
1. Adding the app service first
2. Adding each requested infrastructure service from the templates above
3. Configuring `depends_on` in the app service for all infrastructure services using `condition: service_healthy`
4. Creating a top-level `volumes:` section listing all named volumes used
5. Using a custom bridge network named `app-network` if there are 3+ services

Write the file with clear YAML comments separating each service section.

### 5. Create .env File

Generate a `.env` file with all environment variables used in the compose file, with sensible development defaults and comments:

```env
# Application
APP_PORT=3000
NODE_ENV=development

# PostgreSQL
POSTGRES_DB=appdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/appdb

# Redis
REDIS_PORT=6379
REDIS_URL=redis://localhost:6379

# (Add more based on selected services)
```

Also create `.env.example` with the same structure but placeholder values instead of real defaults.

### 6. Create Init Scripts

If database services are included, create initialization scripts:

#### `scripts/init-db.sql` (for PostgreSQL)
```sql
-- Initialize database extensions and base schema
-- This runs automatically on first container start
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

For MySQL, create an equivalent initialization script.

### 7. Create Prometheus Config (if prometheus is included)

Create `monitoring/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

If grafana is also included, create `monitoring/grafana/provisioning/datasources/datasource.yml`:
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

### 8. Create Convenience Scripts

Create a `scripts/` directory with helpful development scripts:

#### `scripts/reset-db.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Stopping services and removing volumes..."
docker compose down -v --remove-orphans
echo "Starting database service..."
docker compose up -d postgres  # or mysql/mongodb
echo "Waiting for database to be ready..."
sleep 5
echo "Running migrations..."
# Add framework-specific migration command here
echo "Seeding database..."
# Add framework-specific seed command here
echo "Starting all services..."
docker compose up -d
echo "Database reset complete."
```

#### `scripts/seed.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Seeding database..."
# Framework-specific seed command
echo "Seed complete."
```

#### `scripts/logs.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
SERVICE=${1:-}
if [ -z "$SERVICE" ]; then
  docker compose logs -f --tail=100
else
  docker compose logs -f --tail=100 "$SERVICE"
fi
```

Make all scripts executable:
```bash
chmod +x scripts/*.sh
```

### 9. Create Makefile

Create or append to `Makefile` with convenience targets:

```makefile
.PHONY: up down restart logs reset-db seed ps clean

up:                          ## Start all services
	docker compose up -d

down:                        ## Stop all services
	docker compose down

restart:                     ## Restart all services
	docker compose restart

logs:                        ## Follow logs (usage: make logs or make logs s=postgres)
	docker compose logs -f --tail=100 $(s)

reset-db:                    ## Reset database (destroy volumes, re-init)
	./scripts/reset-db.sh

seed:                        ## Seed the database
	./scripts/seed.sh

ps:                          ## Show running containers
	docker compose ps

clean:                       ## Stop services, remove volumes and local images
	docker compose down -v --remove-orphans --rmi local

help:                        ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
```

### 10. Update .gitignore

Ensure `.gitignore` includes:
```
# Docker volumes data (don't commit)
scripts/*.log

# Environment (use .env.example as template)
.env
!.env.example
```

### 11. Final Report

Print a summary with:
- Table of services created with their ports and access URLs
- Web UIs available (RabbitMQ at :15672, MinIO Console at :9001, Grafana at :3001, MailPit at :8025, etc.)
- Default credentials for each service
- Quick start: `docker compose up -d` or `make up`
- View logs: `docker compose logs -f` or `make logs`
- Stop: `docker compose down` or `make down`
- Reset data: `docker compose down -v` or `make clean`
- List of files created
