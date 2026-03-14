# API Performance Optimizer

Analyze and optimize a specific API endpoint for maximum performance: query efficiency, caching, payload optimization, and response time reduction.

## Arguments

$ARGUMENTS - `<endpoint-or-file>` - an API endpoint path (e.g., `/api/users`) or a source file containing route handlers

## Instructions

You are optimizing the performance of a specific API endpoint.

### Step 0: Locate the Endpoint Code

1. If a URL path is provided (e.g., /api/users): search for route definitions matching the path.
   - Express: router.get('/users', ...), app.get('/api/users', ...)
   - Next.js: app/api/users/route.ts or pages/api/users.ts
   - Django: urlpatterns, @api_view
   - FastAPI: @app.get("/users")
   - Flask: @app.route("/users")
   - Go/Gin: r.GET("/users", ...)
   - Spring: @GetMapping("/users")
2. If a file path is provided, read that file directly.
3. Trace the full code path: route handler, service/business logic, data access/repository, middleware.
4. Map out all database queries, external API calls, and I/O operations.

### Step 1: Database Query Analysis

**1a - N+1 Query Detection:**
Search for the N+1 pattern (queries inside loops). Check for missing eager loading: include (Sequelize), populate (Mongoose), select_related/prefetch_related (Django), Preload (GORM), @EntityGraph (JPA). Check GraphQL resolvers for missing dataloaders.

**1b - Query Efficiency:**
- Check for SELECT * when only specific fields are needed. Suggest selecting only required columns.
- Check for appropriate indexes on WHERE/ORDER BY/JOIN columns. Suggest CREATE INDEX statements for unindexed columns.
- Suggest EXPLAIN ANALYZE for complex queries.
- Check for unnecessary or duplicated queries.
- Check that COUNT/SUM/AVG are done in database, not in application code.

**1c - Missing Pagination:**
Check if list endpoints return unbounded results. Suggest cursor-based pagination over OFFSET/LIMIT for large datasets. Include proper response format with data, nextCursor, and hasMore fields. Suggest reasonable default (20) and max (100) limits.

### Step 2: Caching Opportunities

**2a - HTTP Cache Headers:**
Set Cache-Control headers appropriate to data volatility:
- Infrequently changing data: public, max-age=60, s-maxage=300, stale-while-revalidate=600
- User-specific data: private, max-age=30
- Real-time data: no-store

**2b - ETag Support:**
Implement ETag generation from response data hash. Check If-None-Match header and return 304 when data unchanged.

**2c - Application-Level Caching:**
Identify data suitable for caching (read-heavy, write-light; expensive computations; external API responses). Implement Redis or in-memory cache with appropriate TTL. Include cache invalidation strategy (pattern-based key deletion on writes).

**2d - Cache Stampede Prevention:**
For high-traffic endpoints, implement mutex/lock approach to prevent thundering herd on cache miss. Use set with NX (only if not exists) for lock acquisition with short expiry.

### Step 3: Payload Optimization

1. Remove unnecessary fields from response (internal IDs, soft-delete flags, large blobs on list endpoints).
2. Implement sparse fieldsets: allow clients to request only needed fields via query parameter.
3. Enable response compression for payloads over 1KB (gzip/brotli).
4. Check for unnecessary serialization overhead.

### Step 4: Async and Parallelization

1. Identify sequential awaits that could be parallel using Promise.all or asyncio.gather.
2. Identify blocking I/O (synchronous file reads, CPU-intensive computation in request handler).
3. Offload heavy work to background queues (email, PDF generation, image processing, webhooks).
4. Use streaming for large file responses.

### Step 5: Connection Pool and Infrastructure

1. Check database connection pool configuration (pool size, acquire timeout, idle timeout).
   Rule of thumb: pool_size = (num_cpu_cores * 2) + num_spinning_disks.
2. Check for connection leaks (missing finally blocks for release).
3. Check external API calls for HTTP keep-alive, timeout, retry with exponential backoff, circuit breaker.

### Step 6: Response Compression

1. Verify compression middleware is configured (Express compression, Fastify compress, Django GZipMiddleware).
2. Check Nginx/reverse proxy for gzip and brotli configuration with appropriate types and min_length.

### Step 7: Apply Optimizations

For each optimization:
1. Show BEFORE code (current state).
2. Show AFTER code (optimized state).
3. Explain expected impact.
4. Implement the change.
5. If creating indexes, generate migration files.
6. If adding caching, implement invalidation alongside.

### Step 8: Verify

1. Run existing tests for the endpoint.
2. Suggest load testing approach (hey, k6, or ab).

### Output Format

```
## API Optimization Report -- <method> <path>

### File: <handler file path>

### Code Path
<handler> -> <service> -> <repository> -> <database>

### Current Performance Profile (estimated)
| Metric | Value |
|--------|-------|
| DB queries per request | X |
| External API calls | X |
| Estimated response time (p50) | X ms |
| Response payload size | X KB |
| Caching | None / Partial / Full |

### Optimizations Applied
| # | Optimization | Category | Est. Impact |
|---|-------------|----------|-------------|
| 1 | Fixed N+1 query | Database | -200ms, -N queries |
| 2 | Added index on column | Database | -50ms on search |
| 3 | Added Redis cache (5min TTL) | Caching | -180ms (cache hit) |
| 4 | Parallelized independent queries | Async | -150ms |
| 5 | Added response compression | Network | -60% payload |
| 6 | Added pagination (limit: 50) | Database | Prevents unbounded queries |
| 7 | Selected specific fields | Database | -30% query time |
| 8 | Added ETag support | Caching | 304 for unchanged data |

### Estimated Performance After
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| DB queries per request | X | Y | -Z |
| Response time (p50) | X ms | Y ms | -Z% |
| Response payload size | X KB | Y KB | -Z% |

### Files Modified
| File | Change |
|------|--------|
| <file> | <description> |

### Database Migrations Created
| Migration | Purpose |
|-----------|---------|
| <file> | <index or schema change> |

### Cache Invalidation Strategy
- Trigger: <when cache is invalidated>
- Pattern: <TTL / event-based / hybrid>
- Key structure: <cache key naming>

### Load Testing Suggestion
<Command to verify improvements>
```
