# Generate Launch Checklist

Generate a comprehensive pre-launch checklist by analyzing the project and verifying readiness across all critical areas.

## Arguments

$ARGUMENTS - Optional: specific areas to focus on or project URL

## Instructions

1. **Analyze the project** to understand the tech stack, deployment setup, and what checks are relevant. Look at package.json, framework configs, deployment files, etc.

2. **Generate a comprehensive launch checklist** customized to the project. Check off items that can be verified programmatically; leave unchecked items that need manual verification.

3. **Attempt to verify items automatically** where possible:
   - Check for SSL configuration in deployment configs
   - Look for sitemap.xml, robots.txt in public directories
   - Check for error monitoring setup (Sentry DSN in env/config)
   - Look for analytics setup (GA, Plausible, etc.)
   - Check security headers in server/middleware config
   - Look for rate limiting middleware
   - Check for CORS configuration
   - Verify meta tags in HTML templates/layouts

### Output Structure

```markdown
# Launch Checklist: [Project Name]

**Target Launch Date:** [TBD]
**Generated:** [Current Date]

---

## SSL & Domain

- [ ] SSL certificate installed and valid
- [ ] HTTP to HTTPS redirect configured
- [ ] www to non-www (or vice versa) redirect configured
- [ ] DNS records propagated and verified
- [ ] Domain ownership verified
- [ ] HSTS header enabled
- [ ] Certificate auto-renewal configured

## Error Monitoring

- [ ] Error tracking service configured (e.g., Sentry)
- [ ] Source maps uploaded for frontend error tracking
- [ ] Alert notifications configured (email/Slack)
- [ ] Error grouping and filtering set up
- [ ] Unhandled exception handlers in place
- [ ] Server-side error logging configured
- [ ] Error rate alerting thresholds defined

## Uptime & Performance Monitoring

- [ ] Uptime monitoring configured (e.g., UptimeRobot, Better Stack)
- [ ] Health check endpoint implemented (`/health` or `/api/health`)
- [ ] Response time monitoring enabled
- [ ] Downtime alert notifications configured
- [ ] Status page set up (optional but recommended)
- [ ] Performance budgets defined

## Backup & Recovery

- [ ] Database backup system configured
- [ ] Backup schedule verified (daily minimum)
- [ ] Backup restoration tested
- [ ] Point-in-time recovery available
- [ ] Disaster recovery plan documented
- [ ] File/media backup configured (if applicable)
- [ ] Backup retention policy defined

## Analytics

- [ ] Analytics service installed (e.g., Google Analytics, Plausible, PostHog)
- [ ] Tracking code on all pages
- [ ] Goal/conversion tracking configured
- [ ] Cookie consent banner (if required by jurisdiction)
- [ ] UTM parameter handling verified
- [ ] 404 page tracking

## SEO

- [ ] `sitemap.xml` generated and accessible
- [ ] `robots.txt` configured correctly
- [ ] Meta titles on all pages (50-60 characters)
- [ ] Meta descriptions on all pages (150-160 characters)
- [ ] Open Graph tags for social sharing
- [ ] Twitter Card meta tags
- [ ] Canonical URLs set
- [ ] Structured data / JSON-LD (where applicable)
- [ ] Heading hierarchy correct (single H1 per page)
- [ ] Image alt text on all images
- [ ] Clean URL structure (no query params for content pages)
- [ ] 301 redirects for any changed URLs
- [ ] Google Search Console verified
- [ ] Favicon and app icons configured

## Performance

- [ ] Core Web Vitals passing (LCP < 2.5s, FID < 100ms, CLS < 0.1)
- [ ] Images optimized (WebP/AVIF, lazy loading, responsive sizes)
- [ ] CSS and JS minified and bundled
- [ ] Gzip/Brotli compression enabled
- [ ] CDN configured for static assets
- [ ] Font loading optimized (font-display: swap)
- [ ] Critical CSS inlined (above the fold)
- [ ] No render-blocking resources
- [ ] Database queries optimized (no N+1, proper indexes)
- [ ] API response times acceptable (< 200ms p95)
- [ ] Lighthouse score > 90 for Performance
- [ ] Bundle size analyzed and acceptable

## Security

- [ ] Security headers configured:
  - [ ] `Content-Security-Policy`
  - [ ] `X-Content-Type-Options: nosniff`
  - [ ] `X-Frame-Options: DENY` or `SAMEORIGIN`
  - [ ] `X-XSS-Protection: 0` (rely on CSP instead)
  - [ ] `Referrer-Policy: strict-origin-when-cross-origin`
  - [ ] `Permissions-Policy` (camera, microphone, geolocation)
- [ ] CORS properly configured (not wildcard `*` in production)
- [ ] Rate limiting on API endpoints
- [ ] Rate limiting on authentication endpoints (stricter)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding, CSP)
- [ ] CSRF protection enabled
- [ ] Authentication system tested
- [ ] Password requirements enforced
- [ ] Session management secure (httpOnly, secure, sameSite cookies)
- [ ] API keys and secrets in environment variables (not in code)
- [ ] Dependency vulnerability scan clean (`npm audit` / `pip audit`)
- [ ] File upload validation (type, size, content)
- [ ] Admin panel access restricted

## Email

- [ ] Transactional email service configured
- [ ] Email delivery tested (confirmation, password reset, etc.)
- [ ] SPF, DKIM, DMARC records configured
- [ ] Email templates responsive and tested
- [ ] Unsubscribe mechanism (for marketing emails)
- [ ] Reply-to address configured
- [ ] Email sending domain verified

## Payments (if applicable)

- [ ] Payment provider in production/live mode
- [ ] Test transactions completed successfully
- [ ] Webhook endpoints registered and verified
- [ ] Payment failure handling tested
- [ ] Refund flow tested
- [ ] Receipt/invoice generation working
- [ ] PCI compliance requirements met
- [ ] Subscription lifecycle tested (if applicable)

## Legal & Compliance

- [ ] Privacy Policy page published
- [ ] Terms of Service page published
- [ ] Cookie Policy (if using cookies)
- [ ] GDPR compliance (if serving EU users):
  - [ ] Cookie consent mechanism
  - [ ] Data export capability
  - [ ] Account deletion capability
- [ ] Accessibility statement (recommended)
- [ ] Copyright notice in footer

## Accessibility

- [ ] Keyboard navigation works throughout
- [ ] Screen reader tested (VoiceOver/NVDA)
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Focus indicators visible
- [ ] Form labels and error messages accessible
- [ ] Skip navigation link present
- [ ] ARIA landmarks used correctly
- [ ] No auto-playing media
- [ ] Lighthouse Accessibility score > 90

## Mobile & Browser Testing

- [ ] Responsive design verified:
  - [ ] Mobile (375px - iPhone SE)
  - [ ] Mobile large (428px - iPhone Pro Max)
  - [ ] Tablet (768px - iPad)
  - [ ] Desktop (1024px+)
  - [ ] Wide desktop (1440px+)
- [ ] Touch targets adequate size (48x48px minimum)
- [ ] No horizontal scrolling on mobile
- [ ] Browser testing completed:
  - [ ] Chrome (latest)
  - [ ] Firefox (latest)
  - [ ] Safari (latest)
  - [ ] Edge (latest)
  - [ ] Safari iOS
  - [ ] Chrome Android

## Infrastructure & DevOps

- [ ] Production environment configured
- [ ] Environment variables set in production
- [ ] CI/CD pipeline working for production deploys
- [ ] Rollback procedure documented and tested
- [ ] Auto-scaling configured (if applicable)
- [ ] Log aggregation set up
- [ ] Database connection pooling configured
- [ ] Container health checks (if using Docker)

## Final Checks

- [ ] All TODO/FIXME comments resolved
- [ ] Console errors cleared
- [ ] Debug/development flags disabled
- [ ] Test/seed data removed from production
- [ ] All placeholder content replaced
- [ ] 404 page customized
- [ ] 500 error page customized
- [ ] Loading states implemented
- [ ] Empty states designed
- [ ] Client sign-off obtained

---

## Launch Day Procedure

1. [ ] Final staging review with client
2. [ ] Database migration (if needed)
3. [ ] Deploy to production
4. [ ] Verify DNS propagation
5. [ ] Smoke test critical user flows
6. [ ] Verify analytics tracking
7. [ ] Verify error monitoring
8. [ ] Verify email delivery
9. [ ] Verify payment processing (if applicable)
10. [ ] Monitor error rates for 1 hour post-launch
11. [ ] Notify client of successful launch
12. [ ] Celebrate!

---

*Items checked [x] have been verified automatically. Unchecked items [ ] require manual verification.*
```

4. **Customize the checklist** based on the project. Remove sections that do not apply (e.g., Payments section if no payment processing). Add project-specific items.

5. **Auto-verify what you can** by examining the codebase. Mark items as checked `[x]` if you can confirm them from the code, and note what you verified.

6. **Output the complete checklist** as formatted Markdown directly to the user.
