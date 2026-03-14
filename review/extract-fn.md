# Extract Function

Extract a code block into a well-named, well-typed function.

## Arguments

$ARGUMENTS - `<file-path> <start-line> <end-line>` — the file and line range of the code block to extract.

## Instructions

### 1. Parse Arguments

- Extract `file-path`, `start-line`, and `end-line` from `$ARGUMENTS`.
- Validate that start-line < end-line and both are positive integers.
- Read the entire file. Determine the language from the file extension.
- Read the specific code block at the given line range.

### 2. Analyze the Code Block

#### a. Identify Inputs
- List every variable referenced in the block that is declared outside of it.
- These become function parameters.
- Record the type of each variable by examining its declaration or usage context.

#### b. Identify Outputs
- List every variable that is modified or assigned inside the block and used after it.
- If exactly one variable is modified, it becomes the return value.
- If multiple variables are modified, return an object/tuple containing all of them.
- If no variables are modified (pure side-effect), return void/None.

#### c. Identify Side Effects
- Flag any I/O operations (file, network, database, console).
- Flag any mutations of objects passed by reference.
- Flag any global/module-level state changes.
- Document these as JSDoc/docstring notes on the extracted function.

#### d. Determine Context Dependencies
- Check if the block uses `this` / `self` — if so, the function must be a method on the same class, or `this` must be passed explicitly.
- Check if the block uses closure variables that cannot be passed as parameters.

### 3. Generate the Extracted Function

#### a. Choose a Name
- Derive the name from what the code block does, not how it does it.
- Use verb + noun pattern: `calculateTotal`, `validateInput`, `formatUserName`, `fetchOrderDetails`.
- If the block is inside a class, name relative to the class responsibility.

#### b. Build the Signature
- Parameters: all identified inputs, ordered by importance (most critical first).
- Return type: based on identified outputs.
- Add full type annotations:
  - TypeScript: parameter types, return type, generics if needed.
  - Python: type hints for parameters, return type annotation.
  - Other languages: use the language's type annotation mechanism.
- If the function has side effects, document them in a comment or docstring.

#### c. Build the Body
- Copy the code block as the function body.
- Replace any references to outer-scope variables with the parameter names.
- Add a return statement for the identified output(s).
- Ensure proper indentation for the target location.

#### d. Determine Placement
- If the block was inside a class method, place the new function as a private method on the same class, directly below the method it was extracted from.
- If the block was inside a standalone function, place the new function directly above or below the original function (prefer above so it is defined before use).
- If the block was at module level, place the new function in a logical position near related functions.
- NEVER place the function inside another function unless the language idiomatically supports nested functions and it makes sense.

### 4. Replace the Original Code

- Replace the original code block (start-line to end-line) with a call to the new function.
- Pass all identified inputs as arguments.
- Capture the return value in the appropriate variable(s).
- If the block had early returns from the outer function, handle that: either check the return value of the extracted function and return from the outer function conditionally, or restructure accordingly.

### 5. Apply Changes

Use the Edit tool to:
1. Insert the new function at the determined location.
2. Replace the original code block with the function call.

Apply insertions and replacements carefully to avoid line-number drift. If both edits are in the same file, apply the one at the higher line number first.

### 6. Present the Result

Show a summary:

```
Extracted function: `<functionName>`
  Parameters: <list with types>
  Returns: <type>
  Side effects: <list or "none">
  Placed at: line <N>
  Original block (lines <start>-<end>) replaced with function call at line <start>
```

Show the final function signature and the replacement call site.

### 7. Verify

- Re-read the modified file to ensure it parses correctly.
- If the project has a test or build command, run it to verify no regressions.
- If there are syntax errors, fix them immediately.

### 8. Important Rules

- NEVER change the behavior of the code — the extraction must be a pure refactoring.
- NEVER rename existing variables outside the extracted block.
- Preserve all comments that were inside the block — move them into the new function.
- If the code block is too small (1-2 lines) or too trivial, warn the user that extraction may not improve readability, but proceed if they confirm.
- If the code block spans across control flow boundaries (e.g., half of an if/else), warn the user and suggest adjusting the line range.
