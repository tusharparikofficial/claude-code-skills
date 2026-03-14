# Architecture Review

Review code for architectural anti-patterns, circular dependencies, god classes, leaky abstractions, and structural issues.

## Arguments

$ARGUMENTS - File path or directory to analyze (defaults to `src/` if not provided or empty)

## Instructions

### Step 1: Determine Scope

If `$ARGUMENTS` is provided and not empty:
- Use that path as the analysis target
If `$ARGUMENTS` is empty or not provided:
- Check if `src/` exists. If so, use `src/` as the target.
- Otherwise, use the project root directory (current working directory).

Identify the project structure first. Run:
1. `find <target> -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.rs" -o -name "*.cs" \) | head -200` to list all source files
2. `find <target> -type d | head -100` to understand directory structure
3. `wc -l <target>/**/*.{ts,tsx,js,jsx,py,go,java} 2>/dev/null | sort -rn | head -30` to find the largest files

### Step 2: Analyze Circular Dependencies

Trace import/require/include statements to build a module dependency graph.

**Method:**
1. For each source file, extract its imports using Grep:
   - TypeScript/JavaScript: `import .* from ['"]`, `require\(['"]`
   - Python: `from .* import`, `import .*`
   - Go: `import \(` blocks and single `import` lines
   - Java: `import ` statements
2. Resolve relative imports to absolute file paths
3. Detect cycles: if module A imports B, B imports C, and C imports A, that is a circular dependency

Report each cycle found with the full chain: `A -> B -> C -> A`

For large projects, focus on the most critical modules (entry points, shared utilities, core business logic).

### Step 3: Detect God Classes and God Files

Analyze the largest files (from Step 1) for:

**God Files (>500 lines)**
- Read files exceeding 500 lines
- Assess cohesion: does the file handle multiple unrelated responsibilities?
- Count the number of exported functions/classes/types
- If a file has low cohesion (multiple distinct responsibilities), flag it

**God Classes (>300 lines)**
- Classes or objects with too many methods (>15)
- Classes with too many properties/fields (>10)
- Classes that mix data access, business logic, and presentation
- Classes where methods don't share common state (low cohesion)

For each finding, suggest how to split: which methods group together, what new modules to create.

### Step 4: Detect Feature Envy

Look for functions/methods that:
- Access properties of another object more than their own (e.g., `other.x + other.y + other.z` instead of delegating to `other`)
- Pass the same set of parameters from one object to multiple functions
- Repeatedly destructure the same external object

Suggest moving the logic to the class/module that owns the data.

### Step 5: Detect Shotgun Surgery Patterns

Identify changes that would require modifying many files:
- Configuration or constant values duplicated across files instead of centralized
- Enum-like values defined inline in multiple places
- String literals used as identifiers across files (should be constants)
- Interface/type definitions duplicated instead of shared
- Similar switch/case or if/else chains repeated in multiple files

Use Grep to find repeated patterns across the codebase.

### Step 6: Detect Leaky Abstractions

Look for:
- Internal types or implementation details exported from modules that should be private
- Database-specific types (ORM models, query results) used in API response types
- HTTP/framework-specific types (Request, Response) passed into business logic
- Error types from infrastructure leaking into domain layer
- Configuration details embedded in business logic instead of injected

### Step 7: Check Layer Violations

Analyze the architectural layers and check for violations:

**Expected Layering** (detect which pattern the project uses):
- MVC: Controllers -> Services -> Models/Repositories
- Clean Architecture: Controllers -> Use Cases -> Entities
- Hexagonal: Adapters -> Ports -> Domain

**Common Violations:**
- Controllers/handlers containing business logic (more than request parsing, calling service, formatting response)
- Direct database queries in controllers/handlers (bypassing service/repository layer)
- Business logic in UI components (React components with complex data transformations)
- Domain entities depending on infrastructure (importing database clients, HTTP libraries)
- Cross-layer imports (a model importing from a controller)

### Step 8: Check for Missing Abstractions

