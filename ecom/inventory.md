# Build Inventory Management System

Build a complete inventory management system with stock tracking, adjustments, alerts, audit trail, and checkout integration.

## Arguments

$ARGUMENTS - Optional: model name to use for inventory (defaults to "Inventory"). Can also specify framework context.

## Instructions

1. **Parse arguments.** If `$ARGUMENTS` is provided, use it as the primary inventory model name. If empty, default to "Inventory".

2. **Analyze the existing project** to understand the tech stack, database, ORM, existing product/variant models, and code conventions. The inventory system must integrate with existing product models.

3. **Build the following components:**

### Data Models

#### Inventory Model
```
Inventory:
  - id: UUID (primary key)
  - productId: foreign key -> Product
  - variantId: foreign key -> ProductVariant (nullable, for variant-level tracking)
  - sku: string (indexed, matches product/variant SKU)
  - quantityOnHand: integer (current physical stock, default 0)
  - quantityReserved: integer (reserved by unpaid orders, default 0)
  - quantityAvailable: integer (computed: onHand - reserved)
  - reorderPoint: integer (low stock threshold, default 10)
  - reorderQuantity: integer (suggested reorder amount, default 50)
  - warehouseLocation: string (optional, e.g., "A-3-12")
  - backOrderAllowed: boolean (default false)
  - maxBackOrderQuantity: integer (default 0)
  - lastRestockedAt: timestamp (nullable)
  - createdAt: timestamp
  - updatedAt: timestamp

  Constraints:
  - Unique on (productId, variantId) - one inventory record per product/variant
  - quantityOnHand >= 0 (unless backorder allowed)
  - quantityReserved >= 0
```

#### InventoryAdjustment Model (Audit Trail)
```
InventoryAdjustment:
  - id: UUID (primary key)
  - inventoryId: foreign key -> Inventory
  - type: enum (restock, sale, return, adjustment, reservation, release, damaged, transfer)
  - quantityChange: integer (positive for additions, negative for removals)
  - quantityBefore: integer (snapshot before change)
  - quantityAfter: integer (snapshot after change)
  - reason: string (required, human-readable reason)
  - referenceType: string (nullable, e.g., "order", "purchase_order", "manual")
  - referenceId: string (nullable, e.g., order ID)
  - performedBy: foreign key -> User (who made the adjustment)
  - metadata: JSON (additional context)
  - createdAt: timestamp
```

#### StockAlert Model
```
StockAlert:
  - id: UUID (primary key)
  - inventoryId: foreign key -> Inventory
  - type: enum (low_stock, out_of_stock, back_in_stock, overstock)
  - status: enum (active, acknowledged, resolved)
  - message: string
  - acknowledgedBy: foreign key -> User (nullable)
  - acknowledgedAt: timestamp (nullable)
  - resolvedAt: timestamp (nullable)
  - createdAt: timestamp
```

### Stock Operations

Implement these atomic stock operations. Each operation MUST:
- Run inside a database transaction
- Use row-level locking (SELECT FOR UPDATE) to prevent race conditions
- Create an InventoryAdjustment record
- Trigger alerts if thresholds are crossed
- Return the updated inventory state

```
addStock(inventoryId, quantity, reason, performedBy, reference?)
  - Increases quantityOnHand
  - Updates lastRestockedAt
  - Resolves out_of_stock alerts
  - Type: "restock"

removeStock(inventoryId, quantity, reason, performedBy, reference?)
  - Decreases quantityOnHand
  - Validates sufficient available stock (or backorder allowed)
  - Triggers low_stock or out_of_stock alert if threshold crossed
  - Type: "sale" or "damaged" based on reason

reserveStock(inventoryId, quantity, orderId)
  - Increases quantityReserved
  - Validates sufficient available stock
  - Does NOT change quantityOnHand
  - Type: "reservation"
  - Called when order is placed but not yet fulfilled

releaseStock(inventoryId, quantity, orderId)
  - Decreases quantityReserved
  - Does NOT change quantityOnHand
  - Type: "release"
  - Called when order is cancelled before fulfillment

confirmSale(inventoryId, quantity, orderId)
  - Decreases both quantityOnHand and quantityReserved
  - Type: "sale"
  - Called when order is fulfilled/shipped

returnStock(inventoryId, quantity, orderId, reason)
  - Increases quantityOnHand
  - Type: "return"
  - Called when customer returns product

adjustStock(inventoryId, newQuantity, reason, performedBy)
  - Sets quantityOnHand to exact value
  - Records the delta as adjustment
  - Type: "adjustment"
  - Used for inventory counts/corrections
```

### Batch Operations

