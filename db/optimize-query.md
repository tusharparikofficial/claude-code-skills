# Database Query Optimizer

Analyze a slow database query, identify performance issues, and provide an optimized version with index recommendations.

## Arguments

$ARGUMENTS - Required: a SQL query string, an ORM code snippet, a file path containing the query, or a description of the slow operation (e.g., "the user listing endpoint is slow"). If a file path is provided, read the query from that file.

## Instructions

You are optimizing a slow database query. Follow these steps precisely.

### Step 1: Parse Input

Determine what was provided in `$ARGUMENTS`:

1. **Raw SQL query**: Starts with `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `WITH`, or similar SQL keywords
2. **File path**: Contains `/` or `\` and ends with a code file extension — read the file and extract the query
3. **ORM code**: Contains ORM method calls (e.g., `prisma.user.findMany`, `User.objects.filter`, `db.query.users`, `Model.findAll`)
4. **Description**: Plain text describing the slow operation — search the codebase for the relevant query

If ORM code is provided, first translate it to the equivalent SQL for analysis, then provide the fix in both SQL and ORM syntax.

### Step 2: Detect Database Engine

Check the project for database configuration to determine the engine:
- **PostgreSQL**: `postgresql://` in connection strings, `pg` package, `psycopg2`, `pgx`
- **MySQL**: `mysql://` in connection strings, `mysql2` package, `mysqlclient`
- **SQLite**: `.sqlite` files, `better-sqlite3`, `sqlite3` module
- **MongoDB**: `mongodb://` connection strings, `mongoose`, `pymongo` (different optimization strategies)

Optimization recommendations will be engine-specific where relevant.

### Step 3: Analyze Query Structure

Break down the query and identify each of these potential issues:

#### 3a: Scan Type Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| Full table scan | No WHERE clause on large table, or WHERE on non-indexed column | Add appropriate index |
| Index not used | Function applied to indexed column in WHERE (e.g., `WHERE LOWER(email) = ...`) | Use functional index or rewrite condition |
| Implicit type cast | Comparing mismatched types (e.g., string column vs integer) | Fix the type mismatch |

#### 3b: JOIN Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| Missing JOIN index | JOIN on non-indexed column | Add index on FK column |
| Unnecessary JOIN | Joined table's columns not used in SELECT or WHERE | Remove the JOIN |
| Cartesian product | Missing JOIN condition | Add proper ON clause |
| Wrong JOIN type | LEFT JOIN when INNER JOIN suffices | Use INNER JOIN to reduce rows |
| Too many JOINs | More than 5-6 JOINs in one query | Break into subqueries or CTEs |

#### 3c: SELECT Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| SELECT * | Fetching all columns | Specify only needed columns |
| Unused columns | Columns in SELECT not used by application | Remove unused columns |
| Missing covering index | Query could be served entirely from index | Create covering index |

#### 3d: Filtering Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| Non-sargable WHERE | Functions on columns: `WHERE YEAR(created_at) = 2024` | Rewrite: `WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01'` |
| OR conditions | Multiple OR on different columns | Use UNION or restructure |
| LIKE with leading wildcard | `WHERE name LIKE '%smith'` | Use full-text search or trigram index |
| NOT IN with subquery | `WHERE id NOT IN (SELECT ...)` | Use NOT EXISTS or LEFT JOIN WHERE NULL |
| Redundant conditions | Duplicate or contradictory WHERE clauses | Simplify |

#### 3e: Sorting and Pagination Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| Large OFFSET | `LIMIT 20 OFFSET 10000` | Use cursor/keyset pagination |
| ORDER BY without index | Sorting on non-indexed column | Add index matching ORDER BY |
| Filesort | ORDER BY column not in any index | Create index including ORDER BY column |

#### 3f: Subquery Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| Correlated subquery | Subquery references outer query | Convert to JOIN |
| Subquery in SELECT | Scalar subquery per row | Convert to JOIN with aggregation |
| Repeated subquery | Same subquery used multiple times | Use CTE (WITH clause) |

