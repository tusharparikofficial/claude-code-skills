# Generate GitHub Actions Workflow

Generate production-ready GitHub Actions workflows for CI, CD, release, cron, or matrix builds.

## Arguments

$ARGUMENTS - `<workflow-type>` where type is one of: ci, cd, release, cron, matrix

## Instructions

### 1. Parse Arguments

Extract the workflow type from `$ARGUMENTS`. Supported types:
- `ci` - Continuous Integration (lint, type-check, test, build)
- `cd` - Continuous Deployment (build, push, deploy)
- `release` - Release automation (version, changelog, GitHub Release, publish)
- `cron` - Scheduled/recurring job
- `matrix` - CI with matrix strategy across multiple runtime versions

If not provided or unrecognized, ask the user which type they need.

### 2. Auto-Detect Project Stack

Scan the project for manifest files to determine:
- Language and version (Node.js, Python, Go, Java, Rust)
- Package manager (npm, yarn, pnpm, pip, poetry, maven, gradle, cargo)
- Available scripts (lint, typecheck, test, build)
- Framework (Next.js, Nest, Django, FastAPI, Spring Boot, Gin, etc.)
- Existing Dockerfile
- Test framework in use

Check: `package.json`, `go.mod`, `requirements.txt`, `pyproject.toml`, `pom.xml`, `build.gradle`, `Cargo.toml`

### 3. Ensure Directory Exists

```bash
mkdir -p .github/workflows
```

### 4. Generate CI Workflow

If type is `ci`, create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Node.js
      - uses: pnpm/action-setup@v4          # if pnpm
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm                         # or npm/yarn
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint

      # Python
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
      - run: pip install -r requirements-dev.txt
      - run: ruff check .

      # Go
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - uses: golangci/golangci-lint-action@v4

      # Java
      - uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: 'maven'
      - run: ./mvnw checkstyle:check

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # (setup steps matching language)

      # Node.js/TypeScript
      - run: pnpm type-check       # or tsc --noEmit

      # Python
      - run: mypy app/              # or pyright

  test:
    name: Test
    runs-on: ubuntu-latest
    # Add services if tests need a database
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      # (setup steps matching language)
      - run: pnpm test -- --coverage     # or pytest --cov, go test -cover, mvn test
      - name: Upload coverage
        if: always()
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: false

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, type-check, test]
    steps:
      - uses: actions/checkout@v4
      # (setup steps matching language)
      - run: pnpm build              # or go build, mvn package, cargo build
```

Include ONLY the steps relevant to the detected language. Remove irrelevant language blocks. Add appropriate caching for the detected package manager.

### 5. Generate CD Workflow

If type is `cd`, create `.github/workflows/cd.yml`:

First, ask the user for their deployment target. Then generate accordingly:

#### VPS Deployment
```yaml
name: CD

on:
  push:
    branches: [main]

# Required secrets:
#   VPS_HOST - VPS IP or hostname
#   VPS_USER - SSH user
#   VPS_SSH_KEY - Private SSH key
#   VPS_PROJECT_PATH - Path on VPS (e.g., /opt/myapp)

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  deploy:
    name: Deploy to VPS
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd ${{ secrets.VPS_PROJECT_PATH }}
            git pull origin main
            docker compose pull
            docker compose up -d --build
            # Wait for health check
            sleep 10
            docker compose ps
            curl -f http://localhost:3000/api/health || exit 1

      - name: Verify deployment
        run: |
          sleep 15
          curl -f https://${{ vars.DOMAIN }}/api/health || echo "Health check failed"

      - name: Notify on failure
        if: failure()
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd ${{ secrets.VPS_PROJECT_PATH }}
            echo "Deploy failed, rolling back..."
            git checkout HEAD~1
            docker compose up -d --build
```

#### Docker Registry + Cloud Platform
```yaml
name: CD

on:
  push:
    branches: [main]

# Required secrets:
#   REGISTRY_URL - Container registry URL
#   REGISTRY_USERNAME - Registry username
#   REGISTRY_PASSWORD - Registry password/token

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  build-and-push:
    name: Build & Push Image
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ secrets.REGISTRY_URL }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}

      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.REGISTRY_URL }}/${{ github.repository }}
          tags: |
            type=sha,prefix=
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: production
    steps:
      # Platform-specific deploy steps:
      # Vercel: vercel --prod
      # Fly.io: flyctl deploy --image <image>
      # Railway: railway up
      # AWS ECS: aws ecs update-service
      # GCP Cloud Run: gcloud run deploy
      - name: Deploy to platform
        run: echo "Add platform-specific deploy command here"

      - name: Health check
        run: |
          sleep 20
          curl -f https://${{ vars.DOMAIN }}/api/health || exit 1
