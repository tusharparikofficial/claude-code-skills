# Docker Debugger

Diagnose and fix Docker build failures, container runtime issues, and docker-compose configuration problems.

## Arguments

$ARGUMENTS - Optional container name or docker-compose service name. If omitted, diagnoses all containers/services.

## Instructions

Follow these steps to systematically diagnose Docker issues.

### Step 1: Detect Docker Environment

Determine whether the project uses Docker Compose or standalone Docker:

1. Use Glob to check for `docker-compose.yml`, `docker-compose.yaml`, `compose.yml`, or `compose.yaml` in the project root and common subdirectories.
2. Use Glob to check for `Dockerfile`, `Dockerfile.*`, or `*.dockerfile` files.
3. Check if Docker is available by running `docker --version` and `docker compose version` (or `docker-compose --version`).

If no Docker files are found, report that no Docker configuration was detected and stop.

Determine the compose command: use `docker compose` (V2 plugin) if available, otherwise fall back to `docker-compose` (V1 standalone).

### Step 2: Check Container Status

Run the following diagnostics using Bash:

**If docker-compose project:**

```bash
docker compose ps -a 2>&1
```

**If standalone Docker (or specific container from $ARGUMENTS):**

```bash
docker ps -a --filter "name=<container-name>" 2>&1
```

**If no specific target, show all:**

```bash
docker ps -a 2>&1
```

For each container, note:
- **Status**: running, exited, restarting, created
- **Exit code**: 0 = clean exit, non-zero = error
- **Restart count**: high count indicates crash loop
- **Port mappings**: check for conflicts
- **Health status**: healthy, unhealthy, starting

Flag any containers that are:
- Exited with non-zero code
- In a restart loop (restarting status or high restart count)
- Unhealthy
- Not running when they should be

### Step 3: Check Container Logs

For each problematic container (or the target container from $ARGUMENTS):

```bash
docker compose logs --tail=100 <service-name> 2>&1
```

Or for standalone:

```bash
docker logs --tail=100 <container-name> 2>&1
```

Parse the logs for:
- Error messages (search for `error`, `fatal`, `panic`, `exception`, `traceback`)
- Connection failures (`connection refused`, `ECONNREFUSED`, `timeout`)
- Permission denials (`permission denied`, `EACCES`)
- Missing files or modules (`not found`, `no such file`, `ModuleNotFoundError`)
- OOM kills (`Killed`, `OOMKilled`)
- Port binding failures (`address already in use`, `EADDRINUSE`)

### Step 4: Analyze Dockerfile

Read each Dockerfile using the Read tool. Check for common issues:

**Base Image Issues:**
- Using `latest` tag (unpredictable builds)
- Using deprecated or unmaintained base image
- Architecture mismatch (amd64 vs arm64)

**Build Issues:**
- Missing `RUN apt-get update` before `apt-get install`
- Not cleaning up package manager cache (bloated image)
- `COPY` or `ADD` referencing files outside build context
- Missing `.dockerignore` (sending unnecessary files to build context)
- Wrong `WORKDIR` path
- Dependencies installed before code copy (poor layer caching)

**Runtime Issues:**
- Wrong `CMD` or `ENTRYPOINT` (command not found)
- Running as root when not needed (security concern)
- Missing `EXPOSE` for used ports
- Hardcoded paths that differ between local and container
- Missing environment variables with no defaults

### Step 5: Analyze Docker Compose Configuration

Read the docker-compose file using the Read tool. Check for:

**Port Issues:**
- Host port conflicts (same host port mapped to multiple containers)
- Using host ports below 1024 without privileges
- Port not exposed in Dockerfile but mapped in compose

**Volume Issues:**
- Bind mount paths that do not exist on host
- Volume permission mismatches (host UID/GID vs container UID/GID)
- Named volumes not defined in top-level `volumes:` section
- Read-only volumes where writes are needed

**Network Issues:**
- Services that need to communicate not on the same network
- Using `links:` instead of networks (deprecated)
- Wrong service name used as hostname (compose uses service names as DNS)

**Environment Issues:**
- Missing required environment variables (no default and no `.env` file)
- Referencing env_file that does not exist
- Secrets in environment variables instead of Docker secrets

**Dependency Issues:**
- Missing `depends_on` for services that need other services to start first
- No health check on depended-upon services (depends_on only waits for container start, not readiness)
- Circular dependencies

### Step 6: Check Resource Usage

```bash
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" 2>&1
```

Flag containers with:
- Memory usage above 80% of limit
- CPU usage consistently above 90%
- Zero network I/O when network activity is expected

### Step 7: Check Network Connectivity

If the issue involves inter-container communication:

```bash
docker network ls 2>&1
```

```bash
docker network inspect <network-name> 2>&1
```

Verify that containers that need to communicate are on the same network and can resolve each other by service name.

If needed, test connectivity from inside a container:

```bash
docker exec <container-name> ping -c 2 <other-service-name> 2>&1
```

Or:

```bash
docker exec <container-name> wget -qO- http://<other-service-name>:<port>/health 2>&1
```

### Step 8: Apply Fixes

Based on the diagnosis, apply fixes using the Edit tool to modify Dockerfile, docker-compose.yml, or application code. Common fixes:

**Port Conflicts:**
- Change host port mapping in docker-compose.yml
- Kill the process occupying the port: identify with `lsof -i :<port>` or `ss -tlnp`

**Volume Permissions:**
- Add `user:` directive in docker-compose.yml
- Add `RUN chown` in Dockerfile
- Use named volumes instead of bind mounts where appropriate

**Missing Environment Variables:**
- Add defaults in docker-compose.yml
- Create or update `.env` file (warn about sensitive values)

**Build Failures:**
- Fix Dockerfile layer ordering
- Add missing system dependencies
- Fix COPY paths

**Health Check Failures:**
- Add or fix healthcheck in Dockerfile or docker-compose.yml
- Increase health check interval/timeout for slow-starting services

**Dependency Installation:**
- Fix package manager commands
- Add missing system libraries for native modules
- Use multi-stage builds for compilation dependencies

After applying fixes, re-run the relevant Docker command to verify:

```bash
docker compose up --build -d 2>&1
```

Wait a few seconds, then check status again:

```bash
docker compose ps -a 2>&1
```

### Step 9: Report

```
## Docker Diagnosis Report

**Environment**: Docker Compose / Standalone Docker
**Target**: <service/container name or "all">

### Container Status

| Service | Status | Health | Issue |
|---------|--------|--------|-------|
| web | running | healthy | - |
| db | restarting | unhealthy | Connection refused on port 5432 |

### Issues Found

1. **<Issue Title>**
   - Symptom: <what was observed>
   - Root Cause: <why it happened>
   - Fix: <what was changed>
   - File: <file that was modified>

### Fixes Applied

| # | File | Change |
|---|------|--------|
| 1 | docker-compose.yml | Fixed port mapping conflict |
| 2 | Dockerfile | Added missing system dependency |

### Verification

<result of re-running after fixes>

### Manual Steps Required (if any)

<steps that cannot be automated>
```
