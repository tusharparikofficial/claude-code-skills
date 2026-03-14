# Snapshot Test Generator

Generate snapshot tests for UI components, covering all prop variations, states, and visual configurations.

## Arguments

$ARGUMENTS - `<component-file-path>` — Path to the UI component file to generate snapshot tests for.

## Instructions

### Step 1: Analyze the Component

1. Read the component file at the provided path.
2. Extract the component's interface:
   - **Props/inputs**: names, types, required vs optional, default values
   - **Slots/children**: named slots, default slot, render props
   - **State**: internal state variables, derived/computed state
   - **Variants**: size, color, variant props that change visual output
   - **Conditional rendering**: elements that appear/disappear based on props or state
3. Identify the component framework:
   - React (JSX/TSX) — functional or class component
   - Vue (SFC, Composition API, Options API)
   - Svelte (.svelte files)
   - Angular (component + template)
4. Map out the component's visual states:
   - Default/idle state
   - Loading state
   - Error state
   - Empty/no-data state
   - Disabled state
   - Active/selected state
   - Hover/focus state (if CSS-in-JS or styled-components)
5. Identify child components and their impact on rendering.

### Step 2: Detect Snapshot Testing Setup

1. Search for existing snapshot tests to match patterns:
   - Jest snapshots (`.toMatchSnapshot()`, `.toMatchInlineSnapshot()`)
   - Vitest snapshots
   - Storybook + Chromatic/Percy
   - React Testing Library `render()` + snapshots
   - Vue Test Utils `mount()`/`shallowMount()` + snapshots
2. Identify the rendering approach:
   - Full render vs shallow render
   - Custom render wrappers (with providers, theme, router)
   - Whether the project uses `shallowMount` or full `mount`
3. Check for snapshot serializers or custom snapshot resolvers.
4. Locate the snapshot directory convention (`__snapshots__/`, inline, etc.).

### Step 3: Generate Snapshot Test File

#### 3a: Test Setup
- Import testing utilities (render, screen, etc.)
- Import the component under test
- Set up any required providers (Theme, Router, Store, Intl)
- Create mock data factories for complex prop types
- Set up mock functions for callback props

#### 3b: Default State Snapshot
```
test('renders with default props', () => {
  // Render with only required props
  // Assert snapshot matches
});
```

#### 3c: All Optional Props Provided
```
test('renders with all props provided', () => {
  // Render with every prop explicitly set
  // Assert snapshot matches
});
```

#### 3d: Prop Variation Snapshots

For each prop that changes visual output, generate snapshots:

**Enum/union props** (size, variant, color):
- One snapshot per enum value
- Group in a describe block: `describe('sizes', () => { ... })`

**Boolean props** (disabled, loading, checked, open):
- Snapshot with `true`
- Snapshot with `false` (if different from default)

**String props** with visual impact:
- Short text
- Long text (overflow/truncation)
- Empty string
- Text with special characters

**Array/object props**:
- Empty array/object
- Single item
- Many items (to test list rendering)
- Items with varying content

**Children/slot content**:
- Simple text children
- Complex nested children
- No children (if optional)

#### 3e: State-Based Snapshots

**Loading state**:
```
test('renders loading state', () => {
  // Render with loading=true or isLoading prop
  // Assert snapshot shows loading indicator
});
```

**Error state**:
```
test('renders error state', () => {
  // Render with error prop or error state
  // Assert snapshot shows error message/UI
});
```

**Empty state**:
```
test('renders empty state', () => {
  // Render with empty data (items=[], data=null)
  // Assert snapshot shows empty state UI
});
```

**Disabled state**:
```
test('renders disabled state', () => {
  // Render with disabled=true
  // Assert snapshot reflects disabled styling
});
```

#### 3f: Conditional Rendering Snapshots

For each conditional render in the component:
- Snapshot with condition true (element visible)
- Snapshot with condition false (element hidden)
- Test each branch of ternary expressions

#### 3g: Composition Snapshots (if applicable)

If the component composes with other components:
- Snapshot with different child component combinations
- Snapshot compound components together (e.g., Tabs + Tab + TabPanel)

### Step 4: Add Snapshot Update Documentation

Add a comment block at the top of the test file:

```
/**
 * Snapshot tests for <ComponentName>
 *
 * These snapshots capture the rendered output of the component
 * across different prop combinations and states.
 *
 * To update snapshots after intentional visual changes:
 *   npx jest --updateSnapshot --testPathPattern=<this-file>
 *   npx vitest run --update <this-file>
 *
 * Review snapshot diffs carefully before committing updates.
 */
```

### Step 5: Validate and Run

1. Write the test file following project conventions.
2. Run the snapshot tests:
   - Jest: `npx jest <file> --verbose`
   - Vitest: `npx vitest run <file>`
3. Verify all snapshots are created successfully.
4. Review generated snapshots for quality:
   - Snapshots should not be excessively large (if they are, consider shallow rendering)
   - Snapshots should capture meaningful component structure
   - Dynamic values (dates, IDs) should be mocked or stabilized
5. Report summary:
   - Total snapshot tests generated
   - Prop combinations covered
   - States covered
   - Any props or states that were skipped and why

### Important Guidelines

- Use descriptive test names that explain WHAT is being rendered: `renders large primary button with icon`.
- Prefer `toMatchSnapshot()` over `toMatchInlineSnapshot()` for complex components (inline is better for small outputs).
- Mock dates, random IDs, and any non-deterministic values to prevent false snapshot failures.
- If the component uses animations, disable them in tests or snapshot the static state.
- Do not snapshot implementation details (internal state, private methods).
- If using shallow rendering, document why (usually to isolate from child component changes).
- Keep snapshot tests separate from behavioral tests — snapshots verify structure, unit tests verify behavior.
- If a component has more than 50 possible prop combinations, focus on the most common and edge case combinations rather than exhaustive permutations.
- When the project uses Storybook, consider generating stories instead of (or in addition to) snapshot tests.
