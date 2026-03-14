# SEO Audit

Perform a comprehensive technical SEO audit of the current codebase, scoring issues by severity and providing a prioritized fix list.

## Instructions

### Step 1: Identify Project Framework

Detect the project type by examining package.json, config files, and directory structure. Determine if this is Next.js, Nuxt, Gatsby, Astro, Django, Rails, Express, static HTML, or another framework. This determines where to look for pages, routes, and templates.

### Step 2: Discover All Pages and Routes

Find every page/route in the project:
- Next.js: scan `app/` and `pages/` directories for page.tsx, page.js, route files
- Nuxt: scan `pages/` directory
- Astro: scan `src/pages/`
- Django: scan urls.py files and templates
- Express: scan route definitions
- Static: scan all .html files
- Other frameworks: adapt accordingly

Build a complete list of all public-facing URLs/pages.

### Step 3: Audit Meta Tags

For every page discovered, check for:
- `<title>` tag presence and length (should be 30-60 characters)
- `<meta name="description">` presence and length (should be 120-155 characters)
- `<meta name="viewport">` for mobile responsiveness
- `<link rel="canonical">` for canonical URLs
- Duplicate titles or descriptions across pages
- Missing or empty meta tags

Record each issue with its file path and line number.

### Step 4: Audit Open Graph and Twitter Cards

For every page, check for:
- `og:title`, `og:description`, `og:image`, `og:url`, `og:type`
- `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
- Image dimensions (og:image should be 1200x630)
- Missing or incomplete social meta tags

### Step 5: Audit Structured Data (JSON-LD)

Search for JSON-LD script tags across the codebase:
- Check if any structured data exists
- Validate Schema.org types used
- Check for required properties per type (e.g., Article needs headline, author, datePublished)
- Flag pages that should have structured data but don't (articles, products, FAQ pages, organization/homepage)

### Step 6: Audit Sitemap and Robots.txt

Check the project root and public directory for:
- `sitemap.xml` or dynamic sitemap generation (e.g., `app/sitemap.ts` in Next.js)
- All pages included in sitemap
- Proper `lastmod`, `changefreq`, `priority` values
- `robots.txt` exists with proper directives
- Sitemap referenced in robots.txt
- No important pages blocked by robots.txt

### Step 7: Audit Heading Hierarchy

For every page/component, analyze heading usage:
- Exactly one `<h1>` per page
- Headings follow sequential order (no skipping from h1 to h3)
- No empty headings
- Headings contain meaningful text (not just styling)
- Multiple h1 tags on a single page

### Step 8: Audit Image Alt Text

Find all `<img>` tags and image components:
- Missing `alt` attribute
- Empty `alt=""` on non-decorative images
- Alt text that is too long (>125 characters)
- Missing `width` and `height` attributes (causes layout shift / CLS)
- Missing lazy loading (`loading="lazy"`) for below-fold images
- Images without next/image or optimized image components (framework-specific)

### Step 9: Audit Internal and Broken Links

Scan all anchor tags and Link components:
- Links pointing to non-existent internal routes
- Links missing `href` attribute
- Links with `href="#"` or `href="javascript:void(0)"`
- External links missing `rel="noopener noreferrer"`
- Links missing descriptive text (e.g., "click here")

### Step 10: Audit Core Web Vitals Code Issues

Look for code patterns that harm Core Web Vitals:
- **LCP (Largest Contentful Paint)**: Unoptimized hero images, render-blocking scripts/CSS, missing preload for critical resources, large bundle sizes
- **CLS (Cumulative Layout Shift)**: Images without dimensions, dynamically injected content above the fold, fonts causing layout shift (missing `font-display: swap`)
- **INP (Interaction to Next Paint)**: Long-running synchronous JavaScript, heavy event handlers, missing debounce/throttle on input handlers, large component re-renders

### Step 11: Audit Mobile Responsiveness

Check for:
- Viewport meta tag present and correct (`width=device-width, initial-scale=1`)
- No fixed-width elements that could cause horizontal scroll
- Touch target sizes (buttons/links should be at least 44x44px in CSS)
- Font sizes readable on mobile (minimum 16px for body text)

### Step 12: Calculate Score and Generate Report

Assign severity to each issue found:
- **CRITICAL** (10 points each): Missing title tags, no sitemap, no robots.txt, no viewport meta, broken internal links, no h1 on page
- **HIGH** (5 points each): Missing meta descriptions, no canonical URLs, missing OG tags, no structured data, multiple h1s, images without alt text
- **MEDIUM** (3 points each): Title/description length issues, missing Twitter cards, heading hierarchy violations, missing image dimensions, no lazy loading
- **LOW** (1 point each): Alt text too long, missing font-display, external links without noopener, minor CWV code patterns

Calculate the score: Start at 100, subtract points for each issue (minimum 0).

Present the report in this format:

```
# SEO Audit Report

## Overall Score: XX/100

## Summary
- Critical Issues: X
- High Issues: X
- Medium Issues: X
- Low Issues: X

## Critical Issues
1. [File:Line] Description of issue
   Fix: How to fix it

## High Issues
...

## Medium Issues
...

## Low Issues
...

## Prioritized Fix List
1. Fix description (Impact: Critical/High/Medium/Low, Effort: Low/Medium/High)
2. ...

## What's Working Well
- List things the project already does correctly
```

Order the prioritized fix list by impact (highest first), then by effort (lowest effort first within same impact level).
