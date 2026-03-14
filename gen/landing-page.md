# Landing Page Generator

Generate a high-converting landing page with proven conversion structure, responsive design, SEO optimization, and performance best practices.

## Arguments

$ARGUMENTS - Required: `<product-description>` or `<product-name>` describing what the landing page is for

## Instructions

You are generating a complete, high-converting landing page. Follow each step carefully.

### Step 1: Analyze Product and Detect Framework

1. **Parse product info**: Extract from `$ARGUMENTS`:
   - Product/service name
   - What it does (value proposition)
   - Target audience (inferred from description)
   - Key differentiators
2. **Detect framework**: Scan the project for Next.js, React, Vue, Astro, SvelteKit, static HTML, etc.
3. **Detect design system**: Check for Tailwind CSS, CSS Modules, styled-components, Chakra UI, shadcn/ui, MUI, etc.
4. **Check existing patterns**: Look at existing pages/components for styling conventions, component patterns, and project structure

If no framework or styling system is detected, default to HTML + Tailwind CSS (via CDN for static, installed for frameworks).

### Step 2: Generate Landing Page Content

Based on the product description, generate compelling copy for each section:

#### 2.1 Hero Section
- **Headline**: 6-12 words, benefit-focused, addresses the target audience's main desire
- **Subheadline**: 1-2 sentences expanding on the headline, adds specificity
- **Primary CTA**: Action-oriented button text (e.g., "Start Free Trial", "Get Started Free", "Book a Demo")
- **Secondary CTA**: Lower-commitment option (e.g., "Watch Demo", "See How It Works")
- **Social proof snippet**: "Trusted by 10,000+ teams" or "4.9 stars from 500+ reviews" (use placeholder numbers)
- **Hero visual**: Placeholder for product screenshot, video, or illustration

#### 2.2 Logo Bar / Social Proof Strip
- "Trusted by teams at" with 4-6 company logo placeholders
- OR key metrics: "10K+ Users", "99.9% Uptime", "50M+ Processed"

#### 2.3 Problem Section
- Section title: "The Problem" or a question that resonates with pain
- 3 pain points with icons, each as:
  - Short title (3-5 words)
  - 1-2 sentence description of the frustration
- Transition sentence leading to the solution

#### 2.4 Solution / How It Works
- Section title: "How It Works" or "The Solution"
- 3-step process:
  - Step 1: Title + description + icon/image placeholder
  - Step 2: Title + description + icon/image placeholder
  - Step 3: Title + description + icon/image placeholder
- Each step should feel simple and achievable

#### 2.5 Features Section
- Section title: "Everything You Need" or "Features"
- 6-9 features in a grid layout:
  - Feature icon placeholder
  - Feature title (2-4 words)
  - Feature description (1-2 sentences)
- Highlight the most differentiating features

#### 2.6 Testimonials
- Section title: "What Our Customers Say" or "Loved by Teams"
- 3 testimonial cards:
  - Quote text (2-3 sentences, realistic and specific)
  - Person name (placeholder)
  - Person title and company (placeholder)
  - Avatar placeholder
- Use varied testimonials covering different benefits

#### 2.7 Pricing Section (Optional but Recommended)
- Section title: "Simple, Transparent Pricing"
- 2-3 pricing tiers:
  - **Free/Starter**: Basic features, limited usage
  - **Pro/Growth**: Full features, higher limits, highlighted as "Most Popular"
  - **Enterprise/Team**: Custom pricing, premium features
- Each tier: name, price, billing period, feature list, CTA button
- Annual/monthly toggle if applicable

#### 2.8 FAQ Section
- Section title: "Frequently Asked Questions"
- 5-8 Q&A pairs relevant to the product:
  - What does the product do?
  - How much does it cost?
  - Is there a free trial?
  - How do I get started?
  - What support is available?
  - Can I cancel anytime?
  - Is my data secure?
- Collapsible/accordion pattern

#### 2.9 Final CTA Section
- Bold headline restating the main value proposition
- Subtext with urgency or additional incentive
- Primary CTA button (same as hero)
- Trust indicators: "No credit card required", "14-day free trial", "Cancel anytime"

#### 2.10 Footer
- Company name/logo
- Navigation links: Product, Pricing, Blog, Docs, Contact, Careers
- Legal links: Privacy Policy, Terms of Service
- Social media icon links: Twitter/X, LinkedIn, GitHub, etc.
- Copyright notice with current year

### Step 3: Implement the Page

Create the landing page using the detected framework and design system.