#### 3g: Aggregation Issues
| Issue | Detection | Fix |
|-------|-----------|-----|
| COUNT(*) on large table | Counting all rows | Use approximate count or cached count |
| GROUP BY on non-indexed columns | Aggregation requires temp table | Add composite index |
| HAVING without GROUP BY | Filtering without grouping | Use WHERE instead |
| DISTINCT overuse | DISTINCT hiding a JOIN issue | Fix the JOIN to eliminate duplicates |

#### 3h: ORM-Specific Issues (if applicable)
| Issue | Detection | Fix |
|-------|-----------|-----|
| N+1 queries | Loop with individual queries | Use eager loading (include/join/prefetch) |
| Missing select | ORM fetching all fields | Specify select/only fields |
| Lazy loading in loop | Accessing relations in iteration | Use eager loading |
| Raw count on relation | `.length` on loaded collection | Use `.count()` query |
| Missing batch operations | Individual creates/updates in loop | Use createMany/bulkCreate/bulk_update |

### Step 4: Provide Optimized Query

Present the optimization in this format:

```markdown
## Query Analysis

### Original Query
```sql
<original query>
```

### Issues Found

1. **[CRITICAL]** Full table scan on `orders` table (estimated 2M rows)
   - Column `user_id` in WHERE clause has no index
   - Impact: Sequential scan ~2-5 seconds

2. **[HIGH]** SELECT * fetching 25 columns when only 4 are used
   - Unnecessary I/O and memory usage
   - Impact: ~30% more data transfer

3. **[MEDIUM]** Correlated subquery for order totals
   - Executes once per row in outer query
   - Impact: O(n) additional queries

### Optimized Query
```sql
<optimized query with comments explaining each change>
```

### Index Recommendations
```sql
-- [CRITICAL] Index for user_id lookups on orders
CREATE INDEX idx_orders_user_id ON orders (user_id);

-- [HIGH] Composite index for common filter + sort pattern
CREATE INDEX idx_orders_user_status_created ON orders (user_id, status, created_at DESC);

-- [MEDIUM] Covering index to avoid table lookup
CREATE INDEX idx_orders_covering ON orders (user_id, status) INCLUDE (total, created_at);
```

### Estimated Improvement
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Scan type | Seq Scan | Index Scan | - |
| Estimated rows scanned | 2,000,000 | ~50 | 99.99% reduction |
| Estimated time | 2-5s | <10ms | ~200-500x faster |
```

### Step 5: ORM Fix (if applicable)

If the original query came from ORM code, provide the fix in ORM syntax:

```markdown
### ORM Fix

**Before:**
```typescript
const orders = await prisma.order.findMany({
  where: { userId: id },
});
// Then looping to get totals - N+1!
```

**After:**
```typescript
const orders = await prisma.order.findMany({
  where: { userId: id },
  select: {
    id: true,
    status: true,
    total: true,
    createdAt: true,
  },
  include: {
    items: {
      select: { quantity: true, price: true },
    },
  },
  orderBy: { createdAt: 'desc' },
  take: 20,
});
```
```

### Step 6: Additional Recommendations

If relevant, suggest:
- **Caching strategy**: For queries that run frequently with same parameters
- **Materialized views**: For complex aggregation queries that run repeatedly
- **Partitioning**: For very large tables (>10M rows) with time-based access patterns
- **Read replicas**: For read-heavy queries that can tolerate slight staleness
- **Connection pooling**: If many concurrent connections are an issue
- **Query result pagination**: If returning too many rows to the client
- **Denormalization**: If JOIN complexity is the bottleneck and data rarely changes
- **Batch processing**: If the query is part of a bulk operation

### Step 7: Output

Present in this order:
1. Original query (SQL form)
2. Issues found (prioritized: CRITICAL > HIGH > MEDIUM > LOW)
3. Optimized query with inline comments
4. Index creation SQL
5. ORM fix (if applicable)
6. Estimated improvement table
7. Additional recommendations

Do NOT modify any files unless the user explicitly asks. Output everything directly in the response.
