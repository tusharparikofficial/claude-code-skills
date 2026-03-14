# Generate Codebase Map

Generate a comprehensive codebase map showing project structure, module relationships, and architectural overview.

## Instructions

1. **Scan the entire project structure:**
   - List all directories and files (excluding `node_modules`, `.git`, `dist`, `build`, `__pycache__`, `.venv`, `vendor`, `target`, `.next`, `.nuxt`, `coverage`)
   - Identify the project type and primary language
   - Detect monorepo structure (workspaces, packages, apps)

2. **Analyze each directory and key file:**
   - Read directory contents to understand purpose
   - Identify entry points: `main.*`, `index.*`, `app.*`, `server.*`, `cmd/`
   - Identify configuration files and their roles
   - Map test file locations to source files
   - Identify generated vs hand-written code

3. **Detect module dependencies:**
   - Parse import/require statements across source files
   - Identify internal module boundaries
   - Map which modules depend on which
   - Identify circular dependencies if any
   - Detect shared utilities and common modules

4. **Generate CODEMAP.md** with these sections:

   ```markdown
   # Codebase Map

   > Auto-generated overview of the [Project Name] codebase.

   ## Project Summary
   One paragraph: what this project is, primary language, framework, and purpose.

   ## Directory Structure
   ```
   project-root/
   ├── src/                    # Application source code
   │   ├── controllers/        # HTTP request handlers
   │   ├── services/           # Business logic layer
   │   ├── models/             # Data models and schemas
   │   ├── middleware/          # Request middleware
   │   ├── utils/              # Shared utilities
   │   └── config/             # Configuration management
   ├── tests/                  # Test files
   │   ├── unit/               # Unit tests
   │   └── integration/        # Integration tests
   ├── docs/                   # Documentation
   ├── scripts/                # Build and utility scripts
   └── infrastructure/         # IaC and deployment config
   ```
   (Use actual project structure, not this example)

   ## Key Files

   | File | Purpose |
   |------|---------|
   | `src/index.ts` | Application entry point |
   | `src/config/database.ts` | Database connection setup |
   | ... | ... |

   ## Module Dependency Map

   ```mermaid
   graph TD
       A[Entry Point] --> B[Routes]
       B --> C[Controllers]
       C --> D[Services]
       D --> E[Models]
       D --> F[External APIs]
       C --> G[Middleware]
   ```

   ## Entry Points

   | Entry Point | Purpose | Command |
   |-------------|---------|---------|
   | `src/index.ts` | Main application | `npm start` |
   | `src/worker.ts` | Background worker | `npm run worker` |
   | ... | ... | ... |

   ## Data Flow

   Describe how data flows through the system:
   1. Request enters through [entry point]
   2. Passes through [middleware/guards]
   3. Handled by [controller/handler]
   4. Business logic in [service layer]
   5. Data access via [repository/model]
   6. Response returned

   ## External Integrations

   | Integration | Purpose | Config Location |
   |-------------|---------|-----------------|
   | PostgreSQL | Primary database | `src/config/database.ts` |
   | Redis | Caching | `src/config/redis.ts` |
   | Stripe | Payments | `src/services/payment.ts` |
   | ... | ... | ... |

   ## Architecture Patterns

   List the architectural patterns detected:
   - Pattern 1: Description and where it's used
   - Pattern 2: Description and where it's used

   ## Code Statistics

   | Metric | Value |
   |--------|-------|
   | Total source files | N |
   | Primary language | ... |
   | Test files | N |
   | Configuration files | N |
   ```

5. **Quality checks:**
   - Every directory description is based on actual content, not guessed
   - File purposes are derived from reading the files, not assumed from names
   - Dependency map reflects actual imports, not theoretical architecture
   - No placeholder entries remain

6. **Write the file** to `CODEMAP.md` in the project root. If it already exists, show the diff and confirm before overwriting.
