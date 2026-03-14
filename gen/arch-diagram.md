# Architecture Diagram Generator

Generate a comprehensive architecture diagram from codebase analysis using Mermaid syntax.

## Arguments

$ARGUMENTS - Optional scope: `full` (default), `backend`, `frontend`, or `infra`. Controls which layers of the architecture to include in the diagram.

## Instructions

You are generating an architecture diagram for the current codebase. Follow these steps precisely.

### Step 1: Determine Scope

Parse the `$ARGUMENTS` to determine the diagram scope:
- `full` or empty/unspecified: Include all layers (frontend, backend, infrastructure, external services)
- `backend`: Focus on server-side components, APIs, services, database, queues
- `frontend`: Focus on client-side components, pages, state management, API calls
- `infra`: Focus on infrastructure — Docker, Kubernetes, Terraform, CI/CD, networking

### Step 2: Analyze Codebase Structure

Perform a thorough analysis of the codebase. Search for and catalog the following:

#### 2a: Entry Points
- **API routes**: Search for route definitions (`router.get`, `app.post`, `@app.route`, `@GetMapping`, `http.HandleFunc`, Next.js `app/` or `pages/api/`, Express routers, FastAPI routers, etc.)
- **Pages/Views**: Frontend pages, templates, screen components
- **CLI commands**: Command handlers, argument parsers
- **Event handlers**: Message queue consumers, webhook handlers, cron jobs
- **gRPC/GraphQL**: Proto definitions, schema resolvers

#### 2b: Services and Dependencies
- **Service classes/modules**: Business logic layers, use cases, domain services
- **Dependency injection**: Constructor injection, DI containers, providers
- **Inter-service calls**: HTTP clients, gRPC stubs, SDK usage between services
- **Shared libraries**: Common utilities, shared types, internal packages

#### 2c: Data Layer
- **Database models**: ORM entities, schema definitions, migration files
- **Database connections**: Connection strings, pool configurations, multiple databases
- **Cache layers**: Redis, Memcached, in-memory caches
- **File storage**: S3, local filesystem, CDN configurations

#### 2d: External Integrations
- **Third-party APIs**: Payment providers, email services, auth providers, analytics
- **Message queues**: RabbitMQ, Kafka, SQS, BullMQ, Celery
- **Search engines**: Elasticsearch, Algolia, Meilisearch
- **Monitoring**: Sentry, Datadog, Prometheus, logging services

#### 2e: Infrastructure Components
- **Docker**: `docker-compose.yml`, `Dockerfile` — containers, networks, volumes
- **Kubernetes**: Deployments, services, ingress, config maps
- **Terraform/Pulumi**: Cloud resources, networking, IAM
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins pipelines
- **Reverse proxy/Load balancer**: Nginx, Traefik, Caddy configurations

### Step 3: Generate Mermaid Architecture Diagram

Based on the scope and analysis, generate a Mermaid diagram. Use the `graph TD` (top-down) or `graph LR` (left-right) direction based on whichever produces a clearer layout.

Follow these conventions:
- **Subgraphs** for logical groupings (Frontend, Backend, Database, External Services, Infrastructure)
- **Rounded boxes** `(Service Name)` for internal services
- **Database shapes** `[(Database)]` for databases
- **Stadium shapes** `([Queue Name])` for message queues
- **Hexagons** `{{Cache}}` for cache layers
- **Directional arrows** `-->` with labels describing the data flow
- **Dashed arrows** `-.->` for async/event-driven communication
- **Styling** with `classDef` for color-coding different component types

Example structure:
```
graph TD
    subgraph Frontend
        ...
    end
    subgraph Backend
        ...
    end
    subgraph Data
        ...
    end
    subgraph External
        ...
    end
```

Rules for the diagram:
1. Every component must have a descriptive label (not just a variable name)
2. Every arrow must have a label describing what flows through it
3. Group related components into subgraphs
4. Show the primary data flow direction
5. Distinguish sync vs async communication (solid vs dashed arrows)
6. Include port numbers for networked services when available
7. Keep the diagram readable — collapse repetitive similar components (e.g., "15 API Routes" instead of listing all)

### Step 4: Generate Text Summary

After the Mermaid diagram, produce a structured text summary:

```
## Architecture Summary

**Type**: [Monolith / Microservices / Modular Monolith / Serverless / Hybrid]
**Primary Language(s)**: [e.g., TypeScript, Python, Go]
**Framework(s)**: [e.g., Next.js, FastAPI, Spring Boot]

### Components
| Component | Type | Technology | Purpose |
|-----------|------|------------|---------|
| ... | Service/DB/Queue/Cache | ... | ... |

### Data Flow
1. [Step-by-step primary request flow]
2. ...

### External Dependencies
- [Service]: [Purpose]
- ...

### Key Observations
- [Notable architectural patterns]
- [Potential concerns: single points of failure, tight coupling, etc.]
- [Missing components: no cache, no queue, no monitoring, etc.]
```

### Step 5: Output

Present the output in this order:
1. The Mermaid diagram in a fenced code block with `mermaid` language tag
2. The text-based architecture summary
3. Any warnings about components that were ambiguous or could not be fully classified

Do NOT save to a file unless the user explicitly asks. Output everything directly in the response.

### Scope-Specific Guidelines

**If scope is `backend`**:
- Focus on API layer, service layer, data access layer, and integrations
- Show middleware pipeline (auth, validation, logging, error handling)
- Detail database query patterns and connection pooling

**If scope is `frontend`**:
- Focus on page/route structure, component hierarchy, state management
- Show API call patterns and data fetching strategy
- Include client-side caching, auth state, and routing

**If scope is `infra`**:
- Focus on container topology, networking, volumes, secrets
- Show CI/CD pipeline stages
- Include cloud resources and their relationships
- Detail scaling configuration (replicas, auto-scaling rules)
