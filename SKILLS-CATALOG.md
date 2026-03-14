# Claude Code Skills Catalog — 1000+ Skills Brainstorm

> Exhaustive catalog of skills that could be built for Claude Code to maximize
> productivity, capability, and workflow efficiency across every domain.

---

## Table of Contents

1. [Code Generation & Scaffolding (001–060)](#1-code-generation--scaffolding)
2. [Testing & QA (061–130)](#2-testing--qa)
3. [Code Quality & Review (131–190)](#3-code-quality--review)
4. [Debugging & Troubleshooting (191–250)](#4-debugging--troubleshooting)
5. [Refactoring & Cleanup (251–310)](#5-refactoring--cleanup)
6. [Architecture & Design (311–370)](#6-architecture--design)
7. [Database & Data (371–440)](#7-database--data)
8. [DevOps & Infrastructure (441–510)](#8-devops--infrastructure)
9. [Security (511–570)](#9-security)
10. [Performance (571–630)](#10-performance)
11. [Documentation (631–680)](#11-documentation)
12. [API & Integration (681–740)](#12-api--integration)
13. [Frontend & UI (741–800)](#13-frontend--ui)
14. [Mobile Development (801–840)](#14-mobile-development)
15. [AI/ML Engineering (841–890)](#15-aiml-engineering)
16. [Project Management & Workflow (891–940)](#16-project-management--workflow)
17. [Research & Analysis (941–980)](#17-research--analysis)
18. [Meta / Claude Code Self-Improvement (981–1030)](#18-meta--claude-code-self-improvement)
19. [Platform & Cloud Specific (1031–1080)](#19-platform--cloud-specific)
20. [Communication & Collaboration (1081–1120)](#20-communication--collaboration)
21. [Business & Strategy (1121–1150)](#21-business--strategy)

---

## 1. Code Generation & Scaffolding (001–060)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 001 | `scaffold-nextjs` | Full Next.js project with App Router, auth, DB, payments, email | 2-day head start on any SaaS |
| 002 | `scaffold-fastapi` | FastAPI project with SQLAlchemy, Alembic, JWT, CORS, Docker | Production-ready Python API in minutes |
| 003 | `scaffold-express` | Express.js with TypeScript, Prisma, validation, error handling | Skip boilerplate, start building |
| 004 | `scaffold-django` | Django with DRF, Celery, Redis, Docker, custom user model | Full-featured Django in one command |
| 005 | `scaffold-spring` | Spring Boot with JPA, Security, Flyway, OpenAPI, Docker | Enterprise Java starter |
| 006 | `scaffold-go-service` | Go microservice with Chi/Gin, SQLC, migrations, health checks | Idiomatic Go service scaffold |
| 007 | `scaffold-rust-axum` | Rust Axum service with SQLx, tower middleware, tracing | High-performance Rust API |
| 008 | `scaffold-cli` | CLI tool scaffold (Node/Go/Rust/Python) with arg parsing, config, help | Build CLIs fast |
| 009 | `scaffold-chrome-ext` | Chrome extension with manifest v3, popup, background, content scripts | Browser extension starter |
| 010 | `scaffold-vscode-ext` | VS Code extension with commands, webview, tree view, settings | IDE extension starter |
| 011 | `scaffold-monorepo` | Turborepo/Nx monorepo with shared packages, CI, workspace config | Multi-package project setup |
| 012 | `scaffold-electron` | Electron app with IPC, auto-update, tray, native menus | Desktop app starter |
| 013 | `scaffold-tauri` | Tauri v2 app with Rust backend, frontend framework of choice | Lightweight desktop app |
| 014 | `scaffold-react-native` | React Native with Expo, navigation, state, native modules | Mobile app starter |
| 015 | `scaffold-flutter` | Flutter app with BLoC, routing, DI, l10n, theming | Cross-platform mobile starter |
| 016 | `scaffold-swift-ios` | SwiftUI app with MVVM, Core Data, networking, testing | Native iOS starter |
| 017 | `scaffold-kotlin-android` | Kotlin Android with Jetpack Compose, Hilt, Room, Navigation | Native Android starter |
| 018 | `scaffold-microservice` | Language-agnostic microservice template with health, metrics, tracing | Service mesh ready |
| 019 | `scaffold-lambda` | AWS Lambda function with SAM/CDK, layers, API Gateway | Serverless function starter |
| 020 | `scaffold-worker` | Cloudflare Worker with KV, D1, R2, Durable Objects | Edge computing starter |
| 021 | `scaffold-lib` | Library/package scaffold with build, test, docs, publishing config | Open source library starter |
| 022 | `scaffold-mcp-server` | MCP server with tool definitions, resource handling, SSE transport | Extend Claude Code itself |
| 023 | `scaffold-slack-bot` | Slack bot with slash commands, modals, events, OAuth | Team automation starter |
| 024 | `scaffold-discord-bot` | Discord bot with slash commands, embeds, buttons, modals | Community bot starter |
| 025 | `scaffold-telegram-bot` | Telegram bot with inline keyboards, webhooks, middleware | Messaging bot starter |
| 026 | `scaffold-graphql` | GraphQL API with schema, resolvers, dataloaders, subscriptions | Type-safe API starter |
| 027 | `scaffold-grpc` | gRPC service with proto definitions, codegen, interceptors | High-performance RPC starter |
| 028 | `scaffold-websocket` | WebSocket server with rooms, auth, reconnection, heartbeat | Real-time communication starter |
| 029 | `scaffold-queue-worker` | Background job processor (Bull/Celery/Sidekiq pattern) | Async job processing |
| 030 | `scaffold-cron` | Scheduled job runner with logging, retry, dead letter queue | Recurring task automation |
| 031 | `gen-crud` | Generate full CRUD operations from a model/schema definition | Minutes not hours for CRUD |
| 032 | `gen-form` | Generate validated form from schema (React Hook Form, Zod, etc.) | Complex forms instantly |
| 033 | `gen-table` | Generate data table with sort, filter, pagination from schema | Data display component |
| 034 | `gen-api-client` | Generate typed API client from OpenAPI/Swagger spec | Type-safe API consumption |
| 035 | `gen-mock-data` | Generate realistic mock/seed data from schema definitions | Testing & demo data |
| 036 | `gen-migration` | Generate DB migration from model diff or natural language | Schema changes made easy |
| 037 | `gen-dto` | Generate DTOs/view models from domain models | Clean separation of concerns |
| 038 | `gen-mapper` | Generate object mapping code between types | Reduce boilerplate mapping |
| 039 | `gen-validator` | Generate validation schemas (Zod/Joi/Pydantic) from types | Input validation from types |
| 040 | `gen-enum` | Generate enum/constant with all related helpers | Consistent enum patterns |
| 041 | `gen-hook` | Generate custom React hook with tests | Reusable React logic |
| 042 | `gen-context` | Generate React context with provider, hook, and types | State management pattern |
| 043 | `gen-store` | Generate state store (Zustand/Redux/MobX) from shape definition | State management setup |
| 044 | `gen-middleware` | Generate Express/Koa/Fastify middleware with error handling | Cross-cutting concerns |
| 045 | `gen-decorator` | Generate TypeScript/Python decorator with proper typing | Reusable decorators |
| 046 | `gen-factory` | Generate test factory/fixture for a model | Consistent test data |
| 047 | `gen-seeder` | Generate database seeder from schema | Development data setup |
| 048 | `gen-email-template` | Generate responsive email template (MJML/React Email) | Email design |
| 049 | `gen-pdf-template` | Generate PDF template with dynamic data binding | Document generation |
| 050 | `gen-config` | Generate configuration module with validation and defaults | Type-safe config |
| 051 | `gen-error-types` | Generate error class hierarchy from spec | Consistent error handling |
| 052 | `gen-event-types` | Generate event types and handlers for event-driven architecture | Event system setup |
| 053 | `gen-protobuf` | Generate protobuf definitions from TypeScript/Go types | Cross-language schemas |
| 054 | `gen-openapi` | Generate OpenAPI spec from route definitions or code | API documentation |
| 055 | `gen-terraform` | Generate Terraform modules from infrastructure description | IaC from natural language |
| 056 | `gen-dockerfile` | Generate optimized multi-stage Dockerfile for any stack | Container optimization |
| 057 | `gen-github-action` | Generate GitHub Actions workflow for specific use case | CI/CD automation |
| 058 | `gen-makefile` | Generate Makefile with common project tasks | Build automation |
| 059 | `gen-gitignore` | Generate comprehensive .gitignore for tech stack | Clean repositories |
| 060 | `gen-env-template` | Generate .env.example with all required variables documented | Environment setup |

---

## 2. Testing & QA (061–130)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 061 | `test-unit` | Generate unit tests for a function/module with edge cases | Comprehensive unit coverage |
| 062 | `test-integration` | Generate integration tests for API endpoints | API contract verification |
| 063 | `test-e2e-playwright` | Generate Playwright E2E tests from user stories | Critical flow coverage |
| 064 | `test-e2e-cypress` | Generate Cypress E2E tests with fixtures | Browser testing |
| 065 | `test-snapshot` | Generate snapshot tests for UI components | Regression detection |
| 066 | `test-visual` | Set up visual regression testing (Percy/Chromatic/Playwright) | UI change detection |
| 067 | `test-a11y` | Generate accessibility tests (axe-core, pa11y) | WCAG compliance testing |
| 068 | `test-performance` | Generate performance/load tests (k6/Artillery/Locust) | Performance validation |
| 069 | `test-chaos` | Generate chaos engineering tests (fault injection) | Resilience testing |
| 070 | `test-contract` | Generate consumer-driven contract tests (Pact) | Service compatibility |
| 071 | `test-mutation` | Set up and run mutation testing (Stryker/mutmut) | Test quality validation |
| 072 | `test-fuzz` | Generate fuzz tests for input handling code | Edge case discovery |
| 073 | `test-property` | Generate property-based tests (fast-check/Hypothesis) | Invariant verification |
| 074 | `test-smoke` | Generate smoke test suite for deployment verification | Deploy confidence |
| 075 | `test-regression` | Generate regression tests from bug report | Prevent bug recurrence |
| 076 | `test-api-schema` | Validate API responses against schema (Ajv/jsonschema) | Schema compliance |
| 077 | `test-database` | Generate database tests (constraints, triggers, migrations) | Data integrity |
| 078 | `test-email` | Test email sending with capture (MailHog/Mailtrap) | Email verification |
| 079 | `test-webhook` | Test webhook delivery and retry logic | Integration testing |
| 080 | `test-cron` | Test scheduled job execution and timing | Job scheduling verification |
| 081 | `test-queue` | Test message queue producers/consumers | Async processing tests |
| 082 | `test-cache` | Test cache hit/miss/invalidation scenarios | Cache correctness |
| 083 | `test-auth` | Generate authentication/authorization test suite | Security testing |
| 084 | `test-rate-limit` | Test rate limiting behavior and headers | Abuse prevention testing |
| 085 | `test-upload` | Test file upload (size limits, types, malicious files) | Upload security testing |
| 086 | `test-pagination` | Test pagination edge cases (empty, one page, boundaries) | Data listing correctness |
| 087 | `test-search` | Test search functionality (relevance, filters, edge cases) | Search quality |
| 088 | `test-concurrent` | Test concurrent access and race conditions | Concurrency correctness |
| 089 | `test-timeout` | Test timeout handling and circuit breaker behavior | Resilience testing |
| 090 | `test-retry` | Test retry logic with exponential backoff | Error recovery testing |
| 091 | `test-idempotency` | Test idempotency of API operations | Safe retries |
| 092 | `test-i18n` | Test internationalization (locale, RTL, pluralization) | Localization correctness |
| 093 | `test-timezone` | Test timezone handling edge cases | Time correctness |
| 094 | `test-migration` | Test database migration up/down/rollback | Schema change safety |
| 095 | `test-ssl` | Test SSL/TLS configuration and certificate validation | Transport security |
| 096 | `test-cors` | Test CORS configuration for all scenarios | Cross-origin security |
| 097 | `test-csp` | Test Content Security Policy headers | XSS prevention |
| 098 | `test-mobile-responsive` | Test responsive design breakpoints | Mobile compatibility |
| 099 | `test-offline` | Test offline behavior and service worker | PWA testing |
| 100 | `test-ssr` | Test server-side rendering output | SSR correctness |
| 101 | `test-streaming` | Test SSE/streaming responses | Real-time testing |
| 102 | `test-websocket` | Test WebSocket connection, messages, reconnection | Real-time testing |
| 103 | `test-graphql` | Test GraphQL queries, mutations, subscriptions | API testing |
| 104 | `test-grpc` | Test gRPC service methods and streaming | RPC testing |
| 105 | `test-docker` | Test Docker build, compose, networking | Container testing |
| 106 | `test-k8s` | Test Kubernetes manifests and deployments | Orchestration testing |
| 107 | `test-terraform` | Test Terraform plans and state | IaC testing |
| 108 | `test-coverage-report` | Generate detailed coverage report with uncovered lines | Coverage visibility |
| 109 | `test-coverage-enforce` | Set up coverage thresholds and CI enforcement | Quality gates |
| 110 | `test-flaky-detect` | Detect and quarantine flaky tests | Test reliability |
| 111 | `test-flaky-fix` | Analyze and fix flaky test root causes | Test stability |
| 112 | `test-parallel` | Configure parallel test execution | Faster test runs |
| 113 | `test-matrix` | Set up test matrix (OS, Node version, DB version) | Cross-environment |
| 114 | `test-fixture-gen` | Generate test fixtures from production data (anonymized) | Realistic test data |
| 115 | `test-mock-server` | Set up mock API server for testing (MSW/WireMock) | External dependency isolation |
| 116 | `test-spy-audit` | Audit test spies/mocks for correctness and coverage | Mock quality |
| 117 | `test-boundary` | Generate boundary value analysis tests | Edge case coverage |
| 118 | `test-state-machine` | Generate tests from state machine definition | State transition coverage |
| 119 | `test-error-path` | Generate tests for all error paths in a function | Error handling coverage |
| 120 | `test-memory-leak` | Set up memory leak detection in tests | Memory safety |
| 121 | `test-benchmark` | Generate benchmark tests for critical paths | Performance baseline |
| 122 | `test-golden-file` | Set up golden file testing for output validation | Output regression |
| 123 | `test-approval` | Set up approval testing for complex outputs | Human-verified tests |
| 124 | `test-table-driven` | Convert tests to table-driven format (Go/TS) | Test organization |
| 125 | `test-parametrize` | Parametrize existing tests for more coverage | Test amplification |
| 126 | `test-component` | Generate React/Vue component tests (Testing Library) | UI component testing |
| 127 | `test-hook` | Generate React hook tests with renderHook | Hook logic testing |
| 128 | `test-store` | Generate state management tests (Redux/Zustand/MobX) | State logic testing |
| 129 | `test-cli` | Generate tests for CLI commands and flags | CLI tool testing |
| 130 | `test-report-html` | Generate rich HTML test report from results | Test visibility |

---

## 3. Code Quality & Review (131–190)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 131 | `review-pr` | Deep review of PR with security, performance, correctness | Catch issues before merge |
| 132 | `review-diff` | Review staged git diff for issues | Pre-commit quality |
| 133 | `review-file` | Deep review of a single file | File-level quality |
| 134 | `review-architecture` | Review architectural decisions and patterns | Design quality |
| 135 | `review-naming` | Audit variable/function/class naming quality | Readability |
| 136 | `review-types` | Audit TypeScript/Python type coverage and correctness | Type safety |
| 137 | `review-error-handling` | Audit error handling completeness | Robustness |
| 138 | `review-logging` | Audit logging quality (levels, context, PII) | Observability |
| 139 | `review-accessibility` | Review frontend code for accessibility issues | WCAG compliance |
| 140 | `review-i18n` | Review internationalization implementation | Global readiness |
| 141 | `review-sql` | Review SQL queries for correctness and performance | Query quality |
| 142 | `review-api-design` | Review API design against REST/GraphQL best practices | API quality |
| 143 | `review-schema` | Review database schema design | Data model quality |
| 144 | `review-deps` | Audit dependencies for security, size, alternatives | Dependency health |
| 145 | `review-bundle` | Analyze bundle size and suggest optimizations | Bundle size reduction |
| 146 | `review-memory` | Review code for memory leaks and inefficiency | Memory efficiency |
| 147 | `review-concurrency` | Review concurrent code for race conditions/deadlocks | Thread safety |
| 148 | `review-config` | Review configuration management patterns | Config quality |
| 149 | `review-env` | Audit environment variable usage and documentation | Environment hygiene |
| 150 | `review-migration` | Review database migration safety and rollback plan | Migration safety |
| 151 | `lint-setup` | Set up linting (ESLint/Ruff/golangci-lint) with strict rules | Consistent code style |
| 152 | `lint-fix` | Auto-fix all lintable issues in project | Quick cleanup |
| 153 | `lint-custom-rule` | Create custom lint rule for project-specific patterns | Custom enforcement |
| 154 | `format-setup` | Set up formatting (Prettier/Black/gofmt) with hooks | Consistent formatting |
| 155 | `format-check` | Check formatting without modifying files | CI verification |
| 156 | `complexity-report` | Generate cyclomatic/cognitive complexity report | Identify complex code |
| 157 | `complexity-reduce` | Reduce complexity of flagged functions | Simpler code |
| 158 | `duplication-detect` | Find code duplication across codebase | DRY violations |
| 159 | `duplication-extract` | Extract duplicated code into shared utilities | Code deduplication |
| 160 | `dead-code-detect` | Find unused exports, functions, variables, types | Code cleanup targets |
| 161 | `dead-code-remove` | Safely remove verified dead code | Smaller codebase |
| 162 | `import-sort` | Sort and organize imports consistently | Import hygiene |
| 163 | `import-circular` | Detect and resolve circular imports/dependencies | Module health |
| 164 | `import-optimize` | Optimize import statements (tree-shaking friendly) | Bundle optimization |
| 165 | `type-strict` | Migrate to strict TypeScript (no any, strict null checks) | Maximum type safety |
| 166 | `type-infer` | Add type annotations to untyped code | Gradual typing |
| 167 | `type-narrow` | Improve type narrowing and discrimination | Better type inference |
| 168 | `type-brand` | Add branded/nominal types for domain safety | Domain type safety |
| 169 | `type-guard` | Generate type guard functions | Runtime type checking |
| 170 | `type-zod-sync` | Sync Zod schemas with TypeScript types | Schema-type alignment |
| 171 | `comment-cleanup` | Remove outdated/obvious/misleading comments | Comment hygiene |
| 172 | `comment-todo` | Find and categorize all TODOs/FIXMEs/HACKs | Technical debt tracking |
| 173 | `comment-jsdoc` | Add JSDoc to public API functions | API documentation |
| 174 | `magic-number` | Replace magic numbers with named constants | Code clarity |
| 175 | `magic-string` | Replace magic strings with constants/enums | Code clarity |
| 176 | `early-return` | Refactor nested conditionals to early returns | Reduced nesting |
| 177 | `guard-clause` | Add guard clauses to function entry points | Clearer preconditions |
| 178 | `null-safety` | Audit and fix null/undefined handling | Null safety |
| 179 | `promise-audit` | Audit async code for unhandled rejections | Async safety |
| 180 | `error-boundary` | Add error boundaries to React component tree | Graceful error handling |
| 181 | `code-smell` | Detect code smells (long method, god class, etc.) | Refactoring targets |
| 182 | `coupling-analysis` | Analyze module coupling and suggest improvements | Loose coupling |
| 183 | `cohesion-analysis` | Analyze class/module cohesion metrics | High cohesion |
| 184 | `interface-segregation` | Split large interfaces into focused ones | Interface design |
| 185 | `dependency-inversion` | Refactor to depend on abstractions not concretions | Testability |
| 186 | `single-responsibility` | Split classes/modules that do too much | Focused modules |
| 187 | `open-closed` | Refactor to be open for extension, closed for modification | Extensibility |
| 188 | `consistency-check` | Check naming/pattern consistency across codebase | Consistency |
| 189 | `style-guide-gen` | Generate project-specific style guide from existing code | Team alignment |
| 190 | `tech-debt-score` | Calculate and report technical debt score | Debt visibility |

---

## 4. Debugging & Troubleshooting (191–250)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 191 | `debug-error` | Analyze error message/stack trace and suggest fixes | Faster resolution |
| 192 | `debug-build` | Fix build/compilation errors | Unblock development |
| 193 | `debug-runtime` | Diagnose runtime errors with context analysis | Root cause analysis |
| 194 | `debug-network` | Debug network/HTTP issues (CORS, SSL, DNS, timeout) | Network troubleshooting |
| 195 | `debug-memory` | Diagnose memory leaks and high memory usage | Memory debugging |
| 196 | `debug-cpu` | Profile and diagnose high CPU usage | CPU debugging |
| 197 | `debug-deadlock` | Detect and resolve deadlocks in concurrent code | Concurrency debugging |
| 198 | `debug-race` | Find and fix race conditions | Data race prevention |
| 199 | `debug-flaky` | Diagnose intermittent/flaky failures | Reliability |
| 200 | `debug-docker` | Debug Docker build/run issues | Container debugging |
| 201 | `debug-k8s` | Debug Kubernetes pod/service/ingress issues | Orchestration debugging |
| 202 | `debug-ci` | Debug CI/CD pipeline failures | Pipeline debugging |
| 203 | `debug-deploy` | Debug deployment failures (rollback if needed) | Deployment recovery |
| 204 | `debug-db-query` | Debug slow/failing database queries | Query debugging |
| 205 | `debug-db-connection` | Debug database connection pool issues | Connection debugging |
| 206 | `debug-auth` | Debug authentication/authorization failures | Auth debugging |
| 207 | `debug-cors` | Debug CORS errors with fix suggestions | CORS resolution |
| 208 | `debug-ssl` | Debug SSL/TLS certificate issues | SSL debugging |
| 209 | `debug-dns` | Debug DNS resolution issues | DNS debugging |
| 210 | `debug-proxy` | Debug proxy/reverse proxy configuration | Proxy debugging |
| 211 | `debug-websocket` | Debug WebSocket connection issues | Real-time debugging |
| 212 | `debug-sse` | Debug Server-Sent Events issues | Streaming debugging |
| 213 | `debug-graphql` | Debug GraphQL query/mutation errors | GraphQL debugging |
| 214 | `debug-grpc` | Debug gRPC service communication | RPC debugging |
| 215 | `debug-email` | Debug email delivery issues (SMTP, SPF, DKIM) | Email debugging |
| 216 | `debug-cron` | Debug scheduled job failures | Job debugging |
| 217 | `debug-queue` | Debug message queue issues (stuck, DLQ) | Queue debugging |
| 218 | `debug-cache` | Debug cache inconsistency/invalidation | Cache debugging |
| 219 | `debug-search` | Debug search relevance/indexing issues | Search debugging |
| 220 | `debug-react` | Debug React rendering/state/hooks issues | React debugging |
| 221 | `debug-nextjs` | Debug Next.js specific issues (SSR, RSC, routing) | Next.js debugging |
| 222 | `debug-webpack` | Debug Webpack/Vite build configuration | Bundler debugging |
| 223 | `debug-typescript` | Debug complex TypeScript type errors | Type debugging |
| 224 | `debug-python-import` | Debug Python import/module resolution errors | Python debugging |
| 225 | `debug-pip` | Debug pip/poetry/conda dependency conflicts | Python deps debugging |
| 226 | `debug-npm` | Debug npm/yarn/pnpm dependency issues | Node deps debugging |
| 227 | `debug-git` | Debug git issues (merge conflicts, rebase, reset) | Git debugging |
| 228 | `debug-permission` | Debug file/OS permission issues | Permission debugging |
| 229 | `debug-env` | Debug environment variable issues | Environment debugging |
| 230 | `debug-encoding` | Debug character encoding/Unicode issues | Encoding debugging |
| 231 | `debug-timezone` | Debug timezone-related bugs | Time debugging |
| 232 | `debug-locale` | Debug locale/i18n rendering issues | Localization debugging |
| 233 | `debug-mobile` | Debug mobile-specific issues (iOS/Android) | Mobile debugging |
| 234 | `debug-pwa` | Debug PWA issues (service worker, manifest, offline) | PWA debugging |
| 235 | `debug-payment` | Debug payment integration issues (Stripe/etc.) | Payment debugging |
| 236 | `debug-oauth` | Debug OAuth/OIDC flow issues | OAuth debugging |
| 237 | `debug-jwt` | Debug JWT token issues (expiry, claims, signing) | Token debugging |
| 238 | `debug-session` | Debug session management issues | Session debugging |
| 239 | `debug-rate-limit` | Debug rate limiting issues | Rate limit debugging |
| 240 | `debug-migration` | Debug database migration failures | Migration debugging |
| 241 | `debug-log-analyze` | Analyze log files for patterns and anomalies | Log analysis |
| 242 | `debug-bisect` | Use git bisect to find the commit that introduced a bug | Regression finding |
| 243 | `debug-diff` | Compare two versions to find what changed | Change analysis |
| 244 | `debug-perf-trace` | Add performance tracing to identify bottlenecks | Performance debugging |
| 245 | `debug-n+1` | Detect and fix N+1 query problems | Query optimization |
| 246 | `debug-infinite-loop` | Diagnose infinite loops and recursion | Loop debugging |
| 247 | `debug-event-loop` | Debug Node.js event loop blocking | Event loop debugging |
| 248 | `debug-goroutine` | Debug Go goroutine leaks and panics | Goroutine debugging |
| 249 | `debug-segfault` | Debug segmentation faults in C/C++/Rust | Memory debugging |
| 250 | `debug-wasm` | Debug WebAssembly issues | WASM debugging |

---

## 5. Refactoring & Cleanup (251–310)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 251 | `refactor-extract-fn` | Extract code block into a well-named function | Readability |
| 252 | `refactor-extract-module` | Extract related functions into a new module | Organization |
| 253 | `refactor-extract-component` | Extract React component from a larger one | Component composition |
| 254 | `refactor-extract-hook` | Extract custom hook from component logic | Reusable logic |
| 255 | `refactor-extract-service` | Extract business logic into service layer | Separation of concerns |
| 256 | `refactor-extract-repo` | Extract data access into repository pattern | Data abstraction |
| 257 | `refactor-inline` | Inline unnecessary abstractions/indirections | Simplification |
| 258 | `refactor-rename` | Rename symbol across entire codebase safely | Consistent naming |
| 259 | `refactor-move` | Move function/class/file with import updates | Code organization |
| 260 | `refactor-split-file` | Split large file into focused modules | File size management |
| 261 | `refactor-merge-files` | Merge related small files into cohesive module | File consolidation |
| 262 | `refactor-flatten` | Flatten deeply nested code (callbacks, conditionals) | Reduced nesting |
| 263 | `refactor-promise-to-async` | Convert Promises/callbacks to async/await | Modern async patterns |
| 264 | `refactor-class-to-fn` | Convert class components to functional (React) | Modern React |
| 265 | `refactor-fn-to-class` | Convert functions to class when OOP is clearer | OOP refactoring |
| 266 | `refactor-mutable-to-immutable` | Convert mutable patterns to immutable | Immutability |
| 267 | `refactor-imperative-to-declarative` | Convert imperative loops to declarative (map/filter) | Declarative style |
| 268 | `refactor-switch-to-strategy` | Replace switch/if-else chains with strategy pattern | Open-closed principle |
| 269 | `refactor-inheritance-to-composition` | Replace inheritance with composition | Flexible design |
| 270 | `refactor-singleton-to-di` | Replace singletons with dependency injection | Testability |
| 271 | `refactor-god-class` | Break up god class into focused classes | Single responsibility |
| 272 | `refactor-feature-envy` | Move methods to the class they most interact with | Proper encapsulation |
| 273 | `refactor-primitive-obsession` | Replace primitive types with domain types | Type safety |
| 274 | `refactor-data-clump` | Group related parameters into objects | Parameter cleanup |
| 275 | `refactor-long-param` | Reduce function parameter count | Cleaner signatures |
| 276 | `refactor-boolean-param` | Replace boolean parameters with named options | Readable call sites |
| 277 | `refactor-temporal-coupling` | Remove temporal coupling between methods | Robust ordering |
| 278 | `refactor-api-v2` | Create new API version while maintaining backward compat | API evolution |
| 279 | `refactor-monolith-to-modules` | Decompose monolith into modules | Modular architecture |
| 280 | `refactor-modules-to-microservices` | Extract modules into microservices | Service architecture |
| 281 | `refactor-orm-to-raw` | Replace ORM with raw/optimized queries | Performance |
| 282 | `refactor-raw-to-orm` | Replace raw queries with ORM | Safety & maintainability |
| 283 | `refactor-rest-to-graphql` | Migrate REST endpoints to GraphQL | API flexibility |
| 284 | `refactor-js-to-ts` | Migrate JavaScript to TypeScript | Type safety |
| 285 | `refactor-cjs-to-esm` | Convert CommonJS to ES Modules | Modern module system |
| 286 | `refactor-class-to-functional` | Convert OOP to functional programming style | Functional paradigm |
| 287 | `refactor-error-handling` | Standardize error handling patterns | Consistent errors |
| 288 | `refactor-logging` | Standardize logging with structured formats | Consistent logging |
| 289 | `refactor-config` | Centralize scattered configuration | Config management |
| 290 | `refactor-env-vars` | Organize and validate environment variables | Environment hygiene |
| 291 | `refactor-constants` | Extract and organize magic values into constants | Named constants |
| 292 | `refactor-utils` | Organize utility functions by domain | Utility organization |
| 293 | `refactor-types` | Organize and deduplicate type definitions | Type organization |
| 294 | `refactor-tests` | Restructure test suite for clarity and speed | Test organization |
| 295 | `refactor-fixtures` | Consolidate test fixtures and factories | Test data management |
| 296 | `refactor-middleware` | Refactor middleware chain for clarity | Middleware organization |
| 297 | `refactor-routes` | Reorganize routing for consistency | Route organization |
| 298 | `refactor-styles` | Refactor CSS/styles (BEM, CSS modules, Tailwind migration) | Style organization |
| 299 | `refactor-responsive` | Refactor responsive design approach | Responsive consistency |
| 300 | `cleanup-console-log` | Remove all console.log/print debugging statements | Production cleanup |
| 301 | `cleanup-commented-code` | Remove commented-out code blocks | Code hygiene |
| 302 | `cleanup-unused-deps` | Remove unused dependencies from package manifest | Dependency cleanup |
| 303 | `cleanup-unused-files` | Find and remove orphaned/unused files | File cleanup |
| 304 | `cleanup-unused-assets` | Find and remove unused images/fonts/media | Asset cleanup |
| 305 | `cleanup-git-history` | Clean up git history (squash, fixup, reorder) | History hygiene |
| 306 | `cleanup-branches` | Delete merged/stale branches | Branch hygiene |
| 307 | `cleanup-docker` | Remove unused Docker images/containers/volumes | Docker cleanup |
| 308 | `cleanup-node-modules` | Clear and reinstall node_modules | Dependency reset |
| 309 | `cleanup-cache` | Clear build/test/package caches | Cache cleanup |
| 310 | `cleanup-temp` | Remove temporary files and directories | Filesystem cleanup |

---

## 6. Architecture & Design (311–370)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 311 | `arch-review` | Review system architecture for anti-patterns | Architecture quality |
| 312 | `arch-diagram` | Generate architecture diagram (Mermaid/PlantUML) from code | Visual architecture |
| 313 | `arch-decision-record` | Create ADR (Architecture Decision Record) | Decision documentation |
| 314 | `arch-c4-model` | Generate C4 model diagrams (context, container, component) | Hierarchical views |
| 315 | `arch-sequence-diagram` | Generate sequence diagrams from code flow | Flow visualization |
| 316 | `arch-er-diagram` | Generate entity-relationship diagram from schema | Data model visualization |
| 317 | `arch-flow-diagram` | Generate flowchart from business logic | Logic visualization |
| 318 | `arch-dependency-graph` | Generate module dependency graph | Dependency visualization |
| 319 | `arch-event-flow` | Map event-driven architecture flows | Event architecture |
| 320 | `arch-state-machine` | Design state machine for complex workflows | State management |
| 321 | `arch-cqrs` | Implement CQRS pattern (Command Query Responsibility Segregation) | Read/write optimization |
| 322 | `arch-event-sourcing` | Implement event sourcing pattern | Audit trail & replay |
| 323 | `arch-saga` | Implement saga pattern for distributed transactions | Distributed consistency |
| 324 | `arch-circuit-breaker` | Implement circuit breaker for external services | Fault tolerance |
| 325 | `arch-bulkhead` | Implement bulkhead pattern for isolation | Failure isolation |
| 326 | `arch-retry` | Implement retry with exponential backoff and jitter | Resilient calls |
| 327 | `arch-rate-limiter` | Design and implement rate limiting strategy | Abuse prevention |
| 328 | `arch-cache-strategy` | Design caching strategy (layers, invalidation, TTL) | Performance |
| 329 | `arch-search-strategy` | Design search architecture (Elasticsearch/Typesense/etc.) | Search capability |
| 330 | `arch-queue-strategy` | Design message queue architecture | Async processing |
| 331 | `arch-notification` | Design notification system (push, email, SMS, in-app) | User notification |
| 332 | `arch-file-storage` | Design file storage architecture (S3, local, CDN) | File management |
| 333 | `arch-multi-tenant` | Design multi-tenancy architecture | SaaS multi-tenancy |
| 334 | `arch-plugin-system` | Design plugin/extension architecture | Extensibility |
| 335 | `arch-feature-flag` | Implement feature flag system | Gradual rollout |
| 336 | `arch-ab-test` | Design A/B testing infrastructure | Experimentation |
| 337 | `arch-audit-log` | Design audit logging system | Compliance |
| 338 | `arch-versioning` | Design API/data versioning strategy | Backward compatibility |
| 339 | `arch-migration-strategy` | Design data migration strategy | Data evolution |
| 340 | `arch-rollback-plan` | Design rollback procedures for any change | Safety nets |
| 341 | `arch-blue-green` | Design blue-green deployment architecture | Zero-downtime deploy |
| 342 | `arch-canary` | Design canary deployment pipeline | Gradual rollout |
| 343 | `arch-disaster-recovery` | Design disaster recovery plan | Business continuity |
| 344 | `arch-backup-strategy` | Design backup and restore strategy | Data protection |
| 345 | `arch-scaling-plan` | Design horizontal/vertical scaling strategy | Growth readiness |
| 346 | `arch-sharding` | Design database sharding strategy | Horizontal DB scaling |
| 347 | `arch-read-replica` | Design read replica architecture | Read scaling |
| 348 | `arch-cdn-strategy` | Design CDN and edge caching strategy | Global performance |
| 349 | `arch-api-gateway` | Design API gateway configuration | API management |
| 350 | `arch-service-mesh` | Design service mesh (Istio/Linkerd) configuration | Service communication |
| 351 | `arch-domain-model` | Design domain model using DDD principles | Domain-driven design |
| 352 | `arch-bounded-context` | Define bounded contexts and context map | DDD boundaries |
| 353 | `arch-aggregate` | Design aggregates and aggregate roots | DDD consistency |
| 354 | `arch-value-object` | Design value objects for domain concepts | Domain modeling |
| 355 | `arch-domain-event` | Design domain events and event handlers | Event-driven DDD |
| 356 | `arch-hexagonal` | Implement hexagonal (ports & adapters) architecture | Clean architecture |
| 357 | `arch-clean` | Implement clean architecture layers | Dependency inversion |
| 358 | `arch-vertical-slice` | Implement vertical slice architecture | Feature organization |
| 359 | `arch-modular-monolith` | Design modular monolith architecture | Simple + modular |
| 360 | `arch-strangler-fig` | Plan strangler fig migration pattern | Legacy migration |
| 361 | `arch-anti-corruption` | Design anti-corruption layer for legacy integration | Legacy isolation |
| 362 | `arch-bff` | Design Backend for Frontend pattern | Client-specific APIs |
| 363 | `arch-federation` | Design GraphQL federation architecture | Distributed GraphQL |
| 364 | `arch-edge-computing` | Design edge computing architecture | Low-latency |
| 365 | `arch-serverless` | Design serverless architecture (Lambda/Functions) | Event-driven infra |
| 366 | `arch-real-time` | Design real-time data architecture | Live updates |
| 367 | `arch-batch-processing` | Design batch processing pipeline | Large data processing |
| 368 | `arch-etl` | Design ETL/ELT pipeline architecture | Data integration |
| 369 | `arch-data-lake` | Design data lake architecture | Analytics foundation |
| 370 | `arch-trade-off` | Analyze trade-offs for architectural decision | Informed decisions |

---

## 7. Database & Data (371–440)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 371 | `db-design-schema` | Design normalized database schema from requirements | Correct data model |
| 372 | `db-optimize-query` | Optimize slow SQL query with EXPLAIN analysis | Query performance |
| 373 | `db-add-index` | Analyze and add missing indexes | Read performance |
| 374 | `db-remove-index` | Find and remove unused/redundant indexes | Write performance |
| 375 | `db-migration-create` | Create database migration with up/down | Schema change |
| 376 | `db-migration-rollback` | Create rollback migration for failed change | Schema safety |
| 377 | `db-migration-zero-downtime` | Create zero-downtime migration (expand/contract) | No-downtime changes |
| 378 | `db-seed` | Create comprehensive seed data | Development data |
| 379 | `db-backup-restore` | Set up automated backup and test restore | Data protection |
| 380 | `db-partition` | Set up table partitioning strategy | Large table management |
| 381 | `db-vacuum` | Configure autovacuum and maintenance | PostgreSQL health |
| 382 | `db-connection-pool` | Configure connection pool sizing | Connection management |
| 383 | `db-replication` | Set up database replication | High availability |
| 384 | `db-failover` | Configure automatic failover | Disaster recovery |
| 385 | `db-audit` | Implement database audit trail (triggers/CDC) | Compliance tracking |
| 386 | `db-row-security` | Implement row-level security policies | Data access control |
| 387 | `db-encrypt` | Implement column-level encryption | Data at rest security |
| 388 | `db-anonymize` | Anonymize production data for dev/staging | Privacy compliance |
| 389 | `db-normalize` | Normalize denormalized tables | Data integrity |
| 390 | `db-denormalize` | Strategically denormalize for read performance | Read optimization |
| 391 | `db-materialized-view` | Create and manage materialized views | Computed data caching |
| 392 | `db-stored-proc` | Create stored procedures with error handling | Server-side logic |
| 393 | `db-trigger` | Create database triggers with safety checks | Automatic data ops |
| 394 | `db-function` | Create database functions (PLpgSQL/etc.) | Reusable DB logic |
| 395 | `db-constraint` | Add check constraints and domain types | Data validation |
| 396 | `db-foreign-key` | Audit and fix foreign key relationships | Referential integrity |
| 397 | `db-cascade-audit` | Audit cascade delete/update behavior | Safe deletions |
| 398 | `db-deadlock-fix` | Diagnose and fix database deadlocks | Concurrency |
| 399 | `db-lock-analysis` | Analyze lock contention and fix | Performance |
| 400 | `db-slow-log` | Configure and analyze slow query log | Query monitoring |
| 401 | `db-pg-stat` | Analyze pg_stat_statements for optimization | PostgreSQL insights |
| 402 | `db-redis-design` | Design Redis data structures and patterns | Cache design |
| 403 | `db-redis-cluster` | Configure Redis cluster/sentinel | Redis HA |
| 404 | `db-mongodb-schema` | Design MongoDB schema and indexes | Document DB design |
| 405 | `db-elasticsearch-mapping` | Design Elasticsearch mappings and settings | Search index design |
| 406 | `db-timeseries` | Design time-series data storage (TimescaleDB/InfluxDB) | Time data optimization |
| 407 | `db-graph` | Design graph database schema (Neo4j/etc.) | Relationship data |
| 408 | `db-vector` | Set up vector database for embeddings (pgvector/Pinecone) | AI/ML data store |
| 409 | `db-json-column` | Design JSONB column usage patterns | Flexible schema |
| 410 | `db-full-text-search` | Set up full-text search (PostgreSQL/etc.) | Text search |
| 411 | `db-geospatial` | Set up geospatial queries (PostGIS/etc.) | Location queries |
| 412 | `db-recursive-query` | Write recursive CTE queries (tree structures) | Hierarchical data |
| 413 | `db-window-fn` | Write window function queries | Analytics queries |
| 414 | `db-pivot` | Write pivot/crosstab queries | Data transformation |
| 415 | `db-upsert` | Implement upsert (ON CONFLICT) patterns | Idempotent writes |
| 416 | `db-batch-insert` | Optimize batch insert performance | Bulk data loading |
| 417 | `db-batch-update` | Optimize batch update patterns | Bulk modifications |
| 418 | `db-soft-delete` | Implement soft delete pattern | Data retention |
| 419 | `db-temporal` | Implement temporal/versioned data pattern | Historical data |
| 420 | `db-multi-tenant-schema` | Implement multi-tenant database schema | Tenant isolation |
| 421 | `data-pipeline` | Design data processing pipeline | Data processing |
| 422 | `data-validation` | Implement data validation layer | Data quality |
| 423 | `data-transform` | Write data transformation logic | Data mapping |
| 424 | `data-export` | Implement data export (CSV/Excel/JSON) | Data extraction |
| 425 | `data-import` | Implement data import with validation | Data ingestion |
| 426 | `data-sync` | Implement data synchronization between systems | System sync |
| 427 | `data-dedup` | Implement data deduplication logic | Data quality |
| 428 | `data-archive` | Implement data archival strategy | Storage management |
| 429 | `data-retention` | Implement data retention policies | Compliance |
| 430 | `data-gdpr` | Implement GDPR data handling (right to be forgotten, etc.) | Privacy compliance |
| 431 | `data-masking` | Implement dynamic data masking | Privacy |
| 432 | `data-lineage` | Track data lineage across transformations | Data governance |
| 433 | `data-quality-check` | Implement automated data quality checks | Data reliability |
| 434 | `data-reconciliation` | Implement data reconciliation between systems | Consistency |
| 435 | `data-catalog` | Create data catalog/dictionary | Data documentation |
| 436 | `prisma-optimize` | Optimize Prisma schema and queries | ORM performance |
| 437 | `drizzle-setup` | Set up Drizzle ORM with migrations | Modern ORM |
| 438 | `typeorm-optimize` | Optimize TypeORM entities and queries | ORM performance |
| 439 | `sqlalchemy-optimize` | Optimize SQLAlchemy models and queries | Python ORM perf |
| 440 | `knex-optimize` | Optimize Knex.js query builder usage | Query builder perf |

---

## 8. DevOps & Infrastructure (441–510)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 441 | `docker-optimize` | Optimize Dockerfile (multi-stage, layer caching, size) | Smaller, faster builds |
| 442 | `docker-compose` | Create Docker Compose for local dev environment | Local dev setup |
| 443 | `docker-security` | Harden Docker configuration (rootless, secrets, scanning) | Container security |
| 444 | `docker-debug` | Debug Docker container issues | Container debugging |
| 445 | `docker-network` | Configure Docker networking (bridges, overlays) | Container networking |
| 446 | `docker-volume` | Configure Docker volume strategies | Data persistence |
| 447 | `docker-registry` | Set up private Docker registry | Image management |
| 448 | `docker-buildx` | Set up multi-arch Docker builds (amd64/arm64) | Cross-platform images |
| 449 | `k8s-deploy` | Create Kubernetes deployment manifests | Container orchestration |
| 450 | `k8s-service` | Configure Kubernetes services and networking | Service discovery |
| 451 | `k8s-ingress` | Configure ingress controller (nginx/traefik) | Traffic routing |
| 452 | `k8s-hpa` | Configure horizontal pod autoscaler | Auto-scaling |
| 453 | `k8s-secrets` | Manage Kubernetes secrets securely | Secret management |
| 454 | `k8s-configmap` | Manage ConfigMaps for application configuration | Config management |
| 455 | `k8s-helm-chart` | Create Helm chart for application | Package management |
| 456 | `k8s-kustomize` | Set up Kustomize overlays for environments | Environment config |
| 457 | `k8s-rbac` | Configure RBAC policies | Access control |
| 458 | `k8s-network-policy` | Configure network policies | Network security |
| 459 | `k8s-pod-security` | Configure pod security standards | Pod hardening |
| 460 | `k8s-monitoring` | Set up monitoring stack (Prometheus/Grafana) | Cluster monitoring |
| 461 | `ci-github-actions` | Create/optimize GitHub Actions workflow | CI/CD automation |
| 462 | `ci-gitlab` | Create GitLab CI pipeline | CI/CD automation |
| 463 | `ci-jenkins` | Create Jenkinsfile pipeline | CI/CD automation |
| 464 | `ci-circle` | Create CircleCI configuration | CI/CD automation |
| 465 | `ci-matrix` | Set up CI test matrix | Cross-env testing |
| 466 | `ci-cache` | Optimize CI caching strategy | Faster CI |
| 467 | `ci-artifact` | Configure CI artifact storage and sharing | Build artifacts |
| 468 | `ci-release` | Set up automated release pipeline (semantic-release) | Automated releases |
| 469 | `ci-changelog` | Generate changelog from commits (conventional-changelog) | Release notes |
| 470 | `ci-version-bump` | Automate version bumping | Version management |
| 471 | `terraform-module` | Create reusable Terraform module | IaC modularity |
| 472 | `terraform-state` | Configure Terraform state management | IaC state |
| 473 | `terraform-import` | Import existing infrastructure into Terraform | IaC adoption |
| 474 | `terraform-plan-review` | Review Terraform plan for safety | IaC safety |
| 475 | `terraform-cost` | Estimate Terraform infrastructure costs | Cost planning |
| 476 | `pulumi-stack` | Create Pulumi infrastructure stack | IaC (code-native) |
| 477 | `ansible-playbook` | Create Ansible playbook for server provisioning | Config management |
| 478 | `nginx-config` | Generate and optimize Nginx configuration | Web server config |
| 479 | `caddy-config` | Generate Caddy server configuration | Web server config |
| 480 | `traefik-config` | Generate Traefik configuration | Reverse proxy |
| 481 | `ssl-setup` | Set up SSL/TLS (Let's Encrypt, cert management) | HTTPS |
| 482 | `dns-setup` | Configure DNS records and routing | Domain management |
| 483 | `cdn-setup` | Configure CDN (Cloudflare/CloudFront) | Content delivery |
| 484 | `monitoring-setup` | Set up application monitoring (Datadog/NewRelic/Grafana) | Observability |
| 485 | `logging-setup` | Set up centralized logging (ELK/Loki/CloudWatch) | Log aggregation |
| 486 | `alerting-setup` | Configure alerting rules and escalation | Incident alerting |
| 487 | `tracing-setup` | Set up distributed tracing (Jaeger/Zipkin/OpenTelemetry) | Request tracing |
| 488 | `metrics-setup` | Set up application metrics (Prometheus/StatsD) | Performance metrics |
| 489 | `health-check` | Implement comprehensive health check endpoints | Service health |
| 490 | `readiness-probe` | Implement readiness/liveness probes | K8s health |
| 491 | `runbook-create` | Create operational runbook for incidents | Incident response |
| 492 | `sla-dashboard` | Create SLA/SLO dashboard | Reliability tracking |
| 493 | `incident-response` | Create incident response playbook | Incident management |
| 494 | `postmortem` | Generate postmortem template from incident | Learning from incidents |
| 495 | `chaos-monkey` | Set up chaos engineering experiments | Resilience testing |
| 496 | `load-test-setup` | Set up load testing infrastructure (k6/Gatling) | Performance testing |
| 497 | `canary-deploy` | Configure canary deployment pipeline | Safe deployments |
| 498 | `blue-green-deploy` | Configure blue-green deployment | Zero-downtime deploy |
| 499 | `rolling-update` | Configure rolling update strategy | Gradual deployment |
| 500 | `rollback-procedure` | Create automated rollback procedure | Deployment safety |
| 501 | `backup-verify` | Verify backup integrity and restore time | Backup reliability |
| 502 | `cost-optimize` | Analyze and optimize cloud infrastructure costs | Cost reduction |
| 503 | `resource-right-size` | Right-size compute resources (CPU, memory, storage) | Cost optimization |
| 504 | `spot-instance` | Configure spot/preemptible instance strategy | Cost savings |
| 505 | `auto-shutdown` | Configure auto-shutdown for dev/staging environments | Cost savings |
| 506 | `log-rotation` | Configure log rotation and retention | Storage management |
| 507 | `cron-monitor` | Set up cron job monitoring and alerting | Job reliability |
| 508 | `secrets-rotation` | Automate secret rotation | Security automation |
| 509 | `infra-drift-detect` | Detect infrastructure drift from IaC | Config consistency |
| 510 | `compliance-scan` | Scan infrastructure for compliance (CIS, SOC2) | Compliance |

---

## 9. Security (511–570)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 511 | `sec-audit` | Full security audit of application code | Security posture |
| 512 | `sec-owasp-check` | Check against OWASP Top 10 vulnerabilities | Common vuln prevention |
| 513 | `sec-dependency-scan` | Scan dependencies for known vulnerabilities | Supply chain security |
| 514 | `sec-sast` | Run static application security testing | Code security |
| 515 | `sec-dast` | Configure dynamic application security testing | Runtime security |
| 516 | `sec-secret-scan` | Scan for hardcoded secrets (GitLeaks/TruffleHog) | Secret leak prevention |
| 517 | `sec-container-scan` | Scan Docker images for vulnerabilities (Trivy/Snyk) | Container security |
| 518 | `sec-iac-scan` | Scan IaC for misconfigurations (Checkov/tfsec) | Infra security |
| 519 | `sec-auth-implement` | Implement authentication (JWT, session, OAuth) | Auth implementation |
| 520 | `sec-oauth-setup` | Set up OAuth2/OIDC flow (Google, GitHub, etc.) | Social auth |
| 521 | `sec-saml` | Implement SAML SSO | Enterprise SSO |
| 522 | `sec-mfa` | Implement multi-factor authentication | Account security |
| 523 | `sec-passkey` | Implement WebAuthn/passkey authentication | Passwordless auth |
| 524 | `sec-rbac` | Implement role-based access control | Authorization |
| 525 | `sec-abac` | Implement attribute-based access control | Fine-grained auth |
| 526 | `sec-api-key` | Implement API key authentication and management | API auth |
| 527 | `sec-rate-limit` | Implement rate limiting (token bucket, sliding window) | Abuse prevention |
| 528 | `sec-csrf` | Implement CSRF protection | CSRF prevention |
| 529 | `sec-xss` | Audit and fix XSS vulnerabilities | XSS prevention |
| 530 | `sec-sqli` | Audit and fix SQL injection vulnerabilities | SQL injection prevention |
| 531 | `sec-nosqli` | Audit and fix NoSQL injection vulnerabilities | NoSQL injection prevention |
| 532 | `sec-command-injection` | Audit and fix command injection | OS command safety |
| 533 | `sec-path-traversal` | Audit and fix path traversal vulnerabilities | File access safety |
| 534 | `sec-ssrf` | Audit and fix SSRF vulnerabilities | Request safety |
| 535 | `sec-xxe` | Audit and fix XXE vulnerabilities | XML safety |
| 536 | `sec-deserialization` | Audit and fix insecure deserialization | Data safety |
| 537 | `sec-headers` | Configure security headers (CSP, HSTS, X-Frame, etc.) | HTTP security |
| 538 | `sec-cors` | Configure CORS securely | Cross-origin security |
| 539 | `sec-cookie` | Audit and fix cookie security (HttpOnly, Secure, SameSite) | Cookie security |
| 540 | `sec-encryption` | Implement encryption at rest and in transit | Data encryption |
| 541 | `sec-hashing` | Implement secure password hashing (bcrypt/argon2) | Password security |
| 542 | `sec-key-management` | Implement cryptographic key management | Key security |
| 543 | `sec-jwt-best-practice` | Audit JWT implementation for security issues | Token security |
| 544 | `sec-session` | Implement secure session management | Session security |
| 545 | `sec-file-upload` | Secure file upload handling (type checking, scanning) | Upload security |
| 546 | `sec-input-validation` | Implement comprehensive input validation | Input safety |
| 547 | `sec-output-encoding` | Implement proper output encoding | Output safety |
| 548 | `sec-error-handling` | Ensure errors don't leak sensitive information | Info leak prevention |
| 549 | `sec-logging-audit` | Ensure logs don't contain PII/secrets | Log security |
| 550 | `sec-gdpr-compliance` | Implement GDPR technical requirements | Privacy compliance |
| 551 | `sec-hipaa-compliance` | Implement HIPAA technical requirements | Healthcare compliance |
| 552 | `sec-pci-compliance` | Implement PCI DSS requirements | Payment compliance |
| 553 | `sec-soc2-controls` | Implement SOC 2 technical controls | Enterprise compliance |
| 554 | `sec-penetration-test` | Create penetration test plan and scripts | Security testing |
| 555 | `sec-threat-model` | Create threat model (STRIDE/DREAD) | Risk assessment |
| 556 | `sec-attack-surface` | Map application attack surface | Security scope |
| 557 | `sec-incident-plan` | Create security incident response plan | Incident readiness |
| 558 | `sec-breach-notification` | Implement breach notification workflow | Compliance |
| 559 | `sec-access-review` | Audit and review access permissions | Least privilege |
| 560 | `sec-supply-chain` | Audit software supply chain security | Supply chain security |
| 561 | `sec-sbom` | Generate Software Bill of Materials | Dependency transparency |
| 562 | `sec-license-audit` | Audit dependency licenses for compatibility | License compliance |
| 563 | `sec-code-signing` | Set up code signing for releases | Release integrity |
| 564 | `sec-webhook-verify` | Implement webhook signature verification | Webhook security |
| 565 | `sec-api-throttle` | Implement API throttling and abuse detection | API protection |
| 566 | `sec-bot-detection` | Implement bot detection and CAPTCHA | Automated abuse prevention |
| 567 | `sec-content-policy` | Implement content moderation and safety | User content safety |
| 568 | `sec-subresource-integrity` | Implement SRI for external resources | CDN safety |
| 569 | `sec-csp-policy` | Generate and test Content Security Policy | XSS prevention |
| 570 | `sec-pentest-fix` | Fix issues found in penetration test report | Remediation |

---

## 10. Performance (571–630)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 571 | `perf-profile` | Profile application performance and identify bottlenecks | Find slowness |
| 572 | `perf-lighthouse` | Run and fix Lighthouse performance issues | Web vitals |
| 573 | `perf-core-web-vitals` | Optimize Core Web Vitals (LCP, FID, CLS) | User experience |
| 574 | `perf-bundle-analyze` | Analyze and optimize JavaScript bundle size | Load time |
| 575 | `perf-code-split` | Implement code splitting and lazy loading | Initial load |
| 576 | `perf-tree-shake` | Optimize tree shaking configuration | Bundle size |
| 577 | `perf-image-optimize` | Optimize images (format, size, lazy loading, responsive) | Image performance |
| 578 | `perf-font-optimize` | Optimize web font loading (subset, preload, display) | Font performance |
| 579 | `perf-css-optimize` | Optimize CSS (critical CSS, purge unused, minimize) | CSS performance |
| 580 | `perf-preload` | Add resource hints (preload, prefetch, preconnect) | Resource loading |
| 581 | `perf-service-worker` | Implement service worker for caching/offline | Offline & speed |
| 582 | `perf-ssr-optimize` | Optimize server-side rendering performance | SSR speed |
| 583 | `perf-streaming-ssr` | Implement streaming SSR | Time to first byte |
| 584 | `perf-edge-render` | Move rendering to edge (Cloudflare Workers/Vercel Edge) | Latency reduction |
| 585 | `perf-api-optimize` | Optimize API response time | API speed |
| 586 | `perf-query-optimize` | Optimize database query performance | Query speed |
| 587 | `perf-n-plus-1` | Detect and fix N+1 query problems | Query efficiency |
| 588 | `perf-connection-pool` | Optimize database connection pooling | Connection efficiency |
| 589 | `perf-cache-add` | Add caching layer (Redis/Memcached/in-memory) | Response time |
| 590 | `perf-cache-invalidate` | Design cache invalidation strategy | Cache correctness |
| 591 | `perf-cache-warm` | Implement cache warming strategy | Cold start mitigation |
| 592 | `perf-pagination` | Implement efficient pagination (cursor vs offset) | Large dataset handling |
| 593 | `perf-batch` | Implement request batching/debouncing | Network efficiency |
| 594 | `perf-compression` | Configure response compression (gzip/brotli) | Transfer size |
| 595 | `perf-http2` | Configure HTTP/2 and HTTP/3 | Protocol optimization |
| 596 | `perf-cdn-config` | Optimize CDN configuration and cache rules | Content delivery |
| 597 | `perf-dns-prefetch` | Configure DNS prefetching for external domains | DNS latency |
| 598 | `perf-lazy-load` | Implement lazy loading for components/data | Initial load |
| 599 | `perf-virtual-scroll` | Implement virtual scrolling for large lists | Rendering performance |
| 600 | `perf-debounce` | Add debouncing/throttling to frequent operations | CPU usage |
| 601 | `perf-memoize` | Add memoization for expensive computations | Computation caching |
| 602 | `perf-worker-thread` | Move heavy computation to Web Workers/worker threads | Main thread freedom |
| 603 | `perf-wasm` | Optimize hot paths with WebAssembly | Computation speed |
| 604 | `perf-stream` | Implement streaming for large data processing | Memory efficiency |
| 605 | `perf-memory-optimize` | Reduce memory usage and prevent leaks | Memory efficiency |
| 606 | `perf-gc-tune` | Tune garbage collector settings | GC performance |
| 607 | `perf-concurrency` | Optimize concurrent/parallel processing | Throughput |
| 608 | `perf-async-optimize` | Optimize async operations (Promise.all, etc.) | Async efficiency |
| 609 | `perf-startup` | Optimize application startup time | Cold start |
| 610 | `perf-lambda-cold-start` | Optimize Lambda/serverless cold starts | Serverless perf |
| 611 | `perf-docker-startup` | Optimize Docker container startup time | Container speed |
| 612 | `perf-build-speed` | Optimize build pipeline speed | Dev experience |
| 613 | `perf-hmr` | Optimize hot module replacement speed | Dev experience |
| 614 | `perf-test-speed` | Optimize test suite execution speed | CI speed |
| 615 | `perf-ci-speed` | Optimize CI/CD pipeline execution time | CI speed |
| 616 | `perf-dependency-size` | Audit and reduce dependency size | Install speed |
| 617 | `perf-react-render` | Optimize React rendering (memo, useMemo, useCallback) | UI responsiveness |
| 618 | `perf-react-profiler` | Profile React app with React DevTools | React optimization |
| 619 | `perf-animation` | Optimize animations (requestAnimationFrame, GPU) | Smooth animations |
| 620 | `perf-scroll` | Optimize scroll performance (passive listeners) | Scroll smoothness |
| 621 | `perf-input` | Optimize input handling latency | Input responsiveness |
| 622 | `perf-layout-shift` | Fix layout shift issues (CLS) | Visual stability |
| 623 | `perf-paint-optimize` | Reduce paint/composite operations | Render performance |
| 624 | `perf-sql-plan` | Analyze SQL execution plans for optimization | Query planning |
| 625 | `perf-json-optimize` | Optimize JSON serialization/deserialization | Data handling |
| 626 | `perf-regex-optimize` | Optimize regular expressions (ReDoS prevention) | Regex performance |
| 627 | `perf-algorithm` | Optimize algorithm complexity (Big O analysis) | Algorithmic efficiency |
| 628 | `perf-data-structure` | Choose optimal data structure for use case | Data efficiency |
| 629 | `perf-budget` | Set up and enforce performance budgets | Performance governance |
| 630 | `perf-monitoring` | Set up real-user monitoring (RUM) | Production performance |

---

## 11. Documentation (631–680)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 631 | `doc-readme` | Generate comprehensive project README | Project documentation |
| 632 | `doc-contributing` | Create CONTRIBUTING.md guide | Contributor guidance |
| 633 | `doc-api` | Generate API documentation (OpenAPI/Swagger) | API reference |
| 634 | `doc-changelog` | Generate and maintain CHANGELOG.md | Release tracking |
| 635 | `doc-adr` | Create Architecture Decision Record | Decision documentation |
| 636 | `doc-runbook` | Create operational runbook | Operations guide |
| 637 | `doc-onboarding` | Create developer onboarding guide | New dev ramp-up |
| 638 | `doc-style-guide` | Generate project coding style guide | Team consistency |
| 639 | `doc-component` | Generate component documentation (Storybook stories) | UI documentation |
| 640 | `doc-database` | Generate database schema documentation | Data documentation |
| 641 | `doc-deployment` | Create deployment documentation | Deployment guide |
| 642 | `doc-troubleshooting` | Create troubleshooting guide | Self-service debugging |
| 643 | `doc-faq` | Generate FAQ from issues/tickets | Common answers |
| 644 | `doc-security` | Create security documentation (SECURITY.md) | Security guidance |
| 645 | `doc-privacy` | Create privacy policy template | Legal compliance |
| 646 | `doc-terms` | Create terms of service template | Legal documentation |
| 647 | `doc-license` | Choose and add appropriate license | Legal protection |
| 648 | `doc-code-of-conduct` | Create CODE_OF_CONDUCT.md | Community guidelines |
| 649 | `doc-issue-template` | Create GitHub issue templates | Issue quality |
| 650 | `doc-pr-template` | Create pull request template | PR quality |
| 651 | `doc-codemap` | Generate codebase map/overview | Code navigation |
| 652 | `doc-dependency-graph` | Document dependency relationships | Dependency understanding |
| 653 | `doc-data-flow` | Document data flow through the system | Data understanding |
| 654 | `doc-api-versioning` | Document API versioning strategy | API evolution |
| 655 | `doc-error-codes` | Document error codes and meanings | Error reference |
| 656 | `doc-env-vars` | Document all environment variables | Environment setup |
| 657 | `doc-cli-help` | Generate CLI command documentation | CLI reference |
| 658 | `doc-man-page` | Generate man page for CLI tool | Unix documentation |
| 659 | `doc-sdk` | Generate SDK/library usage documentation | Library guide |
| 660 | `doc-tutorial` | Create step-by-step tutorial | Learning resource |
| 661 | `doc-quickstart` | Create quickstart guide | Fast onboarding |
| 662 | `doc-migration-guide` | Create version migration guide | Upgrade guidance |
| 663 | `doc-architecture` | Document system architecture | Architecture reference |
| 664 | `doc-infrastructure` | Document infrastructure setup | Infra reference |
| 665 | `doc-monitoring` | Document monitoring and alerting setup | Observability guide |
| 666 | `doc-incident-template` | Create incident report template | Incident documentation |
| 667 | `doc-postmortem-template` | Create postmortem template | Learning from failures |
| 668 | `doc-sla` | Document SLA/SLO definitions | Reliability contracts |
| 669 | `doc-handoff` | Create project handoff document | Knowledge transfer |
| 670 | `doc-technical-spec` | Generate technical specification document | Feature spec |
| 671 | `doc-prd` | Generate product requirements document | Product spec |
| 672 | `doc-rfc` | Create RFC (Request for Comments) document | Proposal process |
| 673 | `doc-test-plan` | Create test plan document | Testing strategy |
| 674 | `doc-release-notes` | Generate user-facing release notes | Release communication |
| 675 | `doc-internal-wiki` | Generate internal wiki/knowledge base structure | Team knowledge |
| 676 | `doc-openapi-validate` | Validate OpenAPI spec for completeness | API doc quality |
| 677 | `doc-typescript-api` | Generate TypeDoc API documentation | TS library docs |
| 678 | `doc-python-api` | Generate Sphinx/MkDocs API documentation | Python library docs |
| 679 | `doc-go-api` | Generate Go documentation (godoc format) | Go library docs |
| 680 | `doc-diagram` | Generate technical diagram from description (Mermaid) | Visual documentation |

---

## 12. API & Integration (681–740)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 681 | `api-design` | Design RESTful API with proper resources and verbs | API quality |
| 682 | `api-graphql-design` | Design GraphQL schema with types, queries, mutations | GraphQL API design |
| 683 | `api-grpc-design` | Design gRPC service with proto definitions | RPC API design |
| 684 | `api-websocket-design` | Design WebSocket protocol and message types | Real-time API design |
| 685 | `api-sse-design` | Design Server-Sent Events implementation | Streaming API design |
| 686 | `api-webhook-design` | Design webhook system (delivery, retry, signing) | Event notification API |
| 687 | `api-versioning` | Implement API versioning strategy (URL/header/content) | API evolution |
| 688 | `api-pagination` | Implement pagination (cursor, offset, keyset) | Large dataset handling |
| 689 | `api-filtering` | Implement filtering, sorting, field selection | Flexible querying |
| 690 | `api-error-format` | Implement consistent error response format (RFC 7807) | Error consistency |
| 691 | `api-rate-limit` | Implement rate limiting with headers | Abuse prevention |
| 692 | `api-idempotency` | Implement idempotency keys for POST requests | Safe retries |
| 693 | `api-batch` | Implement batch/bulk API endpoints | Efficiency |
| 694 | `api-etag` | Implement ETag caching for API responses | Cache efficiency |
| 695 | `api-hateoas` | Implement HATEOAS links in API responses | API discoverability |
| 696 | `api-openapi-gen` | Generate OpenAPI spec from code/annotations | API documentation |
| 697 | `api-client-gen` | Generate typed client SDK from OpenAPI spec | Client generation |
| 698 | `api-mock` | Create mock API server from spec | Development independence |
| 699 | `api-gateway-setup` | Set up API gateway (Kong/Tyk/AWS API GW) | API management |
| 700 | `integrate-stripe` | Integrate Stripe payments (checkout, subscriptions, webhooks) | Payment processing |
| 701 | `integrate-paypal` | Integrate PayPal payments | Payment processing |
| 702 | `integrate-razorpay` | Integrate Razorpay payments | India payments |
| 703 | `integrate-sendgrid` | Integrate SendGrid for email | Email delivery |
| 704 | `integrate-resend` | Integrate Resend for email | Modern email delivery |
| 705 | `integrate-twilio` | Integrate Twilio for SMS/voice | Communication |
| 706 | `integrate-firebase` | Integrate Firebase (auth, firestore, FCM, storage) | Google platform |
| 707 | `integrate-supabase` | Integrate Supabase (auth, DB, storage, realtime) | Backend as service |
| 708 | `integrate-clerk` | Integrate Clerk for authentication | User management |
| 709 | `integrate-auth0` | Integrate Auth0 for authentication | Enterprise auth |
| 710 | `integrate-aws-s3` | Integrate AWS S3 for file storage | Object storage |
| 711 | `integrate-aws-sqs` | Integrate AWS SQS for message queuing | Message queue |
| 712 | `integrate-aws-sns` | Integrate AWS SNS for notifications | Push notifications |
| 713 | `integrate-aws-lambda` | Integrate AWS Lambda functions | Serverless compute |
| 714 | `integrate-aws-ses` | Integrate AWS SES for email | AWS email |
| 715 | `integrate-cloudflare-r2` | Integrate Cloudflare R2 for storage | Edge storage |
| 716 | `integrate-redis` | Integrate Redis (caching, pub/sub, sessions) | In-memory data |
| 717 | `integrate-elasticsearch` | Integrate Elasticsearch for search | Full-text search |
| 718 | `integrate-algolia` | Integrate Algolia for search | Hosted search |
| 719 | `integrate-openai` | Integrate OpenAI API (chat, embeddings, images) | AI capabilities |
| 720 | `integrate-anthropic` | Integrate Anthropic Claude API | AI capabilities |
| 721 | `integrate-google-maps` | Integrate Google Maps/Places API | Location services |
| 722 | `integrate-google-analytics` | Integrate Google Analytics (GA4) | Web analytics |
| 723 | `integrate-segment` | Integrate Segment for analytics | Data pipeline |
| 724 | `integrate-posthog` | Integrate PostHog for analytics & feature flags | Product analytics |
| 725 | `integrate-sentry` | Integrate Sentry for error tracking | Error monitoring |
| 726 | `integrate-datadog` | Integrate Datadog for monitoring | APM & monitoring |
| 727 | `integrate-slack-api` | Integrate Slack API (messages, modals, events) | Team communication |
| 728 | `integrate-discord-api` | Integrate Discord API (messages, webhooks) | Community comms |
| 729 | `integrate-github-api` | Integrate GitHub API (repos, issues, PRs, actions) | Developer tools |
| 730 | `integrate-notion-api` | Integrate Notion API (pages, databases) | Knowledge management |
| 731 | `integrate-linear-api` | Integrate Linear API (issues, projects) | Project management |
| 732 | `integrate-jira-api` | Integrate Jira API (issues, boards, sprints) | Project management |
| 733 | `integrate-calendar` | Integrate Google/Outlook Calendar API | Scheduling |
| 734 | `integrate-oauth-generic` | Implement generic OAuth2 provider integration | Any OAuth service |
| 735 | `integrate-ical` | Implement iCalendar (.ics) generation and parsing | Calendar events |
| 736 | `integrate-pdf-gen` | Integrate PDF generation (Puppeteer/React-PDF/wkhtmltopdf) | Document generation |
| 737 | `integrate-image-process` | Integrate image processing (Sharp/ImageMagick) | Image manipulation |
| 738 | `integrate-video-process` | Integrate video processing (FFmpeg) | Video manipulation |
| 739 | `integrate-ai-embedding` | Implement vector embedding pipeline | Semantic search |
| 740 | `integrate-webscraper` | Implement web scraping with rate limiting and politeness | Data extraction |

---

## 13. Frontend & UI (741–800)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 741 | `ui-design-system` | Create design system (tokens, components, docs) | UI consistency |
| 742 | `ui-theme` | Implement theming system (dark mode, custom themes) | User preference |
| 743 | `ui-responsive` | Implement responsive design for all breakpoints | Multi-device support |
| 744 | `ui-animation` | Add micro-animations and transitions (Framer Motion) | Polish & UX |
| 745 | `ui-loading-state` | Implement loading states (skeleton, spinner, progress) | Perceived performance |
| 746 | `ui-error-state` | Implement error states with retry and fallback | Error resilience |
| 747 | `ui-empty-state` | Design and implement empty states | Content guidance |
| 748 | `ui-toast` | Implement toast notification system | User feedback |
| 749 | `ui-modal` | Implement modal/dialog system with accessibility | Overlays |
| 750 | `ui-form-wizard` | Create multi-step form wizard | Complex form flows |
| 751 | `ui-data-table` | Create advanced data table (sort, filter, export, virtual) | Data display |
| 752 | `ui-chart` | Create charts and data visualization (Recharts/D3/Chart.js) | Data visualization |
| 753 | `ui-dashboard` | Create admin/analytics dashboard layout | Dashboard design |
| 754 | `ui-sidebar` | Create responsive sidebar navigation | App navigation |
| 755 | `ui-breadcrumb` | Implement breadcrumb navigation | Navigation context |
| 756 | `ui-search` | Implement search UI with suggestions and highlighting | Search experience |
| 757 | `ui-command-palette` | Implement command palette (CMD+K) | Power user UX |
| 758 | `ui-keyboard-shortcuts` | Implement keyboard shortcut system | Power user UX |
| 759 | `ui-drag-drop` | Implement drag and drop functionality | Direct manipulation |
| 760 | `ui-file-upload` | Implement file upload with preview and progress | File handling UX |
| 761 | `ui-rich-text-editor` | Implement rich text editor (TipTap/Lexical/Slate) | Content editing |
| 762 | `ui-markdown-editor` | Implement markdown editor with preview | Markdown editing |
| 763 | `ui-code-editor` | Implement code editor (Monaco/CodeMirror) | Code editing |
| 764 | `ui-date-picker` | Implement date/time picker with timezone support | Date selection |
| 765 | `ui-color-picker` | Implement color picker component | Color selection |
| 766 | `ui-image-cropper` | Implement image cropper/editor | Image editing |
| 767 | `ui-carousel` | Implement carousel/slider component | Content showcase |
| 768 | `ui-infinite-scroll` | Implement infinite scroll with loading | Content browsing |
| 769 | `ui-virtual-list` | Implement virtualized list for large datasets | Performance |
| 770 | `ui-tree-view` | Implement tree/hierarchy view | Hierarchical data |
| 771 | `ui-kanban` | Implement kanban board with drag and drop | Task management |
| 772 | `ui-calendar-view` | Implement calendar view with events | Date visualization |
| 773 | `ui-timeline` | Implement timeline/activity feed | Event history |
| 774 | `ui-stepper` | Implement progress stepper/wizard | Multi-step process |
| 775 | `ui-tabs` | Implement accessible tab interface | Content organization |
| 776 | `ui-accordion` | Implement accordion/collapsible sections | Space efficiency |
| 777 | `ui-tooltip` | Implement tooltip system | Contextual help |
| 778 | `ui-popover` | Implement popover component | Rich tooltips |
| 779 | `ui-dropdown` | Implement accessible dropdown menu | Action menus |
| 780 | `ui-combobox` | Implement combobox/autocomplete | Searchable select |
| 781 | `ui-multi-select` | Implement multi-select with tags | Multiple selection |
| 782 | `ui-avatar` | Implement avatar with fallback and status | User identity |
| 783 | `ui-badge` | Implement badge/chip/tag components | Labels & status |
| 784 | `ui-skeleton` | Create skeleton loading components | Loading states |
| 785 | `ui-onboarding` | Create user onboarding flow (tour, tooltips) | User education |
| 786 | `ui-notification-center` | Create notification center/inbox | User notifications |
| 787 | `ui-settings-page` | Create settings/preferences page | User preferences |
| 788 | `ui-profile-page` | Create user profile page | User management |
| 789 | `ui-pricing-page` | Create pricing/plan comparison page | Conversion |
| 790 | `ui-landing-page` | Create landing page with sections | Marketing |
| 791 | `ui-auth-pages` | Create login/signup/forgot password pages | Auth flow |
| 792 | `ui-error-pages` | Create 404/500/maintenance pages | Error handling |
| 793 | `ui-print-styles` | Create print stylesheet | Print support |
| 794 | `ui-a11y-audit` | Audit and fix accessibility issues | WCAG compliance |
| 795 | `ui-focus-management` | Implement focus management (trapping, restoration) | Keyboard UX |
| 796 | `ui-screen-reader` | Optimize for screen readers (ARIA, live regions) | Screen reader support |
| 797 | `ui-reduced-motion` | Respect reduced motion preferences | Accessibility |
| 798 | `ui-high-contrast` | Support high contrast mode | Visual accessibility |
| 799 | `ui-rtl` | Implement RTL (right-to-left) layout support | Internationalization |
| 800 | `ui-storybook` | Set up Storybook with stories, controls, docs | Component development |

---

## 14. Mobile Development (801–840)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 801 | `mobile-rn-navigation` | Set up React Native navigation (stack, tab, drawer) | App navigation |
| 802 | `mobile-rn-state` | Set up state management for React Native | App state |
| 803 | `mobile-rn-native-module` | Create React Native native module (iOS/Android) | Native access |
| 804 | `mobile-rn-push-notify` | Implement push notifications (FCM/APNs) | User engagement |
| 805 | `mobile-rn-deep-link` | Implement deep linking / universal links | App linking |
| 806 | `mobile-rn-offline` | Implement offline-first with sync | Offline support |
| 807 | `mobile-rn-biometric` | Implement biometric authentication | Security |
| 808 | `mobile-rn-camera` | Implement camera functionality | Device access |
| 809 | `mobile-rn-location` | Implement location services | Geolocation |
| 810 | `mobile-rn-animation` | Implement animations (Reanimated/Moti) | Smooth UX |
| 811 | `mobile-rn-gesture` | Implement gesture handling | Touch interaction |
| 812 | `mobile-rn-codepush` | Set up CodePush for OTA updates | Fast updates |
| 813 | `mobile-rn-app-store` | Prepare app for App Store/Play Store submission | Publishing |
| 814 | `mobile-flutter-state` | Set up Flutter state management (BLoC/Riverpod) | Flutter state |
| 815 | `mobile-flutter-navigation` | Set up Flutter navigation (GoRouter) | Flutter navigation |
| 816 | `mobile-flutter-platform` | Implement platform-specific features | Platform code |
| 817 | `mobile-swift-networking` | Implement networking layer in Swift | iOS networking |
| 818 | `mobile-swift-core-data` | Implement Core Data persistence | iOS persistence |
| 819 | `mobile-swift-widgets` | Implement iOS widgets (WidgetKit) | iOS widgets |
| 820 | `mobile-swift-watch` | Implement watchOS companion app | Apple Watch |
| 821 | `mobile-kotlin-compose` | Implement Jetpack Compose UI | Android UI |
| 822 | `mobile-kotlin-room` | Implement Room database | Android persistence |
| 823 | `mobile-kotlin-work` | Implement WorkManager background tasks | Background processing |
| 824 | `mobile-app-performance` | Profile and optimize mobile app performance | Mobile speed |
| 825 | `mobile-app-size` | Reduce app bundle size | Install conversion |
| 826 | `mobile-app-security` | Implement mobile app security (cert pinning, etc.) | Mobile security |
| 827 | `mobile-app-analytics` | Implement mobile analytics (Firebase/Mixpanel) | Usage tracking |
| 828 | `mobile-app-crash` | Set up crash reporting (Crashlytics/Sentry) | Stability monitoring |
| 829 | `mobile-app-ab-test` | Implement A/B testing in mobile app | Experimentation |
| 830 | `mobile-app-review` | Implement in-app review prompt | App Store ratings |
| 831 | `mobile-app-update` | Implement force/soft update mechanism | Version management |
| 832 | `mobile-app-config` | Implement remote configuration | Dynamic config |
| 833 | `mobile-pwa-setup` | Set up Progressive Web App (manifest, SW, icons) | PWA creation |
| 834 | `mobile-pwa-install` | Implement PWA install prompt | PWA adoption |
| 835 | `mobile-responsive-design` | Implement mobile-first responsive design | Multi-device |
| 836 | `mobile-touch-optimize` | Optimize touch interactions (tap targets, gestures) | Touch UX |
| 837 | `mobile-keyboard` | Handle virtual keyboard interactions | Mobile UX |
| 838 | `mobile-safe-area` | Handle safe areas and notches | Device compatibility |
| 839 | `mobile-haptics` | Implement haptic feedback | Tactile UX |
| 840 | `mobile-accessibility` | Implement mobile accessibility (VoiceOver/TalkBack) | Mobile a11y |

---

## 15. AI/ML Engineering (841–890)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 841 | `ai-prompt-engineer` | Design and optimize LLM prompts with testing | Prompt quality |
| 842 | `ai-rag-setup` | Set up RAG pipeline (embeddings, retrieval, generation) | Knowledge-augmented AI |
| 843 | `ai-vector-db` | Set up vector database (pgvector/Pinecone/Weaviate) | Embedding storage |
| 844 | `ai-embedding-pipeline` | Create document → embedding → index pipeline | Semantic search |
| 845 | `ai-chatbot` | Build conversational AI chatbot with context | Chat interface |
| 846 | `ai-agent-build` | Build AI agent with tool use and planning | Autonomous AI |
| 847 | `ai-agent-eval` | Create evaluation harness for AI agents | Agent quality |
| 848 | `ai-function-calling` | Implement LLM function/tool calling | AI + tools |
| 849 | `ai-structured-output` | Implement structured output from LLMs (JSON mode) | Reliable AI output |
| 850 | `ai-streaming` | Implement streaming AI responses (SSE) | Real-time AI |
| 851 | `ai-cost-optimize` | Optimize AI API costs (caching, model selection, batching) | Cost reduction |
| 852 | `ai-rate-limit` | Handle AI API rate limits with queue and retry | Reliability |
| 853 | `ai-fallback` | Implement AI provider fallback (OpenAI → Anthropic → local) | Reliability |
| 854 | `ai-cache` | Implement semantic caching for AI responses | Cost & latency |
| 855 | `ai-moderation` | Implement AI content moderation pipeline | Safety |
| 856 | `ai-classification` | Build text classification with LLMs | Categorization |
| 857 | `ai-extraction` | Build entity/data extraction from text | Information extraction |
| 858 | `ai-summarization` | Build document summarization pipeline | Content condensing |
| 859 | `ai-translation` | Build AI-powered translation system | Multilingual |
| 860 | `ai-code-review` | Build AI-powered code review system | Automated review |
| 861 | `ai-code-gen` | Build AI-powered code generation tool | Development speed |
| 862 | `ai-image-gen` | Integrate image generation (DALL-E/Stable Diffusion) | Visual content |
| 863 | `ai-image-analyze` | Implement image analysis with vision models | Image understanding |
| 864 | `ai-ocr` | Implement OCR with AI enhancement | Text extraction |
| 865 | `ai-voice` | Implement voice (TTS/STT) integration | Voice interface |
| 866 | `ai-fine-tune` | Set up LLM fine-tuning pipeline | Custom models |
| 867 | `ai-eval-dataset` | Create evaluation dataset for AI quality | AI testing |
| 868 | `ai-ab-test` | A/B test AI models/prompts in production | Model comparison |
| 869 | `ai-observability` | Set up AI observability (Langfuse/LangSmith/Helicone) | AI monitoring |
| 870 | `ai-guardrails` | Implement AI safety guardrails | Responsible AI |
| 871 | `ai-multimodal` | Implement multimodal AI (text + image + audio) | Rich AI interactions |
| 872 | `ai-workflow` | Build multi-step AI workflow (chain of thought) | Complex AI tasks |
| 873 | `ai-memory` | Implement conversation memory/context management | Contextual AI |
| 874 | `ai-knowledge-base` | Build searchable knowledge base with AI | Knowledge management |
| 875 | `ai-recommendation` | Build recommendation engine with embeddings | Personalization |
| 876 | `ai-anomaly-detect` | Build anomaly detection system | Monitoring |
| 877 | `ai-sentiment` | Build sentiment analysis system | Feedback analysis |
| 878 | `ai-search` | Build AI-powered semantic search | Better search |
| 879 | `ai-autocomplete` | Build AI-powered autocomplete | Input assistance |
| 880 | `ai-copilot` | Build domain-specific AI copilot | Productivity |
| 881 | `ml-model-serve` | Deploy ML model with API endpoint | Model serving |
| 882 | `ml-feature-store` | Design feature store for ML features | ML infrastructure |
| 883 | `ml-pipeline` | Create ML training pipeline (MLflow/Kubeflow) | ML ops |
| 884 | `ml-experiment-track` | Set up experiment tracking | ML experimentation |
| 885 | `ml-data-version` | Set up data versioning (DVC) | Data management |
| 886 | `ml-model-monitor` | Set up model monitoring for drift/performance | Model health |
| 887 | `ml-batch-predict` | Set up batch prediction pipeline | Offline inference |
| 888 | `ml-a-b-deploy` | Set up A/B model deployment | Model comparison |
| 889 | `ml-gpu-optimize` | Optimize GPU usage for inference | Compute efficiency |
| 890 | `ml-quantize` | Quantize model for edge/mobile deployment | Model size reduction |

---

## 16. Project Management & Workflow (891–940)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 891 | `pm-sprint-plan` | Plan sprint with story points and dependencies | Sprint planning |
| 892 | `pm-story-write` | Write user stories with acceptance criteria | Requirement quality |
| 893 | `pm-epic-breakdown` | Break down epic into manageable stories | Work decomposition |
| 894 | `pm-estimate` | Estimate effort for tasks (T-shirt sizing, story points) | Planning accuracy |
| 895 | `pm-roadmap` | Create product/technical roadmap | Strategic planning |
| 896 | `pm-retro` | Facilitate sprint retrospective | Team improvement |
| 897 | `pm-standup` | Generate standup update from git activity | Status reporting |
| 898 | `pm-status-report` | Generate weekly/monthly status report | Stakeholder updates |
| 899 | `pm-risk-assess` | Assess project risks and mitigations | Risk management |
| 900 | `pm-dependency-map` | Map project dependencies and critical path | Dependency management |
| 901 | `pm-scope-check` | Check if feature request is in scope | Scope management |
| 902 | `pm-priority-matrix` | Create priority matrix (urgency vs importance) | Prioritization |
| 903 | `pm-stakeholder-map` | Map stakeholders and communication needs | Stakeholder mgmt |
| 904 | `pm-release-plan` | Create release plan with milestones | Release planning |
| 905 | `pm-migration-plan` | Create data/system migration plan | Migration planning |
| 906 | `pm-incident-timeline` | Create incident timeline from logs/commits | Incident analysis |
| 907 | `pm-tech-debt-inventory` | Inventory and prioritize technical debt | Debt management |
| 908 | `pm-decision-log` | Maintain decision log with rationale | Decision tracking |
| 909 | `pm-raci` | Create RACI matrix for responsibilities | Role clarity |
| 910 | `pm-gantt` | Generate Gantt chart from task list | Timeline visualization |
| 911 | `workflow-git-flow` | Set up Git Flow branching strategy | Branch management |
| 912 | `workflow-trunk-based` | Set up trunk-based development | Simple branching |
| 913 | `workflow-conventional-commit` | Set up conventional commits with enforcement | Commit standards |
| 914 | `workflow-pre-commit` | Set up pre-commit hooks (lint, test, format) | Quality gates |
| 915 | `workflow-pr-automation` | Automate PR checks, labels, reviewers | PR efficiency |
| 916 | `workflow-auto-merge` | Set up auto-merge for passing PRs | Merge efficiency |
| 917 | `workflow-dependabot` | Configure Dependabot/Renovate for dep updates | Dependency freshness |
| 918 | `workflow-codeowners` | Set up CODEOWNERS for review assignment | Review routing |
| 919 | `workflow-branch-protect` | Configure branch protection rules | Branch safety |
| 920 | `workflow-release-please` | Set up Release Please for automated releases | Release automation |
| 921 | `workflow-semantic-release` | Set up semantic-release with plugins | Version automation |
| 922 | `workflow-monorepo-ci` | Optimize CI for monorepo (affected only) | CI efficiency |
| 923 | `workflow-dev-container` | Create dev container configuration | Consistent dev env |
| 924 | `workflow-codespace` | Set up GitHub Codespaces configuration | Cloud IDE |
| 925 | `workflow-nix` | Create Nix flake for reproducible dev environment | Reproducible env |
| 926 | `workflow-mise` | Set up mise (formerly rtx) for tool version management | Tool versioning |
| 927 | `workflow-task-runner` | Set up task runner (Just/Task/Make) for common commands | Command shortcuts |
| 928 | `workflow-local-https` | Set up local HTTPS for development (mkcert) | Local dev |
| 929 | `workflow-hot-reload` | Configure optimal hot reload for dev | Dev speed |
| 930 | `workflow-debug-config` | Create VS Code/IDE debug configurations | Debug setup |
| 931 | `workflow-snippet` | Create code snippets for IDE | Code speed |
| 932 | `workflow-template-repo` | Create GitHub template repository | Project templates |
| 933 | `workflow-issue-triage` | Set up automated issue triage and labeling | Issue management |
| 934 | `workflow-stale-bot` | Set up stale issue/PR management | Repo hygiene |
| 935 | `workflow-benchmark-ci` | Set up benchmark regression testing in CI | Performance tracking |
| 936 | `workflow-size-check` | Set up bundle/binary size checking in CI | Size tracking |
| 937 | `workflow-preview-deploy` | Set up preview deployments for PRs | PR review |
| 938 | `workflow-feature-branch-env` | Set up per-branch environments | Feature isolation |
| 939 | `workflow-db-branch` | Set up database branching (Neon/PlanetScale) | DB per branch |
| 940 | `workflow-e2e-on-deploy` | Run E2E tests on preview deployments | Deploy verification |

---

## 17. Research & Analysis (941–980)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 941 | `research-library` | Research and compare libraries/packages for a use case | Informed choices |
| 942 | `research-architecture` | Research architectural patterns for a problem | Design decisions |
| 943 | `research-best-practice` | Research current best practices for a technology | Up-to-date approach |
| 944 | `research-competitor` | Analyze competitor's technical approach | Market intelligence |
| 945 | `research-rfc` | Research relevant RFCs and standards | Standards compliance |
| 946 | `research-benchmark` | Research and run benchmarks for technology choices | Performance comparison |
| 947 | `research-migration-path` | Research migration paths between technologies | Migration planning |
| 948 | `research-vulnerability` | Research specific vulnerability details and fixes | Security response |
| 949 | `research-api` | Research and document an external API | Integration planning |
| 950 | `research-pricing` | Research and compare SaaS/cloud pricing | Cost planning |
| 951 | `analyze-codebase` | Generate comprehensive codebase analysis report | Code understanding |
| 952 | `analyze-complexity` | Analyze codebase complexity metrics | Quality measurement |
| 953 | `analyze-dependencies` | Deep analysis of dependency tree | Dependency insight |
| 954 | `analyze-test-coverage` | Analyze test coverage gaps and priorities | Test planning |
| 955 | `analyze-performance` | Analyze performance profile and bottlenecks | Performance insight |
| 956 | `analyze-security` | Analyze security posture and threats | Security insight |
| 957 | `analyze-accessibility` | Analyze accessibility compliance level | A11y insight |
| 958 | `analyze-api-usage` | Analyze API usage patterns from logs | Usage insight |
| 959 | `analyze-error-patterns` | Analyze error patterns from logs/monitoring | Error insight |
| 960 | `analyze-user-flow` | Analyze user flow through application | UX insight |
| 961 | `analyze-cost` | Analyze infrastructure/API costs with optimization recs | Cost insight |
| 962 | `analyze-tech-stack` | Analyze and report on tech stack health | Stack health |
| 963 | `analyze-git-history` | Analyze git history for patterns (hotspots, churn) | Development insight |
| 964 | `analyze-pr-metrics` | Analyze PR metrics (time to merge, review cycles) | Process insight |
| 965 | `analyze-incident` | Analyze incident for root cause and prevention | Incident learning |
| 966 | `analyze-data-model` | Analyze data model for anti-patterns | Data quality |
| 967 | `analyze-api-design` | Analyze API design for consistency and best practices | API quality |
| 968 | `analyze-bundle` | Analyze JavaScript bundle composition | Bundle insight |
| 969 | `analyze-docker-image` | Analyze Docker image layers and size | Container insight |
| 970 | `analyze-ci-pipeline` | Analyze CI pipeline efficiency and bottlenecks | CI insight |
| 971 | `analyze-log-structure` | Analyze and suggest log structure improvements | Observability |
| 972 | `analyze-retention` | Analyze data retention and storage usage | Storage insight |
| 973 | `analyze-seo` | Analyze SEO technical factors | SEO insight |
| 974 | `analyze-lighthouse` | Deep Lighthouse analysis with fix priorities | Web quality |
| 975 | `analyze-network` | Analyze network requests waterfall | Network insight |
| 976 | `analyze-render` | Analyze React render performance | Render insight |
| 977 | `compare-solutions` | Compare multiple solutions with pros/cons matrix | Decision support |
| 978 | `compare-frameworks` | Compare frameworks for a use case | Framework selection |
| 979 | `compare-hosting` | Compare hosting options (Vercel/AWS/GCP/Railway/Fly) | Hosting selection |
| 980 | `compare-databases` | Compare database options for requirements | DB selection |

---

## 18. Meta / Claude Code Self-Improvement (981–1030)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 981 | `meta-skill-create` | Create a new Claude Code skill from session patterns | Skill expansion |
| 982 | `meta-skill-test` | Test a skill for correctness and edge cases | Skill quality |
| 983 | `meta-skill-optimize` | Optimize skill prompt for better results | Skill performance |
| 984 | `meta-skill-catalog` | List and describe all available skills | Skill discovery |
| 985 | `meta-agent-create` | Create a new specialized agent definition | Agent expansion |
| 986 | `meta-agent-test` | Test agent behavior with scenarios | Agent quality |
| 987 | `meta-agent-orchestrate` | Design multi-agent orchestration workflow | Agent coordination |
| 988 | `meta-hook-create` | Create Claude Code hook for workflow automation | Hook creation |
| 989 | `meta-hook-test` | Test hook execution and side effects | Hook quality |
| 990 | `meta-mcp-create` | Create MCP server for new capability | MCP expansion |
| 991 | `meta-mcp-test` | Test MCP server tools and resources | MCP quality |
| 992 | `meta-claude-md` | Generate/update CLAUDE.md for project | Project config |
| 993 | `meta-memory-organize` | Organize and clean up Claude Code memories | Memory hygiene |
| 994 | `meta-memory-export` | Export memories for backup or sharing | Memory portability |
| 995 | `meta-context-optimize` | Optimize context window usage for long sessions | Context efficiency |
| 996 | `meta-prompt-template` | Create reusable prompt templates | Prompt reuse |
| 997 | `meta-workflow-design` | Design multi-step Claude Code workflow | Workflow design |
| 998 | `meta-eval-create` | Create evaluation harness for Claude Code tasks | Quality measurement |
| 999 | `meta-benchmark` | Benchmark Claude Code performance on tasks | Performance tracking |
| 1000 | `meta-cost-track` | Track and optimize Claude Code API costs | Cost management |
| 1001 | `meta-session-summarize` | Summarize session accomplishments and learnings | Session review |
| 1002 | `meta-pattern-extract` | Extract reusable patterns from completed work | Pattern learning |
| 1003 | `meta-rule-create` | Create project-specific rules (.claude/rules/) | Custom rules |
| 1004 | `meta-permission-config` | Configure optimal permission settings | Permission tuning |
| 1005 | `meta-keybinding` | Configure keyboard shortcuts for efficiency | Input efficiency |
| 1006 | `meta-model-select` | Select optimal model for current task | Model routing |
| 1007 | `meta-parallel-plan` | Plan parallel agent execution for complex task | Parallel efficiency |
| 1008 | `meta-checkpoint` | Save session checkpoint for later resumption | Session continuity |
| 1009 | `meta-handoff` | Create handoff document for another developer/AI | Knowledge transfer |
| 1010 | `meta-teach` | Teach Claude Code a new domain concept | Domain knowledge |
| 1011 | `meta-debug-self` | Debug Claude Code behavior when it gives wrong results | Self-correction |
| 1012 | `meta-token-budget` | Estimate and budget token usage for a task | Cost planning |
| 1013 | `meta-task-decompose` | Decompose complex task into Claude Code subtasks | Task planning |
| 1014 | `meta-retry-strategy` | Design retry strategy for failed Claude Code operations | Reliability |
| 1015 | `meta-quality-gate` | Set up quality gates between Claude Code steps | Quality control |
| 1016 | `meta-audit-trail` | Create audit trail of Claude Code actions | Accountability |
| 1017 | `meta-rollback` | Rollback Claude Code changes to previous state | Safety |
| 1018 | `meta-diff-review` | Review all changes made by Claude Code in session | Change review |
| 1019 | `meta-learn-codebase` | Deep-learn a new codebase and create orientation doc | Codebase onboarding |
| 1020 | `meta-cross-project` | Apply patterns learned from one project to another | Cross-pollination |
| 1021 | `meta-feedback-loop` | Set up human-in-the-loop feedback for AI output | Quality improvement |
| 1022 | `meta-capability-test` | Test Claude Code capabilities for specific tech stack | Capability assessment |
| 1023 | `meta-efficiency-report` | Generate efficiency report for Claude Code session | Usage optimization |
| 1024 | `meta-template-project` | Create project template optimized for Claude Code use | Project templates |
| 1025 | `meta-onboard-user` | Interactive onboarding for new Claude Code user | User onboarding |
| 1026 | `meta-settings-audit` | Audit and optimize Claude Code settings | Settings optimization |
| 1027 | `meta-tool-compare` | Compare tool approaches (Bash vs Read vs Agent) | Tool selection |
| 1028 | `meta-context-dump` | Dump current context state for debugging | Context debugging |
| 1029 | `meta-skill-chain` | Chain multiple skills into a single workflow | Skill composition |
| 1030 | `meta-daily-brief` | Generate daily development briefing from project state | Daily planning |

---

## 19. Platform & Cloud Specific (1031–1080)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 1031 | `aws-iam` | Design IAM policies with least privilege | AWS security |
| 1032 | `aws-vpc` | Design VPC architecture (subnets, NAT, security groups) | AWS networking |
| 1033 | `aws-rds` | Set up RDS with read replicas, Multi-AZ, backups | AWS database |
| 1034 | `aws-ecs` | Set up ECS/Fargate deployment | AWS containers |
| 1035 | `aws-eks` | Set up EKS cluster | AWS Kubernetes |
| 1036 | `aws-cloudfront` | Configure CloudFront distribution | AWS CDN |
| 1037 | `aws-route53` | Configure Route 53 DNS and health checks | AWS DNS |
| 1038 | `aws-cognito` | Set up Cognito for authentication | AWS auth |
| 1039 | `aws-step-functions` | Design Step Functions state machine | AWS orchestration |
| 1040 | `aws-eventbridge` | Set up EventBridge for event routing | AWS events |
| 1041 | `aws-cost-explorer` | Analyze AWS costs and optimization opportunities | AWS cost |
| 1042 | `gcp-cloud-run` | Deploy to Google Cloud Run | GCP containers |
| 1043 | `gcp-cloud-sql` | Set up Cloud SQL with HA | GCP database |
| 1044 | `gcp-gke` | Set up GKE cluster | GCP Kubernetes |
| 1045 | `gcp-cloud-storage` | Configure Cloud Storage buckets and policies | GCP storage |
| 1046 | `gcp-bigquery` | Set up BigQuery for analytics | GCP analytics |
| 1047 | `gcp-pub-sub` | Set up Pub/Sub messaging | GCP messaging |
| 1048 | `gcp-firebase` | Set up Firebase project (Auth, Firestore, Functions) | GCP mobile backend |
| 1049 | `azure-app-service` | Deploy to Azure App Service | Azure compute |
| 1050 | `azure-cosmos-db` | Set up Cosmos DB | Azure database |
| 1051 | `azure-aks` | Set up AKS cluster | Azure Kubernetes |
| 1052 | `azure-functions` | Create Azure Functions | Azure serverless |
| 1053 | `azure-ad` | Configure Azure AD/Entra ID | Azure identity |
| 1054 | `vercel-deploy` | Configure Vercel deployment (env, domains, edge) | Vercel platform |
| 1055 | `vercel-edge` | Configure Vercel Edge Functions | Vercel edge |
| 1056 | `vercel-analytics` | Set up Vercel Analytics and Speed Insights | Vercel monitoring |
| 1057 | `vercel-cron` | Set up Vercel Cron Jobs | Vercel scheduling |
| 1058 | `netlify-deploy` | Configure Netlify deployment and functions | Netlify platform |
| 1059 | `railway-deploy` | Deploy to Railway with database | Railway platform |
| 1060 | `fly-deploy` | Deploy to Fly.io with regions and scaling | Fly platform |
| 1061 | `render-deploy` | Deploy to Render with services and databases | Render platform |
| 1062 | `digitalocean-setup` | Set up DigitalOcean App Platform/Droplets | DO platform |
| 1063 | `cloudflare-pages` | Deploy to Cloudflare Pages | CF platform |
| 1064 | `cloudflare-workers` | Create Cloudflare Workers application | CF edge compute |
| 1065 | `cloudflare-d1` | Set up Cloudflare D1 database | CF database |
| 1066 | `cloudflare-kv` | Set up Cloudflare KV storage | CF key-value |
| 1067 | `cloudflare-r2` | Set up Cloudflare R2 storage | CF object storage |
| 1068 | `cloudflare-queue` | Set up Cloudflare Queues | CF messaging |
| 1069 | `cloudflare-tunnel` | Set up Cloudflare Tunnel for origin access | CF networking |
| 1070 | `supabase-setup` | Full Supabase project setup (auth, DB, storage, RLS) | BaaS setup |
| 1071 | `supabase-rls` | Design Row Level Security policies | Supabase security |
| 1072 | `supabase-edge-fn` | Create Supabase Edge Functions | Supabase serverless |
| 1073 | `supabase-realtime` | Set up Supabase Realtime subscriptions | Supabase real-time |
| 1074 | `neon-setup` | Set up Neon Postgres (branching, autoscaling) | Serverless Postgres |
| 1075 | `planetscale-setup` | Set up PlanetScale MySQL | Serverless MySQL |
| 1076 | `upstash-redis` | Set up Upstash Redis (serverless) | Serverless Redis |
| 1077 | `upstash-kafka` | Set up Upstash Kafka (serverless) | Serverless Kafka |
| 1078 | `turso-setup` | Set up Turso (libSQL) database | Edge database |
| 1079 | `github-pages` | Deploy to GitHub Pages | Static hosting |
| 1080 | `github-packages` | Publish to GitHub Packages | Package registry |

---

## 20. Communication & Collaboration (1081–1120)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 1081 | `write-tech-blog` | Write technical blog post from code/feature | Content creation |
| 1082 | `write-tutorial` | Write step-by-step tutorial | Education |
| 1083 | `write-changelog-entry` | Write user-facing changelog entry | Release communication |
| 1084 | `write-incident-report` | Write incident report from timeline and data | Incident communication |
| 1085 | `write-postmortem` | Write blameless postmortem | Learning documentation |
| 1086 | `write-rfc` | Write RFC for proposed change | Proposal communication |
| 1087 | `write-adr` | Write Architecture Decision Record | Decision documentation |
| 1088 | `write-email-technical` | Draft technical email (stakeholder updates, etc.) | Professional communication |
| 1089 | `write-pr-description` | Write comprehensive PR description | PR communication |
| 1090 | `write-issue` | Write well-structured GitHub issue | Issue quality |
| 1091 | `write-commit-msg` | Write conventional commit message | Commit quality |
| 1092 | `write-code-comment` | Write clarifying code comments for complex logic | Code communication |
| 1093 | `write-review-feedback` | Write constructive code review feedback | Review quality |
| 1094 | `write-deprecation-notice` | Write deprecation notice with migration guide | Deprecation communication |
| 1095 | `write-release-announcement` | Write release announcement for users | Release marketing |
| 1096 | `write-runbook-entry` | Write operational runbook entry | Operations documentation |
| 1097 | `write-status-update` | Generate status update from recent work | Status reporting |
| 1098 | `write-meeting-notes` | Structure meeting notes with action items | Meeting output |
| 1099 | `write-proposal` | Write technical proposal document | Decision making |
| 1100 | `write-spec` | Write technical specification | Feature planning |
| 1101 | `communicate-slack-update` | Draft Slack message for team update | Team communication |
| 1102 | `communicate-stakeholder` | Draft stakeholder communication | Stakeholder management |
| 1103 | `communicate-outage` | Draft outage communication (internal + external) | Incident communication |
| 1104 | `communicate-breaking-change` | Draft breaking change notification | Migration communication |
| 1105 | `communicate-security-advisory` | Draft security advisory | Security communication |
| 1106 | `present-tech-talk` | Create technical presentation outline/slides | Knowledge sharing |
| 1107 | `present-demo` | Prepare demo script and talking points | Feature demonstration |
| 1108 | `present-architecture` | Create architecture presentation | Technical alignment |
| 1109 | `present-retro` | Create retrospective presentation | Team improvement |
| 1110 | `present-metrics` | Create metrics/KPI dashboard presentation | Data communication |
| 1111 | `onboard-dev` | Create developer onboarding checklist/guide | Team growth |
| 1112 | `onboard-project` | Create project context document for new team members | Knowledge transfer |
| 1113 | `onboard-service` | Create service ownership onboarding | Service knowledge |
| 1114 | `knowledge-capture` | Capture tribal knowledge into documentation | Knowledge preservation |
| 1115 | `knowledge-faq` | Create FAQ from team/support questions | Self-service support |
| 1116 | `review-reply` | Draft reply to code review comments | Review efficiency |
| 1117 | `interview-question` | Generate technical interview questions for a role | Hiring |
| 1118 | `interview-rubric` | Create evaluation rubric for technical interviews | Hiring quality |
| 1119 | `mentoring-plan` | Create mentoring/learning plan for a technology | Skill development |
| 1120 | `pair-program` | Guided pair programming session on a problem | Learning & collaboration |

---

## 21. Business & Strategy (1121–1150)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 1121 | `biz-model-canvas` | Generate business model canvas | Strategy |
| 1122 | `biz-lean-canvas` | Generate lean canvas for startup | Startup planning |
| 1123 | `biz-swot` | Perform SWOT analysis | Strategic analysis |
| 1124 | `biz-competitive-analysis` | Analyze competitive landscape | Market intelligence |
| 1125 | `biz-pricing-model` | Design pricing model/strategy | Revenue optimization |
| 1126 | `biz-unit-economics` | Calculate unit economics (LTV, CAC, margins) | Financial health |
| 1127 | `biz-financial-model` | Create financial model/projections | Financial planning |
| 1128 | `biz-metrics-dashboard` | Define and track business metrics/KPIs | Business monitoring |
| 1129 | `biz-okr` | Create OKRs (Objectives and Key Results) | Goal setting |
| 1130 | `biz-user-persona` | Create user personas from data | User understanding |
| 1131 | `biz-user-journey` | Map user journey with touchpoints | UX strategy |
| 1132 | `biz-feature-prioritize` | Prioritize features (RICE/ICE/MoSCoW) | Product prioritization |
| 1133 | `biz-cost-estimate` | Estimate infrastructure/operational costs | Budget planning |
| 1134 | `biz-roi-calculate` | Calculate ROI for technical investment | Investment justification |
| 1135 | `biz-vendor-compare` | Compare SaaS vendor options | Vendor selection |
| 1136 | `biz-build-vs-buy` | Build vs buy analysis for a capability | Make/buy decision |
| 1137 | `biz-launch-checklist` | Create product launch checklist | Launch readiness |
| 1138 | `biz-growth-experiment` | Design growth experiment with hypothesis | Growth hacking |
| 1139 | `biz-funnel-analysis` | Analyze conversion funnel | Conversion optimization |
| 1140 | `biz-churn-analysis` | Analyze churn patterns and prevention | Retention |
| 1141 | `biz-seo-audit` | Perform technical SEO audit | Search visibility |
| 1142 | `biz-analytics-setup` | Set up product analytics tracking plan | Data-driven decisions |
| 1143 | `biz-data-privacy` | Create data privacy compliance plan | Legal compliance |
| 1144 | `biz-terms-of-service` | Generate terms of service | Legal protection |
| 1145 | `biz-cookie-consent` | Implement cookie consent (GDPR/CCPA) | Privacy compliance |
| 1146 | `biz-accessibility-statement` | Create accessibility statement | Legal compliance |
| 1147 | `biz-cap-table` | Create/manage cap table | Equity management |
| 1148 | `biz-pitch-deck` | Create pitch deck structure | Fundraising |
| 1149 | `biz-investor-update` | Draft investor update email | Investor relations |
| 1150 | `biz-hiring-plan` | Create engineering hiring plan | Team growth |

---

## Bonus: Language-Specific Deep Skills (1151–1200)

| # | Skill Name | Description | Benefit |
|---|-----------|-------------|---------|
| 1151 | `lang-ts-advanced-types` | Implement advanced TypeScript types (mapped, conditional, template literal) | Type mastery |
| 1152 | `lang-ts-type-challenge` | Solve TypeScript type challenges for practice | Type skill |
| 1153 | `lang-ts-module-augment` | Augment third-party type definitions | Type coverage |
| 1154 | `lang-ts-project-references` | Set up TypeScript project references | Build optimization |
| 1155 | `lang-ts-path-aliases` | Configure path aliases (tsconfig paths) | Import clarity |
| 1156 | `lang-python-async` | Implement asyncio patterns correctly | Python async |
| 1157 | `lang-python-typing` | Add comprehensive type hints with mypy strict | Python types |
| 1158 | `lang-python-packaging` | Create Python package with pyproject.toml | Python distribution |
| 1159 | `lang-python-cli` | Build Python CLI with Click/Typer | Python CLI |
| 1160 | `lang-python-dataclass` | Convert dicts to dataclasses/Pydantic models | Python data modeling |
| 1161 | `lang-go-interface` | Design Go interfaces for testability | Go design |
| 1162 | `lang-go-error` | Implement Go error handling (wrapping, sentinel, custom) | Go error handling |
| 1163 | `lang-go-context` | Implement proper context.Context usage | Go context |
| 1164 | `lang-go-channel` | Design channel-based communication patterns | Go concurrency |
| 1165 | `lang-go-generics` | Implement Go generics for type-safe utilities | Go generics |
| 1166 | `lang-rust-ownership` | Fix ownership/borrowing issues | Rust safety |
| 1167 | `lang-rust-lifetime` | Annotate and fix lifetime issues | Rust lifetimes |
| 1168 | `lang-rust-async` | Implement async Rust with Tokio | Rust async |
| 1169 | `lang-rust-error` | Implement error handling with thiserror/anyhow | Rust errors |
| 1170 | `lang-rust-trait` | Design trait-based abstractions | Rust design |
| 1171 | `lang-java-stream` | Convert loops to Java Stream API | Java modern |
| 1172 | `lang-java-optional` | Implement proper Optional usage | Java null safety |
| 1173 | `lang-java-record` | Convert classes to Java Records | Java data classes |
| 1174 | `lang-java-sealed` | Implement sealed classes/interfaces | Java ADTs |
| 1175 | `lang-java-virtual-thread` | Implement virtual threads (Project Loom) | Java concurrency |
| 1176 | `lang-swift-combine` | Implement Combine publishers/subscribers | Swift reactive |
| 1177 | `lang-swift-concurrency` | Implement Swift concurrency (async/await, actors) | Swift async |
| 1178 | `lang-swift-swiftui` | Build SwiftUI views with proper patterns | Swift UI |
| 1179 | `lang-kotlin-coroutine` | Implement Kotlin coroutines and flows | Kotlin async |
| 1180 | `lang-kotlin-dsl` | Build Kotlin DSL for configuration | Kotlin DSL |
| 1181 | `lang-sql-window` | Write complex window function queries | SQL analytics |
| 1182 | `lang-sql-recursive` | Write recursive CTE queries | SQL hierarchies |
| 1183 | `lang-sql-optimize` | Optimize SQL query with explain plan analysis | SQL performance |
| 1184 | `lang-css-grid` | Implement CSS Grid layouts | Modern CSS |
| 1185 | `lang-css-animation` | Implement CSS animations and transitions | CSS motion |
| 1186 | `lang-css-container` | Implement CSS container queries | Responsive components |
| 1187 | `lang-css-custom-props` | Implement CSS custom properties system | CSS theming |
| 1188 | `lang-html-semantic` | Convert div soup to semantic HTML | HTML quality |
| 1189 | `lang-html-form` | Build accessible, validated HTML forms | Form quality |
| 1190 | `lang-bash-script` | Write robust bash script with error handling | Shell scripting |
| 1191 | `lang-bash-parse` | Parse CLI arguments in bash (getopts/getopt) | Shell CLI |
| 1192 | `lang-regex-build` | Build and test regular expressions with explanations | Regex creation |
| 1193 | `lang-regex-optimize` | Optimize regex for performance (avoid ReDoS) | Regex safety |
| 1194 | `lang-graphql-schema` | Design GraphQL schema with best practices | GraphQL design |
| 1195 | `lang-protobuf-design` | Design Protocol Buffer messages and services | gRPC schema |
| 1196 | `lang-yaml-lint` | Lint and fix YAML configuration files | Config quality |
| 1197 | `lang-json-schema` | Create JSON Schema for data validation | Data validation |
| 1198 | `lang-toml-config` | Design TOML configuration file structure | Config design |
| 1199 | `lang-markdown-lint` | Lint and fix Markdown files | Doc quality |
| 1200 | `lang-wasm-bridge` | Create WebAssembly bridge code (JS ↔ Rust/C++) | WASM integration |

---

## Summary by Category

| Category | Count | Range |
|----------|-------|-------|
| Code Generation & Scaffolding | 60 | 001–060 |
| Testing & QA | 70 | 061–130 |
| Code Quality & Review | 60 | 131–190 |
| Debugging & Troubleshooting | 60 | 191–250 |
| Refactoring & Cleanup | 60 | 251–310 |
| Architecture & Design | 60 | 311–370 |
| Database & Data | 70 | 371–440 |
| DevOps & Infrastructure | 70 | 441–510 |
| Security | 60 | 511–570 |
| Performance | 60 | 571–630 |
| Documentation | 50 | 631–680 |
| API & Integration | 60 | 681–740 |
| Frontend & UI | 60 | 741–800 |
| Mobile Development | 40 | 801–840 |
| AI/ML Engineering | 50 | 841–890 |
| Project Management & Workflow | 50 | 891–940 |
| Research & Analysis | 40 | 941–980 |
| Meta / Claude Code Self-Improvement | 50 | 981–1030 |
| Platform & Cloud Specific | 50 | 1031–1080 |
| Communication & Collaboration | 40 | 1081–1120 |
| Business & Strategy | 30 | 1121–1150 |
| Language-Specific Deep Skills | 50 | 1151–1200 |
| **Total** | **1200** | |

---

## Implementation Priority Matrix

### Tier 1 — Highest ROI (Build These First)
Skills that save the most time for the most common tasks:

- **Scaffolding** (001–030): Instant project starts
- **Code Generation** (031–060): Eliminate boilerplate
- **TDD & Testing** (061–130): Quality from day one
- **Code Review** (131–140): Catch bugs before merge
- **Debugging** (191–210): Fastest path to resolution
- **Meta Skills** (981–1010): Make Claude Code better at everything else

### Tier 2 — High Value
Skills for ongoing development quality:

- **Refactoring** (251–300): Keep code clean
- **Architecture** (311–340): Right design from the start
- **Database** (371–420): Data layer done right
- **Security** (511–550): Don't get hacked
- **Performance** (571–610): Keep it fast
- **API Integration** (700–740): Connect everything

### Tier 3 — Specialized
Skills for specific domains and deeper work:

- **DevOps** (441–510): Infrastructure automation
- **Frontend UI** (741–800): Beautiful, accessible UIs
- **Mobile** (801–840): Native app development
- **AI/ML** (841–890): AI-powered features
- **Cloud-specific** (1031–1080): Platform expertise

### Tier 4 — Force Multipliers
Skills that amplify team and business impact:

- **Documentation** (631–680): Knowledge preservation
- **Communication** (1081–1120): Clear, effective communication
- **Project Management** (891–940): Organized delivery
- **Business** (1121–1150): Strategic thinking
- **Research** (941–980): Informed decisions
