# Split File

Split a large file into focused, cohesive modules.

## Arguments

$ARGUMENTS - `<file-path>` of the file to split into smaller modules.

## Instructions

### 1. Parse Arguments and Read File

- Extract the file path from `$ARGUMENTS`.
- Read the entire file content. Determine the language and module system (ES Modules, CommonJS, Python modules, Go packages, etc.).
- If the file is under 200 lines, warn the user that splitting may not be beneficial and ask for confirmation before proceeding.

### 2. Analyze File Structure

#### a. Inventory All Declarations
- List every function, class, type/interface, constant, and variable declared in the file.
- For each declaration, record:
  - Name
  - Kind (function, class, type, constant, variable)
  - Line range (start-end)
  - Whether it is exported/public
  - Which other declarations in the file it references

#### b. Build a Dependency Graph
- Create an internal dependency graph: which declarations call/reference which other declarations.
- Identify clusters of tightly coupled declarations (high internal cohesion).
- Identify declarations with no internal dependencies (standalone candidates).

#### c. Identify Natural Split Boundaries
Use these heuristics to group declarations:

1. **Naming patterns**: Functions/types that share a prefix or suffix (`user*`, `*Handler`, `*Service`) likely belong together.
2. **Class boundaries**: Each class and its closely related helpers can be a module.
3. **Type + implementation**: Types/interfaces and the functions that operate on them belong together.
4. **Constants + consumers**: Constants used only by specific functions should move with those functions.
5. **Utilities**: Pure utility functions used across multiple groups can go into a shared utils module.
6. **Domain concepts**: Group by the domain entity they operate on (user, order, payment, etc.).

### 3. Propose Split Plan

Present a plan in this format:

```
## Split Plan for <original-file>

### File 1: <new-file-path>
Purpose: <one-line description>
Contains:
  - functionA (lines X-Y)
  - TypeB (lines X-Y)
  - CONSTANT_C (line X)
Depends on: File 2 (imports TypeD)

### File 2: <new-file-path>
Purpose: <one-line description>
Contains:
  - functionD (lines X-Y)
  - TypeD (lines X-Y)
Depends on: (none)

### Index file: <index-file-path> (if needed)
Re-exports: everything from File 1, File 2
Purpose: backward-compatible public API
```

#### Naming Conventions for New Files
- Use the same casing convention as existing files in the directory.
- Name files after the primary concept they contain: `user-validation.ts`, `order-repository.py`, `payment_handler.go`.
- If an index/barrel file is needed for backward compatibility, create it.

### 4. Wait for Confirmation

- Present the split plan and ask the user: "Proceed with this split? (yes / modify / cancel)"
- If the user wants modifications, adjust the plan and re-present.

### 5. Execute the Split

For each new file in the plan:

#### a. Create the New File
- Write the file with the grouped declarations.
- Add necessary import statements for any dependencies on other new files.
- Preserve the original file's header comments, license blocks, or pragmas as appropriate.
- Maintain the original code formatting and style.

#### b. Handle Imports and Exports
- Each new file must import what it needs from other new files.
- Each new file must export its public declarations.
- If the language supports it, create a barrel/index file that re-exports everything for backward compatibility.

#### c. Update the Original File
- If creating an index file, replace the original file's contents with re-exports.
- If not creating an index file, delete the original file's contents (it is now split).

### 6. Update All Importers Across the Codebase

This is the most critical step:

- Search the entire codebase for any file that imports from the original file path.
- For each importer:
  - Determine which specific declarations it imports.
  - Update the import path to point to the correct new file.
  - If a barrel/index file exists and the importer already works with it, no change needed.
- Use the Grep tool to find all import/require statements referencing the original file.

### 7. Verify Correctness

- Re-read all new files to ensure they parse correctly.
- Search for any remaining references to the original file path that were not updated.
- If the project has a build command, run it to verify no broken imports.
- If the project has tests, run them to verify no regressions.
- Report any issues found and fix them.

### 8. Summary Report

```
Split complete:
  Original: <file-path> (<N> lines)
  Created:
    - <new-file-1> (<N> lines) — <purpose>
    - <new-file-2> (<N> lines) — <purpose>
    - <index-file> (re-exports)
  Updated importers: <N> files
  Tests: PASS / FAIL / NOT RUN
```

### 9. Important Rules

- NEVER break the public API — external consumers must still be able to import from the same path if an index file is created.
- NEVER create circular dependencies between the new files. If the dependency graph requires it, restructure the grouping.
- NEVER split a file into modules where one module has only 1-2 trivial declarations — that is over-splitting.
- Preserve git blame by making minimal changes to the actual code content (only modify imports/exports, not function bodies).
- If the file uses internal/private declarations not meant to be exported, keep them private in the new modules (unexported, prefixed with underscore, etc.).
