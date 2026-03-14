# Build Subscription Billing System

Build a complete subscription billing system with plan management, Stripe integration, customer self-service portal, and dunning for failed payments.

## Arguments

$ARGUMENTS - The billing provider: `stripe` (currently the only supported provider)

## Instructions

1. **Validate the provider argument.** `$ARGUMENTS` should be `stripe`. If not provided, default to `stripe`.

2. **Analyze the existing project** to understand the tech stack, database, ORM, existing user model, and code conventions. Adapt the implementation to match.

3. **Build the following components:**

### Data Models

#### Plan Model
```
Plan:
  - id: UUID (primary key)
  - name: string (e.g., "Pro", "Enterprise")
  - slug: string (unique)
  - description: text
  - stripePriceId: string (Stripe Price ID)
  - stripeProductId: string (Stripe Product ID)
  - price: decimal (display price, source of truth is Stripe)
  - currency: string (default "USD")
  - interval: enum (monthly, yearly)
  - intervalCount: integer (default 1)
  - trialDays: integer (default 0, 0 = no trial)
  - features: JSON (list of feature descriptions)
  - limits: JSON (e.g., { maxUsers: 5, maxStorage: "10GB", maxProjects: 10 })
  - isActive: boolean (default true)
  - sortOrder: integer (for display ordering)
  - metadata: JSON
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### Subscription Model
```
Subscription:
  - id: UUID (primary key)
  - userId: foreign key -> User
  - planId: foreign key -> Plan
  - stripeSubscriptionId: string (unique)
  - stripeCustomerId: string
  - status: enum (trialing, active, past_due, canceled, unpaid, incomplete, paused)
  - currentPeriodStart: timestamp
  - currentPeriodEnd: timestamp
  - trialStart: timestamp (nullable)
  - trialEnd: timestamp (nullable)
  - cancelAtPeriodEnd: boolean (default false)
  - canceledAt: timestamp (nullable)
  - endedAt: timestamp (nullable)
  - metadata: JSON
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### SubscriptionEvent Model (Audit Trail)
```
SubscriptionEvent:
  - id: UUID (primary key)
  - subscriptionId: foreign key -> Subscription
  - userId: foreign key -> User
  - type: enum (created, activated, trial_started, trial_ended, upgraded, downgraded,
               canceled, reactivated, past_due, payment_failed, payment_succeeded,
               renewed, paused, resumed)
  - fromPlanId: foreign key -> Plan (nullable)
  - toPlanId: foreign key -> Plan (nullable)
  - metadata: JSON (e.g., { reason: "too expensive", feedback: "..." })
  - createdAt: timestamp
```

#### Usage Model (for Metered Billing)
```
UsageRecord:
  - id: UUID (primary key)
  - subscriptionId: foreign key -> Subscription
  - userId: foreign key -> User
  - metric: string (e.g., "api_calls", "storage_bytes", "team_members")
  - quantity: integer
  - recordedAt: timestamp
  - stripeUsageRecordId: string (nullable)
  - createdAt: timestamp
```

### Stripe Integration

#### Setup
```
Environment Variables:
  - STRIPE_SECRET_KEY
  - STRIPE_PUBLISHABLE_KEY
  - STRIPE_WEBHOOK_SECRET
  - STRIPE_CUSTOMER_PORTAL_URL (auto-configured)

Stripe Objects to Create/Manage:
  - Products (one per plan)
  - Prices (one per plan + interval combination)
  - Customers (one per user)
  - Subscriptions
  - Checkout Sessions (for new subscriptions)
  - Customer Portal Sessions (for self-service management)
  - Usage Records (for metered billing)
```

#### Checkout Session Flow
```
1. User selects a plan on pricing page
2. Backend creates Stripe Checkout Session:
   - mode: "subscription"
   - customer: stripeCustomerId (create if needed)
   - line_items: [{ price: stripePriceId, quantity: 1 }]
   - subscription_data.trial_period_days (if plan has trial)
   - success_url with {CHECKOUT_SESSION_ID}
   - cancel_url
   - metadata: { userId, planId }
3. Redirect user to Stripe Checkout
4. On success, webhook handles subscription creation
```

#### Customer Portal
```
1. User clicks "Manage Subscription" in account settings
2. Backend creates Stripe Customer Portal Session:
   - customer: stripeCustomerId
   - return_url: account settings page
3. Redirect to Stripe Customer Portal
4. User can: update payment method, cancel, view invoices
5. Changes sync back via webhooks
```

### API Endpoints

```
Plans:
  GET    /api/plans                      - List active plans with features

Subscriptions:
  GET    /api/subscription               - Get current user's subscription
  POST   /api/subscription/checkout      - Create Stripe Checkout Session
  POST   /api/subscription/portal        - Create Stripe Customer Portal Session
  POST   /api/subscription/cancel        - Cancel at period end
  POST   /api/subscription/reactivate    - Reactivate canceled subscription
  POST   /api/subscription/change-plan   - Upgrade or downgrade plan

Usage (for metered billing):
  POST   /api/subscription/usage         - Record usage
  GET    /api/subscription/usage         - Get current period usage

Admin:
  GET    /api/admin/subscriptions        - List all subscriptions (filterable)
  GET    /api/admin/subscriptions/metrics - MRR, churn, trial conversion stats
  PUT    /api/admin/plans/:id            - Update plan (syncs to Stripe)

Webhooks:
  POST   /api/webhooks/stripe            - Stripe webhook handler
```

### Webhook Handler

Handle these Stripe events:

```
customer.subscription.created       -> Create local Subscription record
customer.subscription.updated       -> Update status, period dates, plan changes
customer.subscription.deleted       -> Mark subscription as ended
customer.subscription.trial_will_end -> Send trial ending email (3 days before)

invoice.payment_succeeded           -> Update payment status, log event
invoice.payment_failed              -> Start dunning flow, notify user
invoice.finalized                   -> Store invoice reference

checkout.session.completed          -> Finalize subscription creation

customer.updated                    -> Sync customer data
```

**Webhook security:**
- Verify Stripe signature on every webhook
- Process idempotently (check event ID against processed events)
- Return 200 quickly, process asynchronously if needed
- Log all webhook events for debugging

### Upgrade/Downgrade Logic

```
Upgrade (moving to higher-priced plan):
  - Prorate immediately (charge difference for remaining period)
  - Switch plan effective immediately
  - Use Stripe's proration_behavior: "create_prorations"
  - Log SubscriptionEvent (type: "upgraded")

Downgrade (moving to lower-priced plan):
  - Apply at end of current billing period
  - Use Stripe's proration_behavior: "none" with billing_cycle_anchor: "unchanged"
  - Or offer immediate switch with prorated credit
  - Log SubscriptionEvent (type: "downgraded")

Plan Comparison:
  - Compare plan prices to determine upgrade vs downgrade
  - Show price difference to user before confirming
  - Handle currency and interval differences
```

### Trial Support

```
Trial Flow:
  1. User signs up and selects a plan with trial
  2. Checkout Session created with trial_period_days
  3. Subscription starts in "trialing" status
  4. No charge during trial period
  5. 3 days before trial ends: send reminder email
  6. Trial ends: auto-converts to paid (if payment method on file)
  7. If no payment method: subscription becomes "incomplete"

Implementation:
  - Set trial_period_days on Checkout Session
  - Track trial dates in local Subscription model
  - Handle customer.subscription.trial_will_end webhook
  - Handle transition from trialing -> active or trialing -> incomplete
```

### Cancellation Flow with Retention

```
Cancellation Steps:
  1. User clicks "Cancel Subscription"
  2. Show cancellation survey:
     - Reason selection (too expensive, not using, missing features, switching, other)
     - Optional feedback text
  3. Offer retention incentives based on reason:
     - "Too expensive" -> Offer discount or downgrade
     - "Not using" -> Offer pause instead of cancel
     - "Missing features" -> Collect feature request, offer timeline
  4. If user confirms cancellation:
     - Set cancel_at_period_end = true (access continues until period end)
     - Do NOT cancel immediately (let them use remaining paid time)
     - Log SubscriptionEvent with reason and feedback
     - Send cancellation confirmation email
  5. At period end: Stripe cancels, webhook updates local status

Reactivation:
  - Before period end: user can reactivate (remove cancel_at_period_end)
  - After period end: user must create new subscription
```

### Dunning (Failed Payment Handling)

```
Failed Payment Flow:
  1. invoice.payment_failed webhook received
  2. Update subscription status to "past_due"
  3. Send email: "Payment failed, please update your payment method"
     - Include link to Stripe Customer Portal
  4. Stripe auto-retries (configure Smart Retries in Stripe Dashboard):
     - Retry 1: 3 days after failure
     - Retry 2: 5 days after first retry
     - Retry 3: 7 days after second retry
  5. If all retries fail:
     - Send final warning email
     - Optionally restrict access (read-only mode)
     - After grace period: cancel subscription
  6. If payment succeeds on retry:
     - Update status back to "active"
     - Send "payment successful" email

Grace Period:
  - Define grace period (e.g., 14 days from first failure)
  - During grace period: user retains access but sees warning banner
  - After grace period: downgrade to free tier or lock account
```

### Frontend Components

1. **Pricing Page**
   - Plan comparison cards/table
   - Feature comparison matrix
   - Monthly/yearly toggle (with savings highlight)
   - CTA buttons per plan
   - Current plan indicator (if logged in)

2. **Account/Subscription Page**
   - Current plan details
   - Billing period and next payment date
   - Usage metrics (if metered)
   - "Change Plan" button -> plan comparison with upgrade/downgrade indication
   - "Manage Payment Method" -> Stripe Customer Portal
   - "Cancel Subscription" -> cancellation flow
   - Invoice history

3. **Cancellation Modal/Page**
   - Reason survey
   - Retention offer
   - Confirmation with end-date info

4. **Payment Warning Banner**
   - Shown when subscription is past_due
   - Link to update payment method
   - Days remaining in grace period

### Feature Gating

Implement a subscription check utility:

```
// Check if user has access to a feature
canAccess(user, feature) -> boolean

// Check if user is within plan limits
checkLimit(user, metric, currentUsage) -> { allowed: boolean, limit: number, used: number }

// Middleware to protect routes by plan
requirePlan(minimumPlan) -> middleware
```

### Implementation Order

1. Create database models and migrations
2. Set up Stripe SDK and environment variables
3. Create plan seeding script (sync plans to Stripe)
4. Implement Checkout Session creation
5. Build webhook handler (start with subscription events)
6. Implement subscription status tracking
7. Build Customer Portal integration
8. Add upgrade/downgrade logic
9. Implement trial support
10. Build cancellation flow with retention
11. Add dunning/failed payment handling
12. Build frontend components (pricing page, account page)
13. Add feature gating middleware
14. Write tests for critical paths

4. **Write the implementation** directly into the project. Follow existing code conventions and patterns.