#### Component Structure
```
components/landing/
  Hero.tsx
  LogoBar.tsx
  ProblemSection.tsx
  HowItWorks.tsx
  Features.tsx
  Testimonials.tsx
  Pricing.tsx
  FAQ.tsx
  FinalCTA.tsx
  Footer.tsx
```

Or if the project prefers a single-file approach, create one page file with clearly marked sections.

#### Responsive Design (Mobile-First)
- Mobile: Single column, stacked layout, full-width CTAs
- Tablet (768px+): 2-column grids where appropriate
- Desktop (1024px+): Full layout with max-width container (1200-1400px)
- Large desktop (1440px+): Comfortable spacing, centered content

#### Design Principles
- **Visual hierarchy**: Clear heading sizes (H1 > H2 > H3), consistent spacing
- **White space**: Generous padding between sections (py-16 to py-24)
- **Color**: Use project's color palette; if none, use a professional blue/indigo primary with neutral grays
- **Typography**: System font stack or project's configured fonts; limit to 2 font families
- **Contrast**: Ensure all text meets WCAG AA contrast ratios
- **CTAs**: High contrast, consistent styling, adequate padding for touch targets (min 44x44px)

#### Animation and Interactivity
- Smooth scroll for anchor links
- Subtle fade-in animations on scroll (use Intersection Observer or framer-motion if available)
- Hover states on interactive elements
- FAQ accordion open/close transitions
- Pricing toggle animation (if monthly/yearly toggle)
- Do NOT add excessive animations that hurt performance

### Step 4: SEO Optimization

Add to the landing page:

1. **Meta tags**: Title, description, OG tags, Twitter Card tags (use the SEO meta skill pattern)
2. **Semantic HTML**: Proper heading hierarchy (single H1, H2 for sections, H3 for subsections)
3. **JSON-LD**: Organization or Product structured data
4. **Alt text**: Descriptive alt attributes on all images
5. **Internal links**: Link to relevant pages (pricing, docs, blog)
6. **Fast load**: Lazy load below-fold images, optimize critical rendering path

### Step 5: Performance Optimization

1. **Images**: Use `next/image`, `<picture>`, or `loading="lazy"` for all images
2. **Fonts**: Preload critical fonts, use `font-display: swap`
3. **CSS**: Minimize unused CSS; use Tailwind's purge or CSS modules
4. **JavaScript**: Minimize client-side JS; use static/SSG rendering where possible
5. **Above-the-fold**: Ensure hero section renders without JavaScript (SSR/SSG)
6. **Bundle size**: Avoid heavy animation libraries; prefer CSS transitions

### Step 6: Accessibility

1. **Keyboard navigation**: All interactive elements focusable and operable
2. **ARIA labels**: Buttons, links, and interactive elements have descriptive labels
3. **Skip navigation**: Add "Skip to main content" link
4. **Focus indicators**: Visible focus outlines on all interactive elements
5. **Color**: Do not convey information through color alone
6. **Motion**: Respect `prefers-reduced-motion` for animations
7. **Headings**: Logical heading order for screen readers

### Step 7: Conversion Tracking Preparation

Add data attributes or comments for analytics integration:
- `data-track="hero-cta-click"` on primary CTA
- `data-track="pricing-plan-select"` on pricing buttons
- `data-track="faq-toggle"` on FAQ items
- `data-section="hero|features|pricing|..."` on each section for scroll tracking

### Output Checklist

After generating the landing page, verify:

- [ ] All 10 sections are implemented
- [ ] Page is fully responsive (mobile, tablet, desktop)
- [ ] Semantic HTML with proper heading hierarchy
- [ ] Meta tags and OG tags are set
- [ ] All images have alt text
- [ ] CTAs are prominent and above the fold
- [ ] FAQ section is functional (accordion)
- [ ] Footer has all required links
- [ ] Pricing section has clear differentiation between tiers
- [ ] Page loads fast (no render-blocking resources)
- [ ] Accessibility: keyboard nav, ARIA, focus states
- [ ] No placeholder "Lorem ipsum" text -- all copy is relevant to the product
- [ ] Color scheme is professional and consistent
- [ ] Spacing and typography follow a consistent scale

### Important Notes

- Generate realistic, compelling copy based on the product description -- never use "Lorem ipsum"
- Use placeholder images with descriptive alt text and size comments (e.g., `{/* 1200x630 hero image */}`)
- Follow the project's existing code conventions (file naming, component patterns, import style)
- If Tailwind is used, prefer utility classes; if CSS modules, create matching style files
- Keep the page performant: target <2s LCP, <0.1 CLS, <200ms INP
- The landing page should work as a standalone page that drives conversions
