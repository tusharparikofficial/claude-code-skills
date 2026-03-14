# Scaffold MCP Server

Scaffold a Model Context Protocol (MCP) server with tool definitions, resource handling, and SSE transport in TypeScript.

## Arguments

$ARGUMENTS - `<name>` the name of the MCP server

## Instructions

1. Create the project directory with the given name in the current working directory.

2. Initialize `package.json` with:
   - Name, version, description
   - `"type": "module"`
   - Scripts: `dev`, `build`, `start`, `inspect`
   - `bin` entry pointing to the built CLI entry point

3. Set up TypeScript:
   - `tsconfig.json` with strict mode, ES2022, NodeNext module resolution
   - Output to `dist/` directory

4. Install dependencies:
   - `@modelcontextprotocol/sdk` for the MCP SDK
   - `zod` for input validation schemas
   - TypeScript and related dev dependencies

5. Create the following source files:

### `src/index.ts`
   - Entry point with shebang (`#!/usr/bin/env node`)
   - Create MCP server instance with name and version
   - Register tools and resources
   - Set up stdio transport (default) and SSE transport (optional flag)
   - Graceful shutdown handling

### `src/server.ts`
   - Server class that configures the MCP server
   - Method to register all tools
   - Method to register all resources
   - Error handling middleware

### `src/tools/`
   - `index.ts` - Tool registry that exports all tools
   - `sample-tool.ts` - Example tool with:
     - Tool name and description
     - Input schema defined with Zod
     - Handler function with proper error responses
     - `content` array with `type: "text"` response format

### `src/resources/`
   - `index.ts` - Resource registry
   - `sample-resource.ts` - Example resource with:
     - URI template
     - Resource name and description
     - Read handler returning resource contents

### `src/transports/`
   - `stdio.ts` - Standard I/O transport setup
   - `sse.ts` - Server-Sent Events transport with Express:
     - SSE endpoint for client connections
     - Message endpoint for receiving client messages
     - CORS configuration
     - Connection management

### `src/utils/`
   - `errors.ts` - MCP error response helpers (invalid params, internal error, not found)
   - `logger.ts` - Logging utility (stderr to avoid stdio transport interference)
   - `validation.ts` - Common Zod schemas and validation helpers

6. Create configuration files:
   - `.gitignore` (node_modules, dist, .env)
   - `.eslintrc.json`
   - `.prettierrc`

7. Create `README.md` with:
   - Server description and available tools/resources
   - Installation instructions (npm install, build)
   - Usage with Claude Code:
     - Adding to `.claude.json` or `claude_desktop_config.json`
     - Example configuration block with `mcpServers`
   - Usage with SSE transport
   - Development instructions
   - How to add new tools and resources

8. Create test setup:
   - `vitest.config.ts`
   - `tests/tools/sample-tool.test.ts` - Test the sample tool handler
   - `tests/resources/sample-resource.test.ts` - Test the sample resource

9. Print a summary of created files and next steps for installation and integration with Claude Code.
