# Build Product Search with Filtering

Build a complete product search system with full-text search, faceted filtering, autocomplete, and search analytics.

## Arguments

$ARGUMENTS - Optional: search engine to use: `postgres`, `elasticsearch`, `algolia`, or `typesense` (defaults to `postgres`)

## Instructions

1. **Determine the search engine.** Parse `$ARGUMENTS` for the search engine choice. Default to `postgres` if not specified or empty. Valid options: `postgres`, `elasticsearch`, `algolia`, `typesense`.

2. **Analyze the existing project** to understand the tech stack, database, ORM, existing product models, and code conventions. The search system must work with existing product data.

3. **Build the following components:**

### Search API

#### Endpoints
```
GET  /api/search?q=<query>              - Full-text product search
GET  /api/search/suggest?q=<partial>    - Autocomplete suggestions
GET  /api/search/facets                 - Get available filter facets
GET  /api/search/popular                - Popular/trending searches

Admin:
GET  /api/admin/search/analytics        - Search analytics dashboard data
POST /api/admin/search/reindex          - Trigger full reindex
```

#### Search Query Parameters
```
?q=red shoes                            - Search query (required)
?page=1&limit=20                        - Pagination
?sort=relevance|price_asc|price_desc|newest|popular  - Sort order
?category=shoes                         - Filter by category slug
?categories=shoes,boots,sandals         - Filter by multiple categories
?minPrice=20&maxPrice=100               - Price range filter
?brand=nike,adidas                      - Filter by brand (comma-separated)
?color=red,blue                         - Filter by color attribute
?size=M,L,XL                            - Filter by size attribute
?inStock=true                           - Only show in-stock items
?rating=4                               - Minimum rating filter
?tags=sale,new-arrival                  - Filter by tags
?attributes[material]=leather           - Dynamic attribute filters
```

#### Search Response Format
```json
{
  "results": [
    {
      "id": "uuid",
      "name": "Red Running Shoes",
      "slug": "red-running-shoes",
      "description": "...",
      "price": 79.99,
      "compareAtPrice": 99.99,
      "image": "url",
      "category": "Shoes",
      "rating": 4.5,
      "reviewCount": 42,
      "inStock": true,
      "highlights": {
        "name": "<mark>Red</mark> Running <mark>Shoes</mark>",
        "description": "Comfortable <mark>red</mark> running <mark>shoes</mark> with..."
      }
    }
  ],
  "facets": {
    "categories": [
      { "value": "shoes", "label": "Shoes", "count": 45 },
      { "value": "boots", "label": "Boots", "count": 12 }
    ],
    "priceRanges": [
      { "min": 0, "max": 50, "count": 23 },
      { "min": 50, "max": 100, "count": 34 },
      { "min": 100, "max": 200, "count": 15 }
    ],
    "brands": [
      { "value": "nike", "label": "Nike", "count": 28 },
      { "value": "adidas", "label": "Adidas", "count": 19 }
    ],
    "colors": [...],
    "sizes": [...]
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 156,
    "totalPages": 8
  },
  "meta": {
    "query": "red shoes",
    "took": 23,
    "spellingSuggestion": null
  }
}
```

### Search Engine Implementation

#### PostgreSQL (default)

```sql
-- Add search vector column to products table
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Create GIN index for fast full-text search
CREATE INDEX idx_products_search ON products USING GIN(search_vector);

-- Update function to generate search vector
CREATE OR REPLACE FUNCTION update_product_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.sku, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.short_description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update search vector
CREATE TRIGGER trg_product_search_vector
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_product_search_vector();

-- Search query with ranking
SELECT p.*, ts_rank(search_vector, query) AS rank,
       ts_headline('english', p.name, query) AS highlighted_name,
       ts_headline('english', p.description, query) AS highlighted_description
FROM products p, plainto_tsquery('english', $1) query
WHERE search_vector @@ query
  AND p.status = 'active'
ORDER BY rank DESC
LIMIT $2 OFFSET $3;

-- Faceted counts using conditional aggregation
SELECT
  category_id,
  COUNT(*) FILTER (WHERE price < 50) AS price_under_50,
  COUNT(*) FILTER (WHERE price BETWEEN 50 AND 100) AS price_50_100,
  COUNT(*) FILTER (WHERE price > 100) AS price_over_100
FROM products
WHERE search_vector @@ plainto_tsquery('english', $1)
GROUP BY category_id;

-- Autocomplete using trigram similarity
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING GIN(name gin_trgm_ops);

SELECT DISTINCT name, similarity(name, $1) AS sim
FROM products
WHERE name % $1
ORDER BY sim DESC
LIMIT 10;
```

