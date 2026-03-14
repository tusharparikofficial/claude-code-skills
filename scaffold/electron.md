# Scaffold Electron App

Scaffold a complete Electron application with IPC communication, auto-update, system tray, and a modern frontend.

## Arguments

$ARGUMENTS - `<name>` the name of the Electron application

## Instructions

1. Create the project directory with the given name in the current working directory.

2. Initialize `package.json` with:
   - Name, version, description, author, license
   - `"main": "dist/main/index.js"`
   - Scripts: `dev`, `build`, `preview`, `package`, `make`, `publish`, `lint`, `test`
   - Dependencies: `electron-updater`, `electron-store`, `electron-log`
   - Dev dependencies: `electron`, `electron-builder`, TypeScript, Vite, Vitest, ESLint, Prettier

3. Set up TypeScript:
   - `tsconfig.json` for main process (Node target)
   - `tsconfig.web.json` for renderer process (DOM target)

4. Create the main process files:

### `src/main/index.ts`
   - Create BrowserWindow with secure defaults:
     - `contextIsolation: true`
     - `nodeIntegration: false`
     - `sandbox: true`
     - Preload script path
   - Load renderer URL (dev server in dev, file in production)
   - Window state persistence (position, size) using `electron-store`
   - Handle app lifecycle events (ready, activate, window-all-closed)
   - Set up auto-updater

### `src/main/menu.ts`
   - Native application menu with:
     - File menu (preferences, quit)
     - Edit menu (undo, redo, cut, copy, paste)
     - View menu (reload, dev tools, zoom)
     - Window menu (minimize, close)
     - Help menu (about, check for updates)
   - macOS-specific menu items

### `src/main/tray.ts`
   - System tray icon and context menu
   - Show/hide window on tray click
   - Tray tooltip with app status
   - Platform-specific tray behavior (macOS, Windows, Linux)

### `src/main/updater.ts`
   - Auto-update using `electron-updater`:
     - Check for updates on app start
     - Notify renderer of update status via IPC
     - Download and install updates
     - Progress reporting
   - Logging via `electron-log`

### `src/main/ipc.ts`
   - IPC handler registration for all main-process operations
   - Type-safe IPC channel definitions
   - Handlers for: file operations, settings, app info, window controls

### `src/main/store.ts`
   - Persistent settings store using `electron-store`
   - Typed schema for settings
   - Default values

5. Create the preload script:

### `src/preload/index.ts`
   - `contextBridge.exposeInMainWorld` with typed API
   - Expose IPC invoke/send/on methods with channel whitelisting
   - Type definitions for the exposed API

### `src/preload/types.ts`
   - TypeScript declarations for `window.electronAPI`
   - IPC channel type definitions

6. Create the renderer (frontend):

### React frontend (default) or Vue (if specified in name/args)

#### `src/renderer/`
   - `index.html` - HTML entry point with CSP meta tag
   - `main.tsx` - React app entry point
   - `App.tsx` - Root component with router
   - `vite.config.ts` - Vite configuration for renderer

#### `src/renderer/components/`
   - `TitleBar.tsx` - Custom title bar (frameless window option) with drag region
   - `UpdateNotification.tsx` - Auto-update notification banner
   - `Layout.tsx` - App layout with sidebar/navigation

#### `src/renderer/hooks/`
   - `useElectronAPI.ts` - Hook wrapping the preload API
   - `useTheme.ts` - Dark/light theme hook synced with system preference

#### `src/renderer/styles/`
   - `global.css` - Global styles, CSS variables for theming
   - `titlebar.css` - Title bar styles

7. Create build configuration:

### `electron-builder.yml`
   - App ID, product name, copyright
   - Directories configuration (output, build resources)
   - macOS: DMG, code signing config placeholders
   - Windows: NSIS installer, code signing config placeholders
   - Linux: AppImage, deb, rpm
   - Auto-update publish configuration (GitHub Releases)
   - File associations (if applicable)

8. Create development configuration:
   - `electron.vite.config.ts` or equivalent Vite config for Electron
   - Dev server with hot reload for renderer
   - Main process rebuild on change

9. Create test setup:
   - `vitest.config.ts`
   - `tests/main/` - Main process tests
   - `tests/renderer/` - Renderer component tests
   - Mock for Electron APIs in tests

10. Create assets:
    - `resources/` directory for app icons
    - `resources/icon.png` placeholder (note to replace)
    - `resources/tray-icon.png` placeholder

11. Add configuration files:
    - `.gitignore` (node_modules, dist, out, .env)
    - `.eslintrc.json`
    - `.prettierrc`

12. Create `README.md` with:
    - App description
    - Development setup instructions
    - Build and packaging instructions
    - Auto-update configuration
    - Project structure overview
    - IPC communication patterns

13. Print a summary of created files and next steps.
