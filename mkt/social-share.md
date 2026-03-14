# Social Sharing Component

Implement a social sharing system with share buttons, native share API support, OG tags, UTM parameters, and click tracking.

## Arguments

$ARGUMENTS - Optional `<component-path>`: Path to an existing component to add sharing to. If omitted, creates a new standalone share button component and identifies all shareable pages.

## Instructions

### Step 1: Detect Project Framework

Examine the codebase to determine:
- Framework: Next.js, Nuxt, Astro, React, Vue, Svelte, static HTML
- Component patterns: functional components, class components, SFCs
- Styling approach: Tailwind CSS, CSS Modules, styled-components, etc.
- Existing icon library: Lucide, Heroicons, Font Awesome, React Icons, or none
- TypeScript or JavaScript

If a `<component-path>` argument was provided, locate that component and plan to add sharing functionality to it or alongside it.

### Step 2: Create the Share Button Component

Create a reusable share button component that supports multiple platforms.

**Platforms to include:**
1. **Twitter/X** - `https://twitter.com/intent/tweet?text={text}&url={url}`
2. **LinkedIn** - `https://www.linkedin.com/sharing/share-offsite/?url={url}`
3. **Facebook** - `https://www.facebook.com/sharer/sharer.php?u={url}`
4. **Reddit** - `https://reddit.com/submit?url={url}&title={title}`
5. **Hacker News** - `https://news.ycombinator.com/submitlink?u={url}&t={title}`
6. **Email** - `mailto:?subject={title}&body={text}%0A%0A{url}`
7. **Copy Link** - Copy URL to clipboard with visual feedback

**Component props/API:**
```typescript
interface ShareButtonsProps {
  url: string;           // The URL to share (absolute)
  title: string;         // The page/content title
  description?: string;  // Optional description for platforms that support it
  hashtags?: string[];   // Optional hashtags (Twitter)
  via?: string;          // Optional Twitter handle (without @)
  image?: string;        // Optional image URL for platforms that support it
  variant?: 'horizontal' | 'vertical' | 'floating'; // Layout variant
  size?: 'sm' | 'md' | 'lg'; // Button size
  showLabels?: boolean;  // Show platform names alongside icons
  platforms?: string[];  // Subset of platforms to show (default: all)
  utmSource?: string;    // UTM source override
  className?: string;    // Additional CSS classes
}
```

### Step 3: Implement Share URLs with UTM Parameters

For each platform, construct the share URL with UTM tracking:

