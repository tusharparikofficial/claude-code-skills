# Generate Project Estimate

Generate a detailed project estimate with hour breakdowns, cost analysis, and contingency buffer.

## Arguments

$ARGUMENTS - Project requirements to estimate (e.g., "multi-vendor marketplace with seller dashboard, buyer accounts, product listings, reviews, and Stripe payouts")

## Instructions

1. **Parse the requirements** from `$ARGUMENTS`. Identify all features, integrations, and technical challenges.

2. **Break down into estimable units.** Decompose each requirement into discrete tasks that can be estimated individually.

3. **Generate the estimate** with the following structure:

### Output Structure

```markdown
# Project Estimate: [Project Name]

**Date:** [Current Date]
**Valid for:** 30 days

---

## Requirements Summary

Bullet-point summary of all identified requirements from the input.

## Phase Breakdown

### Phase 1: Discovery & Planning
| Task | Optimistic | Expected | Pessimistic |
|------|-----------|----------|-------------|
| Requirements analysis | Xh | Xh | Xh |
| Technical architecture | Xh | Xh | Xh |
| Database schema design | Xh | Xh | Xh |
| API contract design | Xh | Xh | Xh |
| Project plan & sprint setup | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |

### Phase 2: Design
| Task | Optimistic | Expected | Pessimistic |
|------|-----------|----------|-------------|
| Wireframes & user flows | Xh | Xh | Xh |
| UI design (key screens) | Xh | Xh | Xh |
| Design system / components | Xh | Xh | Xh |
| Responsive design specs | Xh | Xh | Xh |
| Design review & iteration | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |

### Phase 3: Development
| Feature | Optimistic | Expected | Pessimistic |
|---------|-----------|----------|-------------|
| [Feature 1] | Xh | Xh | Xh |
| [Feature 2] | Xh | Xh | Xh |
| [Feature N] | Xh | Xh | Xh |
| Authentication & authorization | Xh | Xh | Xh |
| API development | Xh | Xh | Xh |
| Database implementation | Xh | Xh | Xh |
| Third-party integrations | Xh | Xh | Xh |
| Admin panel | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |

### Phase 4: Testing & QA
| Task | Optimistic | Expected | Pessimistic |
|------|-----------|----------|-------------|
| Unit tests | Xh | Xh | Xh |
| Integration tests | Xh | Xh | Xh |
| E2E tests | Xh | Xh | Xh |
| Performance testing | Xh | Xh | Xh |
| Security testing | Xh | Xh | Xh |
| Bug fixes | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |

### Phase 5: Launch & Deployment
| Task | Optimistic | Expected | Pessimistic |
|------|-----------|----------|-------------|
| CI/CD pipeline setup | Xh | Xh | Xh |
| Staging deployment | Xh | Xh | Xh |
| Production deployment | Xh | Xh | Xh |
| Monitoring & alerts setup | Xh | Xh | Xh |
| Documentation | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |

---

## Hours Summary

| Phase | Optimistic | Expected | Pessimistic |
|-------|-----------|----------|-------------|
| Discovery & Planning | Xh | Xh | Xh |
| Design | Xh | Xh | Xh |
| Development | Xh | Xh | Xh |
| Testing & QA | Xh | Xh | Xh |
| Launch & Deployment | Xh | Xh | Xh |
| **Subtotal** | **Xh** | **Xh** | **Xh** |
| Contingency (20%) | Xh | Xh | Xh |
| **Grand Total** | **Xh** | **Xh** | **Xh** |

## Cost Estimate

### Development Costs
| Scenario | Hours | Rate | Total |
|----------|-------|------|-------|
| Optimistic | Xh | $XXX/hr | $XX,XXX |
| Expected | Xh | $XXX/hr | $XX,XXX |
| Pessimistic | Xh | $XXX/hr | $XX,XXX |

### Infrastructure Costs (Monthly)
| Service | Provider | Est. Cost |
|---------|----------|-----------|
| Hosting / Compute | [e.g., Vercel, AWS, Railway] | $XXX/mo |
| Database | [e.g., Supabase, RDS, PlanetScale] | $XXX/mo |
| File storage / CDN | [e.g., S3, Cloudflare R2] | $XXX/mo |
| Email service | [e.g., Resend, SendGrid] | $XXX/mo |
| Monitoring | [e.g., Sentry, Datadog] | $XXX/mo |
| **Monthly Total** | | **$XXX/mo** |

### Third-Party Service Costs
| Service | Purpose | Pricing Model | Est. Cost |
|---------|---------|---------------|-----------|
| [e.g., Stripe] | Payments | X% per transaction | Variable |
| [e.g., Auth0] | Authentication | Per MAU | $XXX/mo |
| [e.g., Algolia] | Search | Per request | $XXX/mo |

## Contingency Notes

- **20% contingency buffer** applied to account for:
  - Unforeseen technical complexity
  - Scope clarification and minor adjustments
  - Third-party API quirks or undocumented behavior
  - Cross-browser/device compatibility issues
- Contingency does NOT cover:
  - Major scope changes (handled via change request)
  - New feature requests not in original requirements
  - Client-side delays causing rework

## Assumptions
- [List key assumptions that affect the estimate]
```

4. **Use three-point estimation** (optimistic/expected/pessimistic) for every line item. The pessimistic estimate should be roughly 1.5-2x the optimistic estimate.

5. **Always include a 20% contingency buffer** on top of the expected hours.

6. **Be specific to the requirements.** Every feature mentioned in the input should appear as a line item in the Development phase. Do not use generic placeholders.

7. **Output the complete estimate** as formatted Markdown directly to the user.
