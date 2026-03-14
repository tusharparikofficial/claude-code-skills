# SEO Structured Data Generator

Implement JSON-LD structured data (Schema.org) for specified page types, validated against the Schema.org specification and implemented in the project's framework.

## Arguments

$ARGUMENTS - Required: `<page-type>` - one of: article, product, faq, howto, recipe, event, organization, person, breadcrumb, local-business. Can also pass a file path after the type, e.g., `product src/pages/product.tsx`

## Instructions

You are implementing JSON-LD structured data markup. Follow each step carefully.

### Step 1: Parse Arguments and Detect Context

1. Parse `$ARGUMENTS` to extract:
   - **Page type**: The schema type to implement (required)
   - **Target file**: Optional specific file to add structured data to
2. Detect the project framework (Next.js, React, Vue, Astro, SvelteKit, static HTML, etc.)
3. Identify existing structured data in the project to avoid conflicts
4. Find relevant pages that match the requested type if no target file specified

Valid page types and their Schema.org mappings:
| Argument | Schema.org Type(s) |
|----------|-------------------|
| article | Article, BlogPosting, NewsArticle |
| product | Product, Offer, AggregateRating, Review |
| faq | FAQPage, Question, Answer |
| howto | HowTo, HowToStep, HowToSection |
| recipe | Recipe, NutritionInformation |
| event | Event, Place, Performer |
| organization | Organization, ContactPoint, PostalAddress |
| person | Person, ContactPoint |
| breadcrumb | BreadcrumbList, ListItem |
| local-business | LocalBusiness, OpeningHoursSpecification, PostalAddress, GeoCoordinates |

### Step 2: Generate JSON-LD for Requested Type

#### Article / BlogPosting

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title (max 110 chars)",
  "description": "Brief description of the article",
  "image": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "datePublished": "2024-01-15T08:00:00+00:00",
  "dateModified": "2024-01-16T10:00:00+00:00",
  "author": {
    "@type": "Person",
    "name": "Author Name",
    "url": "https://example.com/author"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Publisher Name",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png"
    }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://example.com/article-url"
  },
  "wordCount": 1500,
  "articleSection": "Technology",
  "keywords": ["keyword1", "keyword2"]
}
```

Required fields: headline, image, datePublished, author, publisher
Recommended: dateModified, description, mainEntityOfPage

#### Product

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "description": "Product description",
  "image": [
    "https://example.com/product1.jpg"
  ],
  "sku": "SKU-12345",
  "mpn": "MPN-12345",
  "brand": {
    "@type": "Brand",
    "name": "Brand Name"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/product",
    "priceCurrency": "USD",
    "price": "29.99",
    "priceValidUntil": "2025-12-31",
    "availability": "https://schema.org/InStock",
    "seller": {
      "@type": "Organization",
      "name": "Seller Name"
    }
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "bestRating": "5",
    "ratingCount": "120",
    "reviewCount": "85"
  },
  "review": [
    {
      "@type": "Review",
      "reviewRating": {
        "@type": "Rating",
        "ratingValue": "5",
        "bestRating": "5"
      },
      "author": {
        "@type": "Person",
        "name": "Reviewer Name"
      },
      "reviewBody": "Review text here"
    }
  ]
}
```

Required fields: name, image, offers (price, priceCurrency, availability)
Recommended: sku, brand, aggregateRating, review

