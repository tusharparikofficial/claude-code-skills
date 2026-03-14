# Scaffold Monorepo

Scaffold a Turborepo monorepo with shared packages, workspace configuration, Docker setup, and CI/CD.

## Arguments

$ARGUMENTS - `<project-name> [packages...]` e.g. `myapp web api shared`

## Instructions

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- `project-name` (required) - the root directory/project name
- `packages` (optional) - space-separated list of package/app names

If no packages are specified, default to: `web api shared`

Classify each package:
- If name contains `web`, `app`, `dashboard`, `admin`, `docs`, `landing` -> classify as **app** (goes in `apps/`)
- If name contains `api`, `server`, `backend`, `gateway`, `worker` -> classify as **app** (goes in `apps/`)
- Otherwise -> classify as **package** (goes in `packages/`)
- `shared`, `ui`, `config`, `utils`, `types` are always **packages**

### 2. Initialize Turborepo

```bash
npx create-turbo@latest <project-name> --use-pnpm
```

If the create-turbo scaffolder doesn't work cleanly, manually initialize:

```bash
mkdir <project-name> && cd <project-name>
pnpm init
mkdir -p apps packages
```

### 3. Root Configuration

#### `package.json`
```json
{
  "name": "<project-name>",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "test": "turbo test",
    "type-check": "turbo type-check",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "clean": "turbo clean && rm -rf node_modules"
  },
  "packageManager": "pnpm@9.0.0",
  "engines": {
    "node": ">=20"
  }
}
```

#### `pnpm-workspace.yaml`
```yaml
packages:
  - "apps/*"
  - "packages/*"
```

#### `turbo.json`
```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "clean": {
      "cache": false
    }
  }
}
```

### 4. Create Shared Packages

#### `packages/typescript-config/`

Create a shared TypeScript configuration package:
- `package.json` with name `@<project-name>/typescript-config`
- `base.json` - Base tsconfig with strict mode, ES2022 target, path aliases
- `nextjs.json` - Extends base with Next.js-specific settings (jsx: preserve, plugins)
- `node.json` - Extends base with Node.js-specific settings (module: commonjs or NodeNext)
- `react-library.json` - Extends base with React library settings (jsx: react-jsx, declaration: true)

#### `packages/eslint-config/`

Create a shared ESLint configuration package:
- `package.json` with name `@<project-name>/eslint-config`, dependencies on eslint, typescript-eslint
- `base.js` - Base config with TypeScript rules
- `next.js` - Extends base with Next.js rules (eslint-config-next)
- `node.js` - Extends base with Node.js rules
- `react.js` - Extends base with React rules (eslint-plugin-react, react-hooks)

#### `packages/tailwind-config/` (if any app is frontend)

Create a shared Tailwind configuration package:
- `package.json` with name `@<project-name>/tailwind-config`
- `tailwind.config.ts` - Shared Tailwind config with content paths, theme extensions
- `postcss.config.js` - PostCSS config

### 5. Create Shared Code Package

For the `shared` package (or any package classified as a library):

#### `packages/shared/`
```
packages/shared/
├── package.json
├── tsconfig.json          # Extends @<project-name>/typescript-config/base.json
├── src/
│   ├── index.ts           # Barrel export
│   ├── types/
│   │   └── index.ts       # Shared TypeScript types
│   ├── utils/
│   │   └── index.ts       # Shared utility functions
│   ├── constants/
│   │   └── index.ts       # Shared constants
│   └── validators/
│       └── index.ts       # Shared Zod schemas
└── turbo/
    └── generators/        # Turborepo code generators (optional)
```

`package.json`:
```json
{
  "name": "@<project-name>/shared",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "lint": "eslint src/",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@<project-name>/eslint-config": "workspace:*",
    "@<project-name>/typescript-config": "workspace:*",
    "typescript": "^5.3.0"
  }
}
```

### 6. Create UI Package (if any frontend app exists)

#### `packages/ui/`
```
packages/ui/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts           # Barrel export
│   ├── button.tsx         # Example Button component
│   ├── input.tsx          # Example Input component
│   └── card.tsx           # Example Card component
└── tailwind.config.ts     # Extends shared tailwind config
```

Each component should be a simple, well-typed React component using Tailwind CSS with `cn()` utility for className merging.

### 7. Create App Packages

For each app classified in step 1:

#### Frontend Apps (web, dashboard, admin, docs, landing)

