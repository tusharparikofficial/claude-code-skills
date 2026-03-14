# Deploy to VPS

Deploy a project to a VPS via SSH with Docker, database migrations, health checks, rollback support, and optional first-deploy setup including Nginx and SSL.

## Arguments

$ARGUMENTS - `<vps-host>` SSH host alias or `user@ip` (e.g., `vps-mainvps` or `root@203.0.113.10`)

## Instructions

### 1. Parse VPS Host

Extract the VPS host from `$ARGUMENTS`. If not provided:
- Check if `vps-mainvps` is configured in `~/.ssh/config`
- Check for VPS configuration in the project's `.env` or deployment config
- Ask the user for the SSH host

### 2. Pre-Flight Checks (Local)

Run these checks before deployment:

```bash
# Verify SSH connectivity
ssh -o ConnectTimeout=10 <vps-host> "echo 'SSH connection OK'"

# Check git status
git status --porcelain
```

If there are uncommitted changes, warn the user and ask whether to proceed.

Identify:
- Current branch name
- Remote URL (for cloning on first deploy)
- Latest commit SHA and message
- Project name (from directory name or package.json)
- Project type (detect from package.json, docker-compose.yml, Dockerfile, etc.)

### 3. Determine Deploy Type

SSH into VPS and check:
```bash
ssh <vps-host> "test -d /opt/<project-name> && echo 'UPDATE' || echo 'FIRST_DEPLOY'"
```

### 4. First Deploy Flow

If this is the first deployment:

#### 4a. Install Prerequisites

Check and install required software on VPS:
```bash
ssh <vps-host> << 'DEPLOY_PREREQ'
set -e

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Check Docker Compose
if ! docker compose version &> /dev/null; then
    echo "Docker Compose plugin already included with Docker"
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    apt-get update && apt-get install -y git
fi

# Check Nginx
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt-get update && apt-get install -y nginx
    systemctl enable nginx
fi

# Check Certbot
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    apt-get update && apt-get install -y certbot python3-certbot-nginx
fi

echo "Prerequisites OK"
DEPLOY_PREREQ
```

#### 4b. Clone Repository

```bash
ssh <vps-host> "cd /opt && git clone <repo-url> <project-name>"
```

If the repository is private, ensure git credentials are configured on the VPS. Check `~/.git-credentials` or suggest setting up a deploy key.

#### 4c. Set Up Environment

Prompt the user for production environment variables. Create a checklist of required vars by reading `.env.example` if it exists.

```bash
# Copy env template
ssh <vps-host> "cd /opt/<project-name> && cp .env.example .env"
```

Then either:
- Ask the user for each required value and set them via SSH
- Or instruct the user to manually edit the file: `ssh <vps-host> "nano /opt/<project-name>/.env"`

Verify all required env vars are set (non-empty).

#### 4d. Build and Start

```bash
ssh <vps-host> << 'DEPLOY_BUILD'
set -e
cd /opt/<project-name>
docker compose up -d --build
echo "Waiting for services to start..."
sleep 15
docker compose ps
DEPLOY_BUILD
```

#### 4e. Run Migrations

Detect the migration tool and run migrations:

```bash
# Prisma (Node.js)
ssh <vps-host> "cd /opt/<project-name> && docker compose exec app npx prisma migrate deploy"

# Alembic (Python)
ssh <vps-host> "cd /opt/<project-name> && docker compose exec app alembic upgrade head"

# Django
ssh <vps-host> "cd /opt/<project-name> && docker compose exec app python manage.py migrate"

# golang-migrate
ssh <vps-host> "cd /opt/<project-name> && docker compose exec app migrate -path migrations -database \$DATABASE_URL up"

# Flyway (Java)
ssh <vps-host> "cd /opt/<project-name> && docker compose exec app ./mvnw flyway:migrate"
```

#### 4f. Configure Nginx Reverse Proxy

Ask the user for the domain name. Generate and deploy Nginx config:

```bash
ssh <vps-host> << 'DEPLOY_NGINX'
set -e

DOMAIN="<domain>"
APP_PORT="<port>"

# Create Nginx config
cat > /etc/nginx/sites-available/$DOMAIN << 'NGINX_CONF'
server {
    listen 80;
    server_name <domain> www.<domain>;

    location / {
        proxy_pass http://127.0.0.1:<port>;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX_CONF

# Enable site
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
DEPLOY_NGINX
```

#### 4g. Set Up SSL

```bash
ssh <vps-host> << 'DEPLOY_SSL'
set -e
certbot --nginx -d <domain> -d www.<domain> --non-interactive --agree-tos -m admin@<domain>
# Verify auto-renewal
certbot renew --dry-run
DEPLOY_SSL
```

### 5. Update Deploy Flow

If the project already exists on the VPS:

#### 5a. Create Rollback Snapshot

