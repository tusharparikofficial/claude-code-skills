# Social Share Implementation

Implement social sharing functionality with proper Open Graph previews, share buttons, dynamic OG image generation, UTM tracking, and native share API support.

## Arguments

$ARGUMENTS - Optional: `<page-or-component>` specific page or component to add sharing to (defaults to creating a reusable share system)

## Instructions

You are implementing a complete social sharing system. Follow each step carefully.

### Step 1: Detect Project Context

1. **Framework**: Next.js, React, Vue/Nuxt, Astro, SvelteKit, static HTML, etc.
2. **Existing OG tags**: Check if Open Graph meta tags already exist
3. **Existing share components**: Check for any existing share buttons or utilities
4. **Styling system**: Tailwind, CSS Modules, styled-components, etc.
5. **Target scope**: If `$ARGUMENTS` specifies a page/component, scope to that; otherwise create a reusable system

### Step 2: Implement Open Graph Meta Tags

Ensure every shareable page has proper OG and Twitter Card tags.

#### Required Meta Tags for Social Sharing

```html
<!-- Open Graph -->
<meta property="og:title" content="Page Title" />
<meta property="og:description" content="Compelling description under 155 chars" />
<meta property="og:image" content="https://example.com/og-image.jpg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content="Description of the image" />
<meta property="og:url" content="https://example.com/page" />
<meta property="og:type" content="website" />
<meta property="og:site_name" content="Site Name" />
<meta property="og:locale" content="en_US" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@handle" />
<meta name="twitter:creator" content="@handle" />
<meta name="twitter:title" content="Page Title" />
<meta name="twitter:description" content="Compelling description" />
<meta name="twitter:image" content="https://example.com/og-image.jpg" />
<meta name="twitter:image:alt" content="Description of the image" />
```

#### Framework Implementation

**Next.js App Router:**
```typescript
// In page.tsx or layout.tsx
export const metadata: Metadata = {
  openGraph: {
    title: 'Page Title',
    description: 'Description',
    url: 'https://example.com/page',
    siteName: 'Site Name',
    images: [{
      url: 'https://example.com/og-image.jpg',
      width: 1200,
      height: 630,
      alt: 'OG Image Alt Text',
    }],
    type: 'website',
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Page Title',
    description: 'Description',
    images: ['https://example.com/og-image.jpg'],
    site: '@handle',
    creator: '@handle',
  },
};
```

**For dynamic pages, use `generateMetadata()`.**

### Step 3: Dynamic OG Image Generation

#### Option A: Vercel OG / Next.js OG (Recommended for Next.js)

Create `app/api/og/route.tsx`:

```typescript
import { ImageResponse } from 'next/og';
import type { NextRequest } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get('title') ?? 'Default Title';
  const description = searchParams.get('description') ?? '';
  const type = searchParams.get('type') ?? 'default';

  return new ImageResponse(
    (
      <div
        style={{
          height: '100%',
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#0a0a0a',
          padding: '40px 80px',
        }}
      >
        {/* Logo */}
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: '40px' }}>
          <span style={{ fontSize: '24px', color: '#a0a0a0' }}>Company Name</span>
        </div>

        {/* Title */}
        <div
          style={{
            fontSize: '60px',
            fontWeight: 'bold',
            color: '#ffffff',
            textAlign: 'center',
            lineHeight: 1.2,
            maxWidth: '900px',
          }}
        >
          {title}
        </div>

        {/* Description */}
        {description && (
          <div
            style={{
              fontSize: '24px',
              color: '#a0a0a0',
              textAlign: 'center',
              marginTop: '20px',
              maxWidth: '800px',
            }}
          >
            {description}
          </div>
        )}

        {/* Footer */}
        <div
          style={{
            position: 'absolute',
            bottom: '40px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
          }}
        >
          <span style={{ color: '#666', fontSize: '18px' }}>example.com</span>
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
    },
  );
}
```

