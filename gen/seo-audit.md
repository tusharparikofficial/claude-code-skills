# SEO Audit

Perform a comprehensive technical SEO audit of the codebase, identifying issues across meta tags, structured data, sitemaps, headings, images, links, performance, mobile readiness, and Core Web Vitals.

## Arguments

$ARGUMENTS - Optional: `<directory>` path to audit (defaults to project root)

## Instructions

You are performing a thorough technical SEO audit. Follow each step carefully and produce a structured report at the end.

### Step 0: Determine Scope

- If `$ARGUMENTS` is provided, use it as the root directory to scan. Otherwise, use the current project root.
- Detect the project framework (Next.js, React, Vue, Nuxt, Astro, SvelteKit, static HTML, Django, Rails, etc.) as this affects where and how SEO elements are implemented.
- Identify the file extensions to scan: `.html`, `.htm`, `.jsx`, `.tsx`, `.vue`, `.svelte`, `.astro`, `.php`, `.erb`, `.blade.php`, `.njk`, `.ejs`, `.pug`, `.hbs`, `.md`, `.mdx`, etc.

### Step 1: Meta Tags Audit

For every page/route/layout file, check for:

1. **Title tag**: Must exist, be unique per page, 30-60 characters, contain primary keyword
2. **Meta description**: Must exist, be unique per page, 120-155 characters, contain call-to-action or keyword
3. **Canonical URL**: Must exist on every page, must be absolute URL
4. **Open Graph tags**: `og:title`, `og:description`, `og:image`, `og:type`, `og:url` -- all must be present
5. **Twitter Card tags**: `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
6. **Viewport meta**: `<meta name="viewport" content="width=device-width, initial-scale=1">`
7. **Charset**: `<meta charset="utf-8">` or equivalent
8. **Language**: `lang` attribute on `<html>` tag
9. **Favicon**: Check for favicon link tags

Record each missing or malformed tag with file path, line number, and severity.

### Step 2: Structured Data Audit

Search for JSON-LD (`<script type="application/ld+json">`), Microdata (`itemscope`, `itemtype`), or RDFa (`typeof`, `property`) markup.

- Check if structured data exists on any page
- Validate that `@context` is `https://schema.org`
- Check for Organization, WebSite, BreadcrumbList on homepage/layout
- Check for Article/BlogPosting on blog posts
- Check for Product on product pages
- Check for FAQ on FAQ pages
- Flag pages that would benefit from structured data but lack it

### Step 3: Sitemap Audit

- Search for `sitemap.xml`, `sitemap.ts`, `sitemap.js`, sitemap generation config
- Check if sitemap includes all public routes
- Check for `lastmod`, `changefreq`, `priority` attributes
- Check for sitemap index if site is large
- Check if sitemap is referenced in `robots.txt`

### Step 4: Robots.txt Audit

- Search for `robots.txt` or its generation mechanism
- Check for `User-agent`, `Allow`, `Disallow` directives
- Check for `Sitemap` directive
- Flag if important pages are accidentally blocked
- Flag if `robots.txt` is missing entirely

### Step 5: Heading Hierarchy Audit

For each page:

- Check that exactly ONE `<h1>` exists per page
- Check that heading levels do not skip (e.g., h1 -> h3 with no h2)
- Check that headings contain meaningful text (not empty, not just icons)
- Flag duplicate H1 tags across pages if they should be unique

### Step 6: Image Audit

Search for all `<img>`, `<Image>`, `<picture>`, and CSS background images:

- **Alt text**: Every `<img>` must have an `alt` attribute (empty `alt=""` is acceptable for decorative images)
- **Lazy loading**: Images below the fold should have `loading="lazy"` or use framework lazy loading
- **Size attributes**: `width` and `height` should be specified to prevent CLS
- **Modern formats**: Check for WebP/AVIF usage or `<picture>` with format fallbacks
- **Large images**: Flag images imported/referenced that may be unoptimized (check for optimization pipeline)
- **Next/Image or equivalent**: Check if framework image optimization component is used

### Step 7: Internal Links Audit

- Search for all `<a href>` and framework link components (`<Link>`, `<NuxtLink>`, `<router-link>`)
- Flag links to `#` or `javascript:void(0)` (bad for SEO)
- Flag links without meaningful anchor text
- Check for orphan pages (pages with no internal links pointing to them)
- Check that all internal links use relative paths or proper base URLs
- Flag any hardcoded localhost or development URLs

### Step 8: Performance Audit (Code-Level)

- **Render-blocking resources**: Check for synchronous `<script>` tags in `<head>` without `async` or `defer`
- **CSS delivery**: Check for large inline styles or unoptimized CSS loading
- **Font loading**: Check for `font-display: swap` or font optimization
- **Bundle size**: Check for obvious large imports (moment.js, lodash full import, etc.)
- **Code splitting**: Check if dynamic imports / lazy loading is used for routes
- **Image optimization**: Check for next/image, sharp, or image optimization pipeline

### Step 9: Mobile Readiness Audit

- Check for viewport meta tag
- Search for responsive CSS patterns (media queries, flexbox, grid)
- Check for `touch-action` and mobile interaction patterns
- Flag fixed-width layouts or hardcoded pixel widths that would break on mobile
- Check for tap target sizes (buttons/links too small)

### Step 10: Core Web Vitals (Code-Level)

- **CLS (Cumulative Layout Shift)**: Flag images without dimensions, dynamic content insertion without reserved space, font loading without `font-display`
- **LCP (Largest Contentful Paint)**: Check that hero images are preloaded, check for render-blocking resources, check server-side rendering
- **INP (Interaction to Next Paint)**: Check for heavy event handlers, long-running synchronous JavaScript, check for `useTransition` or equivalent
- **TTFB**: Check for SSR/SSG configuration, caching headers

### Step 11: Generate Report

Compile all findings into a structured report:

```
# SEO Audit Report

## Overall Score: XX/100

Scoring breakdown:
- Meta Tags: XX/15
- Structured Data: XX/10
- Sitemap & Robots: XX/10
- Heading Hierarchy: XX/10
- Images: XX/15
- Internal Links: XX/10
- Performance: XX/10
- Mobile: XX/10
- Core Web Vitals: XX/10

## Issues Found

### CRITICAL (Must Fix)
| # | Issue | File:Line | Description | Fix |
|---|-------|-----------|-------------|-----|

### HIGH (Should Fix)
| # | Issue | File:Line | Description | Fix |
|---|-------|-----------|-------------|-----|

### MEDIUM (Nice to Fix)
| # | Issue | File:Line | Description | Fix |
|---|-------|-----------|-------------|-----|

### LOW (Minor)
| # | Issue | File:Line | Description | Fix |
|---|-------|-----------|-------------|-----|

## Prioritized Fix List
1. [CRITICAL] ...
2. [CRITICAL] ...
3. [HIGH] ...
...

## Recommendations
- Actionable next steps organized by impact
```

### Scoring Guide

Deduct points per category based on issues found:
- CRITICAL issue: -5 points from category
- HIGH issue: -3 points from category
- MEDIUM issue: -1 point from category
- LOW issue: -0.5 points from category
- Minimum score per category is 0

### Important Notes

- Do NOT modify any files during the audit -- this is read-only analysis
- Be specific with file paths and line numbers
- Provide concrete, actionable fixes for every issue
- Consider the framework when suggesting fixes (e.g., Next.js Metadata API vs raw meta tags)
- If the project has no pages or routes (e.g., a library), note that and exit early