Use Next.js App Router:
```bash
cd apps/
npx create-next-app@latest <app-name> --typescript --tailwind --eslint --app --src-dir --use-pnpm
```

Then update the app's configs to reference workspace packages:
- `tsconfig.json` extends `@<project-name>/typescript-config/nextjs.json`
- `.eslintrc.js` extends `@<project-name>/eslint-config/next`
- `tailwind.config.ts` extends `@<project-name>/tailwind-config`
- Add `@<project-name>/shared` and `@<project-name>/ui` as dependencies

#### Backend Apps (api, server, backend, gateway, worker)

Create Express/Node.js app:
```
apps/<app-name>/
├── package.json
├── tsconfig.json          # Extends typescript-config/node.json
├── src/
│   ├── index.ts           # Entry point
│   ├── routes/
│   │   └── health.ts      # Health check route
│   ├── middleware/
│   │   └── error-handler.ts
│   └── lib/
│       └── logger.ts
├── Dockerfile
└── .env.example
```

Dependencies: express, cors, helmet, zod, pino
Dev deps: tsx, typescript, @types/express, @types/cors

Add `@<project-name>/shared` as a dependency.

### 8. Docker Setup

Create a `Dockerfile` for each app in `apps/`:

Frontend apps - Multi-stage Next.js Dockerfile:
```dockerfile
FROM node:20-alpine AS base
RUN corepack enable

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/<app>/package.json ./apps/<app>/
COPY packages/*/package.json ./packages/*/  # Copy all package.jsons
RUN pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm turbo build --filter=<app>...

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
COPY --from=builder /app/apps/<app>/.next/standalone ./
COPY --from=builder /app/apps/<app>/.next/static ./apps/<app>/.next/static
COPY --from=builder /app/apps/<app>/public ./apps/<app>/public
USER nextjs
EXPOSE 3000
CMD ["node", "apps/<app>/server.js"]
```

Backend apps - Multi-stage Node.js Dockerfile:
```dockerfile
FROM node:20-alpine AS base
RUN corepack enable

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/<app>/package.json ./apps/<app>/
COPY packages/*/package.json ./packages/*/
RUN pnpm install --frozen-lockfile --prod

FROM base AS builder
WORKDIR /app
COPY --from=deps /app .
COPY . .
RUN pnpm turbo build --filter=<app>...

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN adduser --system --uid 1001 appuser
COPY --from=builder /app/apps/<app>/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
USER appuser
EXPOSE 4000
CMD ["node", "dist/index.js"]
```

Create root `docker-compose.yml`:
```yaml
services:
  # One service per app
  web:
    build:
      context: .
      dockerfile: apps/web/Dockerfile
    ports:
      - "3000:3000"
    env_file: apps/web/.env.local

  api:
    build:
      context: .
      dockerfile: apps/api/Dockerfile
    ports:
      - "4000:4000"
    env_file: apps/api/.env
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

### 9. CI/CD Pipeline

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      # Only build/test changed packages
      - name: Lint changed packages
        run: pnpm turbo lint --filter=...[HEAD~1]

      - name: Type check changed packages
        run: pnpm turbo type-check --filter=...[HEAD~1]

      - name: Test changed packages
        run: pnpm turbo test --filter=...[HEAD~1]

      - name: Build changed packages
        run: pnpm turbo build --filter=...[HEAD~1]
```

### 10. Developer Experience

Create root-level config files:
- `.prettierrc` - Shared Prettier config
- `.prettierignore` - Ignore node_modules, dist, .next, etc.
- `.gitignore` - Comprehensive gitignore for monorepo
- `.nvmrc` - Node version (20)
- `.env.example` - Root env example

### 11. Create README.md

Generate README with:
- Project name and monorepo structure diagram
- What's inside: list of apps and packages
- Prerequisites (Node.js 20+, pnpm)
- Getting started (install, dev, build)
- Adding new apps/packages instructions
- Turborepo commands cheat sheet
- Docker usage
- CI/CD overview
- Dependency graph (text representation)

### 12. Git Initialization

```bash
git init
git add .
git commit -m "feat: scaffold turborepo monorepo with apps and packages"
```

### 13. Final Verification

Run:
```bash
pnpm install
pnpm lint
pnpm build
```

Fix any errors. Report:
- Final project structure
- List of apps and packages created
- How packages reference each other
- Available commands