```
batchAddStock(items: [{ inventoryId, quantity, reason }], performedBy)
  - Add stock to multiple items in a single transaction
  - All-or-nothing: if one fails, all roll back

batchAdjust(items: [{ inventoryId, newQuantity }], reason, performedBy)
  - Bulk inventory count adjustment
  - Used after physical inventory counts

importStock(csvData, performedBy)
  - Parse CSV with columns: sku, quantity, reason
  - Match SKUs to inventory records
  - Apply adjustments in batch
  - Return report of successes and failures
```

### API Endpoints

```
Inventory:
  GET    /api/inventory                      - List all inventory (with filters)
  GET    /api/inventory/:id                  - Get inventory details with recent adjustments
  GET    /api/inventory/product/:productId   - Get inventory for a product (all variants)
  GET    /api/inventory/low-stock            - List items below reorder point
  GET    /api/inventory/out-of-stock         - List out-of-stock items

Stock Operations:
  POST   /api/inventory/:id/add              - Add stock (restock)
  POST   /api/inventory/:id/remove           - Remove stock
  POST   /api/inventory/:id/adjust           - Set exact stock level
  POST   /api/inventory/:id/reserve          - Reserve stock for order
  POST   /api/inventory/:id/release          - Release reserved stock

Batch Operations:
  POST   /api/inventory/batch/add            - Batch restock
  POST   /api/inventory/batch/adjust         - Batch adjustment
  POST   /api/inventory/import               - Import from CSV

Alerts:
  GET    /api/inventory/alerts               - List active alerts
  PUT    /api/inventory/alerts/:id/acknowledge - Acknowledge alert
  PUT    /api/inventory/alerts/:id/resolve   - Resolve alert

History:
  GET    /api/inventory/:id/history          - Get adjustment history (paginated)
  GET    /api/inventory/history              - Global adjustment history (admin, filterable)

Query Parameters:
  ?page=1&limit=50                           - Pagination
  ?sort=quantityAvailable_asc               - Sorting
  ?belowReorderPoint=true                   - Filter low stock
  ?search=SKU-001                           - Search by SKU or product name
  ?dateFrom=2026-01-01&dateTo=2026-03-14    - Date range for history
```

### Low Stock Alerts

```
Alert Triggers:
  - LOW_STOCK: quantityAvailable <= reorderPoint AND quantityAvailable > 0
  - OUT_OF_STOCK: quantityAvailable <= 0 AND NOT backOrderAllowed
  - BACK_IN_STOCK: was out of stock, now quantityAvailable > 0
  - OVERSTOCK: quantityOnHand > reorderQuantity * 3 (configurable threshold)

Alert Delivery:
  - Create StockAlert record in database
  - Send email notification to admin/inventory manager
  - Optionally send webhook/Slack notification
  - Dashboard widget showing active alerts
```

### Checkout Integration

Integrate inventory checks into the checkout flow:

```
At Add to Cart:
  - Check quantityAvailable >= requested quantity
  - If out of stock and backorder not allowed: reject with clear message
  - If out of stock and backorder allowed: allow but show backorder notice
  - Show "Only X left in stock" warning if quantity is low

At Checkout Validation:
  - Re-validate stock for all cart items
  - Reserve stock for the order (reserveStock)
  - If any item insufficient: remove from cart or reduce quantity, notify user

On Payment Success:
  - Stock already reserved, no additional check needed
  - confirmSale to deduct from physical stock

On Order Cancellation:
  - releaseStock for all order items
  - Re-check if items were on backorder waitlist

On Payment Failure/Timeout:
  - releaseStock for all reserved items
  - Set timeout for automatic release (e.g., 30 minutes)
```

### Back-Order Support

```
When backorder is allowed:
  - Allow orders even when quantityAvailable <= 0
  - Track back-ordered quantity separately
  - Notify customer that item is on backorder
  - When stock arrives (addStock):
    - Automatically allocate to oldest backorders first
    - Notify customers their backorder is being fulfilled
  - Show estimated restock date (if available)
```

### Variant-Level Inventory

```
Inventory tracking at variant level:
  - Each ProductVariant gets its own Inventory record
  - Product-level stock = SUM of all variant stocks
  - Variant selector on frontend shows stock per variant
  - "Size M - In Stock" / "Size L - 2 left" / "Size XL - Out of Stock"
```

### Implementation Order

1. Create database models and migrations
2. Implement core stock operations with transactions and locking
3. Add audit trail (InventoryAdjustment creation in every operation)
4. Implement low stock alert system
5. Build API endpoints
6. Integrate with checkout flow (reserve/release/confirm)
7. Add batch operations and CSV import
8. Build admin UI for inventory management
9. Add back-order support
10. Write tests for race conditions and edge cases

4. **Write the implementation** directly into the project. Follow existing code conventions and patterns.

5. **Pay special attention to concurrency.** Inventory operations MUST use database-level locking to prevent overselling. Test with concurrent requests.
