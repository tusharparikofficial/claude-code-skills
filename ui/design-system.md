# Create Design System

Generate a design system with color tokens, typography, spacing, and base components for React or Vue.

## Arguments

$ARGUMENTS - `<framework>` where framework is one of: react, vue

## Instructions

1. Determine the framework from the arguments. Default to React if not specified.

2. Create a `src/design-system/` directory (or `src/components/design-system/` based on project structure).

3. Generate design tokens as CSS custom properties:

### `tokens/colors.css`
   - Primary palette: 50-950 shades (e.g., `--color-primary-50` through `--color-primary-950`)
   - Neutral/gray palette: 50-950 shades
   - Semantic colors: `--color-success`, `--color-warning`, `--color-error`, `--color-info` (each with light/default/dark variants)
   - Surface colors: `--color-surface`, `--color-surface-raised`, `--color-surface-overlay`
   - Text colors: `--color-text-primary`, `--color-text-secondary`, `--color-text-muted`, `--color-text-inverse`
   - Border colors: `--color-border`, `--color-border-strong`
   - Dark mode overrides using `[data-theme="dark"]` selector

### `tokens/typography.css`
   - Font families: `--font-sans`, `--font-mono`, `--font-heading`
   - Font sizes using a modular scale (1.25 ratio): `--text-xs` through `--text-4xl`
   - Font weights: `--font-normal`, `--font-medium`, `--font-semibold`, `--font-bold`
   - Line heights: `--leading-tight`, `--leading-normal`, `--leading-relaxed`
   - Letter spacing: `--tracking-tight`, `--tracking-normal`, `--tracking-wide`

### `tokens/spacing.css`
   - Spacing scale based on 4px grid: `--space-0` (0), `--space-1` (4px) through `--space-16` (64px)
   - Additional: `--space-px` (1px), `--space-0.5` (2px)

### `tokens/breakpoints.css`
   - Breakpoints: `--bp-sm` (640px), `--bp-md` (768px), `--bp-lg` (1024px), `--bp-xl` (1280px), `--bp-2xl` (1536px)

### `tokens/shadows.css`
   - Shadow scale: `--shadow-sm`, `--shadow-md`, `--shadow-lg`, `--shadow-xl`
   - Focus ring: `--ring-focus`

### `tokens/radii.css`
   - Border radii: `--radius-sm`, `--radius-md`, `--radius-lg`, `--radius-xl`, `--radius-full`

### `tokens/index.css`
   - Import all token files

4. Generate base components (React or Vue based on framework):

### Button component
   - Variants: `primary`, `secondary`, `outline`, `ghost`, `destructive`
   - Sizes: `sm`, `md`, `lg`
   - States: default, hover, focus, active, disabled, loading
   - Loading state with spinner
   - Icon support (left/right icon slots)
   - Full width option
   - Proper `button` element with type attribute
   - Keyboard accessible

### Input component
   - Types: text, email, password, number, search
   - States: default, focus, error, disabled
   - Label (associated with `htmlFor`/`for`)
   - Helper text and error message
   - Left/right addon or icon slots
   - Sizes: `sm`, `md`, `lg`

### Card component
   - Variants: `default`, `outlined`, `elevated`
   - Sections: header, body, footer (composable)
   - Padding options
   - Clickable variant with hover effect

### Badge component
   - Variants: `default`, `success`, `warning`, `error`, `info`
   - Sizes: `sm`, `md`
   - Dot indicator option
   - Removable (with close button)

### Avatar component
   - Image with fallback to initials
   - Sizes: `xs`, `sm`, `md`, `lg`, `xl`
   - Status indicator (online, offline, away)
   - Group/stack layout

### Modal (Dialog) component
   - Overlay backdrop with click-to-close
   - Sizes: `sm`, `md`, `lg`, `full`
   - Header with close button
   - Body with scroll support
   - Footer with action buttons
   - Focus trap
   - Escape key to close
   - Animation (fade + scale)
   - Portal rendering

### Toast (Notification) component
   - Variants: `success`, `error`, `warning`, `info`
   - Auto-dismiss with configurable duration
   - Manual dismiss with close button
   - Stack multiple toasts
   - Position options (top-right, bottom-right, etc.)
   - Toast provider/context for programmatic usage
   - Progress bar for auto-dismiss timer

5. Create theme provider:

### ThemeProvider component
   - Store theme preference in localStorage
   - Sync with system preference (`prefers-color-scheme`)
   - Apply `data-theme` attribute to document
   - Provide theme context (current theme + toggle function)

### Dark mode toggle component
   - Sun/moon icon toggle
   - Options: light, dark, system
   - Animated icon transition

6. Create an `index.ts` barrel file exporting all components and tokens.

7. Create a `README.md` inside the design system directory with:
   - Token reference table
   - Component usage examples
   - Theming instructions
   - How to customize tokens

8. Print a summary of created components and usage instructions.
