# Set Up Application Monitoring

Set up application monitoring including health checks, metrics collection, logging, tracing, dashboards, and alerting.

## Arguments

$ARGUMENTS - `<monitoring-type>` where type is one of: basic, full, custom

## Instructions

### 1. Parse Arguments

Extract the monitoring type from `$ARGUMENTS`:
- `basic` - Health checks + uptime monitoring + basic alerting
- `full` - Metrics + logging + tracing + dashboards + alerting
- `custom` - Ask the user which components they want

If not provided, default to `basic` and ask if they want to upgrade to `full`.

### 2. Detect Application Stack

Examine the project to determine:
- Runtime (Node.js, Python, Go, Java)
- Framework (Express, FastAPI, Gin, Spring Boot, Next.js)
- Existing health check endpoint
- Existing docker-compose.yml
- Existing monitoring setup

### 3. Basic Monitoring

#### 3a. Health Check Endpoint

If no health check endpoint exists, create one appropriate for the detected framework.

**Node.js / Express:**
```typescript
// src/routes/health.ts
import { Router } from "express";

const router = Router();

interface HealthStatus {
  status: "healthy" | "degraded" | "unhealthy";
  timestamp: string;
  uptime: number;
  version: string;
  checks: {
    database: { status: string; latency?: number };
    memory: { used: number; total: number; percentage: number };
    cpu: { loadAvg: number[] };
  };
}

router.get("/health", async (_req, res) => {
  const checks: HealthStatus["checks"] = {
    database: { status: "unknown" },
    memory: { used: 0, total: 0, percentage: 0 },
    cpu: { loadAvg: [] },
  };

  // Database check
  try {
    const dbStart = Date.now();
    // await db.$queryRaw`SELECT 1`;
    checks.database = { status: "connected", latency: Date.now() - dbStart };
  } catch {
    checks.database = { status: "disconnected" };
  }

  // Memory check
  const memUsage = process.memoryUsage();
  const totalMem = require("os").totalmem();
  checks.memory = {
    used: Math.round(memUsage.heapUsed / 1024 / 1024),
    total: Math.round(totalMem / 1024 / 1024),
    percentage: Math.round((memUsage.heapUsed / totalMem) * 100),
  };

  // CPU check
  checks.cpu = { loadAvg: require("os").loadavg() };

  const isHealthy = checks.database.status === "connected";

  const health: HealthStatus = {
    status: isHealthy ? "healthy" : "degraded",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || "unknown",
    checks,
  };

  res.status(isHealthy ? 200 : 503).json(health);
});

export default router;
```

**Python / FastAPI:**
```python
# app/api/v1/health.py
import time
import psutil
from fastapi import APIRouter, Response

router = APIRouter()
start_time = time.time()

@router.get("/health")
async def health_check(response: Response):
    checks = {}

    # Database check
    try:
        db_start = time.time()
        # await db.execute("SELECT 1")
        checks["database"] = {"status": "connected", "latency_ms": round((time.time() - db_start) * 1000, 2)}
    except Exception as e:
        checks["database"] = {"status": "disconnected", "error": str(e)}

    # Memory check
    memory = psutil.virtual_memory()
    checks["memory"] = {
        "used_mb": round(memory.used / 1024 / 1024),
        "total_mb": round(memory.total / 1024 / 1024),
        "percentage": memory.percent,
    }

    # CPU check
    checks["cpu"] = {"load_avg": list(psutil.getloadavg())}

    is_healthy = checks.get("database", {}).get("status") == "connected"
    if not is_healthy:
        response.status_code = 503

    return {
        "status": "healthy" if is_healthy else "degraded",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "uptime_seconds": round(time.time() - start_time, 2),
        "checks": checks,
    }
```

**Go / Gin:**
```go
// internal/handler/health.go
package handler

import (
    "database/sql"
    "net/http"
    "os"
    "runtime"
    "time"
    "github.com/gin-gonic/gin"
)

type HealthHandler struct {
    db        *sql.DB
    startTime time.Time
}

func NewHealthHandler(db *sql.DB) *HealthHandler {
    return &HealthHandler{db: db, startTime: time.Now()}
}

func (h *HealthHandler) Check(c *gin.Context) {
    checks := map[string]interface{}{}

    dbStart := time.Now()
    if err := h.db.Ping(); err != nil {
        checks["database"] = map[string]interface{}{"status": "disconnected", "error": err.Error()}
    } else {
        checks["database"] = map[string]interface{}{"status": "connected", "latency_ms": time.Since(dbStart).Milliseconds()}
    }

    var m runtime.MemStats
    runtime.ReadMemStats(&m)
    checks["memory"] = map[string]interface{}{
        "alloc_mb":   m.Alloc / 1024 / 1024,
        "sys_mb":     m.Sys / 1024 / 1024,
        "goroutines": runtime.NumGoroutine(),
    }

    hostname, _ := os.Hostname()
    status := "healthy"
    statusCode := http.StatusOK
    if checks["database"].(map[string]interface{})["status"] != "connected" {
        status = "degraded"
        statusCode = http.StatusServiceUnavailable
    }

    c.JSON(statusCode, gin.H{
        "status":    status,
        "timestamp": time.Now().UTC().Format(time.RFC3339),
        "uptime":    time.Since(h.startTime).Seconds(),
        "hostname":  hostname,
        "checks":    checks,
    })
}
```

