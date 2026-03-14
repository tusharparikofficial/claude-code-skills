# Analytics Setup

Set up comprehensive analytics tracking with page views, custom events, user identification, conversion tracking, and privacy compliance for the specified analytics platform.

## Arguments

$ARGUMENTS - Required: `<platform>` - one of: ga4, posthog, mixpanel, segment, plausible

## Instructions

You are setting up a complete analytics implementation. Follow each step carefully.

### Step 1: Parse Arguments and Detect Project Context

1. **Platform**: Extract from `$ARGUMENTS`. Valid platforms:
   - `ga4` - Google Analytics 4
   - `posthog` - PostHog (self-hosted or cloud)
   - `mixpanel` - Mixpanel
   - `segment` - Segment (analytics aggregator)
   - `plausible` - Plausible Analytics (privacy-focused)

2. **Detect framework**: Next.js, React, Vue/Nuxt, Astro, SvelteKit, static HTML, etc.
3. **Check existing analytics**: Look for existing tracking scripts, SDKs, or analytics utilities
4. **Check for cookie consent**: Look for existing cookie consent banners/libraries

### Step 2: Install SDK/Script

#### Google Analytics 4 (GA4)

**Environment variable:**
```
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

**Next.js App Router:**
Create `app/layout.tsx` script or `components/GoogleAnalytics.tsx`:
```typescript
import Script from 'next/script';

export function GoogleAnalytics({ measurementId }: { measurementId: string }) {
  return (
    <>
      <Script
        src={`https://www.googletagmanager.com/gtag/js?id=${measurementId}`}
        strategy="afterInteractive"
      />
      <Script id="google-analytics" strategy="afterInteractive">
        {`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${measurementId}', {
            page_path: window.location.pathname,
            anonymize_ip: true,
          });
        `}
      </Script>
    </>
  );
}
```

**Static HTML:**
Add script tags directly to `<head>`.

#### PostHog

```bash
npm install posthog-js
# or for Node.js server-side:
npm install posthog-node
```

**Environment variable:**
```
NEXT_PUBLIC_POSTHOG_KEY=phc_xxxxxxxxxxxxx
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

**Initialization:**
```typescript
import posthog from 'posthog-js';

if (typeof window !== 'undefined') {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    person_profiles: 'identified_only',
    capture_pageview: false, // We handle this manually for SPAs
    capture_pageleave: true,
  });
}
```

#### Mixpanel

```bash
npm install mixpanel-browser
```

**Environment variable:**
```
NEXT_PUBLIC_MIXPANEL_TOKEN=your_token_here
```

**Initialization:**
```typescript
import mixpanel from 'mixpanel-browser';

mixpanel.init(process.env.NEXT_PUBLIC_MIXPANEL_TOKEN!, {
  track_pageview: true,
  persistence: 'localStorage',
  ignore_dnt: false,
});
```

#### Segment

```bash
npm install @segment/analytics-next
```

**Environment variable:**
```
NEXT_PUBLIC_SEGMENT_WRITE_KEY=your_write_key
```

**Initialization:**
```typescript
import { AnalyticsBrowser } from '@segment/analytics-next';

export const analytics = AnalyticsBrowser.load({
  writeKey: process.env.NEXT_PUBLIC_SEGMENT_WRITE_KEY!,
});
```

#### Plausible

**Environment variable:**
```
NEXT_PUBLIC_PLAUSIBLE_DOMAIN=yoursite.com
```

**Next.js:**
```typescript
import Script from 'next/script';

export function PlausibleAnalytics({ domain }: { domain: string }) {
  return (
    <Script
      defer
      data-domain={domain}
      src="https://plausible.io/js/script.js"
      strategy="afterInteractive"
    />
  );
}
```

Or use `next-plausible`:
```bash
npm install next-plausible
```

### Step 3: Create Analytics Utility Module

Create a unified analytics module that abstracts the platform-specific SDK:

```typescript
// lib/analytics.ts

type EventProperties = Record<string, string | number | boolean | string[]>;
type UserTraits = Record<string, string | number | boolean | Date>;

interface AnalyticsClient {
  track(event: string, properties?: EventProperties): void;
  page(name?: string, properties?: EventProperties): void;
  identify(userId: string, traits?: UserTraits): void;
  reset(): void;
  revenue(amount: number, currency: string, properties?: EventProperties): void;
}

// Platform-specific implementations below
```