#### FAQ

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the question?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The answer to the question. Can include <a href='url'>HTML links</a>."
      }
    },
    {
      "@type": "Question",
      "name": "Second question?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Second answer."
      }
    }
  ]
}
```

Required fields: mainEntity with at least one Question/Answer pair
Note: Extract Q&A pairs from page content if available

#### HowTo

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to Do Something",
  "description": "Brief description of the how-to",
  "image": "https://example.com/howto.jpg",
  "totalTime": "PT30M",
  "estimatedCost": {
    "@type": "MonetaryAmount",
    "currency": "USD",
    "value": "0"
  },
  "supply": [
    { "@type": "HowToSupply", "name": "Supply item 1" }
  ],
  "tool": [
    { "@type": "HowToTool", "name": "Tool 1" }
  ],
  "step": [
    {
      "@type": "HowToStep",
      "name": "Step 1 Title",
      "text": "Step 1 description",
      "url": "https://example.com/howto#step1",
      "image": "https://example.com/step1.jpg"
    },
    {
      "@type": "HowToStep",
      "name": "Step 2 Title",
      "text": "Step 2 description",
      "url": "https://example.com/howto#step2",
      "image": "https://example.com/step2.jpg"
    }
  ]
}
```

#### Recipe

```json
{
  "@context": "https://schema.org",
  "@type": "Recipe",
  "name": "Recipe Name",
  "description": "Recipe description",
  "image": ["https://example.com/recipe.jpg"],
  "author": { "@type": "Person", "name": "Chef Name" },
  "datePublished": "2024-01-15",
  "prepTime": "PT15M",
  "cookTime": "PT30M",
  "totalTime": "PT45M",
  "recipeYield": "4 servings",
  "recipeCategory": "Dinner",
  "recipeCuisine": "Italian",
  "keywords": "pasta, easy dinner",
  "nutrition": {
    "@type": "NutritionInformation",
    "calories": "350 calories",
    "servingSize": "1 plate"
  },
  "recipeIngredient": [
    "2 cups flour",
    "1 cup water"
  ],
  "recipeInstructions": [
    {
      "@type": "HowToStep",
      "text": "Mix the flour and water."
    }
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "ratingCount": "52"
  }
}
```

#### Event

```json
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "Event Name",
  "description": "Event description",
  "image": "https://example.com/event.jpg",
  "startDate": "2024-06-15T19:00:00-05:00",
  "endDate": "2024-06-15T23:00:00-05:00",
  "eventStatus": "https://schema.org/EventScheduled",
  "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode",
  "location": {
    "@type": "Place",
    "name": "Venue Name",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "123 Main St",
      "addressLocality": "City",
      "addressRegion": "State",
      "postalCode": "12345",
      "addressCountry": "US"
    }
  },
  "performer": {
    "@type": "Person",
    "name": "Performer Name"
  },
  "organizer": {
    "@type": "Organization",
    "name": "Organizer Name",
    "url": "https://example.com"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/tickets",
    "price": "50.00",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock",
    "validFrom": "2024-01-01T00:00:00-05:00"
  }
}
```

#### Organization

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company Name",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "description": "Company description",
  "foundingDate": "2020",
  "founders": [
    { "@type": "Person", "name": "Founder Name" }
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-555-5555",
    "contactType": "customer service",
    "availableLanguage": "English"
  },
  "sameAs": [
    "https://twitter.com/company",
    "https://linkedin.com/company/company",
    "https://github.com/company"
  ],
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "City",
    "addressRegion": "State",
    "postalCode": "12345",
    "addressCountry": "US"
  }
}
```

#### Person

```json
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "Full Name",
  "url": "https://example.com",
  "image": "https://example.com/photo.jpg",
  "jobTitle": "Job Title",
  "worksFor": {
    "@type": "Organization",
    "name": "Company Name"
  },
  "sameAs": [
    "https://twitter.com/handle",
    "https://linkedin.com/in/handle",
    "https://github.com/handle"
  ],
  "email": "email@example.com",
  "description": "Brief bio"
}
```

#### BreadcrumbList

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://example.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Category",
      "item": "https://example.com/category"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "Current Page"
    }
  ]
}
```

Note: Last item should NOT have an `item` URL (it is the current page).