Use in metadata:
```typescript
openGraph: {
  images: [`/api/og?title=${encodeURIComponent(title)}&description=${encodeURIComponent(description)}`],
}
```

#### Option B: Static OG Images

- Create a default OG image at `public/og-default.jpg` (1200x630px)
- For key pages, create custom static OG images
- Document the image dimensions and guidelines

### Step 4: Create Share Button Component

```typescript
// components/ShareButtons.tsx
'use client';

import { useState, useCallback } from 'react';

interface ShareButtonsProps {
  url: string;
  title: string;
  description?: string;
  hashtags?: string[];
  via?: string; // Twitter handle without @
  image?: string;
  utmSource?: string;
}

interface SharePlatform {
  name: string;
  icon: React.ReactNode;
  getShareUrl: (props: ShareButtonsProps) => string;
  color: string;
}

function buildUTMUrl(baseUrl: string, source: string, medium: string = 'social'): string {
  const url = new URL(baseUrl);
  url.searchParams.set('utm_source', source);
  url.searchParams.set('utm_medium', medium);
  url.searchParams.set('utm_campaign', 'share');
  return url.toString();
}

const platforms: SharePlatform[] = [
  {
    name: 'Twitter / X',
    icon: /* Twitter SVG icon */,
    color: '#000000',
    getShareUrl: ({ url, title, hashtags, via }) => {
      const params = new URLSearchParams({
        text: title,
        url: buildUTMUrl(url, 'twitter'),
      });
      if (hashtags?.length) params.set('hashtags', hashtags.join(','));
      if (via) params.set('via', via);
      return `https://twitter.com/intent/tweet?${params}`;
    },
  },
  {
    name: 'LinkedIn',
    icon: /* LinkedIn SVG icon */,
    color: '#0A66C2',
    getShareUrl: ({ url, title }) => {
      const params = new URLSearchParams({
        url: buildUTMUrl(url, 'linkedin'),
        title,
      });
      return `https://www.linkedin.com/sharing/share-offsite/?${params}`;
    },
  },
  {
    name: 'Facebook',
    icon: /* Facebook SVG icon */,
    color: '#1877F2',
    getShareUrl: ({ url }) => {
      return `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(buildUTMUrl(url, 'facebook'))}`;
    },
  },
  {
    name: 'Reddit',
    icon: /* Reddit SVG icon */,
    color: '#FF4500',
    getShareUrl: ({ url, title }) => {
      const params = new URLSearchParams({
        url: buildUTMUrl(url, 'reddit'),
        title,
      });
      return `https://www.reddit.com/submit?${params}`;
    },
  },
  {
    name: 'Hacker News',
    icon: /* HN SVG icon */,
    color: '#FF6600',
    getShareUrl: ({ url, title }) => {
      const params = new URLSearchParams({
        u: buildUTMUrl(url, 'hackernews'),
        t: title,
      });
      return `https://news.ycombinator.com/submitlink?${params}`;
    },
  },
  {
    name: 'Email',
    icon: /* Email SVG icon */,
    color: '#666666',
    getShareUrl: ({ url, title, description }) => {
      const body = `${description ? description + '\n\n' : ''}${buildUTMUrl(url, 'email')}`;
      return `mailto:?subject=${encodeURIComponent(title)}&body=${encodeURIComponent(body)}`;
    },
  },
];