Look for:
- Raw third-party SDK calls scattered throughout the codebase (should be wrapped in an adapter)
- Direct `fetch`/`axios`/`http` calls in business logic (should be behind an API client abstraction)
- Environment variable access scattered across files (should be centralized in a config module)
- Repeated patterns that suggest a missing utility or helper (same 5+ lines of code appearing in multiple files)

### Step 9: Configuration Analysis

Check for:
- Magic numbers or hardcoded strings that should be in configuration
- Environment-specific values hardcoded instead of read from env/config
- Configuration scattered across multiple files instead of centralized
- Missing validation of configuration values at startup
- Default values that are inappropriate for production

### Step 10: Generate Dependency Graph

Create a text-based dependency graph showing the main modules and their relationships.

Format:
```
Module Dependency Graph
=======================

[controllers/]
  -> services/userService
  -> services/orderService
  -> middleware/auth

[services/userService]
  -> repositories/userRepo
  -> utils/validation
  -> services/emailService    <-- potential circular if emailService -> userService

[services/orderService]
  -> repositories/orderRepo
  -> services/userService
  -> services/paymentService

[repositories/]
  -> models/
  -> database/connection
```

Mark any concerning dependencies with arrows and notes.

### Step 11: Generate Report

Format the output as:

```
## Architecture Review Report

**Scope**: <directory analyzed>
**Files Analyzed**: <count>
**Total Lines**: <approximate>

---

### Summary

<2-3 sentences: overall architectural health, most concerning patterns, recommendations>

---

### Dependency Graph

<text-based graph from Step 10>

---

### Findings

#### Circular Dependencies (<count>)

**[ARCH-CD1]** <cycle description>
- **Chain**: `moduleA -> moduleB -> moduleC -> moduleA`
- **Impact**: <why this is problematic>
- **Fix**: <which dependency to break and how>

#### God Classes/Files (<count>)

**[ARCH-GF1]** <file path> (<line count> lines)
- **Responsibilities**: <list the distinct responsibilities found>
- **Cohesion**: LOW / MEDIUM
- **Refactoring Strategy**:
  - Extract `<responsibility1>` into `<new-file1>`
  - Extract `<responsibility2>` into `<new-file2>`
  - Keep `<core responsibility>` in original file

#### Feature Envy (<count>)

**[ARCH-FE1]** `function` in `file.ext`
- **Envies**: `<target class/module>`
- **Suggestion**: Move to `<target>` or create a method on `<target>`

#### Shotgun Surgery (<count>)

**[ARCH-SS1]** <pattern description>
- **Files affected**: <list of files>
- **Fix**: Centralize in `<suggested location>`

#### Leaky Abstractions (<count>)

**[ARCH-LA1]** <description>
- **File**: `path/to/file.ext:line`
- **Leaked detail**: <what implementation detail is exposed>
- **Fix**: <introduce adapter, create interface, etc.>

#### Layer Violations (<count>)

**[ARCH-LV1]** <description>
- **File**: `path/to/file.ext:line`
- **Violation**: <which layer boundary is crossed>
- **Fix**: <where the logic should live instead>

#### Missing Abstractions (<count>)

**[ARCH-MA1]** <description>
- **Occurrences**: <count of times the pattern appears>
- **Files**: <list>
- **Suggestion**: Create `<suggested abstraction>` to encapsulate this pattern

#### Configuration Issues (<count>)

**[ARCH-CF1]** <description>
- **File**: `path/to/file.ext:line`
- **Fix**: <move to config, extract constant, etc.>

---

### Refactoring Roadmap

| Priority | Finding | Effort | Risk |
|----------|---------|--------|------|
| 1 | <most important fix> | S/M/L | LOW/MED/HIGH |
| 2 | <second fix> | S/M/L | LOW/MED/HIGH |
| 3 | ... | ... | ... |

### Architecture Score

| Dimension | Score (1-5) | Notes |
|-----------|-------------|-------|
| Modularity | <score> | <brief note> |
| Cohesion | <score> | <brief note> |
| Coupling | <score> | <brief note> |
| Layering | <score> | <brief note> |
| Abstraction | <score> | <brief note> |
| **Overall** | **<avg>** | |
```

If findings are severe, offer to help implement the highest-priority refactoring.