```bash
ssh <vps-host> << 'DEPLOY_SNAPSHOT'
set -e
cd /opt/<project-name>

# Save current state for rollback
PREV_COMMIT=$(git rev-parse HEAD)
echo "$PREV_COMMIT" > /tmp/deploy-rollback-commit.txt
docker compose ps > /tmp/deploy-rollback-state.txt
echo "Rollback point: $PREV_COMMIT"
DEPLOY_SNAPSHOT
```

#### 5b. Pull Latest Code

```bash
ssh <vps-host> "cd /opt/<project-name> && git fetch origin && git pull origin <branch>"
```

#### 5c. Zero-Downtime Rebuild

Use a rolling update approach:

```bash
ssh <vps-host> << 'DEPLOY_UPDATE'
set -e
cd /opt/<project-name>

# Build new images without stopping running containers
docker compose build

# Rolling restart - bring up new containers one at a time
docker compose up -d --no-deps --build app

# Wait for the new container to be healthy
echo "Waiting for health check..."
ATTEMPTS=0
MAX_ATTEMPTS=30
until docker compose exec app wget -q --spider http://localhost:3000/api/health 2>/dev/null || [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Attempt $ATTEMPTS/$MAX_ATTEMPTS..."
    sleep 2
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "HEALTH CHECK FAILED"
    exit 1
fi

echo "New container is healthy"
DEPLOY_UPDATE
```

#### 5d. Run Migrations (if needed)

Check for new migration files:
```bash
ssh <vps-host> << 'DEPLOY_MIGRATE'
cd /opt/<project-name>
PREV_COMMIT=$(cat /tmp/deploy-rollback-commit.txt)

# Check if there are new migration files
if git diff --name-only $PREV_COMMIT HEAD | grep -qE '(migrations?|prisma/migrations|alembic/versions)'; then
    echo "New migrations detected, running..."
    # Run appropriate migration command
else
    echo "No new migrations"
fi
DEPLOY_MIGRATE
```

#### 5e. Verify Health

```bash
ssh <vps-host> << 'DEPLOY_VERIFY'
set -e
cd /opt/<project-name>

echo "=== Container Status ==="
docker compose ps

echo "=== Health Check ==="
# Try the health endpoint
if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "Health check: PASSED"
    curl -s http://localhost:3000/api/health | python3 -m json.tool 2>/dev/null || true
else
    echo "Health check: FAILED"
    exit 1
fi

echo "=== Recent Logs ==="
docker compose logs --tail=20 app

echo "=== Deployment Info ==="
echo "Commit: $(git rev-parse --short HEAD)"
echo "Message: $(git log -1 --pretty=%s)"
echo "Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
DEPLOY_VERIFY
```

#### 5f. Automatic Rollback on Failure

If the health check fails:

```bash
ssh <vps-host> << 'DEPLOY_ROLLBACK'
set -e
cd /opt/<project-name>

PREV_COMMIT=$(cat /tmp/deploy-rollback-commit.txt)
echo "ROLLING BACK to $PREV_COMMIT..."

# Revert to previous commit
git checkout $PREV_COMMIT

# Rebuild with previous version
docker compose up -d --build

# Wait for rollback to complete
sleep 15

# Verify rollback
if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "Rollback successful"
else
    echo "CRITICAL: Rollback also failed. Manual intervention required."
    docker compose logs --tail=50
    exit 2
fi
DEPLOY_ROLLBACK
```

Notify the user with:
- The reason for rollback (health check failure, container crash, etc.)
- The commit that was rolled back
- The commit that is now running
- Log output showing the error

### 6. Post-Deploy Verification

After a successful deploy (whether first or update):

```bash
# Check all containers are running
ssh <vps-host> "cd /opt/<project-name> && docker compose ps"

# Check application logs for errors
ssh <vps-host> "cd /opt/<project-name> && docker compose logs --tail=30 app 2>&1 | grep -i 'error\|fatal\|panic' || echo 'No errors found'"

# External health check (if domain is configured)
curl -sf https://<domain>/api/health && echo "External health check: PASSED" || echo "External health check: FAILED (DNS/SSL may not be configured yet)"
```

### 7. Deployment Summary

Print a final summary:

```
=== DEPLOYMENT SUMMARY ===
Status:        SUCCESS / ROLLED_BACK / FAILED
Deploy Type:   First Deploy / Update
VPS Host:      <vps-host>
Project:       <project-name>
Branch:        <branch>
Commit:        <sha> - <message>
Timestamp:     <UTC timestamp>

Services Running:
  - app        (healthy, port 3000)
  - db         (healthy, port 5432)

Application URL: https://<domain>
Health Check:    https://<domain>/api/health

Useful Commands:
  View logs:     ssh <vps-host> "cd /opt/<project-name> && docker compose logs -f"
  Restart:       ssh <vps-host> "cd /opt/<project-name> && docker compose restart"
  Stop:          ssh <vps-host> "cd /opt/<project-name> && docker compose down"
  Rollback:      ssh <vps-host> "cd /opt/<project-name> && git checkout <prev-commit> && docker compose up -d --build"
  Shell:         ssh <vps-host> "cd /opt/<project-name> && docker compose exec app sh"
```
