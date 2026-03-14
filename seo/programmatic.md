# Programmatic SEO

Build programmatic SEO pages from a pattern template, generating page templates, data schemas, URL structures, and internal linking strategies at scale.

## Arguments

$ARGUMENTS - Required `<pattern>`: A template pattern with placeholders in curly braces, e.g. "best {tool} for {industry}", "{city} {service}", "{framework} vs {framework}", "{topic} guide".

## Instructions

### Step 1: Parse the Pattern

Extract the variable placeholders from the pattern argument:
- Identify each `{variable}` in the pattern
- Determine the semantic type of each variable (location, tool name, industry, service, topic, etc.)
- Calculate the total number of page combinations (product of all variable value counts)
- If no valid pattern is provided, show examples and ask the user to specify one

Examples of valid patterns:
- `best {tool} for {industry}` - generates pages like "best-crm-for-healthcare"
- `{city} {service}` - generates pages like "new-york-plumber"
- `{language} {concept} tutorial` - generates pages like "python-decorators-tutorial"
- `{product} vs {product}` - generates comparison pages
- `{topic} statistics {year}` - generates data-driven pages

### Step 2: Detect Project Framework

Identify the framework to determine page creation approach:
- **Next.js App Router**: Dynamic route segments `app/[slug]/page.tsx` or `app/best-[tool]-for-[industry]/page.tsx`
- **Next.js Pages Router**: `pages/[slug].tsx`
- **Nuxt**: `pages/[slug].vue`
- **Astro**: `src/pages/[...slug].astro` with `getStaticPaths`
- **Django**: URL patterns with path converters
- **Static**: Generate individual HTML files via a build script

### Step 3: Design the Data Schema

Create a data schema that defines the variables and their possible values:

```typescript
// Example for "best {tool} for {industry}"
interface PageData {
  tool: {
    slug: string;       // "crm", "project-management"
    name: string;       // "CRM", "Project Management"
    description: string;
    features: string[];
  };
  industry: {
    slug: string;       // "healthcare", "real-estate"
    name: string;       // "Healthcare", "Real Estate"
    description: string;
    painPoints: string[];
  };
}
```

Create the data file with initial seed data:
- Provide 5-10 example values per variable as a starting point
- Include a slug (URL-safe), display name, and relevant attributes per value
- Structure data so adding new values automatically generates new pages
- Store in a JSON, YAML, or TypeScript data file in a logical location (e.g., `src/data/`, `content/`, `lib/data/`)

### Step 4: Design URL Structure

Create a clean, SEO-friendly URL structure:
- Use slugified variable values: `/best-{tool}-for-{industry}` or `/{city}-{service}`
- Keep URLs short and descriptive
- Avoid query parameters for primary variables
- Use hyphens to separate words

Define the URL pattern and implement it in the framework's routing system. For dynamic routes, create the appropriate catch-all or parameterized route.

### Step 5: Create the Page Template

Build a reusable page template/component that renders based on the data:

The template must include:
1. **Dynamic H1**: Derived from the pattern with proper capitalization
2. **Introduction paragraph**: Contextual intro using variable data
3. **Main content sections**: Relevant to the pattern type:
   - For "best X for Y": Feature comparison, use cases, recommendations
   - For "city service": Local information, service details, pricing context
   - For "X vs Y": Side-by-side comparison, pros/cons, verdict
   - For "topic guide": Table of contents, sections, examples
4. **Internal links**: Links to related programmatic pages (same tool different industries, same city different services, etc.)
5. **FAQ section**: Auto-generated FAQs relevant to the variable combination
6. **CTA section**: Call to action relevant to the page context

The template should gracefully handle different data combinations and never produce empty or broken sections.

### Step 6: Implement Meta Tag Template

Create dynamic meta tags for each generated page:

```
Title: Best {Tool Name} for {Industry Name} in {Year} | {Brand}
       (under 60 characters, adjust format to fit)

Description: Discover the best {tool name} solutions for {industry name}. 
             Compare features, pricing, and find the right fit for your {industry} needs.
             (under 155 characters)

Canonical: {baseUrl}/{url-slug}

OG Tags: Dynamic per page with the same title/description pattern
```

Implement using the framework's metadata system (generateMetadata, react-helmet, etc.).

### Step 7: Build Internal Linking Strategy

Create a systematic internal linking structure:
- **Hub pages**: Create index/listing pages that link to all variations (e.g., "Best Tools for Every Industry")
- **Cross-links within pages**: Each page links to related pages:
  - Same first variable, different second: "Best CRM for Other Industries"
  - Same second variable, different first: "Other Tools for Healthcare"
- **Breadcrumbs**: Implement breadcrumb navigation showing the hierarchy
- **Related pages section**: Show 3-5 most relevant sibling pages
- **Footer links**: Categorized links to all pages or popular pages

Implement the linking as a component that receives the current page data and generates appropriate links.

### Step 8: Canonical Strategy for Avoiding Duplication

Implement deduplication safeguards:
- Self-referencing canonical URL on every page
- For "X vs Y" patterns where order doesn't matter, pick a canonical ordering (alphabetical) and redirect the reverse
- Ensure no two URL patterns produce identical content
- Add `noindex` to paginated listing pages beyond page 1
- Use consistent URL casing (lowercase) and trailing slash convention
- Implement redirects for any duplicate URL variations

### Step 9: Integrate with Sitemap

Add all programmatic pages to the sitemap:
- Create a function that generates all URL combinations from the data
- Add to the existing sitemap or create a dedicated sitemap section
- Set appropriate priority (typically 0.6-0.7 for programmatic pages)
- Set changefreq based on how often the data changes
- Use lastmod from the data file's last modification date

If a sitemap doesn't exist yet, create one following the sitemap generation approach.

### Step 10: Create Data Loader

Implement a data loading utility:
- Function to get all possible page combinations (for static generation / `getStaticPaths`)
- Function to get data for a specific page by its slug/parameters
- Validation that ensures no missing data for any combination
- TypeScript types for the data schema (if applicable)

```typescript
// Example utility
export function getAllPages(): PageParams[] { ... }
export function getPageData(params: PageParams): PageData { ... }
export function getRelatedPages(current: PageParams, limit: number): PageParams[] { ... }
```

### Step 11: Summary and Scaling Instructions

Report what was created:

```
## Programmatic SEO Implementation

- Pattern: {original pattern}
- Total pages generated: {count}
- URL structure: /{url-pattern}
- Data file: {path}
- Page template: {path}
- Meta tag template: {path}
- Internal linking component: {path}
- Data loader: {path}

### To Add More Pages
1. Add new entries to {data file path}
2. Pages are automatically generated on next build/deploy
3. Sitemap updates automatically

### Files Created/Modified
- [list of all file paths]
```
