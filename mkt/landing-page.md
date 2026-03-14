# Landing Page Generator

Generate a high-converting, responsive, SEO-optimized landing page using the project's existing framework and design system.

## Arguments

$ARGUMENTS - Required `<product-description>`: A brief description of the product, service, or offering the landing page is for. Include key value propositions, target audience, and any specific requirements.

## Instructions

### Step 1: Analyze the Product

Parse the product description to extract:
- **Product name** and category
- **Target audience** and their pain points
- **Key value propositions** (3-5 main benefits)
- **Differentiators** from competitors
- **Desired action** (sign up, buy, book demo, download, etc.)

If the description is too vague, ask the user to clarify the target audience and primary CTA before proceeding.

### Step 2: Detect Project Framework and Design System

Examine the codebase to determine:
- Framework: Next.js, Nuxt, Astro, React, Vue, Svelte, static HTML, etc.
- Styling: Tailwind CSS, CSS Modules, styled-components, Chakra UI, shadcn/ui, etc.
- Existing components: Check for a component library, design tokens, theme configuration
- Typography and color scheme from existing pages or theme config
- Existing layout patterns (header, footer, navigation) to maintain consistency

Reuse existing components and design patterns. The landing page should feel like a natural part of the existing site.

### Step 3: Generate Page Structure

Create the landing page with these sections in order:

**1. Hero Section**
- Compelling headline (5-10 words, addresses the core benefit)
- Supporting subheadline (1-2 sentences expanding on the headline)
- Primary CTA button (action-oriented text: "Start Free Trial", "Get Started", "Book a Demo")
- Optional secondary CTA (lower commitment: "Learn More", "Watch Demo")
- Hero image or illustration placeholder (with proper alt text)
- Social proof snippet below CTA (e.g., "Trusted by 10,000+ teams" or star rating)

**2. Social Proof Bar**
- Logo strip of notable customers/partners (use placeholder images with alt text)
- Or: Key metrics ("50K+ users", "4.9/5 rating", "99.9% uptime")
- Keep it concise, one horizontal row

**3. Problem/Solution Section**
- Articulate the problem the target audience faces (2-3 pain points)
- Present the product as the solution
- Use a before/after or problem/solution layout
- Include a relevant visual (screenshot, illustration, or icon grid)

**4. Features Section**
- 3-6 key features in a grid or alternating layout
- Each feature: icon/image, title (3-5 words), description (1-2 sentences)
- Focus on benefits, not just features ("Save 10 hours/week" not "Automated reporting")
- Optional: Link each feature to a more detailed page

**5. How It Works Section**
- 3-4 steps showing the user journey
- Numbered steps with title and brief description
- Visual progression (icons, screenshots, or illustrations)
- Ends with the outcome/result the user achieves

**6. Testimonials Section**
- 2-3 customer testimonials
- Each: quote text, person name, title/company, avatar placeholder
- Use a carousel or grid layout
- Include real-looking but placeholder content (mark clearly with TODO comments for real data)

**7. Pricing Section (if applicable)**
- 2-3 pricing tiers (or single plan)
- Plan name, price, billing period
- Feature list per plan with checkmarks
- Highlighted "most popular" tier
- CTA button per plan
- If pricing is not relevant, skip this section

**8. FAQ Section**
- 5-8 common questions and answers
- Expandable accordion pattern
- Questions derived from the product description and common objections
- Include JSON-LD FAQPage structured data

**9. Final CTA Section**
- Reinforcing headline summarizing the value
- Brief motivating text
- Primary CTA button (same as hero)
- Optional urgency element (but avoid dark patterns)

### Step 4: Implement Responsive Design

Ensure the page is fully responsive:
- Mobile-first approach
- Stack horizontal layouts vertically on mobile
- Appropriate font sizes (minimum 16px body text on mobile)
- Touch-friendly button sizes (minimum 44x44px tap targets)
- No horizontal scrolling at any viewport
- Test at: 320px (mobile), 768px (tablet), 1024px (laptop), 1440px (desktop)
- Use the project's existing responsive utilities (Tailwind breakpoints, media queries, etc.)

### Step 5: Implement SEO

Add complete SEO for the landing page:
- Title tag under 60 characters with primary keyword
- Meta description under 155 characters with CTA
- Canonical URL
- Open Graph tags (title, description, image, url, type)
- Twitter Card tags
- JSON-LD structured data (FAQPage for the FAQ section, Organization or Product as appropriate)
- Proper heading hierarchy (single H1 in hero, H2 for sections, H3 for subsections)
- Alt text on all images

### Step 6: Performance Optimization

Apply performance best practices:
- Lazy load images below the fold (`loading="lazy"`)
- Preload critical hero image if applicable
- Use next/image or framework-specific optimized image components
- Minimize client-side JavaScript (prefer static/server-rendered content)
- Add width and height to all images to prevent CLS
- Use system font stack or properly loaded web fonts with `font-display: swap`
- Keep the page under 200KB transferred (excluding images)

### Step 7: Add Micro-Interactions (subtle)

Add tasteful interactions that enhance UX without hurting performance:
- Smooth scroll for anchor links to page sections
- Hover states on buttons and interactive elements
- Fade-in or slide-up animations on scroll for content sections (use CSS animations or Intersection Observer, not heavy JS libraries)
- Focus states for accessibility

### Step 8: Accessibility

Ensure the page is accessible:
- Semantic HTML elements (header, main, section, footer, nav)
- Proper ARIA labels where needed
- Sufficient color contrast (WCAG AA minimum, 4.5:1 for text)
- Keyboard navigation support
- Screen reader-friendly content order
- Skip-to-content link

### Step 9: Create the Page File

Create the page file in the appropriate location for the framework:
- Next.js App Router: `app/[page-name]/page.tsx`
- Next.js Pages: `pages/[page-name].tsx`
- Nuxt: `pages/[page-name].vue`
- Astro: `src/pages/[page-name].astro`
- Static: `[page-name].html` or `[page-name]/index.html`

Extract reusable section components if the project follows a component-based architecture.

### Step 10: Summary

Report what was created:

```
## Landing Page Summary

- Page: [file path]
- URL: /[page-name]
- Framework: [detected framework]
- Styling: [detected styling system]
- Sections: Hero, Social Proof, Problem/Solution, Features, How It Works, Testimonials, Pricing, FAQ, Final CTA

### TODOs for the User
- [ ] Replace placeholder testimonials with real customer quotes
- [ ] Replace logo strip placeholders with actual partner logos
- [ ] Add real product screenshots/images
- [ ] Update pricing if applicable
- [ ] Add analytics tracking (use /mkt/analytics)
- [ ] Set up OG image (use /mkt/og-image)
- [ ] Connect CTA buttons to signup/payment flow

### Files Created/Modified
- [list of file paths]
```
