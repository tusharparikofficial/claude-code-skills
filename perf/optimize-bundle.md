# JS Bundle Optimizer

Analyze and optimize JavaScript bundle size for faster loading.

## Arguments

$ARGUMENTS - Optional focus area or entry point (e.g., "main bundle", "vendor chunk", or leave blank for all)

## Instructions

1. **Detect the build tool** by reading `package.json` and config files:
   - Webpack: `webpack.config.js` or `next.config.js`
   - Vite: `vite.config.ts`
   - Rollup: `rollup.config.js`
   - esbuild: `esbuild` in scripts
   - Turbopack: `next.config.js` with turbo

2. **Run bundle analysis**:
   - Install and configure `webpack-bundle-analyzer`, `rollup-plugin-visualizer`, or `vite-bundle-analyzer` if not present.
   - Run a production build and capture the stats.
   - Parse the output to get: total bundle size, chunk sizes, module sizes.
   - Identify the top 10 largest dependencies by size.

3. **Find the largest dependencies**:
   - List all node_modules packages included in the bundle with their sizes.
   - For each large dependency (>50KB gzipped), check if a lighter alternative exists:
     - `moment` -> `dayjs` or `date-fns`
     - `lodash` -> `lodash-es` or individual imports
     - `axios` -> `ky` or native `fetch`
     - `uuid` -> `crypto.randomUUID()`
     - `classnames` -> `clsx`
     - `underscore` -> native array methods
   - Check if the dependency is used in only a few places (candidate for removal).

4. **Find duplicate packages**:
   - Check for multiple versions of the same package in the bundle.
   - Identify the source: different dependencies requiring different versions.
   - Recommend resolution: package.json `overrides`/`resolutions`, or updating dependencies.

5. **Check tree-shaking effectiveness**:
   - Find barrel files (`index.ts` that re-export everything) that prevent tree-shaking.
   - Find `import *` patterns that include unused exports.
   - Check `sideEffects` field in package.json for dependencies.
   - Verify `"sideEffects": false` is set in the project's own package.json if applicable.

6. **Apply code splitting**:
   - Identify routes/pages that are not lazy-loaded. Add dynamic imports.
   - Move heavy components below the fold to lazy-loaded chunks.
   - Configure shared chunk splitting to avoid duplication across route chunks.
   - Set up prefetching for likely next-navigation chunks.

7. **Apply lazy loading**:
   - Find components using heavy libraries (charts, editors, maps) that are imported at the top level.
   - Convert to dynamic imports with loading fallbacks.
   - For React: use `React.lazy()` + `Suspense`. For Next.js: use `next/dynamic`.
   - For non-React: use native `import()` with loading states.

8. **Apply additional optimizations**:
   - Enable gzip/brotli compression in the build output.
   - Configure aggressive minification (terser options: drop console, mangle).
   - Move large static data (JSON, constants) to external files loaded on demand.
   - Configure long-term caching with content hashes in filenames.

9. **Generate before/after report**:
   - Table: chunk name, before size (gzipped), after size (gzipped), savings %.
   - Total before vs. after.
   - Estimated load time improvement at 3G, 4G, broadband speeds.
   - List of changes made with explanations.

10. **Verify the build still works**: Run the production build after optimizations and confirm no errors.
