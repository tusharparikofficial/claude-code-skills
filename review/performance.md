# Performance Review

Performance-focused code review analyzing database queries, frontend rendering, backend processing, algorithmic complexity, and network efficiency.

## Arguments

$ARGUMENTS - File path or directory to analyze for performance issues

## Instructions

### Step 1: Determine Scope and Technology

Identify the target files:
- If `$ARGUMENTS` is a file: analyze that file and any files it imports/depends on
- If `$ARGUMENTS` is a directory: scan all source files in that directory

Detect the technology stack to determine which performance patterns are relevant:
- Check for `package.json` (Node.js), `requirements.txt`/`pyproject.toml` (Python), `go.mod` (Go), `pom.xml`/`build.gradle` (Java)
- Check for frontend frameworks: React (`react` in dependencies), Vue, Angular, Svelte
- Check for ORMs: Prisma, TypeORM, Sequelize, Django ORM, SQLAlchemy, GORM, Hibernate
- Check for database clients: pg, mysql2, mongodb, redis

Read the target files using the Read tool. For directories, list files first and read the most relevant ones (prioritize API handlers, database queries, React components, data processing logic).

### Step 2: Database Performance Analysis

Search for and analyze:

**N+1 Query Patterns**
- Database calls inside loops: look for ORM query methods (`find`, `findOne`, `get`, `filter`, `query`, `select`, `fetch`) inside `for`, `forEach`, `map`, `while` loops
- Sequential awaits of database calls that could be batched: `await db.find(id1); await db.find(id2)` instead of `await db.findMany([id1, id2])`
- GraphQL resolvers that trigger individual queries per item
- Django: `for item in queryset:` followed by accessing a related field (should use `select_related` or `prefetch_related`)
- Rails: accessing `.association` in a loop without `includes`

**Missing Indexes**
- Query patterns that filter or sort by columns that may not be indexed
- New `WHERE` clauses on columns without apparent index
- `ORDER BY` on non-indexed columns with large tables
- Compound queries that could benefit from composite indexes
- Full text search without full-text indexes

**Unoptimized Queries**
- `SELECT *` when only specific columns are needed
- Missing `LIMIT` on queries that could return large result sets
- Unnecessary `JOIN`s that fetch more data than needed
- Subqueries that could be rewritten as JOINs
- Missing `DISTINCT` causing duplicate processing
- `COUNT(*)` on large tables without caching

**Connection Management**
- Creating new database connections per request instead of pooling
- Missing connection pool configuration
- Not releasing connections back to pool (missing `finally` blocks)
- Connection leaks in error paths

### Step 3: Frontend Performance Analysis

If frontend code is detected, analyze:

**Unnecessary Re-renders**
- React components missing `React.memo()` for pure components receiving complex props
- Inline object/array/function creation in JSX props: `style={{color: 'red'}}`, `onClick={() => handler(id)}`
- Missing `useMemo` for expensive computations in render
- Missing `useCallback` for function props passed to child components
- State updates that trigger unnecessary re-renders of sibling components
- Missing dependency arrays in `useEffect`, `useMemo`, `useCallback`
- State stored too high in the component tree

**Large Bundle Issues**
- Importing entire libraries when tree-shakeable imports exist: `import _ from 'lodash'` vs `import debounce from 'lodash/debounce'`
- Large dependencies imported synchronously that could use dynamic `import()`
- Missing code splitting at route boundaries
- Images imported directly into JS bundles instead of using `<img>` with optimized sources
- Missing lazy loading for below-the-fold components

**Blocking Resources**
- Synchronous scripts in `<head>` without `async` or `defer`
- Render-blocking CSS that could be inlined or deferred
- Large fonts loaded synchronously without `font-display: swap`
- Missing preloading for critical resources

**DOM and Layout**
- Layout thrashing: reading layout properties then writing styles in a loop
- Excessive DOM nodes created in lists without virtualization
- Missing `will-change` or `transform: translateZ(0)` for animated elements
- Forced synchronous layouts

### Step 4: Backend Performance Analysis

**Synchronous Blocking**
- Blocking I/O operations in async contexts (Node.js: `fs.readFileSync`, `execSync` in request handlers)
- CPU-intensive operations on the main thread/event loop without offloading to workers
- Synchronous HTTP calls that should be async
- Missing concurrency for independent I/O operations (`Promise.all` instead of sequential awaits)