```typescript
function buildShareUrl(platform: string, baseUrl: string, title: string, utmSource?: string): string {
  // Add UTM parameters to the shared URL
  const shareUrl = new URL(baseUrl);
  shareUrl.searchParams.set('utm_source', utmSource || platform);
  shareUrl.searchParams.set('utm_medium', 'social');
  shareUrl.searchParams.set('utm_campaign', 'share_button');
  const encodedUrl = encodeURIComponent(shareUrl.toString());
  const encodedTitle = encodeURIComponent(title);

  switch (platform) {
    case 'twitter':
      return `https://twitter.com/intent/tweet?text=${encodedTitle}&url=${encodedUrl}`;
    case 'linkedin':
      return `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`;
    case 'facebook':
      return `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`;
    case 'reddit':
      return `https://reddit.com/submit?url=${encodedUrl}&title=${encodedTitle}`;
    case 'hackernews':
      return `https://news.ycombinator.com/submitlink?u=${encodedUrl}&t=${encodedTitle}`;
    case 'email':
      return `mailto:?subject=${encodedTitle}&body=${encodedTitle}%0A%0A${encodedUrl}`;
    default:
      return '#';
  }
}
```

### Step 4: Implement Native Share API (Mobile)

Add Web Share API support for mobile devices:

```typescript
async function handleNativeShare(url: string, title: string, description?: string): Promise<boolean> {
  if (typeof navigator !== 'undefined' && navigator.share) {
    try {
      await navigator.share({
        title,
        text: description || title,
        url,
      });
      return true;
    } catch (err) {
      // User cancelled or share failed
      if ((err as Error).name !== 'AbortError') {
        console.error('Share failed:', err);
      }
      return false;
    }
  }
  return false;
}
```

On mobile (detect via user agent or screen width), show a single "Share" button that triggers the native share dialog. Fall back to the platform-specific buttons if the Web Share API is not available.

### Step 5: Implement Copy Link Functionality

Create a copy-to-clipboard function with visual feedback:

```typescript
async function copyToClipboard(url: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(url);
    return true;
  } catch {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = url;
    textArea.style.position = 'fixed';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.select();
    const success = document.execCommand('copy');
    document.body.removeChild(textArea);
    return success;
  }
}
```

Show visual feedback when copied:
- Change button text/icon to "Copied!" or a checkmark
- Reset after 2 seconds
- Use a toast notification if the project has a toast system

### Step 6: Add Icons

Use platform-appropriate icons for each share button:
- If the project uses an icon library (Lucide, Heroicons, etc.), use it
- If not, create minimal inline SVG icons for each platform
- Keep icons accessible with `aria-label` attributes
- Use brand colors for each platform icon (Twitter blue, LinkedIn blue, Facebook blue, Reddit orange, HN orange)

Provide both filled and outline icon variants matching the component's `variant` prop.

### Step 7: Implement Click Tracking

Track share button clicks for analytics:

```typescript
function trackShareClick(platform: string, url: string, title: string) {
  // If the project has an analytics module, use it
  if (typeof trackEvent === 'function') {
    trackEvent('social_share', {
      platform,
      url,
      title,
      location: window.location.pathname,
    });
  }

  // Also fire a custom DOM event for flexibility
  window.dispatchEvent(new CustomEvent('share-click', {
    detail: { platform, url, title },
  }));
}
```

Integrate with the project's existing analytics setup if present (check for the analytics utility module from `/mkt/analytics`).

### Step 8: Create Layout Variants

Implement multiple layout options:

**Horizontal (default):**
- Share buttons in a row, suitable for inline placement
- Responsive: wraps on small screens

**Vertical:**
- Share buttons stacked vertically
- Suitable for sidebar placement

**Floating:**
- Fixed position on the left or right side of the viewport
- Visible during scroll
- Collapses to a single share icon on mobile
- Appears after scrolling past a threshold (e.g., 200px)

### Step 9: Ensure OG Tags on Shareable Pages

Check that all pages where the share component is used have proper OG tags:
- `og:title` - matches the page title
- `og:description` - matches the page description
- `og:image` - has a proper 1200x630 image
- `og:url` - canonical URL
- `twitter:card` - set to `summary_large_image`

If OG tags are missing, add them or recommend running `/seo/meta-tags` to implement them.

### Step 10: Accessibility

Ensure the share component is fully accessible:
- Each button has an `aria-label` (e.g., "Share on Twitter")
- Keyboard navigable (Tab between buttons, Enter/Space to activate)
- Focus visible styles on all buttons
- Share links open in a new window (`target="_blank"` with `rel="noopener noreferrer"`)
- Color contrast meets WCAG AA (4.5:1 minimum)
- Announce "Link copied" to screen readers when copy button is used (via `aria-live` region)

### Step 11: Integrate with Target Pages

If a `<component-path>` was provided, add the share component to that specific component/page.

If no path was provided, identify the most shareable pages in the project and add the share component:
- Blog post pages
- Product pages
- Landing pages
- Any content-heavy pages

Place the share buttons in a natural location:
- Below the page title or at the end of content for articles
- In a sidebar for long-form content
- As a floating bar for scrollable pages

### Step 12: Summary

Report what was implemented:

```
## Social Sharing Implementation

- Framework: [detected framework]
- Styling: [detected styling system]
- Platforms: Twitter, LinkedIn, Facebook, Reddit, Hacker News, Email, Copy Link
- Native Share API: Yes (mobile fallback)
- Layout variants: horizontal, vertical, floating

### Files Created/Modified
- Share component: [file path]
- Share utility: [file path]
- Icons: [file path or "inline SVGs"]
- Updated pages: [list of file paths]

### Features
- UTM parameter tracking on all share URLs
- Click tracking integration
- Native Web Share API on mobile
- Copy to clipboard with visual feedback
- Keyboard accessible
- Screen reader friendly

### TODOs for the User
- [ ] Verify OG tags on all shareable pages (run /seo/meta-tags)
- [ ] Set up OG images (run /mkt/og-image)
- [ ] Add Twitter handle to share component config (via prop)
- [ ] Customize brand colors for share buttons if needed
- [ ] Test social card previews after deployment
```