Implementation notes for PostgreSQL:
- Use `plainto_tsquery` for user input (safe from injection)
- Weight fields: A (name, SKU), B (short description, tags), C (full description)
- Use `ts_headline` for search result highlighting
- Use `pg_trgm` extension for fuzzy autocomplete
- Faceted counts via conditional aggregation in a single query
- Consider materialized views for frequently-used facet combinations

#### Elasticsearch

```
Index Mapping:
  - name: text (with keyword sub-field for sorting/aggregation)
  - description: text
  - sku: keyword
  - price: float
  - category: keyword
  - tags: keyword (array)
  - attributes: nested (for variant attributes)
  - suggest: completion (for autocomplete)

Search Query:
  - Use multi_match with best_fields for relevance
  - Boost name field (^3) over description (^1)
  - Use function_score for boosting featured/popular products
  - Use highlight for search result highlighting

Facets:
  - Use aggregations (terms, range, nested)
  - Filter aggregations to respect active filters (post_filter pattern)

Autocomplete:
  - Use completion suggester for prefix-based suggestions
  - Use search_as_you_type field for partial matching

Sync Strategy:
  - On product create/update: index to Elasticsearch
  - On product delete: remove from index
  - Background job for full reindex
  - Use bulk API for batch operations
```

#### Algolia

```
Configuration:
  - ALGOLIA_APP_ID
  - ALGOLIA_ADMIN_KEY (server-side only)
  - ALGOLIA_SEARCH_KEY (client-side, restricted)

Index Setup:
  - Searchable attributes: name, description, sku, tags, category_name
  - Ranking: typo, geo, words, filters, proximity, attribute, exact, custom
  - Custom ranking: desc(popularity), desc(rating)
  - Facets: category, price, brand, color, size, tags, in_stock

Frontend:
  - Use InstantSearch.js or React InstantSearch
  - Provides built-in UI components for search, facets, pagination
  - Client-side search (fast, no server roundtrip for search queries)

Sync:
  - Save objects on product create/update
  - Delete objects on product delete
  - Use replicas for different sort orders (price_asc, price_desc, newest)
```

#### Typesense

```
Configuration:
  - TYPESENSE_HOST
  - TYPESENSE_PORT
  - TYPESENSE_API_KEY

Collection Schema:
  {
    "name": "products",
    "fields": [
      { "name": "name", "type": "string" },
      { "name": "description", "type": "string" },
      { "name": "sku", "type": "string" },
      { "name": "price", "type": "float", "facet": true },
      { "name": "category", "type": "string", "facet": true },
      { "name": "tags", "type": "string[]", "facet": true },
      { "name": "brand", "type": "string", "facet": true },
      { "name": "color", "type": "string[]", "facet": true },
      { "name": "in_stock", "type": "bool", "facet": true },
      { "name": "popularity", "type": "int32" },
      { "name": "rating", "type": "float" }
    ],
    "default_sorting_field": "popularity"
  }

Search:
  - Use multi-field search with query_by weights
  - Built-in typo tolerance
  - Faceted search with filter_by
  - Group by for deduplication

Frontend:
  - Use typesense-instantsearch-adapter with InstantSearch.js
  - Or use Typesense JS client directly
```

### Autocomplete / Suggestions

