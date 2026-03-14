# SEO Sitemap Generator

Generate a dynamic sitemap.xml with all public routes, proper metadata, and framework-specific implementation. Also configures robots.txt.

## Arguments

$ARGUMENTS - No required arguments. Optional: `<base-url>` to use as the site's base URL.

## Instructions

You are generating a comprehensive sitemap.xml for the project. Follow each step precisely.

### Step 1: Detect Project Framework and Configuration

1. **Framework detection**: Next.js, Nuxt, Astro, SvelteKit, Remix, Gatsby, Django, Rails, Express, static HTML, etc.
2. **Base URL**: Check for base URL in:
   - `$ARGUMENTS` (if provided)
   - Environment variables: `SITE_URL`, `NEXT_PUBLIC_SITE_URL`, `BASE_URL`, `VITE_BASE_URL`
   - Config files: `next.config.js`, `nuxt.config.ts`, `astro.config.mjs`, etc.
   - If none found, use placeholder `https://example.com` and add a TODO comment
3. **Existing sitemap**: Check if a sitemap already exists and what approach is used
4. **Route discovery method**: File-based routing vs config-based vs dynamic

### Step 2: Discover All Routes

Scan the project to find all public routes:

#### File-Based Routing (Next.js, Nuxt, Astro, SvelteKit)
- Scan page directories for route files
- Parse dynamic route segments: `[id]`, `[slug]`, `[...catchAll]`
- Exclude:
  - API routes (`/api/*`)
  - Internal routes (starting with `_`)
  - Error pages (404, 500, error, not-found)
  - Auth pages (login, register, forgot-password) unless they should be indexed
  - Admin/dashboard pages
  - Files with `noindex` or robots configuration

#### Config-Based Routing (React Router, Vue Router, Express)
- Parse router configuration files
- Extract all route paths
- Identify which are public vs protected

#### Static Sites
- Find all `.html` files
- Map file paths to URLs

#### Django
- Parse `urls.py` files for all URL patterns
- Identify public views vs authenticated views

For dynamic routes (e.g., `/blog/[slug]`), document that these need data source integration and provide the pattern.

### Step 3: Determine Metadata for Each Route

For each discovered route, determine:

#### lastmod (Last Modified)
Priority order:
1. Git last commit date for the file: `git log -1 --format="%Y-%m-%dT%H:%M:%S+00:00" -- <file>`
2. File system modification date
3. Current date as fallback

#### changefreq (Change Frequency)
Based on content type:
| Route Pattern | changefreq |
|---------------|------------|
| Homepage `/` | daily |
| Blog index `/blog` | daily |
| Blog posts `/blog/*` | monthly |
| Product pages | weekly |
| Documentation | weekly |
| Legal pages (privacy, terms) | yearly |
| About, contact | monthly |
| Pricing | weekly |
| Changelog | weekly |

#### priority
Based on page depth and importance:
| Route Pattern | priority |
|---------------|----------|
| Homepage `/` | 1.0 |
| Main sections (`/blog`, `/products`, `/pricing`) | 0.8 |
| Sub-pages (`/blog/post`, `/products/item`) | 0.6 |
| Utility pages (`/about`, `/contact`) | 0.5 |
| Legal pages (`/privacy`, `/terms`) | 0.3 |
| Deep nested pages | 0.4 |

### Step 4: Generate Sitemap Implementation

#### Next.js (App Router) -- PREFERRED

Create `app/sitemap.ts`:

```typescript
import type { MetadataRoute } from 'next';

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://example.com';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  // Static routes
  const staticRoutes: MetadataRoute.Sitemap = [
    {
      url: BASE_URL,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1.0,
    },
    {
      url: `${BASE_URL}/about`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.5,
    },
    // ... all other static routes
  ];

  // Dynamic routes (e.g., blog posts from CMS/database)
  // const posts = await fetchAllPosts();
  // const postRoutes = posts.map((post) => ({
  //   url: `${BASE_URL}/blog/${post.slug}`,
  //   lastModified: new Date(post.updatedAt),
  //   changeFrequency: 'monthly' as const,
  //   priority: 0.6,
  // }));

  return [...staticRoutes /*, ...postRoutes */];
}
```

For large sites (>50K URLs), create `app/sitemap/[id]/route.ts` with sitemap index.

#### Next.js (Pages Router)

Create `pages/sitemap.xml.ts` with `getServerSideProps` that returns XML.

#### Nuxt

Create `server/routes/sitemap.xml.ts` or use `@nuxtjs/sitemap` module.

#### Astro

Create `src/pages/sitemap.xml.ts`:

