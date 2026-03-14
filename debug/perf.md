# Performance Debugger

Identify and fix performance bottlenecks in code, database queries, or web endpoints.

## Arguments

$ARGUMENTS - A file path to profile, a URL to analyze, a database query to explain, or a description of what is slow (e.g., "the /api/users endpoint takes 3 seconds")

## Instructions

Follow these steps to identify and fix performance bottlenecks.

### Step 1: Classify the Input

Determine what type of performance analysis is needed based on `$ARGUMENTS`:

| Input Type | Indicators | Analysis Mode |
|-----------|-----------|---------------|
| **File path** | Starts with `/`, `./`, `~`, has file extension | Code profiling |
| **URL** | Starts with `http://` or `https://` | Endpoint analysis |
| **SQL query** | Contains `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `JOIN` | Query optimization |
| **Description** | Free-form text like "dashboard is slow" | Full-stack investigation |

For descriptions, search the codebase to find the relevant code paths before proceeding.

### Step 2: Endpoint Analysis (if URL or API description)

If the target is a web endpoint:

**Measure baseline response time:**
```bash
curl -o /dev/null -s -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\nFirstByte: %{time_starttransfer}s\nTotal: %{time_total}s\nSize: %{size_download} bytes\n" "<url>"
```

Run this 3 times to get consistent numbers. Note the variance.

**Identify which phase is slow:**
- DNS > 100ms: DNS resolution issue
- Connect - DNS > 100ms: network latency or TCP issue
- TLS - Connect > 200ms: TLS handshake issue
- FirstByte - TLS > 500ms: server processing is slow (backend issue)
- Total - FirstByte > 1s: response body is large or streaming issue

**If server processing is slow**, find the route handler in the codebase:

Use Grep to search for the URL path pattern in route definitions:
- Express/Node: search for `app.get`, `router.get`, `app.post` with the path
- Django: search for `path(`, `url(` with the pattern
- Go: search for `HandleFunc`, `Handle`, `mux.` with the path
- FastAPI: search for `@app.get`, `@router.get` with the path

Read the handler code and trace the execution path, identifying:
- Database queries made
- External API calls
- CPU-intensive operations
- File I/O operations

### Step 3: Database Query Analysis (if SQL or DB-related)

If the issue involves database queries:

**Find the query in the codebase:**
Use Grep to search for the query text, table names, or ORM model references.

**Check for common query performance issues:**

1. **N+1 Query Pattern**: Loop that executes a query per iteration
   - Search for queries inside loops or `.map()` / `.forEach()` callbacks
   - ORM patterns: accessing relationships without eager loading
   - Fix: use `JOIN`, `IN` clause, or eager loading (`include`, `select_related`, `prefetch_related`, `Preload`)

2. **Missing Indexes**: Full table scans on large tables
   - Look for `WHERE` clauses on columns without indexes
   - Look for `ORDER BY` on non-indexed columns
   - Look for `JOIN` on non-indexed foreign keys
   - Fix: add appropriate indexes

3. **SELECT ***: Fetching all columns when only a few are needed
   - Fix: specify only needed columns

4. **Missing Pagination**: Loading all rows without `LIMIT`/`OFFSET`
   - Fix: add pagination with reasonable page sizes

5. **Unoptimized JOINs**: Joining large tables without proper conditions
   - Fix: add WHERE clauses to filter before joining

6. **Missing Connection Pooling**: Creating new connections per request
   - Search for database connection setup code
   - Fix: configure connection pool (min, max, idle timeout)

If a database is accessible, suggest running `EXPLAIN ANALYZE` on the problematic query and provide the exact command. Parse the EXPLAIN output if available, looking for:
- Sequential scans on large tables (need index)
- High row estimates vs actual rows (stale statistics)
- Nested loops with large inner sets (need hash or merge join)
- Sort operations on large sets (need index or increase work_mem)

### Step 4: Code Profiling (if file path or handler code)

Read the target file using the Read tool. Analyze the code for performance issues:

**Algorithmic Complexity:**
- Nested loops on large datasets: O(n^2) or worse
- Linear search where hash lookup would work: O(n) vs O(1)
- Sorting repeatedly when once would suffice
- Recursive calls without memoization
- String concatenation in loops (use StringBuilder/join)

**I/O Bottlenecks:**
- Sequential API calls that could be parallelized
- Reading entire files into memory instead of streaming
- Synchronous file operations blocking the event loop
- Missing connection reuse (HTTP keep-alive, connection pools)

**Memory Issues:**
- Loading entire datasets when pagination/streaming is possible
- Creating large intermediate arrays/objects
- Deep cloning when shallow would suffice
- Retaining references preventing garbage collection

**Caching Opportunities:**
- Repeated identical computations
- Database queries with same parameters
- API calls for data that changes infrequently
- Template rendering with static parts

**Language-Specific Issues:**

*Node.js/JavaScript:*
- Blocking the event loop with CPU-intensive work
- Not using `Promise.all()` for parallel async operations
- Large JSON parse/stringify on hot paths
- RegExp with catastrophic backtracking

*Python:*
- Using lists where sets would be faster for lookups
- Not using generators for large sequences
- Global Interpreter Lock (GIL) blocking for CPU work (use multiprocessing)
- Repeated imports inside functions

*Go:*
- Excessive allocations in hot paths (use sync.Pool)
- Unbuffered channels causing goroutine blocking
- Lock contention on shared mutexes
- Not using `strings.Builder` for string building

### Step 5: Search for Related Patterns

Use Grep to search the codebase for similar patterns that might have the same performance issue. This helps identify:
- Whether the same anti-pattern exists elsewhere
- Whether there is existing optimized code that can be referenced
- Whether there is caching infrastructure already available

### Step 6: Apply Optimizations

Use the Edit tool to apply specific fixes. For each optimization:

1. **Document the change**: Add a code comment explaining why the optimization was made
2. **Preserve correctness**: Never sacrifice correctness for performance
3. **Measure the improvement**: Provide an estimate of the expected improvement

Common optimizations to apply:

**Parallelize independent operations:**
```
// Before: sequential (3 API calls, 1s each = 3s)
result1 = await fetchA()
result2 = await fetchB()
result3 = await fetchC()

// After: parallel (3 API calls, 1s each = 1s)
[result1, result2, result3] = await Promise.all([fetchA(), fetchB(), fetchC()])
```

**Add database indexes:**
Identify the migration or schema file and add the index.

**Fix N+1 queries:**
Replace loop queries with batch queries or eager loading.

**Add caching:**
Add caching for expensive, cacheable operations. Use existing cache infrastructure if present in the project.

**Optimize data structures:**
Replace arrays with sets/maps for lookups, use appropriate data structures.

**Add pagination:**
Add LIMIT/OFFSET or cursor-based pagination for unbounded queries.

### Step 7: Report

```
## Performance Analysis

**Target**: <file/URL/query>
**Type**: Endpoint / Query / Code

### Bottlenecks Identified

| # | Location | Issue | Impact | Severity |
|---|----------|-------|--------|----------|
| 1 | src/api/users.ts:45 | N+1 query in user list | 100ms per user, 5s for 50 users | CRITICAL |
| 2 | src/api/users.ts:62 | No pagination, loads all records | Memory spike, 2s query time | HIGH |
| 3 | src/utils/transform.ts:12 | O(n^2) nested loop | 500ms for 1000 items | MEDIUM |

### Optimizations Applied

| # | File | Change | Estimated Improvement |
|---|------|--------|----------------------|
| 1 | src/api/users.ts | Replaced N+1 with eager loading | 5s -> 200ms |
| 2 | src/api/users.ts | Added cursor-based pagination (limit 50) | Unbounded -> constant time |
| 3 | src/utils/transform.ts | Replaced nested loop with Map lookup | O(n^2) -> O(n) |

### Estimated Total Improvement

**Before**: ~7.5s response time
**After**: ~400ms response time (estimated ~19x improvement)

### Additional Recommendations

<suggestions for caching, CDN, infrastructure changes, monitoring>
```

Ensure all optimizations maintain the existing behavior and do not introduce regressions. If an optimization changes the API contract (e.g., adding pagination where there was none), note it clearly.
