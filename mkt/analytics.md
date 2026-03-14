# Analytics Setup

Set up analytics tracking with SDK installation, page views, custom events, user identification, UTM capture, conversion tracking, and privacy-aware cookie consent.

## Arguments

$ARGUMENTS - Required `<platform>`: one of `ga4`, `posthog`, `mixpanel`, `segment`, `plausible`. Specifies the analytics platform to integrate.

## Instructions

### Step 1: Validate the Platform Argument

Parse the `<platform>` argument. It must be one of:
- `ga4` - Google Analytics 4 (free, widely used, Google ecosystem)
- `posthog` - PostHog (open-source, product analytics, session replay)
- `mixpanel` - Mixpanel (event-based analytics, funnels, retention)
- `segment` - Segment (customer data platform, routes to multiple destinations)
- `plausible` - Plausible (privacy-first, no cookies, GDPR compliant by default)

If the argument is missing or invalid, list the valid platforms and ask the user to specify one.

### Step 2: Detect Project Framework

Examine the codebase to determine:
- Framework: Next.js (App Router or Pages Router), Nuxt, Astro, React SPA, Vue SPA, Svelte, Express, Django, static HTML
- Existing analytics: Check if any analytics is already installed (avoid conflicts)
- Environment variable patterns: `.env`, `.env.local`, `next.config.js`, etc.
- TypeScript or JavaScript

### Step 3: Install the SDK

Install the appropriate SDK package:

| Platform | Package |
|----------|---------|
| GA4 | `@next/third-parties` (Next.js) or `gtag.js` script |
| PostHog | `posthog-js` and `posthog-node` (for server-side) |
| Mixpanel | `mixpanel-browser` |
| Segment | `@segment/analytics-next` |
| Plausible | `plausible-tracker` or script tag (no npm needed) |

Add the package to the project's dependencies. If the project uses a lockfile, note that the user needs to run the install command.

### Step 4: Create the Analytics Utility Module

Create a centralized analytics module that abstracts the platform-specific SDK behind a consistent interface. Place it at a logical location (e.g., `src/lib/analytics.ts`, `src/utils/analytics.ts`).

The module must export these functions:

```typescript
// Initialize analytics (call once on app load)
export function initAnalytics(): void

// Track page views
export function trackPageView(url: string, properties?: Record<string, unknown>): void

// Track custom events
export function trackEvent(
  eventName: string,
  properties?: Record<string, unknown>
): void

// Identify a user (after login/signup)
export function identifyUser(
  userId: string,
  traits?: Record<string, unknown>
): void

// Track revenue/conversion events
export function trackRevenue(
  amount: number,
  currency: string,
  properties?: Record<string, unknown>
): void

// Reset/logout (clear user identity)
export function resetAnalytics(): void
```

Implement each function using the platform-specific SDK calls:

**GA4:**
- `initAnalytics`: Load gtag.js script, configure with Measurement ID
- `trackPageView`: `gtag('event', 'page_view', { page_path: url })`
- `trackEvent`: `gtag('event', eventName, properties)`
- `identifyUser`: `gtag('config', MEASUREMENT_ID, { user_id: userId })`
- `trackRevenue`: `gtag('event', 'purchase', { value: amount, currency, ...properties })`

**PostHog:**
- `initAnalytics`: `posthog.init(API_KEY, { api_host: HOST })`
- `trackPageView`: `posthog.capture('$pageview', { $current_url: url })`
- `trackEvent`: `posthog.capture(eventName, properties)`
- `identifyUser`: `posthog.identify(userId, traits)`
- `trackRevenue`: `posthog.capture('purchase', { revenue: amount, currency, ...properties })`

**Mixpanel:**
- `initAnalytics`: `mixpanel.init(TOKEN)`
- `trackPageView`: `mixpanel.track('Page View', { url, ...properties })`
- `trackEvent`: `mixpanel.track(eventName, properties)`
- `identifyUser`: `mixpanel.identify(userId); mixpanel.people.set(traits)`
- `trackRevenue`: `mixpanel.people.track_charge(amount, { currency, ...properties })`

**Segment:**
- `initAnalytics`: `analytics.load({ writeKey: WRITE_KEY })`
- `trackPageView`: `analytics.page(properties)`
- `trackEvent`: `analytics.track(eventName, properties)`
- `identifyUser`: `analytics.identify(userId, traits)`
- `trackRevenue`: `analytics.track('Order Completed', { revenue: amount, currency, ...properties })`

**Plausible:**
- `initAnalytics`: Load script or initialize plausible-tracker
- `trackPageView`: Automatic (script-based) or `plausible.trackPageview()`
- `trackEvent`: `plausible.trackEvent(eventName, { props: properties })`
- `identifyUser`: Not applicable (Plausible is privacy-first, no user identification)
- `trackRevenue`: `plausible.trackEvent('purchase', { revenue: { amount, currency } })`

### Step 5: Implement Page View Tracking

Set up automatic page view tracking based on the framework:

**Next.js App Router:**
- Create a client component (e.g., `AnalyticsProvider`) that wraps the app in `app/layout.tsx`
- Use `usePathname()` and `useSearchParams()` from `next/navigation` to track route changes
- Call `trackPageView` on every pathname change via `useEffect`

**Next.js Pages Router:**
- Use `router.events` in `_app.tsx` to listen for `routeChangeComplete`
- Call `trackPageView` on each route change