#### GA4 Implementation

```typescript
function createGA4Client(measurementId: string): AnalyticsClient {
  return {
    track(event, properties) {
      if (typeof window === 'undefined') return;
      window.gtag?.('event', event, properties);
    },
    page(name, properties) {
      if (typeof window === 'undefined') return;
      window.gtag?.('event', 'page_view', {
        page_title: name,
        page_location: window.location.href,
        page_path: window.location.pathname,
        ...properties,
      });
    },
    identify(userId, traits) {
      if (typeof window === 'undefined') return;
      window.gtag?.('set', { user_id: userId });
      if (traits) {
        window.gtag?.('set', 'user_properties', traits);
      }
    },
    reset() {
      // GA4 doesn't have a built-in reset
    },
    revenue(amount, currency, properties) {
      if (typeof window === 'undefined') return;
      window.gtag?.('event', 'purchase', {
        value: amount,
        currency,
        ...properties,
      });
    },
  };
}
```

#### PostHog Implementation

```typescript
import posthog from 'posthog-js';

function createPostHogClient(): AnalyticsClient {
  return {
    track(event, properties) {
      posthog.capture(event, properties);
    },
    page(name, properties) {
      posthog.capture('$pageview', { $current_url: window.location.href, ...properties });
    },
    identify(userId, traits) {
      posthog.identify(userId, traits);
    },
    reset() {
      posthog.reset();
    },
    revenue(amount, currency, properties) {
      posthog.capture('purchase', { revenue: amount, currency, ...properties });
    },
  };
}
```

#### Mixpanel Implementation

```typescript
import mixpanel from 'mixpanel-browser';

function createMixpanelClient(): AnalyticsClient {
  return {
    track(event, properties) {
      mixpanel.track(event, properties);
    },
    page(name, properties) {
      mixpanel.track('Page View', { page: name, ...properties });
    },
    identify(userId, traits) {
      mixpanel.identify(userId);
      if (traits) mixpanel.people.set(traits);
    },
    reset() {
      mixpanel.reset();
    },
    revenue(amount, currency, properties) {
      mixpanel.people.track_charge(amount);
      mixpanel.track('Purchase', { amount, currency, ...properties });
    },
  };
}
```

#### Segment Implementation

```typescript
import { analytics } from './segment-init';

function createSegmentClient(): AnalyticsClient {
  return {
    track(event, properties) {
      analytics.track(event, properties);
    },
    page(name, properties) {
      analytics.page(name, properties);
    },
    identify(userId, traits) {
      analytics.identify(userId, traits);
    },
    reset() {
      analytics.reset();
    },
    revenue(amount, currency, properties) {
      analytics.track('Order Completed', {
        revenue: amount,
        currency,
        ...properties,
      });
    },
  };
}
```

#### Plausible Implementation

```typescript
function createPlausibleClient(): AnalyticsClient {
  return {
    track(event, properties) {
      if (typeof window === 'undefined') return;
      window.plausible?.(event, { props: properties });
    },
    page() {
      // Plausible handles page views automatically
    },
    identify() {
      // Plausible is privacy-focused and doesn't support user identification
    },
    reset() {
      // N/A for Plausible
    },
    revenue(amount, currency, properties) {
      if (typeof window === 'undefined') return;
      window.plausible?.('Purchase', {
        revenue: { amount, currency },
        props: properties,
      });
    },
  };
}
```

### Step 4: Implement Page View Tracking

#### SPA Route Change Tracking (Next.js App Router)

Create a `components/AnalyticsProvider.tsx`:

```typescript
'use client';

import { usePathname, useSearchParams } from 'next/navigation';
import { useEffect, Suspense } from 'react';
import { analytics } from '@/lib/analytics';

function AnalyticsPageView() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  useEffect(() => {
    const url = `${pathname}${searchParams.toString() ? '?' + searchParams.toString() : ''}`;
    analytics.page(pathname, { url });
  }, [pathname, searchParams]);

  return null;
}

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Suspense fallback={null}>
        <AnalyticsPageView />
      </Suspense>
      {children}
    </>
  );
}
```

