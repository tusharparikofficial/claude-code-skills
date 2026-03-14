# Scaffold Slack Bot

Scaffold a Slack bot using Bolt.js with slash commands, event handling, modals, and Docker deployment.

## Arguments

$ARGUMENTS - `<name>` the name of the Slack bot

## Instructions

1. Create the project directory with the given name in the current working directory.

2. Initialize `package.json` with:
   - Name, version, description
   - Scripts: `dev`, `build`, `start`, `test`, `lint`
   - Dependencies: `@slack/bolt`, `dotenv`
   - Dev dependencies: TypeScript, Vitest, ESLint, Prettier

3. Set up TypeScript with `tsconfig.json` (strict mode, ES2022, outDir: dist).

4. Create the following source files:

### `src/app.ts`
   - Initialize Bolt app with token, signing secret, app-level token (for Socket Mode)
   - Configure Socket Mode for development, HTTP for production
   - Register all listeners (commands, events, actions, views)
   - Start the app with port configuration
   - Graceful shutdown on SIGTERM/SIGINT

### `src/listeners/`
   - `index.ts` - Register all listener modules
   - `commands/index.ts` - Slash command registry
   - `commands/hello.ts` - Sample slash command (`/hello`) with:
     - Input parsing
     - Ephemeral response
     - Rich message formatting with Block Kit
   - `events/index.ts` - Event subscription registry
   - `events/app-mention.ts` - Handle `app_mention` events:
     - Parse mention text
     - Reply in thread
   - `events/message.ts` - Handle `message` events with filtering
   - `actions/index.ts` - Interactive action registry
   - `actions/button-click.ts` - Handle button click actions with acknowledgment
   - `views/index.ts` - Modal view submission registry
   - `views/sample-modal.ts` - Modal dialog with:
     - Form inputs (text, select, date picker)
     - View submission handler
     - Input validation

### `src/blocks/`
   - `home-tab.ts` - App Home tab layout using Block Kit
   - `messages.ts` - Reusable message templates with Block Kit blocks
   - `modals.ts` - Reusable modal templates

### `src/middleware/`
   - `auth.ts` - Custom middleware for authorization checks
   - `logging.ts` - Request logging middleware

### `src/utils/`
   - `config.ts` - Environment variable loading and validation
   - `logger.ts` - Structured logging utility
   - `errors.ts` - Error handling helpers with user-friendly Slack messages

### `src/types/`
   - `index.ts` - Shared TypeScript types for commands, events, actions

5. Create OAuth flow support:
   - `src/oauth/` directory
   - `install-provider.ts` - OAuth installation flow using `@slack/bolt` InstallProvider
   - `callback.ts` - OAuth callback handler
   - Note: Include instructions for single-workspace vs. distributed app

6. Create environment configuration:
   - `.env.example` with all required variables:
     - `SLACK_BOT_TOKEN`
     - `SLACK_SIGNING_SECRET`
     - `SLACK_APP_TOKEN` (for Socket Mode)
     - `SLACK_CLIENT_ID` (for OAuth)
     - `SLACK_CLIENT_SECRET` (for OAuth)
     - `PORT`
     - `NODE_ENV`
   - `.env` added to `.gitignore`

7. Create Docker deployment files:
   - `Dockerfile` - Multi-stage build (build + runtime)
   - `docker-compose.yml` - Service definition with environment variables
   - `.dockerignore`

8. Create test setup:
   - `vitest.config.ts`
   - `tests/commands/hello.test.ts`
   - `tests/events/app-mention.test.ts`
   - Mock utilities for Bolt context objects (say, respond, ack, client)

9. Add configuration files:
   - `.gitignore`
   - `.eslintrc.json`
   - `.prettierrc`

10. Create `README.md` with:
    - Bot description
    - Slack app setup instructions (create app, configure scopes, enable events)
    - Required OAuth scopes list
    - Event subscriptions to enable
    - Development setup (Socket Mode)
    - Production deployment (Docker)
    - Environment variables reference
    - Adding new commands/events guide

11. Create `slack-app-manifest.yml` - Slack app manifest for easy app creation via api.slack.com.

12. Print a summary of created files and next steps.
