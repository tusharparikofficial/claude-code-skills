# Scaffold Chrome Extension

Scaffold a complete Chrome extension with Manifest V3, TypeScript, and a modern build pipeline.

## Arguments

$ARGUMENTS - `<name>` the name of the Chrome extension

## Instructions

1. Create the project directory with the given name in the current working directory.

2. Initialize `package.json` with the extension name, scripts for dev/build/watch, and dependencies.

3. Create `manifest.json` (Manifest V3):
   - `manifest_version: 3`
   - `name`, `version`, `description`
   - `permissions`: storage, activeTab, tabs (adjust based on needs)
   - `action` with `default_popup`, `default_icon`
   - `background` with `service_worker` pointing to the built background script
   - `content_scripts` array with matches pattern and script reference
   - `options_page` or `options_ui` with `open_in_tab: false`
   - `icons` with 16, 32, 48, 128 sizes

4. Set up TypeScript:
   - `tsconfig.json` with strict mode, DOM lib, ES2022 target
   - Chrome types via `@types/chrome`

5. Set up build system (Vite or webpack):
   - Multiple entry points: popup, background, content, options
   - Output to `dist/` directory
   - Copy manifest.json and static assets to dist
   - Watch mode for development
   - Source maps in development only

6. Create source files:

### `src/popup/`
   - `popup.html` - Clean popup UI with basic layout
   - `popup.ts` - Popup logic: read/write storage, send messages to background
   - `popup.css` - Styled popup with sensible defaults

### `src/background/`
   - `service-worker.ts` - Background service worker:
     - `chrome.runtime.onInstalled` listener
     - `chrome.runtime.onMessage` listener for message passing
     - `chrome.action.onClicked` handler
     - Alarm setup for periodic tasks
     - Context menu creation

### `src/content/`
   - `content.ts` - Content script:
     - DOM manipulation helpers
     - Message passing to/from background
     - `chrome.runtime.onMessage` listener
     - Mutation observer setup for dynamic pages

### `src/options/`
   - `options.html` - Options page UI
   - `options.ts` - Options logic: save/load settings via `chrome.storage.sync`
   - `options.css` - Options page styling

### `src/shared/`
   - `storage.ts` - Type-safe wrapper around `chrome.storage` API (get, set, remove, onChange)
   - `messaging.ts` - Type-safe message passing helpers (sendMessage, onMessage with typed payloads)
   - `types.ts` - Shared TypeScript interfaces for messages, storage schema, settings

7. Create icon placeholders:
   - `public/icons/` directory
   - `icon-16.png`, `icon-32.png`, `icon-48.png`, `icon-128.png` placeholder files
   - Note in README that these should be replaced with actual icons

8. Create `public/` directory for static assets.

9. Add configuration files:
   - `.gitignore` (node_modules, dist, .env)
   - `.eslintrc.json` with TypeScript config
   - `.prettierrc`

10. Create `README.md` with:
    - Extension description
    - Development setup instructions
    - How to load the unpacked extension in Chrome
    - Build commands
    - Project structure overview
    - Screenshots template section

11. Print a summary of created files and next steps.