#### 3b. Uptime Monitoring

Provide setup instructions for external uptime monitoring:

**BetterStack (formerly BetterUptime):**
1. Sign up at https://betterstack.com
2. Add a new monitor with the health check URL
3. Configure check interval (30s-5m)
4. Set up notification channels (email, Slack, SMS)

**UptimeRobot (free tier):**
1. Sign up at https://uptimerobot.com
2. Add HTTP(s) monitor pointing to `/api/health`
3. Set check interval (5 minutes on free tier)
4. Configure alert contacts

**Self-hosted alternative** - Create a cron-based checker:

```bash
#!/usr/bin/env bash
# scripts/healthcheck.sh - Run via cron every minute
set -euo pipefail

HEALTH_URL="${HEALTH_URL:-http://localhost:3000/api/health}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
LOG_FILE="/var/log/healthcheck.log"

response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$HEALTH_URL" 2>/dev/null || echo "000")
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

if [ "$response" != "200" ]; then
    echo "$timestamp - UNHEALTHY (HTTP $response)" >> "$LOG_FILE"
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -s -X POST "$SLACK_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"text\":\"ALERT: Health check failed! Status: $response at $timestamp\"}" > /dev/null
    fi
else
    echo "$timestamp - HEALTHY" >> "$LOG_FILE"
fi
```

Add to crontab: `* * * * * /opt/<project>/scripts/healthcheck.sh`

#### 3c. Basic Alerting

Create a Slack webhook alerting script:

```bash
#!/usr/bin/env bash
# scripts/alert.sh
WEBHOOK_URL="$SLACK_WEBHOOK_URL"
MESSAGE="$1"
SEVERITY="${2:-warning}"

COLOR="warning"
case $SEVERITY in
    critical) COLOR="danger" ;;
    warning)  COLOR="warning" ;;
    info)     COLOR="#36a64f" ;;
esac

curl -s -X POST "$WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{
        \"attachments\": [{
            \"color\": \"$COLOR\",
            \"title\": \"$SEVERITY: Application Alert\",
            \"text\": \"$MESSAGE\",
            \"ts\": $(date +%s)
        }]
    }"
```

### 4. Full Monitoring Stack

If type is `full`, set up the complete observability stack:

#### 4a. Docker Compose Monitoring Stack

Create `docker-compose.monitoring.yml`:

```yaml
services:
  prometheus:
    image: prom/prometheus:v2.50.0
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./monitoring/prometheus/rules/:/etc/prometheus/rules/:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
      interval: 15s
      timeout: 5s
      retries: 3

  grafana:
    image: grafana/grafana:10.3.0
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_USER: ${GRAFANA_USER:-admin}
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_INSTALL_PLUGINS: grafana-clock-panel
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards:ro
    depends_on:
      prometheus:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 15s
      timeout: 5s
      retries: 3

  loki:
    image: grafana/loki:2.9.4
    ports:
      - "3100:3100"
    volumes:
      - ./monitoring/loki/loki-config.yml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3100/ready"]
      interval: 15s
      timeout: 5s
      retries: 3

  promtail:
    image: grafana/promtail:2.9.4
    volumes:
      - ./monitoring/promtail/promtail-config.yml:/etc/promtail/config.yml:ro
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    command: -config.file=/etc/promtail/config.yml
    depends_on:
      - loki
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:v1.7.0
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.49.1
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:v0.27.0
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

#### 4b. Prometheus Configuration

Create `monitoring/prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

#### 4c. Alert Rules

Create `monitoring/prometheus/rules/alerts.yml`:
```yaml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} over the last 5 minutes"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P95 latency is {{ $value }}s over the last 5 minutes"

      - alert: AppDown
        expr: up{job="app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Application is down"
          description: "The application has been unreachable for 1 minute"

  - name: infrastructure
    rules:
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      - alert: DiskSpaceLow
        expr: (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) > 0.85
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space is running low"
          description: "Disk usage is {{ $value | humanizePercentage }}"

      - alert: ContainerRestarting
        expr: increase(container_start_time_seconds[1h]) > 3
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Container is restarting frequently"
```

