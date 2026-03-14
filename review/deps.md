# Dependency Audit

Audit project dependencies for vulnerabilities, staleness, license issues, bundle size, and maintenance status.

## Arguments

No required arguments. Automatically detects the project's dependency manifest files.

## Instructions

### Step 1: Detect Package Manifests

Search for dependency manifest files in the project root and common subdirectories. Run these in parallel:

1. `find . -maxdepth 3 -name "package.json" -not -path "*/node_modules/*" | head -10`
2. `find . -maxdepth 3 \( -name "requirements.txt" -o -name "pyproject.toml" -o -name "Pipfile" -o -name "setup.py" -o -name "setup.cfg" \) | head -10`
3. `find . -maxdepth 3 -name "go.mod" | head -10`
4. `find . -maxdepth 3 \( -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" \) | head -10`
5. `find . -maxdepth 3 \( -name "Gemfile" -o -name "*.gemspec" \) | head -10`
6. `find . -maxdepth 3 -name "Cargo.toml" | head -10`
7. `find . -maxdepth 3 -name "composer.json" | head -10`

Read all found manifest files using the Read tool.

If no manifest files are found, inform the user and stop.

### Step 2: Vulnerability Scan

Run the available vulnerability scanning tools. Execute in parallel based on detected ecosystems:

**Node.js/npm:**
```
npm audit --json 2>/dev/null || yarn audit --json 2>/dev/null || pnpm audit --json 2>/dev/null
```
Parse the JSON output to extract:
- Package name, installed version, vulnerable version range
- Severity (critical, high, moderate, low)
- Advisory URL and CVE identifier
- Fix available (yes/no, fixed version)

**Python:**
```
pip-audit --format json 2>/dev/null || safety check --json 2>/dev/null
```
If neither tool is available, check if `pip-audit` can be run with `python -m pip_audit`.

**Go:**
```
govulncheck ./... 2>/dev/null
```
If not available, check `go.sum` for known vulnerable versions.

**Rust:**
```
cargo audit --json 2>/dev/null
```

**Ruby:**
```
bundle audit check 2>/dev/null
```

**Java/Maven:**
```
mvn dependency-check:check 2>/dev/null
```

If no vulnerability scanner is available for the ecosystem, note this as a recommendation and skip to the next check.

### Step 3: Staleness Analysis

For each dependency, assess its freshness.

**Node.js:**
Run `npm outdated --json 2>/dev/null` to get current vs latest versions. For each outdated dependency:
- Calculate how many major/minor versions behind
- Flag dependencies that have not been updated in the project for >1 year
- Distinguish between `dependencies`, `devDependencies`, and `peerDependencies`

**Python:**
Run `pip list --outdated --format json 2>/dev/null` to see outdated packages.

**Go:**
Run `go list -m -u all 2>/dev/null | head -50` to list modules with available updates.

For all ecosystems, flag:
- **CRITICAL**: Dependencies >3 major versions behind
- **WARNING**: Dependencies >1 year without updates in the project manifest
- **INFO**: Minor/patch updates available

### Step 4: Bundle Size Analysis (Frontend Projects)

If this is a frontend project (has React, Vue, Angular, Svelte, or similar in dependencies):

Identify the heaviest dependencies by checking known large packages:
- `moment` -> suggest `date-fns` or `dayjs` (65KB vs 2KB)
- `lodash` (full) -> suggest `lodash-es` or individual imports
- `rxjs` (full import) -> suggest tree-shaking
- `@material-ui/core` or `@mui/material` -> check for proper tree-shaking
- `aws-sdk` -> suggest `@aws-sdk/client-*` (v3 modular)
- `chart.js` -> check if full bundle or tree-shaken
- `pdf.js` -> large, check if lazy-loaded

Check `package.json` for `sideEffects` field (important for tree-shaking).

If a bundler config exists (`webpack.config.js`, `vite.config.ts`, `next.config.js`), check for bundle analysis setup.

Report estimated bundle size impact for the top 10 largest dependencies.

### Step 5: License Compatibility

For Node.js projects, run:
```
npx license-checker --json 2>/dev/null | head -200
```

If not available, read `node_modules/*/package.json` for license fields, or parse the lock file.

For other ecosystems, check the manifest for license declarations.

Flag incompatible licenses:
- **CRITICAL**: GPL/AGPL in a proprietary/MIT project (copyleft contamination)
- **WARNING**: LGPL (requires careful linking)
- **WARNING**: No license specified (legally ambiguous)
- **INFO**: Dual-licensed packages (choose the compatible option)

Common compatible licenses for most projects: MIT, BSD-2, BSD-3, Apache-2.0, ISC, Unlicense.

### Step 6: Maintenance Status

For the top dependencies (those used in production, not devDependencies), assess maintenance status:

Use Grep to check for signs in the codebase:
- `deprecated` warnings in lock files or install output
- Package names known to be deprecated or archived

Check for:
- Packages with known replacements (e.g., `request` -> `got`/`axios`/`node-fetch`)
- Packages that are archived or unmaintained
- Packages with a single maintainer and no recent activity