```
Autocomplete Endpoint: GET /api/search/suggest?q=<partial>

Response:
{
  "suggestions": [
    { "text": "red running shoes", "type": "query" },
    { "text": "Red Nike Air Max", "type": "product", "slug": "red-nike-air-max" },
    { "text": "Running Shoes", "type": "category", "slug": "running-shoes" }
  ]
}

Implementation:
  - Return product name matches (top 3)
  - Return category matches (top 2)
  - Return popular search queries that match (top 3)
  - Debounce on frontend (300ms)
  - Minimum 2 characters before triggering
  - Cache popular prefixes
```

### Search Result Ranking

```
Default Ranking Factors:
  1. Text relevance (primary)
  2. Exact match boost (name exact match ranks highest)
  3. Product popularity (sales count, view count)
  4. Rating (higher-rated products rank higher)
  5. Recency (newer products get slight boost)
  6. In-stock boost (in-stock products rank above out-of-stock)
  7. Featured boost (featured products get ranking bonus)

Custom Boosts (configurable):
  - Sponsored/promoted products can be pinned to top positions
  - Category-specific ranking rules
  - Seasonal/sale item boosting
```

### Search Analytics

#### SearchQuery Model
```
SearchQuery:
  - id: UUID (primary key)
  - query: string (the search term)
  - normalizedQuery: string (lowercase, trimmed)
  - resultsCount: integer
  - userId: foreign key -> User (nullable for anonymous)
  - sessionId: string
  - filters: JSON (applied filters)
  - clickedProductId: foreign key -> Product (nullable)
  - clickPosition: integer (nullable, which result was clicked)
  - convertedOrderId: foreign key -> Order (nullable)
  - createdAt: timestamp
```

#### Analytics Tracking
```
Track:
  - Every search query (with result count)
  - Click-through: which result position was clicked
  - Conversion: did the search lead to a purchase
  - Zero-result queries: searches that returned nothing

Analytics Dashboard Data:
  GET /api/admin/search/analytics
  - Top search queries (last 7/30 days)
  - Zero-result queries (to inform catalog gaps)
  - Search-to-click rate
  - Search-to-purchase conversion rate
  - Average results per query
  - Popular filters used
```

### Frontend Components

1. **Search Bar Component**
   - Input with search icon
   - Autocomplete dropdown (debounced, 300ms)
   - Recent searches (stored in localStorage)
   - Popular searches (from analytics)
   - Keyboard navigation (arrow keys, Enter, Escape)
   - Mobile-friendly (full-screen search on mobile)

2. **Filter Sidebar**
   - Category filter (with hierarchy, collapsible)
   - Price range filter (slider or min/max inputs)
   - Dynamic attribute filters (color swatches, size chips, brand checkboxes)
   - "In Stock Only" toggle
   - Rating filter (star rating selector)
   - Active filters display with clear buttons
   - "Clear All Filters" button
   - Filter counts (show number of results per filter value)
   - URL-synced filters (filters reflected in URL for shareability)

3. **Search Results Grid**
   - Grid/list view toggle
   - Sort dropdown (Relevance, Price Low-High, Price High-Low, Newest, Popular)
   - Result count ("Showing 1-20 of 156 results for 'red shoes'")
   - Product cards with highlighted search terms
   - Pagination or infinite scroll
   - "No results" state with suggestions
   - Loading skeleton while searching

### Implementation Order

1. Choose and set up the search engine (based on argument)
2. Create search index schema / configuration
3. Build indexing pipeline (sync products to search engine)
4. Implement search API endpoint with basic text search
5. Add faceted filtering
6. Add sorting options
7. Implement autocomplete/suggestions
8. Build search result highlighting
9. Create frontend search bar component
10. Create filter sidebar component
11. Create search results grid
12. Add search analytics tracking
13. Build admin analytics dashboard
14. Write tests for search accuracy and edge cases

4. **Write the implementation** directly into the project. Follow existing code conventions and patterns.

5. **Handle edge cases:**
   - Empty search query: show popular/featured products
   - No results: show spelling suggestions, related categories, popular products
   - Special characters in search: sanitize input
   - Very long queries: truncate to reasonable length
   - Concurrent indexing: handle race conditions during reindex