Wrap the app in `app/layout.tsx`:
```typescript
<AnalyticsProvider>
  {children}
</AnalyticsProvider>
```

#### Vue/Nuxt Route Tracking

Use `router.afterEach()` hook.

#### Other SPAs

Listen to `popstate` events or use the framework's router hooks.

### Step 5: Define Tracking Plan

Create a tracking plan document `docs/tracking-plan.md` (or output to console):

```markdown
# Tracking Plan

## Page Views
Automatically tracked on route changes.

## Core Events

| Event Name | Trigger | Properties | Category |
|------------|---------|------------|----------|
| sign_up | User completes registration | method, plan | Conversion |
| login | User logs in | method | Auth |
| logout | User logs out | - | Auth |
| subscription_started | User starts paid plan | plan, price, interval | Revenue |
| subscription_cancelled | User cancels plan | plan, reason | Revenue |
| feature_used | User uses a key feature | feature_name, context | Engagement |
| button_clicked | User clicks tracked button | button_name, page | Engagement |
| form_submitted | User submits a form | form_name, success | Conversion |
| error_occurred | Error happens in app | error_type, message, page | Technical |
| search_performed | User searches | query, results_count | Engagement |
| item_added_to_cart | User adds item to cart | item_id, item_name, price | E-commerce |
| checkout_started | User begins checkout | cart_value, item_count | E-commerce |
| purchase_completed | User completes purchase | order_id, total, items | Revenue |

## User Properties

| Property | Type | Set When |
|----------|------|----------|
| plan | string | Sign up, plan change |
| company | string | Profile update |
| role | string | Sign up |
| created_at | date | Sign up |
| last_login | date | Login |

## UTM Parameters
Automatically captured: utm_source, utm_medium, utm_campaign, utm_term, utm_content
```

### Step 6: Implement Event Tracking Helpers

Create typed helper functions for common events:

```typescript
// lib/analytics/events.ts

import { analytics } from './client';

// Auth events
export function trackSignUp(method: 'email' | 'google' | 'github', plan?: string) {
  analytics.track('sign_up', { method, plan: plan ?? 'free' });
}

export function trackLogin(method: 'email' | 'google' | 'github') {
  analytics.track('login', { method });
}

// Conversion events
export function trackFormSubmission(formName: string, success: boolean) {
  analytics.track('form_submitted', { form_name: formName, success });
}

export function trackButtonClick(buttonName: string, page: string) {
  analytics.track('button_clicked', { button_name: buttonName, page });
}

// Revenue events
export function trackPurchase(orderId: string, total: number, currency: string, items: number) {
  analytics.revenue(total, currency, { order_id: orderId, item_count: items });
}

// Feature events
export function trackFeatureUsed(featureName: string, context?: string) {
  analytics.track('feature_used', { feature_name: featureName, context: context ?? '' });
}

// Error events
export function trackError(errorType: string, message: string) {
  analytics.track('error_occurred', {
    error_type: errorType,
    message: message.substring(0, 500),
    page: typeof window !== 'undefined' ? window.location.pathname : '',
  });
}
```

### Step 7: UTM Parameter Capture

```typescript
// lib/analytics/utm.ts

interface UTMParams {
  utm_source?: string;
  utm_medium?: string;
  utm_campaign?: string;
  utm_term?: string;
  utm_content?: string;
}

export function captureUTMParams(): UTMParams {
  if (typeof window === 'undefined') return {};

  const params = new URLSearchParams(window.location.search);
  const utmParams: UTMParams = {};

  const utmKeys = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content'] as const;
  for (const key of utmKeys) {
    const value = params.get(key);
    if (value) {
      utmParams[key] = value;
    }
  }

  // Store in sessionStorage for attribution across page views
  if (Object.keys(utmParams).length > 0) {
    sessionStorage.setItem('utm_params', JSON.stringify(utmParams));
  }

  return utmParams;
}

export function getStoredUTMParams(): UTMParams {
  if (typeof window === 'undefined') return {};
  const stored = sessionStorage.getItem('utm_params');
  return stored ? JSON.parse(stored) : {};
}
```

### Step 8: Cookie Consent Integration