```typescript
import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';

export const GET: APIRoute = async () => {
  // Generate sitemap XML
};
```

Or use `@astrojs/sitemap` integration.

#### SvelteKit

Create `src/routes/sitemap.xml/+server.ts`.

#### Django

Configure `django.contrib.sitemaps`:

```python
# sitemaps.py
from django.contrib.sitemaps import Sitemap
from .models import Post

class StaticViewSitemap(Sitemap):
    priority = 0.5
    changefreq = 'monthly'

    def items(self):
        return ['home', 'about', 'contact']

    def location(self, item):
        return reverse(item)

class PostSitemap(Sitemap):
    changefreq = 'monthly'
    priority = 0.6

    def items(self):
        return Post.objects.filter(published=True)

    def lastmod(self, obj):
        return obj.updated_at
```

#### Express

Create a route handler or use `express-sitemap-xml` package.

#### Static Sites

Generate a `sitemap.xml` file directly:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2024-01-15T00:00:00+00:00</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <!-- ... more URLs ... -->
</urlset>
```

### Step 5: Image Sitemap Entries

For pages with important images, add image sitemap extensions:

```xml
<url>
  <loc>https://example.com/page</loc>
  <image:image>
    <image:loc>https://example.com/image.jpg</image:loc>
    <image:title>Image title</image:title>
    <image:caption>Image description</image:caption>
  </image:image>
</url>
```

In framework implementations, document how to add image entries to the sitemap.

### Step 6: Sitemap Index (Large Sites)

If the site has or may have >50,000 URLs, implement a sitemap index:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://example.com/sitemap-pages.xml</loc>
    <lastmod>2024-01-15T00:00:00+00:00</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-blog.xml</loc>
    <lastmod>2024-01-15T00:00:00+00:00</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-products.xml</loc>
    <lastmod>2024-01-15T00:00:00+00:00</lastmod>
  </sitemap>
</sitemapindex>
```

### Step 7: Configure robots.txt

Create or update `robots.txt` (or its framework equivalent):

```
User-agent: *
Allow: /

# Block non-public paths
Disallow: /api/
Disallow: /admin/
Disallow: /dashboard/
Disallow: /_next/
Disallow: /private/

# Sitemap
Sitemap: https://example.com/sitemap.xml
```

#### Framework-Specific robots.txt

- **Next.js App Router**: Create `app/robots.ts`:
  ```typescript
  import type { MetadataRoute } from 'next';
  export default function robots(): MetadataRoute.Robots {
    return {
      rules: { userAgent: '*', allow: '/', disallow: ['/api/', '/admin/'] },
      sitemap: `${process.env.NEXT_PUBLIC_SITE_URL}/sitemap.xml`,
    };
  }
  ```
- **Astro**: Create `public/robots.txt` or generate dynamically
- **Django**: Use `django.contrib.sitemaps` robots view or static file
- **Static**: Create `robots.txt` in the public/root directory

### Step 8: Google Search Console Instructions

After implementation, provide instructions for submitting:

1. Go to Google Search Console: https://search.google.com/search-console
2. Select or add your property
3. Navigate to "Sitemaps" in the left sidebar
4. Enter the sitemap URL (e.g., `https://example.com/sitemap.xml`)
5. Click "Submit"
6. Verify the sitemap is processed without errors
7. Check "Coverage" report for any indexing issues

Also suggest:
- Bing Webmaster Tools: https://www.bing.com/webmasters
- Add sitemap URL to robots.txt (already done above)

### Step 9: Verification

After implementation, verify:

- [ ] Sitemap is accessible at `/sitemap.xml`
- [ ] All public routes are included
- [ ] No private/auth/admin routes are included
- [ ] API routes are excluded
- [ ] `lastmod` dates are populated
- [ ] `changefreq` is appropriate for each page type
- [ ] `priority` reflects page importance hierarchy
- [ ] URLs are absolute with correct base URL
- [ ] robots.txt exists and references the sitemap
- [ ] robots.txt does not accidentally block important pages
- [ ] For dynamic routes, data source integration is documented
- [ ] XML is well-formed and valid

### Important Notes

- Never include non-canonical URLs in the sitemap
- Never include pages with `noindex` directive
- All URLs must be absolute (include protocol and domain)
- URLs should match the canonical form (trailing slash consistency)
- Maximum 50,000 URLs per sitemap file
- Maximum 50MB uncompressed per sitemap file
- For large sites, use sitemap index with multiple sitemap files
- Consider gzip compression for large sitemaps (sitemap.xml.gz)
- Dynamic routes need data source integration -- provide clear patterns and TODO comments
