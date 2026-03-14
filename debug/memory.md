# Memory Leak Debugger

Diagnose memory leaks and high memory usage in application code by analyzing source patterns, identifying unbounded growth, and providing targeted fixes.

## Arguments

$ARGUMENTS - A file path to analyze, a process name/description (e.g., "node server", "the API process"), or a description of the memory issue (e.g., "memory grows over time", "OOM after 2 hours")

## Instructions

Follow these steps to identify and fix memory leaks and high memory usage.

### Step 1: Determine the Analysis Target

Based on `$ARGUMENTS`:

- **If a file path**: Read the file directly and analyze it for memory leak patterns.
- **If a process or description**: Detect the project language/framework and search the codebase for relevant code.

**Detect the primary language:**

Use Glob to check for project files:

| File | Language/Runtime |
|------|-----------------|
| `package.json` | Node.js / JavaScript / TypeScript |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |
| `*.csproj`, `*.sln` | C# / .NET |

The detected language determines which memory leak patterns to search for.

### Step 2: Check System-Level Memory (if applicable)

If the user describes a running process with high memory usage, check system-level information:

```bash
ps aux --sort=-%mem | head -20
```

Or for a specific process:
```bash
ps aux | grep "<process-name>"
```

Check if the process has memory limits configured (Docker, systemd, ulimit):
```bash
ulimit -v 2>/dev/null
```

If running in Docker:
```bash
docker stats --no-stream 2>/dev/null
```

### Step 3: Language-Specific Analysis

Based on the detected language, search for the specific memory leak patterns described below.

---

#### Node.js / JavaScript / TypeScript

Search the codebase for these common leak patterns:

**3a. Uncleared Timers and Intervals**

Use Grep to search for:
- `setInterval` without corresponding `clearInterval`
- `setTimeout` in loops or recursive patterns without cleanup
- Missing cleanup in `process.on('exit')` or `process.on('SIGTERM')`

```
Pattern: setInterval( ... ) stored in variable but never cleared
Fix: Store the interval ID and clear it on shutdown or when no longer needed
```

**3b. Event Listener Leaks**

Search for:
- `addEventListener` or `.on(` without corresponding `removeEventListener` or `.off(`
- `.addListener(` without `.removeListener(`
- Repeated calls to add listeners (e.g., inside a request handler or loop)

Check for the Node.js warning pattern:
- Search for `MaxListenersExceededWarning` or `setMaxListeners`

```
Pattern: Adding listeners inside request handlers or loops without removal
Fix: Add listeners once, or remove in cleanup. Use { once: true } for one-shot listeners.
```

**3c. Closure Leaks**

Search for:
- Functions returned from other functions that capture large scope variables
- Callbacks registered that reference large objects in outer scope
- Module-level arrays/maps that grow without bound

```
Pattern: Closure captures reference to large object, preventing GC
Fix: Null out references when done, use WeakRef or WeakMap for caches
```

**3d. Growing Collections**

Search for:
- Module-level `Map`, `Set`, `Array`, or plain object used as a cache/store
- `.push(`, `.set(`, `[key] =` on module-level collections without corresponding deletion or size limits

```
Pattern: Module-level cache that grows without eviction
Fix: Add max size limit with LRU eviction, or use WeakMap for object keys
```

**3e. React-Specific (if React project)**

Search for:
- `useEffect` without a cleanup return function
- `useEffect` that adds event listeners, timers, or subscriptions without cleanup
- State updates on unmounted components (setting state in async callbacks without checking mount status)

```
Pattern: useEffect with addEventListener but no cleanup return
Fix: Return a cleanup function that removes the listener
```

**3f. Stream Leaks**

Search for:
- Readable/writable streams that are not closed or destroyed
- HTTP responses not being consumed or destroyed on error
- `pipe()` without error handling

```
Pattern: Stream created but not properly closed on error paths
Fix: Add error handlers and call stream.destroy() in error/close handlers
```

---

#### Python

**3g. Circular References**

Search for:
- Classes with mutual references (A references B, B references A)
- Objects stored in their own containers
- `__del__` methods (prevent proper GC of circular refs in older Python)

```
Pattern: Two objects referencing each other, preventing reference count GC
Fix: Use weakref.ref() for back-references, avoid __del__ methods
```

**3h. Unclosed Resources**

Search for:
- `open(` without `with` statement
- Database connections opened without closing
- `requests.Session()` or `urllib3.PoolManager()` without `.close()`
- `socket.socket()` without `.close()`

```
Pattern: File/connection opened without context manager or explicit close
Fix: Use 'with' statement for all resource acquisition
```

**3i. Large Data Structures**

Search for:
- Module-level lists, dicts used as caches
- `@lru_cache` without `maxsize` parameter (unbounded cache)
- `global` keyword used to accumulate data
- Pandas DataFrames loaded without chunking for large files

```
Pattern: @lru_cache without maxsize (defaults to unbounded)
Fix: Set explicit maxsize: @lru_cache(maxsize=128)
```

**3j. Thread/Process Leaks**

Search for:
- `threading.Thread` or `multiprocessing.Process` created without joining
- Thread pools without shutdown
- `concurrent.futures` executors without context managers

```
Pattern: Threads spawned without join or daemon=True
Fix: Use ThreadPoolExecutor with context manager, or set daemon=True
```

---

#### Go

**3k. Goroutine Leaks**

Search for:
- `go func()` calls without cancellation context
- Goroutines blocked on channel operations with no way to exit
- Missing `context.Context` propagation
- `select` without `case <-ctx.Done():`