```typescript
// lib/analytics/consent.ts

type ConsentStatus = 'granted' | 'denied' | 'pending';

interface ConsentState {
  analytics: ConsentStatus;
  marketing: ConsentStatus;
  functional: ConsentStatus;
}

const DEFAULT_CONSENT: ConsentState = {
  analytics: 'pending',
  marketing: 'pending',
  functional: 'granted',
};

export function getConsentState(): ConsentState {
  if (typeof window === 'undefined') return DEFAULT_CONSENT;
  const stored = localStorage.getItem('cookie_consent');
  return stored ? JSON.parse(stored) : DEFAULT_CONSENT;
}

export function setConsentState(consent: ConsentState): void {
  localStorage.setItem('cookie_consent', JSON.stringify(consent));

  // Update analytics based on consent
  if (consent.analytics === 'granted') {
    initializeAnalytics();
  } else if (consent.analytics === 'denied') {
    disableAnalytics();
  }
}

export function hasAnalyticsConsent(): boolean {
  const consent = getConsentState();
  return consent.analytics === 'granted';
}

function initializeAnalytics() {
  // Platform-specific initialization after consent
  // GA4: gtag('consent', 'update', { analytics_storage: 'granted' });
  // PostHog: posthog.opt_in_capturing();
}

function disableAnalytics() {
  // GA4: gtag('consent', 'update', { analytics_storage: 'denied' });
  // PostHog: posthog.opt_out_capturing();
}
```

#### GA4-Specific Consent Mode

```typescript
// Initialize with consent mode BEFORE loading GA4
window.gtag?.('consent', 'default', {
  analytics_storage: 'denied',
  ad_storage: 'denied',
  ad_user_data: 'denied',
  ad_personalization: 'denied',
});
```

### Step 9: Privacy Configuration

For each platform, configure privacy settings:

#### GDPR/CCPA Compliance
- **IP anonymization**: Enable by default
- **Data retention**: Set to minimum required period
- **PII handling**: Never send PII in event properties
- **User deletion**: Document how to delete user data per platform
- **Cookie duration**: Set appropriate cookie lifetimes

#### Platform-Specific Privacy

**GA4:**
```typescript
gtag('config', measurementId, {
  anonymize_ip: true,
  cookie_expires: 63072000, // 2 years in seconds
  cookie_flags: 'SameSite=None;Secure',
});
```

**PostHog:**
```typescript
posthog.init(key, {
  person_profiles: 'identified_only',
  mask_all_text: false,
  mask_all_element_attributes: false,
  respect_dnt: true,
});
```

**Plausible:** Privacy-first by default (no cookies, no PII).

### Step 10: Verification and Testing

After implementation, verify:

- [ ] Analytics SDK loads without errors
- [ ] Page views are tracked on route changes
- [ ] Custom events fire correctly
- [ ] User identification works after login
- [ ] UTM parameters are captured from URLs
- [ ] Cookie consent gate works (analytics disabled until consent)
- [ ] No PII is sent in event properties
- [ ] Analytics is disabled when consent is denied
- [ ] Revenue tracking calculates correctly
- [ ] Error tracking captures client errors
- [ ] Analytics works in development (or is properly disabled)
- [ ] No analytics scripts load in SSR (client-only)
- [ ] Tracking plan document is complete and accurate

### File Structure Summary

```
lib/
  analytics/
    index.ts          # Main export, creates and exports analytics client
    client.ts         # Platform-specific client implementation
    events.ts         # Typed event tracking helpers
    utm.ts            # UTM parameter capture
    consent.ts        # Cookie consent management
    types.ts          # TypeScript interfaces

components/
  AnalyticsProvider.tsx   # Page view tracking wrapper
  CookieConsent.tsx       # Cookie consent banner (if needed)

docs/
  tracking-plan.md        # Event tracking documentation
```

### Important Notes

- NEVER hardcode analytics keys in source code -- always use environment variables
- NEVER send PII (email, full name, phone) in event properties
- Always check `typeof window !== 'undefined'` before accessing browser APIs
- Disable analytics in development unless explicitly testing (`NODE_ENV === 'production'`)
- Use `strategy="afterInteractive"` (Next.js) or equivalent to not block page load
- Test that analytics events appear in the platform's real-time/debug view
- Keep event names consistent: use `snake_case` for event names and properties
- Limit custom event properties to essential data only
- Document every tracked event in the tracking plan
