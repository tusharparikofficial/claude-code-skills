# Build Product Catalog System

Build a complete product catalog system with models, API endpoints, admin CRUD, and frontend components.

## Arguments

$ARGUMENTS - The framework to use: `nextjs`, `django`, or `express`

## Instructions

1. **Validate the framework argument.** `$ARGUMENTS` must be one of: `nextjs`, `django`, or `express`. If not provided or invalid, ask the user to specify.

2. **Analyze the existing project** to understand the current setup, database, ORM, and conventions already in use. Adapt the implementation to match existing patterns.

3. **Build the following components:**

### Data Models

#### Product Model
```
Product:
  - id: UUID (primary key)
  - name: string (required, max 255)
  - slug: string (unique, auto-generated from name)
  - description: text (rich text / markdown)
  - shortDescription: string (max 500)
  - sku: string (unique)
  - price: decimal (required, precision 10, scale 2)
  - compareAtPrice: decimal (optional, for showing discounts)
  - costPrice: decimal (optional, for margin tracking)
  - currency: string (default "USD")
  - status: enum (draft, active, archived)
  - featured: boolean (default false)
  - categoryId: foreign key -> Category
  - tags: string[] (array of tags)
  - metadata: JSON (flexible key-value data)
  - weight: decimal (optional, for shipping)
  - dimensions: JSON { length, width, height, unit }
  - seoTitle: string (optional)
  - seoDescription: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### Category Model
```
Category:
  - id: UUID (primary key)
  - name: string (required)
  - slug: string (unique)
  - description: text (optional)
  - parentId: foreign key -> Category (self-referential for hierarchy)
  - image: string (URL)
  - sortOrder: integer (default 0)
  - isActive: boolean (default true)
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### ProductImage Model
```
ProductImage:
  - id: UUID (primary key)
  - productId: foreign key -> Product
  - url: string (required)
  - altText: string
  - sortOrder: integer (default 0)
  - isPrimary: boolean (default false)
  - createdAt: timestamp
```

#### ProductVariant Model
```
ProductVariant:
  - id: UUID (primary key)
  - productId: foreign key -> Product
  - name: string (e.g., "Large / Red")
  - sku: string (unique)
  - price: decimal (overrides product price if set)
  - stock: integer (default 0)
  - attributes: JSON { size: "L", color: "Red", ... }
  - isActive: boolean (default true)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### API Endpoints

```
Products:
  GET    /api/products              - List products (paginated, filterable, sortable)
  GET    /api/products/:slug        - Get product by slug (with variants, images, category)
  POST   /api/products              - Create product (admin)
  PUT    /api/products/:id          - Update product (admin)
  DELETE /api/products/:id          - Soft delete / archive product (admin)

Categories:
  GET    /api/categories            - List categories (with hierarchy)
  GET    /api/categories/:slug      - Get category with products
  POST   /api/categories            - Create category (admin)
  PUT    /api/categories/:id        - Update category (admin)
  DELETE /api/categories/:id        - Delete category (admin)

Variants:
  POST   /api/products/:id/variants     - Add variant
  PUT    /api/products/:id/variants/:vid - Update variant
  DELETE /api/products/:id/variants/:vid - Delete variant

Search:
  GET    /api/products/search?q=       - Full-text search
```

### Query Parameters for Product Listing
```
?page=1&limit=20           - Pagination
?sort=price_asc            - Sorting (price_asc, price_desc, name_asc, newest, popular)
?category=category-slug    - Filter by category
?minPrice=10&maxPrice=100  - Price range filter
?status=active             - Status filter (admin only)
?featured=true             - Featured filter
?search=keyword            - Search filter
?tags=tag1,tag2            - Tag filter
```

### Frontend Components

Build these UI components/pages:

1. **Product Listing Page**
   - Grid/list view toggle
   - Filter sidebar (category, price range, tags)
   - Sort dropdown
   - Pagination
   - Product cards with image, name, price, quick-add button

2. **Product Detail Page**
   - Image gallery with thumbnails
   - Product info (name, price, description)
   - Variant selector (size, color dropdowns/buttons)
   - Add to cart button with quantity selector
   - Related products section
   - Breadcrumb navigation

3. **Admin CRUD**
   - Product list with search, filter, bulk actions
   - Product create/edit form with:
     - Basic info fields
     - Rich text editor for description
     - Image upload with drag-and-drop
     - Variant management (add/edit/remove)
     - Category selector
     - SEO fields
   - Category management with drag-and-drop reordering

### Image Handling

- Support image upload to local storage or cloud (S3/Cloudflare R2)
- Generate responsive image sizes (thumbnail: 150x150, medium: 600x600, large: 1200x1200)
- Lazy loading on frontend
- Alt text support for accessibility

### Search Implementation

- Full-text search on product name, description, tags, and SKU
- For PostgreSQL: use `tsvector` and `tsquery`
- For other databases: use LIKE-based search with proper indexing
- Return results with relevance ranking

4. **Framework-specific implementation:**

   **Next.js:** Use App Router, Server Components for listing/detail pages, Server Actions or API routes for mutations, Prisma for ORM, React Server Components for data fetching.

   **Django:** Use Django REST Framework for API, Django ORM for models, Django admin for admin CRUD, django-filter for filtering, django-mptt or django-treebeard for category hierarchy.

   **Express:** Use Express Router, Sequelize or Prisma for ORM, multer for image uploads, express-validator for validation.

5. **Include proper error handling, input validation, and pagination** in all endpoints.

6. **Write the implementation** directly into the project. Follow existing code conventions and patterns found in the codebase.
