# Dynamic OG Image Generator

Set up dynamic Open Graph image generation for shareable pages, using Vercel OG (Satori) or a similar approach to create branded social preview images on the fly.

## Instructions

### Step 1: Detect Project Framework

Examine the codebase to determine the best OG image generation approach:

- **Next.js (App Router)**: Use `next/og` (built-in ImageResponse based on Satori) - create `opengraph-image.tsx` files or an API route
- **Next.js (Pages Router)**: Use `@vercel/og` package with an API route at `pages/api/og.ts`
- **Nuxt/Vue**: Use `@nuxt/og-image` module or a server route with Satori
- **Astro**: Use `@vercel/og` or `satori` directly in an API endpoint
- **Express/Node**: Use `satori` + `@resvg/resvg-js` to generate PNG from JSX-like markup
- **Other**: Use `satori` directly with the appropriate server-side rendering setup

Also check for:
- Existing brand assets (logo, fonts, colors)
- Existing OG image setup to extend rather than replace
- TypeScript or JavaScript usage

### Step 2: Install Dependencies

Install the necessary packages based on the framework:

| Framework | Packages |
|-----------|----------|
| Next.js App Router | Built-in `next/og` (no install needed) |
| Next.js Pages Router | `@vercel/og` |
| Other Node.js | `satori`, `@resvg/resvg-js`, `sharp` (optional) |

