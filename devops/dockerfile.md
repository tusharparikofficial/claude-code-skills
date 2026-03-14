# Dockerfile Generator

Generate an optimized multi-stage Dockerfile for any project by auto-detecting the technology stack.

## Arguments

$ARGUMENTS - Optional `<project-path>` (defaults to current working directory)

## Instructions

1. **Detect the project path**: Use `$ARGUMENTS` if provided, otherwise use the current working directory.

2. **Auto-detect the technology stack** by checking for these files in the project root:
   - `package.json` -> Node.js (check for `typescript` dep to determine TS vs JS)
   - `go.mod` -> Go
   - `requirements.txt` or `pyproject.toml` or `Pipfile` -> Python
   - `pom.xml` or `build.gradle` -> Java
   - `Cargo.toml` -> Rust
   - If multiple are found, ask the user which stack to target.
   - If none are found, ask the user to specify the stack.

3. **Read the manifest file** to understand dependencies, build commands, and entry points:
   - Node: read `package.json` for `scripts.build`, `scripts.start`, `engines.node`, framework (Next.js, Nest, Express, etc.)
   - Go: read `go.mod` for module name and Go version
   - Python: read `requirements.txt` or `pyproject.toml` for dependencies and Python version
   - Java: read `pom.xml`/`build.gradle` for Java version, build tool, packaging type
   - Rust: read `Cargo.toml` for binary name and edition

4. **Generate the Dockerfile** following these rules:

   **Base images** (use specific version tags, never `latest`):
   - Node: `node:<version>-alpine` (or `-slim` if native deps detected)
   - Go: `golang:<version>-alpine` for build, `gcr.io/distroless/static-debian12` or `alpine` for runtime
   - Python: `python:<version>-slim`
   - Java: `eclipse-temurin:<version>-jdk-alpine` for build, `eclipse-temurin:<version>-jre-alpine` for runtime
   - Rust: `rust:<version>-alpine` for build, `alpine` or `gcr.io/distroless/cc-debian12` for runtime

   **Multi-stage build** (always use at least 2 stages):
   - Stage 1 (`builder`): Install dependencies, copy source, build
   - Stage 2 (`runtime`): Copy only built artifacts, minimal runtime

   **Layer caching optimization**:
   - Copy dependency manifests FIRST (`package.json`, `go.mod`, `requirements.txt`, etc.)
   - Install dependencies in a separate layer BEFORE copying source code
   - Copy source code AFTER dependency installation
   - Use `--mount=type=cache` for package manager caches where supported

   **Security**:
   - Create and use a non-root user (`appuser` with UID 1001)
   - Set `USER appuser` before `CMD`
   - Use `COPY --chown=appuser:appuser` for application files
   - Do NOT install unnecessary packages
   - Remove package manager caches in the same layer as install

   **Health check**:
   - Add `HEALTHCHECK` instruction appropriate for the app type
   - HTTP apps: `curl` or `wget` to health endpoint
   - CLI apps: skip or use process check

   **Metadata**:
   - Add `LABEL` instructions for maintainer, version, description
   - Set appropriate `EXPOSE` port(s)
   - Use `WORKDIR /app`

   **Environment**:
   - Set `NODE_ENV=production` for Node.js
   - Set `PYTHONDONTWRITEBYTECODE=1` and `PYTHONUNBUFFERED=1` for Python
   - Set `CGO_ENABLED=0` for Go (when no CGO needed)

5. **Generate a `.dockerignore` file** alongside the Dockerfile:
   - Always include: `.git`, `node_modules`, `__pycache__`, `.env*`, `*.log`, `.DS_Store`, `Dockerfile`, `docker-compose*.yml`, `.dockerignore`
   - Stack-specific: `dist`/`build` for Node, `target` for Rust/Java, `vendor` for Go (if not vendoring), `.venv`/`venv` for Python

6. **Output both files** to the project directory:
   - Write `Dockerfile` to the project root
   - Write `.dockerignore` to the project root

7. **Print a summary** explaining:
   - Detected stack and version
   - Number of stages and their purposes
   - Final image base and approximate size
   - How to build: `docker build -t <app-name> .`
   - How to run: `docker run -p <port>:<port> <app-name>`