export function ShareButtons(props: ShareButtonsProps) {
  const [copied, setCopied] = useState(false);

  const handleNativeShare = useCallback(async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: props.title,
          text: props.description,
          url: props.url,
        });
      } catch (err) {
        // User cancelled or share failed -- ignore AbortError
        if (err instanceof Error && err.name !== 'AbortError') {
          console.error('Share failed:', err);
        }
      }
    }
  }, [props]);

  const handleCopyLink = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(props.url);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = props.url;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  }, [props.url]);

  const handleShareClick = (platform: SharePlatform) => {
    const shareUrl = platform.getShareUrl(props);

    // Track share event
    if (typeof window !== 'undefined' && 'analytics' in window) {
      // analytics.track('share_clicked', { platform: platform.name, url: props.url });
    }

    if (platform.name === 'Email') {
      window.location.href = shareUrl;
    } else {
      window.open(shareUrl, '_blank', 'width=600,height=400,noopener,noreferrer');
    }
  };

  return (
    <div className="flex items-center gap-2">
      {/* Native Share (mobile) */}
      {'share' in navigator && (
        <button
          onClick={handleNativeShare}
          aria-label="Share"
          className="share-button"
        >
          {/* Share icon */}
          Share
        </button>
      )}

      {/* Platform buttons */}
      {platforms.map((platform) => (
        <button
          key={platform.name}
          onClick={() => handleShareClick(platform)}
          aria-label={`Share on ${platform.name}`}
          title={`Share on ${platform.name}`}
          className="share-button"
        >
          {platform.icon}
        </button>
      ))}

      {/* Copy Link */}
      <button
        onClick={handleCopyLink}
        aria-label="Copy link"
        className="share-button"
      >
        {copied ? 'Copied!' : 'Copy Link'}
      </button>
    </div>
  );
}
```

### Step 5: Implement SVG Icons

Create lightweight SVG icons for each platform. Do NOT import a heavy icon library just for share buttons:

```typescript
// components/icons/social.tsx

export function TwitterIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" width="20" height="20">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

export function LinkedInIcon({ className }: { className?: string }) { /* ... */ }
export function FacebookIcon({ className }: { className?: string }) { /* ... */ }
export function RedditIcon({ className }: { className?: string }) { /* ... */ }
export function HackerNewsIcon({ className }: { className?: string }) { /* ... */ }
export function EmailIcon({ className }: { className?: string }) { /* ... */ }
export function LinkIcon({ className }: { className?: string }) { /* ... */ }
export function ShareIcon({ className }: { className?: string }) { /* ... */ }
```

### Step 6: Toast Notification for Copy

Create a lightweight toast notification for the "Copied!" feedback:

```typescript
// components/Toast.tsx
'use client';

import { useEffect, useState } from 'react';

interface ToastProps {
  message: string;
  visible: boolean;
  onClose: () => void;
  duration?: number;
}

export function Toast({ message, visible, onClose, duration = 2000 }: ToastProps) {
  useEffect(() => {
    if (visible) {
      const timer = setTimeout(onClose, duration);
      return () => clearTimeout(timer);
    }
  }, [visible, duration, onClose]);

  if (!visible) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className="fixed bottom-4 right-4 bg-gray-900 text-white px-4 py-2 rounded-lg shadow-lg
                 animate-in slide-in-from-bottom-2 z-50"
    >
      {message}
    </div>
  );
}
```

### Step 7: Share Click Tracking

Add analytics tracking to share events:

```typescript
// lib/analytics/share-tracking.ts

export function trackShareClick(platform: string, url: string, title: string) {
  // Replace with your analytics implementation
  if (typeof window !== 'undefined') {
    // GA4
    window.gtag?.('event', 'share', {
      method: platform,
      content_type: 'page',
      item_id: url,
    });

    // PostHog
    // posthog.capture('share_clicked', { platform, url, title });

    // Generic
    // analytics.track('share_clicked', { platform, url, title });
  }
}

export function trackShareSuccess(platform: string, url: string) {
  // For native share API which has a success callback
  if (typeof window !== 'undefined') {
    window.gtag?.('event', 'share_complete', {
      method: platform,
      item_id: url,
    });
  }
}

export function trackCopyLink(url: string) {
  if (typeof window !== 'undefined') {
    window.gtag?.('event', 'copy_link', {
      content_type: 'page',
      item_id: url,
    });
  }
}
```

### Step 8: Social Preview Tool

Create a utility to preview how links will appear on each platform:

```typescript
// lib/social-preview.ts

export interface SocialPreview {
  platform: string;
  title: string;        // How title will be truncated
  description: string;  // How description will be truncated
  imageSize: string;    // Expected image dimensions
  notes: string;        // Platform-specific notes
}