**Caching**
- Repeated expensive computations without caching
- Database queries for slowly-changing data without caching layer
- Missing HTTP cache headers (`Cache-Control`, `ETag`, `Last-Modified`)
- API responses that could benefit from CDN caching
- Missing memoization for pure function calls with repeated arguments

**Memory Issues**
- Unbounded in-memory caches without eviction policy (growing `Map` or `Object`)
- Large arrays/objects held in module-level scope
- Event listeners registered without cleanup
- Streams not properly destroyed on error
- Large file reads loaded entirely into memory instead of streaming
- Closures that capture more scope than needed

**Concurrency**
- Missing connection pool limits
- Unbounded concurrent operations (missing semaphore/queue)
- Missing timeouts on external HTTP calls
- Missing circuit breaker for failing downstream services

### Step 5: Algorithm and Data Structure Analysis

**Complexity Issues**
- O(n^2) patterns: nested loops over the same or correlated data, `array.includes()` or `array.indexOf()` inside a loop (use a Set)
- O(n^2) sorting: bubble sort, selection sort on large datasets
- Repeated linear searches that could use a hash map
- Recursive algorithms without memoization that have overlapping subproblems
- String concatenation in loops (should use StringBuilder/join pattern)

**Redundant Computations**
- Same value computed multiple times in a function
- Filtering and then mapping when both could be done in one pass
- Converting data structures back and forth unnecessarily
- Sorting already-sorted data

**Data Structure Choice**
- Using arrays for frequent lookups (should use Map/Set/Object)
- Using linked structures for random access patterns
- Using mutable structures where immutable builders would prevent copying

### Step 6: Network Performance Analysis

**Missing Compression**
- HTTP responses without gzip/brotli compression
- Large JSON payloads that could be compressed
- Missing `Accept-Encoding` handling

**Pagination**
- API endpoints returning unbounded lists without pagination
- Missing cursor-based pagination for large datasets
- Offset-based pagination on large tables (should use cursor/keyset)

**Over-fetching**
- REST endpoints returning entire objects when clients need few fields
- Missing field selection/sparse fieldsets
- GraphQL queries fetching fields that are not used by the client
- Including related entities by default instead of on-demand

**Request Optimization**
- Multiple sequential API calls that could be batched
- Missing request deduplication
- Missing request cancellation for superseded requests
- Polling when WebSockets or Server-Sent Events would be more efficient

### Step 7: Generate Report

Format the output as:

```
## Performance Review Report

**Scope**: <file/directory>
**Technology Stack**: <detected stack>

---

### Summary

<2-3 sentences: overall performance posture, number of findings, most impactful issue>

**Estimated Impact**: <qualitative assessment: Critical performance issue / Moderate optimization opportunities / Minor improvements available / Code is well-optimized>

---

### Findings

#### HIGH IMPACT (<count>)

**[PERF-H1]** <category> — <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <detailed description with current code reference>
- **Impact**: <estimated impact: response time, memory, CPU, bandwidth>
- **Before**:
  ```<lang>
  // current code
  ```
- **After**:
  ```<lang>
  // optimized code
  ```

#### MEDIUM IMPACT (<count>)

**[PERF-M1]** <category> — <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <description>
- **Optimization**:
  ```<lang>
  // suggested improvement
  ```

#### LOW IMPACT (<count>)

**[PERF-L1]** <title> — `path/to/file.ext:line` — <description and suggestion>

---

### Performance Checklist

| Category | Status | Findings |
|----------|--------|----------|
| Database Queries | PASS/WARN/FAIL | <count> |
| Frontend Rendering | PASS/WARN/FAIL/N/A | <count> |
| Backend Processing | PASS/WARN/FAIL | <count> |
| Algorithm Complexity | PASS/WARN/FAIL | <count> |
| Network Efficiency | PASS/WARN/FAIL | <count> |
| Memory Management | PASS/WARN/FAIL | <count> |
| Caching | PASS/WARN/FAIL | <count> |

---

### Optimization Priority

1. <Highest impact fix — estimated improvement>
2. <Second priority — estimated improvement>
3. ...

### Quick Wins

<List any optimizations that are simple to implement (< 30 minutes) and have measurable impact>
```

Offer to implement HIGH impact fixes if the user wants. Always provide before/after code for HIGH and MEDIUM impact findings.