**React SPA (Vite/CRA):**
- Listen to React Router's location changes
- Call `trackPageView` on each location change

**Other frameworks:**
- Adapt to the framework's routing lifecycle

### Step 6: Implement UTM Capture

Create a UTM parameter capture utility:
- On page load, extract UTM parameters from the URL: `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`
- Store them in `sessionStorage` or cookies so they persist across the session
- Include UTM data as properties in all subsequent events and page views
- Also capture: `ref`, `referrer`, `gclid` (Google Ads), `fbclid` (Facebook Ads)

```typescript
export function captureUtmParams(): Record<string, string> {
  const params = new URLSearchParams(window.location.search);
  const utmKeys = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'ref', 'gclid', 'fbclid'];
  const utmData: Record<string, string> = {};
  for (const key of utmKeys) {
    const value = params.get(key);
    if (value) utmData[key] = value;
  }
  if (Object.keys(utmData).length > 0) {
    sessionStorage.setItem('utm_data', JSON.stringify(utmData));
  }
  return JSON.parse(sessionStorage.getItem('utm_data') || '{}');
}
```

### Step 7: Implement Conversion Tracking

Set up key conversion events:

```typescript
// Signup conversion
export function trackSignup(method: string) {
  trackEvent('sign_up', { method });
}

// Login
export function trackLogin(method: string) {
  trackEvent('login', { method });
}

// Feature activation
export function trackFeatureUse(featureName: string) {
  trackEvent('feature_used', { feature: featureName });
}

// Purchase/subscription
export function trackPurchase(plan: string, amount: number, currency: string) {
  trackRevenue(amount, currency, { plan });
}

// CTA click
export function trackCtaClick(ctaName: string, location: string) {
  trackEvent('cta_click', { cta: ctaName, location });
}
```

Place these in the analytics module or a separate `src/lib/tracking.ts` file.

### Step 8: Implement Cookie Consent (if needed)

For GA4, Mixpanel, and Segment (which use cookies), implement cookie consent:

**Skip this step for Plausible** (cookieless by design) and **PostHog** (if configured in cookieless mode).

Create a cookie consent banner component:
- Show on first visit if no consent decision has been made
- Options: "Accept All", "Reject Non-Essential", and optionally "Customize"
- Store consent decision in a cookie or localStorage
- Only initialize analytics tracking after consent is granted
- Provide a way to change preference later (link in footer)
- Respect `Do Not Track` browser setting

Modify `initAnalytics` to check for consent before loading:

```typescript
export function initAnalytics() {
  const consent = getConsentStatus();
  if (consent === 'granted' || platform === 'plausible') {
    // Initialize SDK
  }
}
```

### Step 9: Environment Variables

Create the required environment variables:

| Platform | Variable | Example |
|----------|----------|---------|
| GA4 | `NEXT_PUBLIC_GA_MEASUREMENT_ID` | `G-XXXXXXXXXX` |
| PostHog | `NEXT_PUBLIC_POSTHOG_KEY` | `phc_xxxxx` |
| PostHog | `NEXT_PUBLIC_POSTHOG_HOST` | `https://app.posthog.com` |
| Mixpanel | `NEXT_PUBLIC_MIXPANEL_TOKEN` | `xxxxx` |
| Segment | `NEXT_PUBLIC_SEGMENT_WRITE_KEY` | `xxxxx` |
| Plausible | `NEXT_PUBLIC_PLAUSIBLE_DOMAIN` | `yoursite.com` |

Add these to `.env.example` or `.env.template` (never to `.env` with real values).

Use the project's existing env variable prefix convention (e.g., `NEXT_PUBLIC_`, `VITE_`, `NUXT_PUBLIC_`).

### Step 10: Add Development Safeguards

Prevent analytics from firing in development:
- Check `process.env.NODE_ENV === 'production'` before initializing
- Or check for the presence of the API key (don't fire if key is empty/undefined)
- Add debug logging in development that shows what would be tracked
- Optionally support a `debug` mode that logs events to console

```typescript
const isDev = process.env.NODE_ENV !== 'production';

export function trackEvent(name: string, props?: Record<string, unknown>) {
  if (isDev) {
    console.log(`[Analytics] ${name}`, props);
    return;
  }
  // Actual tracking call
}
```

### Step 11: Summary

Report what was implemented:

```
## Analytics Setup Summary

- Platform: {platform name}
- Framework: {detected framework}
- Cookie consent: {yes/no/not needed}

### Files Created
- Analytics module: [file path]
- Provider component: [file path]
- Cookie consent component: [file path] (if applicable)
- UTM capture utility: [file path]
- Conversion tracking: [file path]
- Environment template: [file path]

### Events Configured
- Page views (automatic on route change)
- Custom events (via trackEvent)
- User identification (via identifyUser)
- UTM parameter capture (automatic on page load)
- Revenue tracking (via trackRevenue)
- Conversion events (signup, login, purchase, CTA click)

### Required Environment Variables
- {list of variables needed}

### TODOs for the User
- [ ] Get API key from {platform dashboard URL}
- [ ] Set environment variable {VAR_NAME}
- [ ] Run package install: {npm install / yarn / pnpm install}
- [ ] Add custom events to key user actions in the app
- [ ] Set up conversion goals in {platform} dashboard
- [ ] Configure data retention settings in {platform} dashboard
- [ ] Review cookie consent implementation for your jurisdiction
```
