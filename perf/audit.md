# Performance Audit

Perform a comprehensive performance audit of the application, identifying bottlenecks and providing prioritized optimization recommendations.

## Arguments

$ARGUMENTS - Optional scope: `full` (default), `frontend`, `backend`, or `database`. Limits the audit to a specific domain.

## Instructions

You are performing a performance audit. Parse the scope from `$ARGUMENTS` (default to `full` if empty or unrecognized).

### Step 0: Project Discovery

1. Detect the project type:
   - Frontend: React, Next.js, Vue, Nuxt, Angular, Svelte, Astro, static site
   - Backend: Express, Fastify, Django, Flask, FastAPI, Gin, Spring, Rails
   - Full-stack: Next.js, Nuxt, SvelteKit, Remix, etc.
2. Identify the build tool (webpack, vite, esbuild, turbopack, rollup, parcel).
3. Identify the database (PostgreSQL, MySQL, MongoDB, SQLite, Redis, etc.).
4. Identify caching layers (Redis, Memcached, CDN, in-memory).
5. Check for existing performance monitoring or profiling setup.

### Step 1: Frontend Audit (scope: full, frontend)

Perform the following frontend checks:

1. Bundle Size Analysis:
   - Check the build configuration for bundle analysis (webpack-bundle-analyzer, rollup-plugin-visualizer, @next/bundle-analyzer).
   - If a build script exists, check output sizes.
   - Examine package.json for known heavy packages: moment (330KB, suggest dayjs), lodash (70KB, suggest lodash-es), axios (suggest native fetch), crypto-js (suggest crypto.subtle), aws-sdk (suggest v3 modular).
   - Search for barrel imports that break tree-shaking.

2. Code Splitting and Lazy Loading:
   - Check if route-based code splitting is configured (React.lazy, next/dynamic, defineAsyncComponent).
   - Search for large components that should be lazy-loaded (modals, charts, editors, maps).
   - Check for statically imported heavy libraries that should be dynamic.

3. Image Optimization:
   - Check for modern formats (WebP, AVIF) vs legacy (PNG, JPG, GIF).
   - Check for oversized images (above 500KB).
   - Check for responsive images (srcset, sizes).
   - Check for loading="lazy" and explicit width/height.

4. Font Loading:
   - Check for font-display: swap or optional.
   - Check for preload on critical fonts.
   - Check for self-hosted vs CDN fonts.
   - Check for unnecessary font variants.

5. Critical Rendering Path:
   - Check for render-blocking CSS and synchronous scripts in head.
   - Check for critical CSS inlining.
   - Check for preconnect and dns-prefetch hints.

6. Third-Party Scripts:
   - Check for analytics, ads, chat widgets loaded synchronously.
   - Verify async/defer attributes.
   - Check for deferred loading of non-critical scripts.

7. Core Web Vitals Estimation:
   - LCP: Large images, slow fonts, render-blocking CSS.
   - INP: Heavy JS execution, long tasks, unoptimized event handlers.
   - CLS: Missing image dimensions, dynamic content, font swap flash.

### Step 2: Backend Audit (scope: full, backend)

Perform the following backend checks:

1. API Response Time Analysis:
   - Examine route handlers for synchronous blocking, sequential awaits that could be parallel.
   - Check for response compression (gzip, brotli).

2. Database Query Performance:
   - Detect N+1 query patterns (queries in loops).
   - Check for missing eager loading (include, prefetch_related, Preload, JOIN).
   - Check for SELECT * when only specific fields are needed.
   - Check for missing pagination on list endpoints.
   - Check for queries on unindexed columns.

3. Memory and Resource Usage:
   - Check for memory leak patterns (growing maps, unreleased listeners, unbounded caches).
   - Check connection pool configuration (database, Redis, HTTP clients).
   - Check for proper resource cleanup (connections, file handles).

4. Caching Analysis:
   - Check existing caching (in-memory, Redis, HTTP headers, CDN).
   - Identify caching opportunities (frequently read data, expensive computations, API responses).
   - Check cache invalidation strategy (TTL, event-based, stale-while-revalidate).

5. Async and Concurrency:
   - Check for blocking operations that should be async.
   - Check for parallelization opportunities (independent queries/calls awaited sequentially).
   - Check for background job usage (email, PDF, image processing, webhooks).

### Step 3: Database Audit (scope: full, database)

Perform the following database checks:

1. Schema Analysis:
   - Check for missing indexes on frequently queried columns (foreign keys, search fields, sort fields).
   - Check for missing composite indexes for multi-column queries.
   - Check for appropriate data types, constraints, and unique constraints.

2. Query Optimization:
   - Check complex queries for appropriate indexes, efficient joins, pagination, and optimized aggregations.
   - Check ORM query generation for inefficient patterns.

3. Connection Management:
   - Check pool size, connection timeout, idle timeout, and health checks.
   - Check for connection leaks and long-running transactions.

### Output Format

Present findings in this structure:

```
## Performance Audit Report

**Project**: <name>
**Type**: <frontend/backend/fullstack>
**Framework**: <detected>
**Scope**: <scope>
**Date**: <current date>

### Executive Summary
<2-3 sentence overview of performance posture and top priorities>

### Performance Score: X/100

### Findings
| # | Issue | Category | Impact | Fix | Effort | Priority |
|---|-------|----------|--------|-----|--------|----------|
| 1 | <issue> | <category> | <estimated improvement> | <brief fix> | <S/M/L> | <P0-P3> |

### Quick Wins (fix in < 1 hour)
**[QW-001] <Title>**
- **Impact**: <estimated improvement>
- **Current**: <what it is now>
- **Fix**: <specific code/config change>
- **File**: `<file:line>`

### Detailed Findings
<Organized by Frontend / Backend / Database>

### Metrics Summary
| Metric | Current (estimated) | Target | Gap |
|--------|-------------------|--------|-----|
| Bundle size | X KB | <target> KB | <diff> |

### Recommended Action Plan
1. **Immediate** (P0): <actions>
2. **This sprint** (P1): <actions>
3. **Next sprint** (P2): <actions>
4. **Backlog** (P3): <actions>
```

Adjust the report to only include sections relevant to the chosen scope.
