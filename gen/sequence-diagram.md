# Sequence Diagram Generator

Generate a sequence diagram from code flow analysis, tracing execution from an entry point through all layers.

## Arguments

$ARGUMENTS - Required entry point to trace. Examples: `POST /api/orders`, `createOrder function`, `UserService.register`, `handlePaymentWebhook`. Can be an API route, function name, class method, or event handler.

## Instructions

You are generating a sequence diagram by tracing the execution flow from a specific entry point through all application layers. Follow these steps precisely.

### Step 1: Validate Entry Point

Parse `$ARGUMENTS` to identify the entry point. It could be:
- **API route**: `GET /api/users`, `POST /api/orders` — find the route handler
- **Function name**: `createOrder`, `processPayment` — find the function definition
- **Class method**: `UserService.register`, `OrderController.create` — find the class and method
- **Event handler**: `onOrderCreated`, `handleWebhook` — find the event listener/handler
- **CLI command**: `sync-users`, `migrate` — find the command handler

If the entry point cannot be found, report similar matches and ask for clarification.

### Step 2: Trace Execution Flow

Starting from the entry point, trace the complete execution path by reading the actual code. For each step, record:

1. **Caller**: Which component/actor initiates
2. **Callee**: Which component/actor receives
3. **Action**: What operation is performed (function name, query, HTTP call)
4. **Return value**: What is returned
5. **Conditions**: Any if/else, switch, or guard clauses
6. **Loops**: Any iteration over collections
7. **Error paths**: try/catch, error returns, exception handling

#### Layers to trace through:
1. **Entry point**: Route handler, controller method, command handler
2. **Middleware/Interceptors**: Authentication, authorization, validation, rate limiting, logging
3. **Controller/Handler**: Request parsing, input validation, response formatting
4. **Service layer**: Business logic, orchestration, domain rules
5. **Repository/Data access**: Database queries (specify the actual query or ORM call)
6. **External API calls**: HTTP requests to third-party services (specify URL patterns, payloads)
7. **Event emissions**: Published events, queue messages, webhooks fired
8. **Cache interactions**: Cache reads (hit/miss), cache writes, invalidation
9. **Response construction**: Status code, response body shape, headers

### Step 3: Generate Mermaid Sequence Diagram — Happy Path

Generate a Mermaid `sequenceDiagram` showing the successful execution flow.

Follow these conventions:
- **Participants** declared at the top with descriptive aliases:
  ```
  participant C as Client
  participant MW as Middleware
  participant API as API Controller
  participant SVC as OrderService
  participant DB as PostgreSQL
  participant EXT as Stripe API
  participant Q as EventQueue
  ```
- **Solid arrows** (`->>`) for synchronous calls
- **Dashed arrows** (`-->>`) for responses/returns
- **Dotted arrows** (`--)`) for async/fire-and-forget messages
- **Activation bars**: Use `activate`/`deactivate` to show when a component is processing
- **Notes**: Use `Note over` or `Note right of` for important context (e.g., "JWT validated", "Cache HIT")
- **Alt blocks**: For conditional branches
  ```
  alt condition
      ...
  else other condition
      ...
  end
  ```
- **Opt blocks**: For optional steps
  ```
  opt if cache miss
      ...
  end
  ```
- **Loop blocks**: For iterations
  ```
  loop for each item in cart
      ...
  end
  ```
- **Labels on arrows**: Describe the action concisely — include function names, HTTP methods, query descriptions
- **Return values**: Show what is returned on dashed arrows (e.g., `-->> C: 201 Created { orderId }`)

### Step 4: Generate Mermaid Sequence Diagram — Error Path

Generate a separate sequence diagram showing the primary error/failure path. Include:
- Validation failures (400 Bad Request)
- Authentication/authorization failures (401/403)
- Resource not found (404)
- Business rule violations (422)
- External service failures (502/503)
- Database errors (500)
- Timeout scenarios

Use the `alt` block to show where the flow diverges from the happy path:
```
alt valid input
    SVC ->> DB: INSERT order
    DB -->> SVC: order record
else invalid input
    SVC -->> API: ValidationError
    API -->> C: 400 { errors: [...] }
end
```

### Step 5: Generate Flow Summary

After the diagrams, produce a structured summary:

```markdown
## Flow Summary: <entry-point>

### Happy Path
1. **Client** sends `POST /api/orders` with `{ items, paymentMethod }`
2. **Auth Middleware** validates JWT token, extracts userId
3. **Validation Middleware** validates request body against OrderSchema
4. **OrderService.create()** orchestrates:
   a. Fetches product prices from DB
   b. Calculates totals with tax
   c. Charges payment via Stripe API
   d. Creates order record in DB
   e. Emits `order.created` event to queue
5. **Response**: `201 Created` with `{ orderId, total, status }`

### Error Scenarios
| Scenario | Where it fails | Status | Response |
|----------|---------------|--------|----------|
| Invalid token | Auth Middleware | 401 | `{ error: "Unauthorized" }` |
| Missing fields | Validation | 400 | `{ errors: [...] }` |
| Payment declined | Stripe API call | 422 | `{ error: "Payment failed" }` |
| DB write fails | OrderService → DB | 500 | `{ error: "Internal error" }` |

### Side Effects
- Event `order.created` published to `orders` queue
- Cache key `user:{id}:orders` invalidated
- Audit log entry created

### Performance Notes
- Estimated DB queries: N
- External API calls: N
- Async operations: N
```

### Step 6: Output

Present in this order:
1. Entry point identified (file path, line number)
2. Happy path sequence diagram (Mermaid code block)
3. Error path sequence diagram (Mermaid code block)
4. Flow summary with table of error scenarios
5. Side effects and performance notes
6. Any assumptions made during tracing (e.g., "assumed standard auth middleware is applied based on route group")

Do NOT save to a file unless the user explicitly asks. Output everything directly in the response.

### Guidelines

- Trace ACTUAL code, not hypothetical flows. Read the source files and follow the call chain.
- If a function calls another function in a different file, follow it. Do not stop at service boundaries.
- Include the actual database queries or ORM method calls (e.g., `prisma.order.create(...)`, `SELECT * FROM orders WHERE...`)
- For external API calls, include the HTTP method and endpoint (e.g., `POST https://api.stripe.com/v1/charges`)
- Keep participant count manageable — collapse internal helper functions into their parent service participant
- If the flow is extremely complex (>50 interactions), split into sub-diagrams by phase (e.g., "Authentication", "Processing", "Fulfillment")
