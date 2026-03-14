# Meta Tags

Generate and implement complete meta tags for pages in the project, including title, description, canonical, Open Graph, Twitter Cards, and JSON-LD structured data.

## Arguments

$ARGUMENTS - Optional `<page-path>` to target a specific page. If omitted, generate meta tags for all pages discovered in the project.

## Instructions

### Step 1: Detect Project Framework

Examine the codebase to determine the framework and the correct meta tag implementation pattern:
- **Next.js App Router**: Use `generateMetadata` function exported from `page.tsx` or `layout.tsx`
- **Next.js Pages Router**: Use `next/head` component with `<Head>`
- **React (CRA/Vite)**: Use `react-helmet-async` or `react-helmet`
- **Vue/Nuxt**: Use `useHead()` composable or `vue-meta`
- **Astro**: Use `<head>` in layout with Astro.props
- **Svelte/SvelteKit**: Use `<svelte:head>`
- **Django**: Use template blocks in base template
- **Static HTML**: Edit `<head>` directly
- **Other**: Adapt to whatever pattern the project uses

Check if the project already has a meta tag utility, SEO component, or shared head configuration. Reuse existing patterns rather than introducing new ones.

### Step 2: Determine Target Pages

If a `<page-path>` argument was provided:
- Locate that specific page file
- If the path doesn't exist, report the error and list available pages

If no argument was provided:
- Discover all pages/routes in the project (same discovery as the SEO audit)
- List them and proceed with all pages

### Step 3: Analyze Page Content

For each target page, read the page content to understand:
- What the page is about (to write accurate titles and descriptions)
- The page type (homepage, article, product, about, contact, listing, etc.)
- Any existing meta tags (to preserve or improve them)
- Dynamic data that should be included in meta tags

### Step 4: Generate Meta Tags

For each page, generate the following:

**Title Tag:**
- Under 60 characters
- Include primary keyword near the beginning
- Include brand name at the end separated by ` | ` or ` - `
- Unique per page
- Format: `Primary Keyword - Secondary Context | Brand`

**Meta Description:**
- Under 155 characters
- Include a call to action or value proposition
- Include primary keyword naturally
- Unique per page

**Canonical URL:**
- Absolute URL using the site's domain
- Self-referencing canonical for each page
- Use a base URL from environment variables or site config

**Open Graph Tags:**
- `og:title` - Can be slightly different from title tag, optimized for social
- `og:description` - Can be slightly different from meta description, optimized for engagement
- `og:image` - Absolute URL to a 1200x630 image (use a default if page-specific doesn't exist)
- `og:url` - Canonical URL of the page
- `og:type` - `website` for homepage, `article` for blog posts, appropriate type per page
- `og:site_name` - Project/brand name
- `og:locale` - e.g., `en_US`

**Twitter Card Tags:**
- `twitter:card` - `summary_large_image` (preferred) or `summary`
- `twitter:title` - Same as og:title or customized
- `twitter:description` - Same as og:description or customized
- `twitter:image` - Same as og:image
- `twitter:site` - Twitter handle if available in project config

**JSON-LD Structured Data:**
- Homepage: `Organization` or `WebSite` with `SearchAction`
- Blog post: `Article` with `headline`, `author`, `datePublished`, `image`
- Product page: `Product` with `name`, `description`, `price`, `availability`
- FAQ page: `FAQPage` with question/answer pairs
- About page: `Organization` or `Person`
- Contact page: `ContactPoint`
- Other: Choose the most appropriate Schema.org type

### Step 5: Implement in Code

Implement the meta tags using the framework-specific pattern detected in Step 1.

**For Next.js App Router:**
```typescript
export async function generateMetadata({ params }): Promise<Metadata> {
  return {
    title: '...',
    description: '...',
    alternates: { canonical: '...' },
    openGraph: { title: '...', description: '...', images: ['...'], url: '...', type: '...', siteName: '...' },
    twitter: { card: 'summary_large_image', title: '...', description: '...', images: ['...'] },
  };
}
```

**For React Helmet:**
```jsx
<Helmet>
  <title>...</title>
  <meta name="description" content="..." />
  <link rel="canonical" href="..." />
  <meta property="og:title" content="..." />
  ...
</Helmet>
```

**For static HTML**, edit the `<head>` section directly.

For JSON-LD, add a `<script type="application/ld+json">` tag with the structured data object. In React frameworks, this is typically rendered as a component.

### Step 6: Create Shared SEO Utility (if not existing)

If the project doesn't already have one, create a shared SEO utility/component:
- A reusable function or component that accepts title, description, image, url, and type
- Default values for site name, locale, default OG image, Twitter handle
- Reads base URL from environment variable (e.g., `NEXT_PUBLIC_SITE_URL`, `VITE_SITE_URL`)
- Constructs absolute URLs for canonical, OG image, etc.

Place this utility in a logical location for the project structure (e.g., `src/lib/seo.ts`, `src/components/SEO.tsx`, `utils/meta.py`).

### Step 7: Verify Implementation

After implementing, verify:
- No duplicate meta tags on any page
- All URLs are absolute (not relative)
- Title and description are within character limits
- JSON-LD is valid JSON
- OG image URLs are accessible
- Canonical URLs match the actual page URLs

Report what was implemented per page in a summary table:

```
| Page | Title | Description | Canonical | OG | Twitter | JSON-LD |
|------|-------|-------------|-----------|-----|---------|---------|
| /    | ...   | ...         | Yes       | Yes | Yes     | WebSite |
| /about | ... | ...        | Yes       | Yes | Yes     | Org     |
```
