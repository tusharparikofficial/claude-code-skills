# Accessibility Audit

Perform a comprehensive accessibility audit against WCAG 2.1 guidelines and report findings with fixes.

## Arguments

$ARGUMENTS - Optional `<page-or-component>` file path or component name. If omitted, audits the entire project.

## Instructions

1. Determine the audit scope:
   - If a specific page or component is provided, focus on that file and its children.
   - If no argument is provided, scan the project for all template/component files (`.tsx`, `.jsx`, `.vue`, `.html`, `.svelte`).
   - Identify the framework in use (React, Vue, Svelte, plain HTML) to apply framework-specific checks.

2. Check **ARIA roles and labels** (WCAG 4.1.2):
   - Verify all interactive elements have accessible names:
     - Buttons have text content, `aria-label`, or `aria-labelledby`
     - Links have descriptive text (not "click here" or "read more" alone)
     - Icon-only buttons have `aria-label`
   - Check for correct ARIA role usage:
     - No redundant roles (e.g., `role="button"` on `<button>`)
     - Custom widgets have appropriate roles (`dialog`, `tablist`, `menu`, etc.)
     - `role="presentation"` or `role="none"` used correctly for decorative elements
   - Verify `aria-expanded`, `aria-selected`, `aria-checked` states are toggled correctly
   - Check for `aria-live` regions for dynamic content updates

3. Check **keyboard navigation** (WCAG 2.1.1, 2.1.2):
   - All interactive elements are focusable (in the tab order or via `tabindex="0"`)
   - No positive `tabindex` values (only `0` or `-1`)
   - Custom components handle keyboard events:
     - Buttons respond to Enter and Space
     - Dropdowns respond to Arrow keys, Escape
     - Modals trap focus and restore on close
     - Tabs respond to Arrow keys
   - No keyboard traps (user can always navigate away)
   - Skip links or skip navigation mechanism present

4. Check **focus management** (WCAG 2.4.7):
   - Focus indicator is visible on all interactive elements
   - Focus styles have sufficient contrast (3:1 minimum against background)
   - Focus moves logically after interactions:
     - Modal open: focus moves to modal
     - Modal close: focus returns to trigger element
     - Route change: focus moves to main content or page title
     - Deletion: focus moves to next logical element
   - `outline: none` is not used without a replacement focus style

5. Check **color contrast** (WCAG 1.4.3, 1.4.6):
   - Normal text: minimum 4.5:1 contrast ratio against background
   - Large text (18pt or 14pt bold): minimum 3:1 contrast ratio
   - UI components and graphical objects: minimum 3:1 contrast ratio
   - Focus indicators: minimum 3:1 contrast ratio
   - Check contrast in both light and dark modes if applicable
   - Flag any text on images or gradients where contrast may vary

6. Check **screen reader text** (WCAG 1.1.1, 1.3.1):
   - All images have `alt` attributes:
     - Decorative images: `alt=""` (empty string)
     - Informative images: descriptive alt text
     - No alt text that starts with "image of" or "picture of"
   - SVG icons have `aria-hidden="true"` if decorative, or `role="img"` with title if informative
   - Visually hidden text (`.sr-only` / `.visually-hidden`) used where visual context is needed
   - Content order in DOM matches visual order

7. Check **heading hierarchy** (WCAG 1.3.1, 2.4.6):
   - Single `<h1>` per page
   - Headings follow sequential order (no skipping levels: h1 -> h3)
   - Headings are descriptive and not empty
   - Headings are used for structure, not styling

8. Check **form labels** (WCAG 1.3.1, 3.3.2):
   - All form inputs have associated `<label>` elements (using `htmlFor`/`for`)
   - Or inputs have `aria-label` or `aria-labelledby`
   - Required fields are indicated (not by color alone)
   - Error messages are associated with inputs (`aria-describedby` or `aria-errormessage`)
   - Form validation errors are announced to screen readers
   - Placeholder text is not used as the only label

9. Check **alt text for media** (WCAG 1.1.1, 1.2.1):
   - All `<img>` elements have `alt` attributes
   - `<video>` elements have captions or transcripts
   - `<audio>` elements have transcripts
   - `<canvas>` elements have fallback content

10. Check **skip links** (WCAG 2.4.1):
    - Skip-to-main-content link present as first focusable element
    - Skip link is visible on focus
    - Target `id` exists on the main content area

11. Check **reduced motion** (WCAG 2.3.3):
    - `@media (prefers-reduced-motion: reduce)` is used to disable/reduce animations
    - Auto-playing animations can be paused
    - No content flashes more than 3 times per second

12. Generate an audit report with the following format:

```
## Accessibility Audit Report

### Summary
- Total issues found: X
- Critical (WCAG A): X
- Major (WCAG AA): X
- Minor (WCAG AAA): X
- WCAG conformance level: A / AA / AAA / None

### Critical Issues (Must Fix)
1. **[Rule]** Description
   - File: path/to/file.tsx:line
   - WCAG: criterion number
   - Fix: specific code change needed

### Major Issues (Should Fix)
...

### Minor Issues (Nice to Have)
...

### Passed Checks
- List of checks that passed
```

13. For each issue found, provide the specific fix:
   - Show the current code
   - Show the corrected code
   - Explain why the change is needed

14. If there are critical issues, offer to apply the fixes automatically.
