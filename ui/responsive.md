# Implement Responsive Design

Analyze a page or component and implement comprehensive responsive design with mobile-first breakpoints.

## Arguments

$ARGUMENTS - `<page-or-component>` the file path or component name to make responsive

## Instructions

1. Read and analyze the specified page or component:
   - Identify the current layout structure (grid, flexbox, absolute positioning)
   - Identify all child elements and their sizing
   - Check existing media queries or responsive patterns
   - Note any images, tables, or complex elements that need special handling

2. Implement mobile-first responsive breakpoints:
   - Start with mobile styles as the base (no media query)
   - `@media (min-width: 640px)` - Small screens (landscape phones, small tablets)
   - `@media (min-width: 768px)` - Medium screens (tablets)
   - `@media (min-width: 1024px)` - Large screens (laptops)
   - `@media (min-width: 1280px)` - Extra large screens (desktops)
   - Use `em` units for media queries if the project convention allows it

3. Implement responsive grid/layout:
   - Convert fixed-width layouts to fluid layouts using `%`, `vw`, `fr`, or `clamp()`
   - Use CSS Grid for 2D layouts with responsive `grid-template-columns`:
     - Mobile: single column
     - Tablet: 2 columns
     - Desktop: 3-4 columns (as appropriate)
   - Use `repeat(auto-fit, minmax(min, 1fr))` for auto-responsive grids where applicable
   - Set `max-width` on content containers with `margin: 0 auto` for centering
   - Use container queries (`@container`) where the component's layout should respond to its own container size rather than the viewport

4. Implement collapsible navigation:
   - If the page has a navigation bar:
     - Desktop: Horizontal nav with visible links
     - Mobile: Hamburger menu icon that toggles a slide-out or dropdown menu
     - Add proper ARIA attributes (`aria-expanded`, `aria-controls`, `aria-label`)
     - Ensure keyboard accessibility (Enter/Space to toggle, Escape to close)
     - Prevent body scroll when mobile menu is open

5. Optimize touch targets:
   - Ensure all interactive elements (buttons, links, form controls) have a minimum touch target of 44x44px on mobile
   - Add appropriate padding to small interactive elements
   - Increase spacing between adjacent touch targets to prevent mis-taps

6. Implement responsive typography (font scaling):
   - Use `clamp()` for fluid typography: `font-size: clamp(1rem, 2.5vw, 1.5rem)`
   - Scale heading sizes down for mobile
   - Ensure body text is at least 16px on mobile (prevents iOS zoom on input focus)
   - Adjust line-height for readability at different sizes

7. Implement responsive images:
   - Add `srcset` and `sizes` attributes for resolution switching:
     ```html
     <img srcset="image-400.jpg 400w, image-800.jpg 800w, image-1200.jpg 1200w"
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          src="image-800.jpg" alt="...">
     ```
   - Use `<picture>` element for art direction (different crops at different sizes)
   - Set `max-width: 100%; height: auto;` on images
   - Consider `loading="lazy"` for below-the-fold images
   - Use `aspect-ratio` to prevent layout shift

8. Handle responsive tables:
   - For data tables on mobile, implement one of:
     - Horizontal scroll with `-webkit-overflow-scrolling: touch`
     - Card-based layout (each row becomes a card with label-value pairs)
     - Hide less important columns on mobile with `display: none`
   - Add a visual indicator for horizontal scroll (fade/shadow on edges)

9. Apply container queries where appropriate:
   - Use `container-type: inline-size` on parent containers
   - Use `@container` queries for components that should adapt to their container width
   - Especially useful for reusable card, widget, and sidebar components

10. Add reduced motion support:
    - Wrap animations and transitions in `@media (prefers-reduced-motion: no-preference)`
    - Provide static alternatives for users who prefer reduced motion

11. Test the implementation:
    - Verify layout at all breakpoints (320px, 640px, 768px, 1024px, 1280px)
    - Check for horizontal overflow at each breakpoint
    - Verify touch targets meet minimum size
    - Verify text is readable without zooming on mobile

12. Print a summary of all responsive changes made, breakpoints used, and any manual testing recommendations.