```

#### Environment-Specific Deploys

For CD, also offer staging/production split:
```yaml
  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    environment: staging
    # ... deploy to staging

  deploy-production:
    if: github.ref == 'refs/heads/main'
    environment: production
    # ... deploy to production
```

Document all required secrets as comments at the top of the workflow.

### 6. Generate Release Workflow

If type is `release`, create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags: ['v*']

permissions:
  contents: write
  packages: write

jobs:
  release:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for changelog

      - name: Generate changelog
        id: changelog
        run: |
          # Get previous tag
          PREV_TAG=$(git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "")
          if [ -z "$PREV_TAG" ]; then
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" HEAD)
          else
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" ${PREV_TAG}..HEAD)
          fi
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body: |
            ## Changes

            ${{ steps.changelog.outputs.changelog }}

            ## Docker Image

            ```
            docker pull ghcr.io/${{ github.repository }}:${{ github.ref_name }}
            ```
          draft: false
          prerelease: ${{ contains(github.ref, '-rc') || contains(github.ref, '-beta') || contains(github.ref, '-alpha') }}
          generate_release_notes: true

      # Optional: Build and push Docker image tagged with version
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push release image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.ref_name }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      # Optional: Publish to package registry
      # Node.js: npm publish
      # Python: twine upload dist/*
      # Go: no publish needed (tagged release is enough)
      # Java: ./mvnw deploy
```

Also create a helper workflow or document how to create version tags:
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

### 7. Generate Cron Workflow

If type is `cron`, ask the user:
1. What should the job do?
2. What schedule? (provide examples: `0 0 * * *` daily, `0 */6 * * *` every 6h, `0 9 * * 1` Monday 9am)

Create `.github/workflows/cron.yml`:

```yaml
name: Scheduled Job

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  workflow_dispatch: {}   # Allow manual trigger

jobs:
  scheduled-task:
    name: Run Scheduled Task
    runs-on: ubuntu-latest
    timeout-minutes: 30   # Prevent runaway jobs
    steps:
      - uses: actions/checkout@v4

      # Setup steps for the runtime

      - name: Run task
        run: |
          # User-specified task command
          echo "Running scheduled task..."

      - name: Create issue on failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Scheduled job failed: ${new Date().toISOString()}`,
              body: `The scheduled workflow failed. [View run](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId})`,
              labels: ['bug', 'automated']
            });
```

### 8. Generate Matrix Workflow

If type is `matrix`, create `.github/workflows/ci-matrix.yml`:

```yaml
name: CI (Matrix)

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ci-matrix-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    name: Test (${{ matrix.runtime-version }})
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Node.js
        node-version: [18, 20, 22]
        # Python
        python-version: ['3.10', '3.11', '3.12']
        # Go
        go-version: ['1.21', '1.22']
        # Java
        java-version: ['17', '21']

    steps:
      - uses: actions/checkout@v4

      # Node.js matrix
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm test

      # Python matrix
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -r requirements.txt
      - run: pytest

      # Go matrix
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - run: go test ./...

      # Java matrix
      - uses: actions/setup-java@v4
        with:
          java-version: ${{ matrix.java-version }}
          distribution: 'temurin'
          cache: 'maven'
      - run: ./mvnw test

  # Combined status check for branch protection
  ci-status:
    name: CI Status
    runs-on: ubuntu-latest
    needs: [test]
    if: always()
    steps:
      - name: Check matrix results
        run: |
          if [ "${{ needs.test.result }}" != "success" ]; then
            echo "Matrix tests failed"
            exit 1
          fi
```

Include ONLY the matrix entries relevant to the detected language. Remove the others.

### 9. Add Environment and Secrets Documentation

At the top of every generated workflow file, add a comment block documenting:
```yaml
# ============================================================
# Required Secrets (configure in GitHub Settings > Secrets):
#   SECRET_NAME - Description of what this secret is
# Required Variables (configure in GitHub Settings > Variables):
#   VARIABLE_NAME - Description
# ============================================================
```

### 10. Final Report

Print a summary with:
- Workflow file location (`.github/workflows/<name>.yml`)
- Trigger events (push, PR, tag, schedule, manual)
- Jobs and their purposes
- Required secrets to configure in GitHub repository settings
- Required variables to configure
- Link to test the workflow: push a commit or manually dispatch
- Any additional configuration needed (e.g., Codecov token, registry credentials)