export function generatePreviews(
  title: string,
  description: string,
  image: string,
  url: string,
): SocialPreview[] {
  return [
    {
      platform: 'Twitter / X',
      title: title.substring(0, 70),
      description: description.substring(0, 200),
      imageSize: '1200x628 (summary_large_image) or 144x144 (summary)',
      notes: 'Large image card preferred. Title limited to ~70 chars visible.',
    },
    {
      platform: 'LinkedIn',
      title: title.substring(0, 200),
      description: description.substring(0, 256),
      imageSize: '1200x627 (1.91:1 ratio)',
      notes: 'LinkedIn caches aggressively. Use Post Inspector to refresh.',
    },
    {
      platform: 'Facebook',
      title: title.substring(0, 88),
      description: description.substring(0, 200),
      imageSize: '1200x630 (1.91:1 ratio)',
      notes: 'Use Facebook Sharing Debugger to refresh cache.',
    },
    {
      platform: 'Reddit',
      title: title.substring(0, 300),
      description: '',
      imageSize: '1200x630 preferred',
      notes: 'Reddit uses og:image. Title from post, not OG tag.',
    },
    {
      platform: 'Hacker News',
      title: title.substring(0, 80),
      description: '',
      imageSize: 'N/A (text only)',
      notes: 'HN shows title and domain only. No images or descriptions.',
    },
    {
      platform: 'iMessage / SMS',
      title: title.substring(0, 100),
      description: description.substring(0, 200),
      imageSize: '1200x630',
      notes: 'Uses og:image and og:title. Rich link preview.',
    },
    {
      platform: 'Slack',
      title: title.substring(0, 150),
      description: description.substring(0, 300),
      imageSize: '1200x630',
      notes: 'Slack unfurls links using OG tags. Shows image, title, description.',
    },
  ];
}
```

Output the preview information when the skill runs so the user can verify how their content will appear.

### Step 9: Platform Cache Debugging Tools

Provide links for debugging/refreshing social media caches:

```
## Social Preview Debugging URLs

- Twitter Card Validator: https://cards-dev.twitter.com/validator
- Facebook Sharing Debugger: https://developers.facebook.com/tools/debug/
- LinkedIn Post Inspector: https://www.linkedin.com/post-inspector/
- Google Rich Results Test: https://search.google.com/test/rich-results
- Open Graph Preview: https://www.opengraph.xyz/
```

### Step 10: Verification Checklist

After implementation, verify:

- [ ] Every shareable page has og:title, og:description, og:image, og:url
- [ ] Every shareable page has twitter:card, twitter:title, twitter:description, twitter:image
- [ ] OG image is at least 1200x630px
- [ ] OG image URL is absolute (includes https://)
- [ ] Share buttons render correctly on desktop and mobile
- [ ] Native share API works on supported mobile browsers
- [ ] Copy to clipboard works with toast confirmation
- [ ] Share URLs include UTM parameters
- [ ] Share click tracking fires events
- [ ] Share popup windows open at appropriate size
- [ ] All share links use noopener,noreferrer for security
- [ ] Icons are lightweight SVG (not imported from heavy library)
- [ ] Component is accessible (aria-labels, keyboard navigation)
- [ ] Dynamic OG images generate correctly (if implemented)
- [ ] OG tags work for both static and dynamic pages

### Important Notes

- OG images MUST be absolute URLs (start with `https://`)
- OG image minimum size: 1200x630px (1.91:1 aspect ratio) for large cards
- Twitter requires `twitter:card` to be set for cards to display
- Facebook caches OG tags aggressively -- use their debugger to refresh
- LinkedIn also caches -- use Post Inspector to force refresh
- Native share API (`navigator.share`) only works on HTTPS
- Do not add share count APIs (most platforms have deprecated public count APIs)
- Keep share button component lightweight -- avoid importing full icon libraries
- UTM parameters should NOT be included in canonical URLs or og:url
- Test share previews on actual platforms, not just in browser