Common deprecated packages to flag:
- `request` (deprecated, use `got`, `axios`, `node-fetch`, or `undici`)
- `node-uuid` (use `uuid`)
- `moment` (use `date-fns`, `dayjs`, or `luxon`)
- `left-pad` (use String.prototype.padStart)
- `underscore` (use `lodash` or native JS)
- `bower` (use npm)
- `tslint` (use eslint with @typescript-eslint)
- `istanbul` (use nyc or c8)

### Step 7: Unused Dependencies

Cross-reference declared dependencies with actual imports in the codebase:

For each dependency in the manifest:
1. Search the codebase for imports of that package: `import.*from ['"]<package>`, `require\(['"]<package>`, `from <package> import`
2. If no imports found, flag as potentially unused
3. Check for indirect usage (CLI tools used in scripts, build plugins, type packages)

Exclude from "unused" check:
- `devDependencies` that are build tools (`webpack`, `vite`, `tsc`, `jest`, `eslint`, etc.)
- Type packages (`@types/*`) — check if the corresponding package is imported
- Babel/PostCSS/ESLint plugins referenced in config files
- CLI tools referenced in `scripts` section of package.json

### Step 8: Alternative Suggestions

For heavy or problematic dependencies, suggest lighter alternatives:

| Current | Alternative | Savings | Notes |
|---------|-------------|---------|-------|
| moment | date-fns | ~60KB | Tree-shakeable, immutable |
| lodash | lodash-es or native | ~70KB | Modern JS covers most use cases |
| axios | fetch (native) | ~13KB | Built into Node 18+ and all browsers |
| express | fastify | Similar | 2x performance, schema validation |
| mongoose | Prisma / Drizzle | Similar | Type-safe, better DX |
| request | got / undici | Similar | request is deprecated |
| uuid | crypto.randomUUID() | ~7KB | Native in Node 19+ and modern browsers |

### Step 9: Generate Report

```
## Dependency Audit Report

**Project**: <detected from package name or directory>
**Ecosystem**: <Node.js / Python / Go / Java / Rust / Ruby / PHP>
**Total Dependencies**: <count> (production: <count>, dev: <count>)
**Date**: <current date>

---

### Summary

<2-3 sentences: overall health, critical issues, key recommendations>

---

### Vulnerability Scan

#### CRITICAL (<count>)

**[DEP-VC1]** <package@version> — <CVE or advisory>
- **Severity**: CRITICAL
- **Description**: <vulnerability description>
- **Fix**: Upgrade to `<package@fixed-version>`
- **Advisory**: <URL>

#### HIGH (<count>)

**[DEP-VH1]** <package@version> — <CVE or advisory>
- **Severity**: HIGH
- **Fix**: `npm install <package>@<version>` / `pip install <package>>=<version>`

#### MODERATE (<count>)

**[DEP-VM1]** <package@version> — <brief description and fix>

#### LOW (<count>)

**[DEP-VL1]** <package@version> — <brief description>

---

### Staleness Report

| Package | Current | Latest | Behind | Last Updated | Status |
|---------|---------|--------|--------|-------------|--------|
| <name> | <ver> | <ver> | <n> major | <date> | CRITICAL/WARNING/OK |

---

### Bundle Size Impact (Frontend)

| Package | Estimated Size (min+gzip) | % of Bundle | Alternative |
|---------|--------------------------|-------------|-------------|
| <name> | <size> | <pct> | <alternative or "N/A"> |

**Total estimated dependency size**: <size>

---

### License Audit

| Status | Package | License | Issue |
|--------|---------|---------|-------|
| CRITICAL | <name> | GPL-3.0 | Copyleft in MIT project |
| WARNING | <name> | UNKNOWN | No license declared |
| OK | <name> | MIT | Compatible |

---

### Maintenance Status

| Package | Status | Action |
|---------|--------|--------|
| <name> | DEPRECATED | Replace with <alternative> |
| <name> | ARCHIVED | Replace with <alternative> |
| <name> | UNMAINTAINED | Consider alternative |

---

### Unused Dependencies

| Package | Type | Confidence | Action |
|---------|------|------------|--------|
| <name> | production | DEFINITE | Remove |
| <name> | dev | LIKELY | Verify and remove |

---

### Recommended Actions

| Priority | Action | Command | Impact |
|----------|--------|---------|--------|
| 1 | Fix critical vulnerability in <pkg> | `npm install <pkg>@<ver>` | Security |
| 2 | Remove deprecated <pkg>, replace with <alt> | `npm uninstall <pkg> && npm install <alt>` | Maintenance |
| 3 | Remove unused <pkg> | `npm uninstall <pkg>` | Bundle size |
| 4 | Update stale dependencies | `npm update` | Security, features |

---

### Health Score

| Dimension | Score (1-5) | Notes |
|-----------|-------------|-------|
| Security | <score> | <n> known vulnerabilities |
| Freshness | <score> | <n> outdated packages |
| Bundle Size | <score> | <size> total |
| Licensing | <score> | <n> issues |
| Maintenance | <score> | <n> deprecated/archived |
| **Overall** | **<avg>** | |
```

Offer to run the suggested update commands if the user wants to fix issues immediately.