#### LocalBusiness

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Business Name",
  "description": "Business description",
  "image": "https://example.com/business.jpg",
  "url": "https://example.com",
  "telephone": "+1-555-555-5555",
  "email": "info@example.com",
  "priceRange": "$$",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "City",
    "addressRegion": "State",
    "postalCode": "12345",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": "40.7128",
    "longitude": "-74.0060"
  },
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "09:00",
      "closes": "17:00"
    },
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": "Saturday",
      "opens": "10:00",
      "closes": "14:00"
    }
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.6",
    "reviewCount": "250"
  },
  "sameAs": [
    "https://facebook.com/business",
    "https://yelp.com/biz/business"
  ]
}
```

### Step 3: Create Structured Data Utility Module

Create a reusable module for generating JSON-LD:

```typescript
// lib/seo/structured-data.ts (or equivalent for the project's language)

// Type definitions for each schema
interface ArticleJsonLd { ... }
interface ProductJsonLd { ... }
interface FaqJsonLd { ... }
// etc.

// Builder functions
export function buildArticleJsonLd(data: ArticleJsonLd): object { ... }
export function buildProductJsonLd(data: ProductJsonLd): object { ... }
export function buildFaqJsonLd(data: FaqJsonLd): object { ... }
export function buildHowToJsonLd(data: HowToJsonLd): object { ... }
export function buildRecipeJsonLd(data: RecipeJsonLd): object { ... }
export function buildEventJsonLd(data: EventJsonLd): object { ... }
export function buildOrganizationJsonLd(data: OrganizationJsonLd): object { ... }
export function buildPersonJsonLd(data: PersonJsonLd): object { ... }
export function buildBreadcrumbJsonLd(items: BreadcrumbItem[]): object { ... }
export function buildLocalBusinessJsonLd(data: LocalBusinessJsonLd): object { ... }

// Renderer component or function
export function JsonLd({ data }: { data: object }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

Adapt the module to the project's language and framework:
- TypeScript/JavaScript: typed interfaces + builder functions
- Python/Django: dictionary builders + template tag
- PHP: array builders + blade directive
- Static HTML: raw JSON-LD script tags

### Step 4: Implement in Target Pages

Inject the JSON-LD into the appropriate pages:

#### Next.js (App Router)
Add to `metadata` export or render `<JsonLd>` component in page layout.
Can also use `generateMetadata` for dynamic structured data.

#### Next.js (Pages Router)
Use `<Head>` with `<script type="application/ld+json">`.

#### React
Render `<Helmet>` with script tag or use `<JsonLd>` component.

#### Vue/Nuxt
Use `useHead()` with `script` option for JSON-LD.

#### Astro
Add `<script type="application/ld+json">` in page `<head>`.

#### Static HTML
Add script tag directly before `</head>`.

### Step 5: Populate with Real Data

- Read the actual page content to populate structured data fields with real values
- Use environment variables for URLs: `SITE_URL`, `NEXT_PUBLIC_SITE_URL`, etc.
- Use dynamic data from CMS/database when available (via props, params, API calls)
- For fields that cannot be inferred, add clear TODO comments with instructions

### Step 6: Validation and Testing

After implementation, provide:

1. **Self-validation**: Check the generated JSON-LD is valid JSON
2. **Schema.org compliance**: Verify all required fields are present for the type
3. **Testing instructions**:
   - Google Rich Results Test: https://search.google.com/test/rich-results
   - Schema.org Validator: https://validator.schema.org/
   - JSON-LD Playground: https://json-ld.org/playground/
4. **Common errors to avoid**:
   - Missing `@context`
   - Wrong `@type` spelling
   - Relative URLs (must be absolute)
   - Missing required fields
   - Invalid date formats (must be ISO 8601)
   - Price as number without quotes (should be string)

### Important Notes

- Always use `@context: "https://schema.org"` (not http)
- All URLs in structured data must be absolute
- Dates must be in ISO 8601 format
- Price values should be strings, not numbers
- Do not duplicate data already in meta tags unless required by the schema
- Multiple JSON-LD blocks on one page are valid and preferred over nesting unrelated types
- Extract real content from the page when possible rather than using placeholder text