```
Pattern: Goroutine waiting on channel with no cancellation path
Fix: Accept context.Context, add case <-ctx.Done() to select statements
```

To check for goroutine count at runtime (if a pprof endpoint exists):
```bash
curl -s http://localhost:6060/debug/pprof/goroutine?debug=1 2>/dev/null | head -5
```

**3l. Unbounded Channel Buffers**

Search for:
- `make(chan ..., <large-number>)` with producers faster than consumers
- Channels that are never drained
- Missing rate limiting on channel writes

```
Pattern: Buffered channel fills up because consumer is slower than producer
Fix: Add backpressure, rate limiting, or worker pool pattern
```

**3m. Unclosed Resources in Go**

Search for:
- `http.Get` or `http.Do` without `defer resp.Body.Close()`
- `os.Open` or `os.Create` without `defer f.Close()`
- `sql.Open` without connection pool limits
- `bufio.NewScanner` or `bufio.NewReader` on unclosed sources

```
Pattern: HTTP response body not closed
Fix: Add 'defer resp.Body.Close()' immediately after error check
```

**3n. Sync.Pool Misuse**

Search for:
- Objects allocated in hot paths that could use `sync.Pool`
- `sync.Pool` with `New` function that allocates large objects

---

#### General (All Languages)

**3o. Caching Without Eviction**

Search for any in-memory cache implementation:
- LRU/LFU cache without max size
- TTL cache without expiration cleanup
- Application-level caches that grow with each unique request

**3p. Connection Pool Exhaustion**

Search for database/HTTP client connection configuration:
- Missing max connection settings
- Connections acquired but not released (missing `defer`/`finally`/`using`)
- Pool size too large for available memory

**3q. Large File Processing**

Search for file reading patterns:
- `readFileSync` / `readFile` / `read()` loading entire files into memory
- Missing streaming for large file processing
- Base64 encoding large files in memory

**3r. Logging Accumulation**

Search for:
- In-memory log buffers without rotation
- Request/response logging that stores full bodies
- Debug data accumulation in production

### Step 4: Analyze Identified Patterns

For each potential memory leak pattern found:

1. Read the file using the Read tool
2. Confirm whether the pattern is actually a leak (some patterns are intentional and bounded)
3. Assess severity:
   - **CRITICAL**: Unbounded growth proportional to requests/time (will eventually OOM)
   - **HIGH**: Bounded but large growth (may cause OOM under load)
   - **MEDIUM**: Slow growth, takes hours/days to be problematic
   - **LOW**: Suboptimal memory usage but not a leak

### Step 5: Apply Fixes

Use the Edit tool to fix each confirmed memory leak. Apply fixes in order of severity.

**Common fix patterns:**

**Add cleanup/disposal:**
- Add `clearInterval`, `removeEventListener`, cleanup return in `useEffect`
- Add `defer close()`, `with` statement, `finally` block
- Add `context.Context` cancellation for goroutines

**Add bounds to collections:**
- Set `maxsize` on caches
- Implement LRU eviction
- Use `WeakMap`/`WeakRef`/`weakref` for caches keyed by objects
- Add TTL-based expiration

**Switch to streaming:**
- Replace `readFileSync` with `createReadStream`
- Replace `pd.read_csv()` with `pd.read_csv(chunksize=...)`
- Use streaming JSON parsers for large JSON

**Add connection pool limits:**
- Set `max` connections on database pools
- Set `maxSockets` on HTTP agents
- Configure idle timeout for connection reuse

**Add goroutine lifecycle management:**
- Pass `context.Context` and check `ctx.Done()`
- Use `errgroup.Group` for managed goroutine lifecycles
- Add `sync.WaitGroup` for tracking goroutine completion

### Step 6: Report

```
## Memory Leak Analysis

**Target**: <file/process>
**Language**: <detected language>
**Severity**: CRITICAL / HIGH / MEDIUM / LOW

### Leaks Identified

| # | File:Line | Pattern | Severity | Growth Rate |
|---|-----------|---------|----------|-------------|
| 1 | src/cache.ts:23 | Unbounded Map cache | CRITICAL | ~1MB per 1000 requests |
| 2 | src/events.ts:45 | Event listeners added per request | HIGH | ~100 listeners/min |
| 3 | src/api.ts:78 | useEffect missing cleanup | MEDIUM | Per component mount |

### Fixes Applied

| # | File | Before | After |
|---|------|--------|-------|
| 1 | src/cache.ts | `new Map()` with no eviction | LRU cache with max 1000 entries |
| 2 | src/events.ts | `emitter.on()` in handler | Moved to initialization, added cleanup |
| 3 | src/api.ts | `useEffect(() => { sub() })` | `useEffect(() => { sub(); return () => unsub() })` |

### Estimated Memory Impact

**Before**: Memory grows ~1MB/min under load, OOM after ~4 hours
**After**: Memory stabilizes at ~200MB under same load

### Monitoring Recommendations

- Add memory usage metrics to your monitoring (process.memoryUsage() / runtime.MemStats / resource.getrusage)
- Set up alerts for memory usage above 80% of limit
- Consider adding a /debug/heap endpoint (protected) for production debugging
- Run periodic heap snapshots in staging to catch new leaks early

### Additional Patterns to Watch

<any patterns found that are not leaks now but could become leaks if usage changes>
```

If the analysis does not find any clear memory leaks but the user reports high memory usage, suggest:
1. Taking a heap snapshot/profile for runtime analysis
2. Checking if the working set is legitimately large (large dataset, many concurrent connections)
3. Checking if the memory limit is too low for the workload
4. Checking for operating system memory overcommit settings
