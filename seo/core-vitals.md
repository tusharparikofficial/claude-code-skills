# Core Web Vitals Fix

Analyze and fix Core Web Vitals issues: CLS, LCP, and INP.

## Instructions

1. **Scan the codebase for CLS (Cumulative Layout Shift) issues**
   - Find images and videos without explicit `width` and `height` attributes
   - Find dynamically injected content above the fold (ads, banners, notifications)
   - Find web fonts causing FOIT/FOUT (flash of invisible/unstyled text)
   - Find CSS that causes layout recalculation (animations on layout properties)
   - Find elements without reserved space (skeleton screens, placeholders)
   - Check for `transform` animations instead of `top`/`left`/`width`/`height`
   - **Fix**: Add dimensions to media, use `font-display: swap`, add placeholders, use CSS `contain`, use `aspect-ratio`

2. **Scan the codebase for LCP (Largest Contentful Paint) issues**
   - Find hero images not using `priority`/`fetchpriority="high"`/`loading="eager"`
   - Find large unoptimized images (no responsive srcset, no modern formats like WebP/AVIF)
   - Find render-blocking CSS and JavaScript in `<head>`
   - Find third-party scripts loaded synchronously
   - Find server response time issues (missing caching headers, no CDN hints)
   - Find LCP element candidates (largest image/text block in viewport)
   - **Fix**: Add `priority` to hero images, optimize images (next/image, sharp, srcset), async/defer scripts, preload critical resources, add `<link rel="preconnect">` for third-party origins

3. **Scan the codebase for INP (Interaction to Next Paint) issues**
   - Find long-running JavaScript on the main thread (heavy computations, large loops)
   - Find synchronous operations that block interaction (localStorage, large JSON parse)
   - Find event handlers without debouncing/throttling
   - Find missing `will-change` or `content-visibility` optimizations
   - Find hydration bottlenecks in SSR frameworks
   - Find large component re-renders triggered by interactions
   - **Fix**: Move heavy work to Web Workers, use `requestIdleCallback`, debounce handlers, virtualize long lists, use `startTransition` in React, lazy load non-critical components

4. **Check resource loading optimization**
   - Verify critical CSS is inlined or preloaded
   - Check for unused CSS and JavaScript (code splitting)
   - Verify images use modern formats and responsive sizes
   - Check for proper caching headers (Cache-Control, ETag)
   - Verify `<link rel="preload">` for critical resources
   - Check bundle sizes and recommend code splitting where needed
   - Verify tree shaking is effective

5. **Check third-party script impact**
   - Identify all third-party scripts (analytics, ads, widgets, chat)
   - Check if they use `async` or `defer`
   - Recommend `loading="lazy"` for below-fold iframes
   - Suggest facade pattern for heavy widgets (YouTube, maps, chat)
   - Check for Partytown or worker-based loading

6. **Generate a fix report**
   - List all issues found, grouped by vital (CLS, LCP, INP)
   - Severity: CRITICAL (failing threshold), WARNING (close to threshold), INFO (optimization)
   - CWV thresholds: LCP < 2.5s (good), CLS < 0.1 (good), INP < 200ms (good)
   - For each issue: file path, line number, problem description, fix applied or recommended
   - Estimated impact of each fix

7. **Apply automated fixes**
   - Apply all safe, non-breaking fixes automatically
   - For fixes requiring architectural changes, provide detailed instructions
   - Add performance monitoring snippet if not already present (web-vitals library)
   - Verify fixes don't introduce regressions
