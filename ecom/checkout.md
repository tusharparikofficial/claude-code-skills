# Build Checkout Flow

Build a complete checkout flow with cart management, payment integration, order processing, and email notifications.

## Arguments

$ARGUMENTS - The payment provider to integrate: `stripe` or `razorpay`

## Instructions

1. **Validate the payment provider argument.** `$ARGUMENTS` must be one of: `stripe` or `razorpay`. If not provided or invalid, ask the user to specify.

2. **Analyze the existing project** to understand the tech stack, database, ORM, existing product/user models, and code conventions. Adapt the implementation to match.

3. **Build the following components:**

### Cart System

#### Cart Data Model
```
Cart:
  - id: UUID (primary key)
  - userId: foreign key -> User (nullable for guest carts)
  - sessionId: string (for guest carts)
  - status: enum (active, converted, abandoned)
  - expiresAt: timestamp (for guest carts, e.g., 7 days)
  - createdAt: timestamp
  - updatedAt: timestamp

CartItem:
  - id: UUID (primary key)
  - cartId: foreign key -> Cart
  - productId: foreign key -> Product
  - variantId: foreign key -> ProductVariant (nullable)
  - quantity: integer (min 1)
  - unitPrice: decimal (price at time of adding)
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### Cart API Endpoints
```
POST   /api/cart/items              - Add item to cart
PUT    /api/cart/items/:id          - Update item quantity
DELETE /api/cart/items/:id          - Remove item from cart
GET    /api/cart                    - Get current cart with items
DELETE /api/cart                    - Clear cart
POST   /api/cart/merge              - Merge guest cart into user cart (on login)
```

#### Cart Business Logic
- Validate stock availability before adding/updating items
- Recalculate totals on every cart modification
- Lock prices at time of adding to cart (store unitPrice on CartItem)
- Support guest carts (identified by session/cookie) and authenticated carts
- Merge guest cart into user cart on login
- Persist cart server-side (not just in localStorage)
- Cart expiration for abandoned guest carts

### Order System

#### Order Data Model
```
Order:
  - id: UUID (primary key)
  - orderNumber: string (unique, human-readable, e.g., "ORD-20260314-XXXX")
  - userId: foreign key -> User
  - status: enum (pending, confirmed, processing, shipped, delivered, cancelled, refunded)
  - paymentStatus: enum (pending, paid, failed, refunded, partially_refunded)
  - paymentProvider: string (stripe/razorpay)
  - paymentIntentId: string (provider's payment ID)
  - subtotal: decimal
  - tax: decimal
  - shippingCost: decimal
  - discount: decimal (default 0)
  - total: decimal
  - currency: string (default "USD")
  - shippingAddress: JSON { name, line1, line2, city, state, postalCode, country, phone }
  - billingAddress: JSON { name, line1, line2, city, state, postalCode, country }
  - notes: text (optional customer notes)
  - metadata: JSON (flexible data)
  - createdAt: timestamp
  - updatedAt: timestamp

OrderItem:
  - id: UUID (primary key)
  - orderId: foreign key -> Order
  - productId: foreign key -> Product
  - variantId: foreign key -> ProductVariant (nullable)
  - productName: string (snapshot at order time)
  - variantName: string (snapshot at order time)
  - sku: string (snapshot at order time)
  - quantity: integer
  - unitPrice: decimal
  - total: decimal
  - createdAt: timestamp
```

#### Order API Endpoints
```
POST   /api/orders                  - Create order from cart (initiates checkout)
GET    /api/orders                  - List user's orders
GET    /api/orders/:id              - Get order details
PUT    /api/orders/:id/cancel       - Cancel order (if cancellable)

Admin:
GET    /api/admin/orders            - List all orders (filterable by status)
PUT    /api/admin/orders/:id/status - Update order status
```

### Checkout Flow

#### Checkout Page Components
1. **Cart Summary** - Review items, quantities, prices
2. **Shipping Address Form** - Name, address fields with validation
3. **Shipping Method Selection** - If applicable
4. **Payment Section** - Provider-specific payment form
5. **Order Summary Sidebar** - Subtotal, tax, shipping, discount, total
6. **Place Order Button** - Triggers payment and order creation

#### Checkout API
```
POST   /api/checkout/validate       - Validate cart and shipping before payment
POST   /api/checkout/create-session  - Create payment session (Stripe/Razorpay)
POST   /api/checkout/confirm        - Confirm order after successful payment
POST   /api/webhooks/payment        - Payment provider webhook handler
```

### Payment Integration

#### Stripe Implementation
```
1. Create Checkout Session or Payment Intent:
   - Use Stripe Checkout for hosted payment page, OR
   - Use Payment Intents API + Stripe Elements for embedded form
   - Include line items with prices
   - Set success and cancel URLs
   - Include metadata (orderId, userId)

2. Webhook Handler (/api/webhooks/stripe):
   - Verify webhook signature using STRIPE_WEBHOOK_SECRET
   - Handle events:
     - checkout.session.completed -> Confirm order, update payment status
     - payment_intent.succeeded -> Mark payment as paid
     - payment_intent.payment_failed -> Mark payment as failed
     - charge.refunded -> Update order status to refunded
   - Idempotent processing (check if already handled)

3. Environment Variables:
   - STRIPE_SECRET_KEY
   - STRIPE_PUBLISHABLE_KEY
   - STRIPE_WEBHOOK_SECRET
```

#### Razorpay Implementation
```
1. Create Razorpay Order:
   - POST to Razorpay Orders API
   - Amount in smallest currency unit (paise for INR)
   - Include receipt (order number) and notes

2. Frontend Integration:
   - Load Razorpay checkout.js
   - Open Razorpay payment modal with order_id
   - Handle success callback (razorpay_payment_id, razorpay_order_id, razorpay_signature)

3. Payment Verification:
   - Verify signature: HMAC-SHA256(order_id + "|" + payment_id, secret)
   - Confirm order on successful verification

4. Webhook Handler (/api/webhooks/razorpay):
   - Verify webhook signature
   - Handle events: payment.captured, payment.failed, refund.processed

5. Environment Variables:
   - RAZORPAY_KEY_ID
   - RAZORPAY_KEY_SECRET
   - RAZORPAY_WEBHOOK_SECRET
```

### Edge Cases to Handle

- **Failed payment**: Show clear error message, allow retry, do not create order
- **Duplicate orders**: Use idempotency keys; check for existing orders with same payment intent
- **Stock validation**: Re-validate stock at checkout time, not just cart time
- **Race conditions**: Use database transactions for stock decrement + order creation
- **Webhook retries**: Make webhook handler idempotent (check if order already processed)
- **Partial payment**: Handle cases where payment amount does not match order total
- **Cart expiry**: Handle case where cart items become unavailable during checkout
- **Price changes**: Compare cart prices with current prices at checkout time

### Email Notifications

Send emails at these events (use the project's existing email service or set up a new one):

1. **Order Confirmation** - Sent after successful payment
   - Order number, items, totals, shipping address
   - Estimated delivery (if applicable)

2. **Order Shipped** - Sent when status changes to "shipped"
   - Tracking number and carrier link
   - Order summary

3. **Payment Failed** - Sent on payment failure
   - What went wrong (generic, no sensitive details)
   - Link to retry payment

4. **Order Cancelled** - Sent on cancellation
   - Refund details and timeline

5. **Refund Processed** - Sent when refund is complete
   - Refund amount and method

### Implementation Order

Follow this sequence:
1. Create database models and migrations
2. Implement cart API endpoints with stock validation
3. Implement order model and creation logic
4. Integrate payment provider (Stripe or Razorpay)
5. Build webhook handler with signature verification
6. Build checkout page UI
7. Add email notification triggers
8. Write tests for critical paths (payment, stock validation, webhooks)

4. **Write the implementation** directly into the project. Follow existing code conventions and patterns.

5. **Include comprehensive error handling** at every step of the checkout flow. Payment flows must never silently fail.
