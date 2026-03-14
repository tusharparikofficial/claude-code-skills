# CI/CD Pipeline Optimizer

Analyze and optimize existing CI/CD pipeline configurations for speed and efficiency.

## Arguments

$ARGUMENTS - Optional path to CI config file (auto-detects if not provided)

## Instructions

1. **Locate the CI/CD configuration** by checking (in order):
   - Path from `$ARGUMENTS` if provided
   - `.github/workflows/*.yml` (GitHub Actions)
   - `.gitlab-ci.yml` (GitLab CI)
   - `Jenkinsfile` (Jenkins)
   - `.circleci/config.yml` (CircleCI)
   - `bitbucket-pipelines.yml` (Bitbucket Pipelines)
   - `.travis.yml` (Travis CI)
   - If none found, inform the user and stop.

2. **Read all CI configuration files** found. For GitHub Actions, read ALL workflow files in `.github/workflows/`.

3. **Analyze the pipeline** and identify issues in these categories:

### Caching Issues

Check for:
- **Missing dependency caches**: Is the package manager cache being used?
  - Node: `actions/setup-node` with `cache: 'npm'/'yarn'/'pnpm'`, or `actions/cache` for `node_modules`
  - Python: `actions/setup-python` with `cache: 'pip'`, or cache `.venv`
  - Go: `actions/setup-go` with `cache: true`, or cache `~/go/pkg/mod`
  - Java: `actions/setup-java` with `cache: 'maven'/'gradle'`
  - Rust: `Swatinem/rust-cache` or cache `target/`
- **Missing Docker layer cache**: Is `docker/build-push-action` using `cache-from`/`cache-to`?
- **Incorrect cache keys**: Are cache keys using the right hash (lockfile, not all source files)?
- **Cache not restored on PRs**: Ensure cache is available for PR builds (check `restore-keys`)
- **Overly broad cache invalidation**: Cache key changes too frequently

### Parallelization Opportunities

Check for:
- Jobs that could run in parallel but are sequential (e.g., lint, typecheck, and unit tests)
- Matrix strategy not used where multiple versions/platforms are tested
- Fan-out/fan-in patterns that could be applied
- Test splitting for large test suites (suggest tools like `jest --shard`, `pytest-split`, `gotestsum`)
- Steps within a job that could be separate parallel jobs

### Unnecessary Work

Check for:
- Steps that run on every push but should only run on PRs or main
- Duplicate checkout steps across jobs
- Full git history clone when shallow clone suffices (`fetch-depth: 0` when not needed)
- Installing devDependencies when only building for production
- Running ALL tests when only specific files changed (suggest path filters)
- Deploying preview environments for non-PR events
- Building Docker images when no Docker-related files changed

### Docker Optimizations

Check for:
- Not using BuildKit (`DOCKER_BUILDKIT=1`)
- Missing `--build-arg BUILDKIT_INLINE_CACHE=1`
- Not using multi-stage builds
- Large base images that could be replaced with alpine/slim variants
- Not using `.dockerignore` (or a poor one)
- Building images multiple times when once would suffice

### Slow Tests

Check for:
- No test parallelism configured
- E2E tests running without need (could be a separate workflow)
- No test caching or incremental testing
- Tests running against real services instead of mocked/in-memory alternatives
- Missing `--ci` or `--forceExit` flags for test runners

### General Inefficiencies

Check for:
- Old action versions (e.g., `actions/checkout@v2` instead of `v4`)
- Missing `concurrency` configuration (running duplicate builds on rapid pushes)
- No `timeout-minutes` on jobs (risk of hanging builds)
- `runs-on: ubuntu-latest` when a specific version would be more predictable
- Missing `continue-on-error` for non-critical jobs
- Not using `workflow_call` for reusable workflows (duplicated config across files)

4. **Generate an optimization report** with:
   - Current estimated pipeline duration (based on steps analysis)
   - Each issue found, categorized by severity:
     - **HIGH**: Issues causing significant slowdown (missing caches, sequential jobs)
     - **MEDIUM**: Moderate improvements (old action versions, missing concurrency)
     - **LOW**: Minor optimizations (fetch-depth, specific versions)
   - Estimated time savings for each optimization
   - Total estimated time savings

5. **Apply the optimizations** to the CI config files:
   - Make a backup comment at the top noting what was changed
   - Apply all HIGH and MEDIUM optimizations
   - Add comments explaining each change
   - For LOW optimizations, add TODO comments

6. **Write the optimized configuration** to the original file location(s).

7. **Print the final report** with:
   - Summary of changes made
   - Before/after comparison (estimated durations)
   - Total estimated time savings per build
   - Monthly time savings estimate (assuming X builds/day)
   - Any manual steps needed (e.g., configuring cache secrets, setting up test splitting)
   - Recommendations that require architectural changes (not applied automatically)
