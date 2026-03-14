# Scaffold Next.js Application

Scaffold a production-ready Next.js 14+ application with App Router, TypeScript, and optional integrations.

## Arguments

$ARGUMENTS - `<project-name> [options]` where options are: --auth, --db, --payments, --email

## Instructions

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- `project-name` (required) - the directory/project name
- `--auth` - include authentication (NextAuth.js or Clerk)
- `--db` - include database (Prisma + PostgreSQL)
- `--payments` - include Stripe payments
- `--email` - include email (Resend + React Email)

If no project name is provided, ask the user for one before proceeding.

### 2. Initialize Project

Run:
```bash
npx create-next-app@latest <project-name> \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --use-pnpm
```

After initialization, `cd` into the project directory for all subsequent steps.

### 3. Install Base Dependencies

```bash
pnpm add zod clsx tailwind-merge lucide-react
pnpm add -D prettier prettier-plugin-tailwindcss @types/node
```

### 4. Create Directory Structure

Create the following directories under `src/`:

```
src/
├── app/
│   ├── (marketing)/        # Public pages
│   ├── (dashboard)/         # Authenticated pages (if --auth)
│   ├── api/                 # API routes
│   │   └── health/
│   │       └── route.ts     # Health check endpoint
│   ├── error.tsx            # Error boundary
│   ├── loading.tsx          # Root loading state
│   ├── not-found.tsx        # 404 page
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Home page
├── components/
│   ├── ui/                  # Reusable UI primitives
│   │   ├── button.tsx
│   │   └── input.tsx
│   ├── layouts/             # Layout components
│   │   ├── header.tsx
│   │   └── footer.tsx
│   └── providers.tsx        # Client providers wrapper
├── lib/
│   ├── constants.ts         # App-wide constants
│   └── utils.ts             # Utility functions (cn helper)
├── hooks/                   # Custom React hooks
├── types/                   # TypeScript type definitions
│   └── index.ts
└── utils/                   # Pure utility functions
```

### 5. Create Core Files

#### `src/lib/utils.ts`
```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

#### `src/app/api/health/route.ts`
```typescript
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
}
```

#### `src/app/error.tsx`
Create a client component error boundary that displays a user-friendly error message and a retry button. Include `reset()` callback support.

#### `src/app/loading.tsx`
Create a loading spinner/skeleton component used as the root loading state.

#### `src/app/not-found.tsx`
Create a 404 page with a link back to home.

### 6. Environment Validation

Create `src/env.ts` using Zod for runtime environment variable validation:

```typescript
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  NEXT_PUBLIC_APP_URL: z.string().url().default("http://localhost:3000"),
  // Add more as integrations are added
});

export const env = envSchema.parse(process.env);
```

Create `.env.example` with all required variables documented.
Create `.env.local` with development defaults.

### 7. Conditional: --auth (Authentication)

If `--auth` is specified:

Install NextAuth.js v5 (Auth.js):
```bash
pnpm add next-auth@beta @auth/prisma-adapter
```

Create:
- `src/lib/auth.ts` - Auth.js configuration with credentials + Google/GitHub providers
- `src/app/api/auth/[...nextauth]/route.ts` - Auth API route
- `src/app/(auth)/login/page.tsx` - Login page with form
- `src/app/(auth)/signup/page.tsx` - Sign up page with form
- `src/middleware.ts` - Route protection middleware
- `src/components/auth/user-button.tsx` - User avatar/menu component
- `src/components/auth/login-form.tsx` - Reusable login form
- `src/components/auth/signup-form.tsx` - Reusable signup form

Add auth env vars to `src/env.ts`:
```
AUTH_SECRET, AUTH_GOOGLE_ID, AUTH_GOOGLE_SECRET (optional)
```

### 8. Conditional: --db (Database)

If `--db` is specified:

Install Prisma:
```bash
pnpm add @prisma/client
pnpm add -D prisma
npx prisma init
```

Create:
- `prisma/schema.prisma` - Schema with User model (and Account/Session if --auth)
- `src/lib/db.ts` - Singleton Prisma client instance
- `prisma/seed.ts` - Seed script with sample data
- Add `prisma` seed config to `package.json`

If `--auth` is also specified, include the Auth.js Prisma adapter models in the schema.

Add database env vars to `src/env.ts`:
```
DATABASE_URL
```

### 9. Conditional: --payments (Stripe)

If `--payments` is specified:

Install:
```bash
pnpm add stripe @stripe/stripe-js
```

Create:
- `src/lib/stripe.ts` - Stripe server-side client
- `src/lib/stripe-client.ts` - Stripe client-side loader
- `src/app/api/stripe/checkout/route.ts` - Create checkout session
- `src/app/api/stripe/webhook/route.ts` - Webhook handler with signature verification
- `src/app/api/stripe/portal/route.ts` - Customer portal session
- `src/components/payments/pricing-card.tsx` - Pricing display component
- `src/components/payments/checkout-button.tsx` - Checkout trigger button

Add Stripe env vars to `src/env.ts`:
```
STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
```

### 10. Conditional: --email (Email)

If `--email` is specified:

Install:
```bash
pnpm add resend @react-email/components react-email
```

Create:
- `src/lib/email.ts` - Resend client wrapper with send function
- `src/emails/welcome.tsx` - Welcome email template using React Email
- `src/emails/reset-password.tsx` - Password reset template (if --auth)
- `src/app/api/email/send/route.ts` - Email sending API route
- Add `email:dev` script to package.json for React Email preview

Add email env vars to `src/env.ts`:
```
RESEND_API_KEY, EMAIL_FROM
```

### 11. Docker Setup

Create `Dockerfile` with multi-stage build:
- Stage 1: `deps` - Install dependencies only
- Stage 2: `builder` - Build the Next.js app
- Stage 3: `runner` - Production image with standalone output
- Use `node:20-alpine` as base
- Run as non-root user `nextjs`
- Set `NEXT_TELEMETRY_DISABLED=1`

Create `docker-compose.yml`:
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    env_file: .env.local
    depends_on:
      db:
        condition: service_healthy
  # Include db service if --db flag
```

If `--db`, add PostgreSQL service with health check and persistent volume.

Create `.dockerignore` excluding node_modules, .next, .git, etc.

### 12. CI/CD Pipeline

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm build
```

### 13. Configuration Files

Create/update:
- `.prettierrc` - Prettier config with tailwind plugin
- `.prettierignore` - Ignore patterns
- `tsconfig.json` - Ensure strict mode and path aliases

Add scripts to `package.json`:
```json
{
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "type-check": "tsc --noEmit"
}
```

### 14. Create README.md

Generate a README with:
- Project name and description
- Tech stack list
- Prerequisites (Node.js 20+, pnpm, Docker)
- Getting started instructions (clone, install, env setup, run)
- Available scripts
- Project structure overview
- Deployment instructions
- Environment variables table

### 15. Final Verification

Run:
```bash
pnpm lint
pnpm build
```

Fix any errors that arise. Report the final project structure and which integrations were set up.