#### 4d. Alertmanager Configuration

Create `monitoring/alertmanager/alertmanager.yml`:
```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical'
      repeat_interval: 1h

receivers:
  - name: 'default'
    # Configure receivers:
    # slack_configs:
    #   - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
    #     channel: '#alerts'
    #     send_resolved: true

  - name: 'critical'
    # slack_configs:
    #   - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
    #     channel: '#alerts-critical'
    #     send_resolved: true
```

#### 4e. Application Metrics Instrumentation

Add metrics to the application based on detected runtime:

**Node.js (prom-client):**
```bash
pnpm add prom-client
```

```typescript
// src/lib/metrics.ts
import { Registry, Counter, Histogram, Gauge, collectDefaultMetrics } from "prom-client";

export const register = new Registry();
collectDefaultMetrics({ register });

export const httpRequestsTotal = new Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "path", "status"],
  registers: [register],
});

export const httpRequestDuration = new Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "path", "status"],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

export const activeConnections = new Gauge({
  name: "http_active_connections",
  help: "Number of active HTTP connections",
  registers: [register],
});
```

Create metrics middleware and `/metrics` endpoint.

**Python (prometheus-fastapi-instrumentator):**
```bash
pip install prometheus-client prometheus-fastapi-instrumentator
```

```python
from prometheus_fastapi_instrumentator import Instrumentator

def setup_metrics(app):
    Instrumentator(
        should_group_status_codes=True,
        should_ignore_untemplated=True,
        excluded_handlers=["/health", "/metrics"],
    ).instrument(app).expose(app, endpoint="/metrics")
```

**Go (prometheus/client_golang):**
```bash
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

Instrument with standard Go Prometheus client and add `/metrics` endpoint via `promhttp.Handler()`.

#### 4f. Structured Logging

Configure JSON structured logging:

**Node.js (pino):**
```typescript
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  base: {
    service: process.env.SERVICE_NAME || "app",
    env: process.env.NODE_ENV || "development",
  },
});
```

**Python (structlog):**
```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.StackInfoRenderer(),
        structlog.dev.set_exc_info,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ],
)
```

#### 4g. Loki Configuration

Create `monitoring/loki/loki-config.yml`:
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

limits_config:
  retention_period: 720h
```

Create `monitoring/promtail/promtail-config.yml`:
```yaml
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
```

#### 4h. Grafana Provisioning

Create `monitoring/grafana/provisioning/datasources/datasource.yml`:
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
```

Create `monitoring/grafana/provisioning/dashboards/dashboard.yml`:
```yaml
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    options:
      path: /var/lib/grafana/dashboards
```

Create pre-built dashboard JSON files in `monitoring/grafana/dashboards/`:

**Application Dashboard** (`app-dashboard.json`) with panels for:
- Request rate (requests/second)
- Error rate (5xx / total)
- Response time (P50, P95, P99)
- Active connections
- Top endpoints by request count
- Error breakdown by status code

**Infrastructure Dashboard** (`infra-dashboard.json`) with panels for:
- CPU usage (%)
- Memory usage (used/total/available)
- Disk usage and I/O
- Network traffic (in/out)
- Container status and resource usage

### 5. OpenTelemetry Tracing (Full mode only)

If the user wants distributed tracing, add OpenTelemetry instrumentation and Jaeger to the monitoring stack:

```yaml
  jaeger:
    image: jaegertracing/all-in-one:1.54
    ports:
      - "16686:16686"
      - "4317:4317"
      - "4318:4318"
    environment:
      COLLECTOR_OTLP_ENABLED: true
    restart: unless-stopped
```

Install the appropriate OpenTelemetry SDK for the detected runtime and create the tracing setup file.

### 6. Custom Monitoring

If type is `custom`, present the user with a component menu:
1. Health check endpoint
2. Uptime monitoring (external)
3. Prometheus metrics
4. Grafana dashboards
5. Structured logging (Loki)
6. Distributed tracing (Jaeger/OpenTelemetry)
7. Alerting (Alertmanager)
8. Node/system metrics (node-exporter)
9. Container metrics (cAdvisor)

Ask which components to include and generate only those.

### 7. Final Report

Print a summary with:
- Components installed
- Access URLs:
  - Prometheus: http://localhost:9090
  - Grafana: http://localhost:3001 (admin/admin)
  - Alertmanager: http://localhost:9093
  - Jaeger: http://localhost:16686 (if tracing enabled)
  - Loki: http://localhost:3100 (via Grafana)
- How to start: `docker compose -f docker-compose.monitoring.yml up -d`
- How to access Grafana dashboards
- Alert channels to configure
- Files created/modified
- Next steps (configure alert receivers, add custom dashboards, tune thresholds)
