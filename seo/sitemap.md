# Sitemap Generator

Generate a dynamic XML sitemap for the project, detecting all routes and pages, with framework-specific implementation and robots.txt integration.

## Instructions

### Step 1: Detect Project Framework

Identify the project framework to determine the sitemap implementation strategy:
- **Next.js App Router**: Create `app/sitemap.ts` that exports a `sitemap()` function
- **Next.js Pages Router**: Create `pages/sitemap.xml.ts` with `getServerSideProps`
- **Nuxt**: Use `@nuxtjs/sitemap` module or create `server/routes/sitemap.xml.ts`
- **Astro**: Use `@astrojs/sitemap` integration or create `src/pages/sitemap.xml.ts`
- **Django**: Use `django.contrib.sitemaps` framework
- **Express/Node**: Create a `/sitemap.xml` route handler
- **Static site**: Generate a static `sitemap.xml` file
- **Other**: Adapt to the framework's routing mechanism

### Step 2: Discover All Routes and Pages

Scan the entire project to build a complete list of public-facing URLs:

**For file-based routing (Next.js, Nuxt, Astro):**
- Scan the pages/app directory for all page files
- Identify dynamic routes (e.g., `[slug]`, `[id]`) and determine their possible values from data sources
- Exclude API routes, error pages (404, 500), internal pages, and admin pages
- Exclude pages with `noindex` meta tags or that are behind authentication

**For code-based routing (Express, Django):**
- Scan route definitions and URL patterns
- Identify all public GET endpoints that serve HTML
- Exclude API endpoints, auth-protected routes, and admin routes

**For static sites:**
- Scan all HTML files in the output/public directory
- Follow internal links to discover all pages

Build a complete URL list with metadata.

### Step 3: Gather Metadata for Each URL

For each discovered URL, collect:

**lastmod (Last Modified Date):**
- Primary: Use git log to get the last commit date for each file: `git log -1 --format=%cI -- <file-path>`
- Fallback: Use file system modification time
- For dynamic pages: Use the most recent data update timestamp if available

**changefreq (Change Frequency):**
- Homepage: `daily`
- Blog index/listing pages: `daily`
- Individual blog posts: `monthly`
- Product pages: `weekly`
- Static pages (about, contact): `monthly`
- Legal pages (privacy, terms): `yearly`

**priority:**
- Homepage: `1.0`
- Main category/section pages: `0.8`
- Individual content pages: `0.6`
- Utility pages (contact, about): `0.4`
- Legal/policy pages: `0.2`

### Step 4: Implement the Sitemap

Implement the sitemap using the framework-specific approach detected in Step 1.

For all implementations, the generated XML must follow the sitemap protocol:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2024-01-15T10:30:00+00:00</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

**Next.js App Router**: Export an async `sitemap()` function from `app/sitemap.ts` returning `MetadataRoute.Sitemap`.

**Django**: Create a `sitemaps.py` with `Sitemap` subclasses and wire into `urls.py`.

**Express/Node**: Create a GET `/sitemap.xml` route that sets `Content-Type: application/xml`.

**Static**: Generate a complete `sitemap.xml` file with all discovered URLs.

### Step 5: Handle Large Sites (Sitemap Index)

If the project has more than 50,000 URLs or the sitemap would exceed 50MB, implement a sitemap index:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://example.com/sitemap-pages.xml</loc>
    <lastmod>2024-01-15T10:30:00+00:00</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-blog.xml</loc>
    <lastmod>2024-01-15T10:30:00+00:00</lastmod>
  </sitemap>
</sitemapindex>
```

Split sitemaps by content type (pages, blog posts, products, etc.) even for smaller sites if the project has distinct content categories. This makes it easier to monitor indexing per section in Google Search Console.

### Step 6: Update robots.txt

Check if `robots.txt` exists in the project root or public directory.

**If it exists:**
- Add or update the `Sitemap:` directive to point to the sitemap URL
- Verify existing directives don't block important pages
- Do not modify existing Allow/Disallow rules unless they block the sitemap itself

**If it doesn't exist, create one:**
```
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

Use the site's base URL from environment variables or project config. The `Sitemap` directive must use an absolute URL.

### Step 7: Handle Dynamic Routes

For dynamic routes (blog posts, products, etc.):
- Identify the data source (database, CMS, API, markdown files, etc.)
- Create a function to fetch all slugs/IDs for dynamic pages
- Generate URLs for each dynamic page with appropriate metadata
- Handle pagination if the data source has many items
- Ensure newly published content automatically appears in the sitemap

### Step 8: Add Caching (for dynamic sitemaps)

For server-rendered sitemaps, add caching to avoid regenerating on every request:
- Cache the sitemap XML for a reasonable duration (e.g., 1 hour for active sites, 24 hours for static sites)
- Use appropriate cache headers: `Cache-Control: public, max-age=3600, s-maxage=3600`
- Invalidate cache when content changes (if using a CMS webhook or similar)

### Step 9: Verify and Report

After implementation, verify:
- The sitemap is valid XML
- All discovered pages are included
- No private/auth-protected pages are included
- URLs are absolute with the correct domain
- lastmod dates are in ISO 8601 format (W3C Datetime)
- robots.txt references the sitemap with an absolute URL
- Dynamic routes are properly resolved

Report:
```
## Sitemap Implementation Summary

- Framework: [detected framework]
- Implementation: [file path]
- Total URLs: [count]
- Static pages: [count]
- Dynamic pages: [count]
- Sitemap index: [yes/no]
- robots.txt: [created/updated] at [path]

### URLs Included
| URL Pattern | Count | Priority | Change Frequency |
|-------------|-------|----------|-----------------|
| /           | 1     | 1.0      | daily           |
| /blog/*     | 25    | 0.6      | monthly         |
| ...         | ...   | ...      | ...             |

### Files Modified/Created
- [list of file paths]
```