If custom fonts are needed, download font files (e.g., Inter, project's brand font) and place them in a location accessible to the API route (e.g., `public/fonts/` or `assets/fonts/`).

### Step 3: Create the OG Image API Route

**Next.js App Router - Route Handler approach (`app/api/og/route.tsx`):**

Create an API route that accepts query parameters and returns a generated image:
- `title` - The page title to display
- `description` - Optional subtitle or description
- `type` - Optional page type (blog, product, default) for different layouts

The route should:
1. Parse query parameters
2. Load the brand font
3. Generate the image using `ImageResponse`
4. Return a PNG image with proper cache headers

**Design the image template with:**
- Dimensions: 1200x630 pixels (standard OG image size)
- Background: Brand gradient or solid color
- Logo: Brand logo in the corner
- Title: Large, bold text (primary content)
- Description: Smaller supporting text
- Footer: Domain name or brand tagline
- Visual accent: Decorative elements (gradient shapes, patterns)

Use JSX-like syntax that Satori understands (a subset of CSS Flexbox):
- Satori supports: `display: flex`, `flexDirection`, `alignItems`, `justifyContent`, `padding`, `margin`, `fontSize`, `fontWeight`, `color`, `backgroundColor`, `borderRadius`, `border`, `position`, `top/left/right/bottom`, `width`, `height`, `overflow`
- Satori does NOT support: CSS Grid, `box-shadow`, `text-shadow`, `transform` (limited), custom CSS properties
- Use `tw` prop for Tailwind-like classes if using `@vercel/og`

### Step 4: Create Multiple Templates

Create different OG image templates for different page types:

**Default template:**
- Brand logo top-left
- Large title centered
- Subtle description below
- Brand gradient background
- Domain in footer

**Blog/Article template:**
- "Blog" or category label at top
- Article title prominently displayed
- Author name and date
- Reading time indicator
- Different color scheme from default

**Product template:**
- Product name
- Key feature or tagline
- Price or "Free" badge
- Brand logo

Create a template selection mechanism based on the `type` query parameter.

### Step 5: Handle Dynamic Data

For pages with dynamic content, ensure the OG image route can accept the necessary data:

```
/api/og?title=How+to+Build+a+Startup&type=blog&author=Jane+Doe&date=2024-01-15
```

URL-encode all parameter values. Validate and sanitize inputs:
- Truncate titles longer than 100 characters
- Provide default values for missing parameters
- Escape any HTML entities in the text

### Step 6: Integrate with Pages

Update each shareable page to use the dynamic OG image:

**Next.js App Router with `opengraph-image.tsx`:**
Create `opengraph-image.tsx` files alongside page files for automatic OG image generation. Or use the API route approach with `generateMetadata`:

```typescript
export async function generateMetadata({ params }): Promise<Metadata> {
  return {
    openGraph: {
      images: [{
        url: `/api/og?title=${encodeURIComponent(title)}&type=blog`,
        width: 1200,
        height: 630,
        alt: title,
      }],
    },
    twitter: {
      card: 'summary_large_image',
      images: [`/api/og?title=${encodeURIComponent(title)}&type=blog`],
    },
  };
}
```

**For other frameworks:**
Set the `og:image` and `twitter:image` meta tags to point to the API route URL with appropriate query parameters. Use absolute URLs (include the domain).

### Step 7: Add Caching

Configure caching for generated OG images to avoid regeneration on every request:

- Use `Cache-Control: public, max-age=86400, s-maxage=86400, stale-while-revalidate=604800`
- For Vercel: Use the Edge Runtime for faster cold starts
- For self-hosted: Consider caching generated images to disk or a CDN
- Set `Content-Type: image/png` response header

For Next.js App Router:
```typescript
export const runtime = 'edge'; // Faster cold starts on Vercel
```

### Step 8: Font Loading

Load custom fonts for the OG image:

```typescript
// Load font file
const fontData = await fetch(
  new URL('../../assets/fonts/Inter-Bold.ttf', import.meta.url)
).then((res) => res.arrayBuffer());

// Use in ImageResponse
new ImageResponse(element, {
  width: 1200,
  height: 630,
  fonts: [
    { name: 'Inter', data: fontData, weight: 700, style: 'normal' },
  ],
});
```

If the project has a custom brand font, use it. Otherwise, use Inter or the project's configured font. Always include a fallback (Satori bundles Noto Sans as a fallback).

### Step 9: Testing Instructions

Provide testing instructions:

```
## Testing Your OG Images

### Local Testing
1. Start the dev server
2. Visit: http://localhost:3000/api/og?title=Test+Title&type=default
3. You should see a 1200x630 PNG image

### Social Card Preview Tools
- **Twitter Card Validator**: https://cards-dev.twitter.com/validator
- **Facebook Sharing Debugger**: https://developers.facebook.com/tools/debug/
- **LinkedIn Post Inspector**: https://www.linkedin.com/post-inspector/
- **OpenGraph.xyz**: https://www.opengraph.xyz/

### Verify Meta Tags
1. View page source on any shareable page
2. Search for og:image and twitter:image meta tags
3. Verify the URL is absolute and accessible

### Common Issues
- Image not showing: Ensure og:image URL is absolute (includes domain)
- Blurry image: Ensure dimensions are exactly 1200x630
- Font not loading: Check font file path and format (must be TTF or OTF for Satori)
- Timeout on generation: Reduce image complexity, use Edge Runtime
```

### Step 10: Summary

Report what was implemented:

```
## OG Image Generator Summary

- Framework: [detected framework]
- Approach: [next/og | @vercel/og | satori + resvg]
- Templates: [default, blog, product]
- Font: [font name used]

### API Route
- URL: /api/og
- Parameters: title, description, type, author, date
- Output: 1200x630 PNG image
- Caching: 24-hour cache with stale-while-revalidate

### Files Created/Modified
- API route: [file path]
- Font files: [file path] (if added)
- Updated pages with og:image: [list of file paths]

### Usage Examples
- Default: /api/og?title=Your+Page+Title
- Blog: /api/og?title=Blog+Post+Title&type=blog&author=Name
- Product: /api/og?title=Product+Name&type=product

### TODOs for the User
- [ ] Add your brand logo file (replace placeholder)
- [ ] Customize colors to match your brand
- [ ] Add brand font file if using a custom font
- [ ] Set NEXT_PUBLIC_SITE_URL for absolute URLs in production
- [ ] Test with social card preview tools after deployment
```
