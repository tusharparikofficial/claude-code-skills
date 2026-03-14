# SEO Meta Tags Generator

Generate and implement comprehensive meta tags (title, description, OG, Twitter Card, JSON-LD) for all pages in the project, tailored to the detected framework.

## Arguments

$ARGUMENTS - Optional: `<page-path>` specific page or route file to target (defaults to all pages)

## Instructions

You are generating and implementing SEO meta tags for a web project. Follow each step precisely.

### Step 1: Detect Framework and Project Structure

Scan the project to determine:

1. **Framework**: Next.js (App Router or Pages Router), React (CRA/Vite), Vue/Nuxt, Astro, SvelteKit, Remix, Gatsby, static HTML, Django, Rails, etc.
2. **Routing pattern**: File-based routing, config-based, or static files
3. **Existing meta implementation**: Check if there is already a meta tag strategy in place (e.g., `generateMetadata`, `react-helmet`, `useHead`, `<Head>` component)
4. **Site metadata**: Look for site name, base URL, default OG image in config files (`.env`, `next.config`, `nuxt.config`, `site.config`, etc.)

If `$ARGUMENTS` is provided, scope work to that specific page/route. Otherwise, process all pages.

### Step 2: Inventory All Pages

Build a list of all pages/routes in the project:

- Next.js App Router: `app/**/page.tsx`
- Next.js Pages Router: `pages/**/*.tsx`
- Vue/Nuxt: `pages/**/*.vue`
- Astro: `src/pages/**/*.astro`
- SvelteKit: `src/routes/**/+page.svelte`
- Static: `**/*.html`
- Django: URL patterns in `urls.py` mapped to templates
- Other: adapt to the framework detected

For each page, determine:
- Page type: homepage, about, blog listing, blog post, product, FAQ, contact, pricing, legal, etc.
- Primary keyword/topic (inferred from file name, route, content, headings)
- Whether it already has meta tags

### Step 3: Generate Meta Tags Per Page

For EACH page, generate the following:

#### Title Tag
- Format: `{Primary Keyword} | {Site Name}` or `{Page-Specific Title} - {Site Name}`
- Keep under 60 characters
- Front-load the most important keyword
- Make each title unique across the site

#### Meta Description
- 120-155 characters
- Include primary keyword naturally
- Include a call-to-action or value proposition
- Make compelling for click-through from search results
- Unique per page

#### Canonical URL
- Absolute URL: `https://example.com/path`
- Use the project's configured base URL or a placeholder `SITE_URL` env variable
- Ensure trailing slash consistency

#### Open Graph Tags
```html
<meta property="og:title" content="{Title, can differ from title tag}" />
<meta property="og:description" content="{Description, can differ from meta desc}" />
<meta property="og:image" content="{Absolute URL to OG image, min 1200x630}" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:type" content="{website|article|product}" />
<meta property="og:url" content="{Canonical URL}" />
<meta property="og:site_name" content="{Site Name}" />
<meta property="og:locale" content="en_US" />
```

#### Twitter Card Tags
```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="{Title}" />
<meta name="twitter:description" content="{Description}" />
<meta name="twitter:image" content="{Image URL}" />
<meta name="twitter:site" content="@{twitter_handle}" />
<meta name="twitter:creator" content="@{twitter_handle}" />
```

#### Additional Tags (where applicable)
```html
<meta name="robots" content="index, follow" />
<link rel="alternate" hreflang="en" href="{URL}" />
```

### Step 4: Generate JSON-LD Structured Data Per Page

Based on page type, generate appropriate JSON-LD:

- **Homepage**: Organization + WebSite (with SearchAction if search exists)
- **Blog Post**: Article or BlogPosting
- **Product Page**: Product with Offer
- **FAQ Page**: FAQPage
- **About Page**: Organization or Person
- **Contact Page**: Organization with ContactPoint
- **Pricing Page**: Product or Service with Offer

Example for homepage:
```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "{Site Name}",
  "url": "{Site URL}",
  "description": "{Site Description}",
  "publisher": {
    "@type": "Organization",
    "name": "{Org Name}",
    "logo": {
      "@type": "ImageObject",
      "url": "{Logo URL}"
    }
  }
}
```

### Step 5: Implement in Framework

#### Next.js (App Router)
```typescript
// In each page.tsx or layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: '...',
  description: '...',
  alternates: { canonical: '...' },
  openGraph: { title: '...', description: '...', images: ['...'], type: '...', url: '...' },
  twitter: { card: 'summary_large_image', title: '...', description: '...', images: ['...'] },
};

// For dynamic pages, use generateMetadata:
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  // fetch data and return metadata
}
```

Also create or update `app/layout.tsx` with default metadata and JSON-LD in the `<head>`.

#### Next.js (Pages Router)
Use `next/head` with `<Head>` component in each page.

#### React (CRA/Vite)
Install and use `react-helmet-async`:
- Wrap app in `<HelmetProvider>`
- Use `<Helmet>` in each route component

#### Vue/Nuxt
Use `useHead()` composable or `definePageMeta()`.

#### Astro
Use `<head>` in layout with Astro props for dynamic values.

#### SvelteKit
Use `<svelte:head>` in each `+page.svelte`.

#### Static HTML
Add meta tags directly to `<head>` of each HTML file.

### Step 6: Create Shared Meta Utilities

Create a reusable utility/helper for generating meta tags:

1. **Site config**: Central file with site name, base URL, default OG image, social handles
2. **Meta builder function**: Takes page-specific data and returns complete meta object
3. **JSON-LD builder**: Functions for each schema type that return valid JSON-LD objects

Example utility structure:
```
lib/
  seo/
    config.ts       # Site-wide SEO config
    metadata.ts     # Meta tag builder
    structured-data.ts  # JSON-LD builders
```

### Step 7: OG Image Strategy

If the project lacks OG images:

1. **Static approach**: Create a default OG image template and note where to place it
2. **Dynamic approach** (Next.js): Create `app/api/og/route.tsx` using `@vercel/og` or `next/og` for dynamic OG image generation
3. Document the OG image dimensions: 1200x630px minimum

### Step 8: Verification Checklist

After implementation, output a checklist:

- [ ] Every page has a unique title tag under 60 characters
- [ ] Every page has a unique meta description under 155 characters
- [ ] Every page has a canonical URL
- [ ] Every page has Open Graph tags (title, description, image, type, url)
- [ ] Every page has Twitter Card tags
- [ ] Homepage has Organization + WebSite JSON-LD
- [ ] Blog posts have Article JSON-LD
- [ ] Product pages have Product JSON-LD (if applicable)
- [ ] Default OG image exists or dynamic OG generation is configured
- [ ] Site config is centralized and reusable
- [ ] No duplicate titles or descriptions across pages

### Important Notes

- Never use placeholder text like "Lorem ipsum" in meta content -- always generate realistic, SEO-optimized copy based on the page content
- If page content is unclear, use file/route names and headings to infer purpose
- Use env variables for base URL (e.g., `NEXT_PUBLIC_SITE_URL`) rather than hardcoding
- Preserve any existing valid meta tags; only add missing ones or improve poor ones
- Follow the project's existing code style (semicolons, quotes, imports)
