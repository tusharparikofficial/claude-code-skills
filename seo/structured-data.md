# Structured Data

Implement Schema.org compliant JSON-LD structured data for the specified type, validated against the spec and integrated into the project framework.

## Arguments

$ARGUMENTS - Required `<type>`: one of `article`, `product`, `faq`, `organization`, `breadcrumb`, `local-business`, `event`, `howto`. Specifies the Schema.org type to implement.

## Instructions

### Step 1: Validate the Type Argument

Parse the `<type>` argument. It must be one of:
- `article` - For blog posts, news articles, guides
- `product` - For product pages with pricing, availability, reviews
- `faq` - For FAQ pages with question/answer pairs
- `organization` - For company/brand information (usually homepage)
- `breadcrumb` - For navigation breadcrumb trails
- `local-business` - For businesses with physical locations
- `event` - For events with dates, locations, tickets
- `howto` - For step-by-step instructional content

If the argument is missing or invalid, list the valid types and ask the user to specify one.

### Step 2: Detect Project Framework

Identify the project framework to determine how to inject JSON-LD:
- **Next.js App Router**: Add `<script type="application/ld+json">` in page component or via metadata API
- **Next.js Pages Router**: Add via `next/head` or `_document.tsx`
- **React**: Add via `react-helmet` or a dedicated component
- **Vue/Nuxt**: Add via `useHead()` or `useJsonld()`
- **Astro**: Add in layout `<head>` section
- **Django**: Add in template `<head>` block
- **Static HTML**: Add directly in `<head>`

### Step 3: Identify Target Pages

Based on the type, find the relevant pages in the project:
- `article`: Blog post pages, article pages, guide pages
- `product`: Product detail pages, product listing pages
- `faq`: FAQ pages, help center pages
- `organization`: Homepage, about page
- `breadcrumb`: All pages (usually implemented in layout)
- `local-business`: Homepage, contact page, location pages
- `event`: Event listing and detail pages
- `howto`: Tutorial pages, how-to guides

If no relevant pages exist, inform the user and suggest creating them or applying to the most appropriate existing page.

### Step 4: Generate JSON-LD Schema

Generate the complete JSON-LD object for the specified type. Include all required and recommended properties per Schema.org specification.

**Article (`Article` or `BlogPosting`):**
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "",
  "description": "",
  "image": "",
  "author": { "@type": "Person", "name": "" },
  "publisher": {
    "@type": "Organization",
    "name": "",
    "logo": { "@type": "ImageObject", "url": "" }
  },
  "datePublished": "",
  "dateModified": "",
  "mainEntityOfPage": { "@type": "WebPage", "@id": "" }
}
```

**Product:**
```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "",
  "description": "",
  "image": "",
  "brand": { "@type": "Brand", "name": "" },
  "offers": {
    "@type": "Offer",
    "price": "",
    "priceCurrency": "",
    "availability": "https://schema.org/InStock",
    "url": ""
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "",
    "reviewCount": ""
  }
}
```

**FAQ (`FAQPage`):**
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": ""
      }
    }
  ]
}
```

**Organization:**
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "",
  "url": "",
  "logo": "",
  "sameAs": [],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "",
    "contactType": "customer service"
  }
}
```

**Breadcrumb (`BreadcrumbList`):**
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": ""
    }
  ]
}
```

**Local Business (`LocalBusiness`):**
```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "",
    "addressLocality": "",
    "addressRegion": "",
    "postalCode": "",
    "addressCountry": ""
  },
  "telephone": "",
  "openingHoursSpecification": [],
  "geo": { "@type": "GeoCoordinates", "latitude": "", "longitude": "" },
  "url": "",
  "image": ""
}
```

**Event:**
```json
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "",
  "startDate": "",
  "endDate": "",
  "location": {
    "@type": "Place",
    "name": "",
    "address": { "@type": "PostalAddress" }
  },
  "description": "",
  "image": "",
  "offers": {
    "@type": "Offer",
    "price": "",
    "priceCurrency": "",
    "url": "",
    "availability": "https://schema.org/InStock"
  },
  "organizer": { "@type": "Organization", "name": "", "url": "" }
}
```

**HowTo:**
```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "",
  "description": "",
  "totalTime": "",
  "estimatedCost": { "@type": "MonetaryAmount", "currency": "", "value": "" },
  "supply": [],
  "tool": [],
  "step": [
    {
      "@type": "HowToStep",
      "name": "",
      "text": "",
      "image": "",
      "url": ""
    }
  ]
}
```

### Step 5: Populate with Real Data

Read the existing page content and populate the JSON-LD with actual data from the project:
- Extract titles, descriptions, dates from page content or CMS data
- Use dynamic data bindings for pages that render dynamic content (blog posts, products)
- Use environment variables or config for site-wide values (site URL, organization name)
- For breadcrumbs, derive from the URL path and route structure

### Step 6: Create Reusable Component/Utility

Create a reusable structured data component or utility function:
- Accept the schema type and data as props/parameters
- Serialize to JSON and render as `<script type="application/ld+json">`
- Handle proper escaping of special characters in JSON
- Support multiple schemas per page (e.g., Article + BreadcrumbList)

Place this in a shared location (e.g., `src/components/JsonLd.tsx`, `src/lib/structured-data.ts`).

### Step 7: Implement on Target Pages

Add the structured data to all identified target pages:
- Import the utility/component
- Pass the appropriate data
- For dynamic pages, ensure data is populated at build time or server-side

### Step 8: Validate the Schema

After implementation, validate the generated JSON-LD:
- Verify it is valid JSON (no syntax errors)
- Verify all required properties are present per Schema.org spec
- Verify property values are the correct types (strings, numbers, dates in ISO 8601)
- Verify URLs are absolute
- Verify dates are in ISO 8601 format

### Step 9: Provide Testing Instructions

Output testing instructions for the user:

```
## Testing Your Structured Data

1. **Google Rich Results Test**: https://search.google.com/test/rich-results
   - Enter your page URL or paste the HTML
   - Verify all structured data is detected and valid
   - Check for warnings and errors

2. **Schema.org Validator**: https://validator.schema.org/
   - Paste your JSON-LD to validate against the full Schema.org spec

3. **Browser DevTools**:
   - Open your page in the browser
   - View Page Source and search for "application/ld+json"
   - Copy the JSON and validate at https://jsonlint.com/

4. **Google Search Console**:
   - After deployment, check Enhancements section
   - Monitor for structured data errors over time
```

### Step 10: Summary

Report what was implemented:
- Which Schema.org type was added
- Which pages received structured data
- File paths of all modified/created files
- Any properties that need manual data entry (e.g., geo coordinates, phone numbers)
- Link to the relevant Schema.org documentation for reference
