# Email Template Generator

Generate responsive, production-ready email templates for common transactional and marketing email types, with framework integration and sending service setup.

## Arguments

$ARGUMENTS - Required: `<email-type>` - one of: welcome, verify, reset-password, invoice, notification, newsletter, onboarding, abandoned-cart

## Instructions

You are generating a production-ready email template. Follow each step carefully.

### Step 1: Parse Arguments and Detect Project Context

1. **Email type**: Extract from `$ARGUMENTS`. Valid types:
   - `welcome` - New user welcome email
   - `verify` - Email verification
   - `reset-password` - Password reset
   - `invoice` - Payment/invoice receipt
   - `notification` - Generic notification with action
   - `newsletter` - Newsletter/digest email
   - `onboarding` - Onboarding drip sequence (day 1/3/7)
   - `abandoned-cart` - Cart abandonment recovery

2. **Detect email framework**: Check for existing email tooling:
   - React Email (`@react-email/components`)
   - MJML (`mjml`)
   - Handlebars/EJS templates
   - Raw HTML email templates
   - If none found, default to React Email for JS/TS projects, raw HTML otherwise

3. **Detect sending service**: Check for:
   - Resend (`resend`)
   - SendGrid (`@sendgrid/mail`)
   - AWS SES (`@aws-sdk/client-ses`, `aws-sdk`)
   - Nodemailer (`nodemailer`)
   - Postmark (`postmark`)
   - If none found, recommend Resend and provide setup instructions

4. **Brand detection**: Look for:
   - Color variables/theme: Tailwind config, CSS variables, theme files
   - Logo: `logo.svg`, `logo.png` in public/assets
   - Company name: package.json name, site config, .env
   - If not found, use professional defaults (blue primary, neutral text)

### Step 2: Generate Email Template

#### Base Layout

Every email template needs a shared layout wrapper:

```
emails/
  _layout.tsx        # Shared layout (header, footer, styles)
  welcome.tsx
  verify.tsx
  reset-password.tsx
  invoice.tsx
  notification.tsx
  newsletter.tsx
  onboarding-day1.tsx
  onboarding-day3.tsx
  onboarding-day7.tsx
  abandoned-cart.tsx
```

**Layout includes:**
- Email width: 600px max (centered)
- Background: light gray (#f4f4f5)
- Content area: white background
- Header: Logo + company name
- Footer: Company address, unsubscribe link, social links
- Preheader text support (hidden preview text)
- Font: System font stack (Arial, Helvetica, sans-serif for email compatibility)

#### Template: Welcome

```
Subject: Welcome to {Company} - Let's get started!
Preheader: You're all set. Here's what to do next.

[Logo]

Hi {firstName},

Welcome to {Company}! We're excited to have you on board.

Here's how to get started:

[Step 1 Icon] Complete your profile
Set up your account to get the most out of {Company}.

[Step 2 Icon] Explore features
Check out our key features and start using them right away.

[Step 3 Icon] Join the community
Connect with other users and get tips.

[Primary CTA: Get Started]

Need help? Reply to this email or visit our help center.

[Footer: company address, unsubscribe, social links]
```

**Dynamic data placeholders:**
- `{{firstName}}` - User's first name
- `{{companyName}}` - Company name
- `{{dashboardUrl}}` - Link to dashboard/app
- `{{helpUrl}}` - Link to help center

#### Template: Verify Email

```
Subject: Verify your email address
Preheader: Click the button below to verify your email.

[Logo]

Hi {firstName},

Please verify your email address to complete your registration.

[Primary CTA: Verify Email Address]
(Links to: {verificationUrl})

Or copy and paste this link:
{verificationUrl}

This link expires in {expiryHours} hours.

If you didn't create an account, you can safely ignore this email.

[Footer]
```

**Dynamic data:**
- `{{firstName}}`, `{{verificationUrl}}`, `{{expiryHours}}`

#### Template: Reset Password

```
Subject: Reset your password
Preheader: We received a request to reset your password.

[Logo]

Hi {firstName},

We received a request to reset your password. Click the button below to choose a new password.

[Primary CTA: Reset Password]
(Links to: {resetUrl})

Or copy and paste this link:
{resetUrl}

This link expires in {expiryMinutes} minutes.

If you didn't request a password reset, please ignore this email or contact support if you're concerned about your account security.

[Footer]
```

**Security notes in template:**
- Never include the actual password
- Include IP/location of request if available
- Link expires within 1 hour

#### Template: Invoice

```
Subject: Invoice #{invoiceNumber} from {Company}
Preheader: Your invoice for {amount} is ready.

[Logo]

Invoice #{invoiceNumber}

Date: {invoiceDate}
Due: {dueDate}

Bill to:
{customerName}
{customerEmail}

[Items Table]
| Item          | Qty | Unit Price | Amount |
|---------------|-----|------------|--------|
| {item.name}   | {q} | {price}    | {total}|
|               |     | Subtotal   | {sub}  |
|               |     | Tax ({r}%) | {tax}  |
|               |     | Total      | {total}|

Payment method: {paymentMethod} ending in {last4}

[Primary CTA: View Invoice]
[Secondary CTA: Download PDF]

[Footer]
```

**Dynamic data:**
- `{{invoiceNumber}}`, `{{invoiceDate}}`, `{{dueDate}}`
- `{{customerName}}`, `{{customerEmail}}`
- `{{items[]}}` - Array of line items
- `{{subtotal}}`, `{{tax}}`, `{{total}}`
- `{{paymentMethod}}`, `{{last4}}`

#### Template: Notification

```
Subject: {notificationTitle}
Preheader: {preheaderText}

[Logo]

Hi {firstName},

{notificationBody}

[Primary CTA: {actionText}]
(Links to: {actionUrl})

{additionalContext}

[Footer]
```

**Dynamic data:**
- `{{notificationTitle}}`, `{{notificationBody}}`
- `{{actionText}}`, `{{actionUrl}}`
- `{{additionalContext}}`

#### Template: Newsletter

```
Subject: {newsletterTitle} - {Company} Newsletter
Preheader: {preheaderText}

[Logo]

{introText}

--- Featured Article ---
[Article Image]
{article.title}
{article.excerpt}
[Read More -> {article.url}]

--- More Articles ---
{article.title} - {article.excerpt} [Read ->]
{article.title} - {article.excerpt} [Read ->]
{article.title} - {article.excerpt} [Read ->]

--- Quick Links ---
[Product Update] [Blog] [Community]

[Primary CTA: Visit Our Blog]

[Footer with prominent Unsubscribe link]
```

**Dynamic data:**
- `{{newsletterTitle}}`, `{{introText}}`
- `{{articles[]}}` - Array of articles with title, excerpt, url, imageUrl
- `{{quickLinks[]}}` - Array of quick links

#### Template: Onboarding (Day 1 / Day 3 / Day 7)

**Day 1:**
```
Subject: Getting started with {Company}
Focus: Quick win - complete one key action
CTA: Complete your first [action]
```

**Day 3:**
```
Subject: Did you know? {Feature highlight}
Focus: Feature discovery - show a powerful feature
CTA: Try {feature}
```

**Day 7:**
```
Subject: You're doing great! Here's what's next
Focus: Engagement - show progress and next steps
CTA: Upgrade / Invite team / Explore advanced features
```

Each onboarding email should:
- Reference the user's progress or activity
- Highlight one specific feature or benefit
- Include a single clear CTA
- Be concise (under 200 words of body text)

#### Template: Abandoned Cart

```
Subject: You left something behind!
Preheader: Your items are waiting for you.

[Logo]

Hi {firstName},

You left some items in your cart. They're still available!

[Cart Items]
[Product Image] {product.name} - {product.price}
[Product Image] {product.name} - {product.price}

Cart Total: {cartTotal}

[Primary CTA: Complete Your Purchase]

{Optional: Discount offer}
Use code {discountCode} for {discountPercent}% off your order.
This offer expires in {expiryHours} hours.

[Footer]
```

**Dynamic data:**
- `{{cartItems[]}}` - Array of products with name, price, image, quantity
- `{{cartTotal}}`, `{{discountCode}}`, `{{discountPercent}}`, `{{expiryHours}}`

### Step 3: Implement Email Templates

#### React Email Implementation

```typescript
// emails/welcome.tsx
import {
  Body, Button, Container, Head, Heading, Hr,
  Html, Img, Link, Preview, Section, Text,
} from '@react-email/components';

interface WelcomeEmailProps {
  firstName: string;
  dashboardUrl: string;
}

export default function WelcomeEmail({ firstName, dashboardUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to Company - Let's get started!</Preview>
      <Body style={main}>
        <Container style={container}>
          {/* ... template content ... */}
        </Container>
      </Body>
    </Html>
  );
}

// Inline styles (required for email compatibility)
const main = { backgroundColor: '#f4f4f5', fontFamily: 'Arial, sans-serif' };
const container = { margin: '0 auto', padding: '20px', maxWidth: '600px' };
// ... more styles
```

#### MJML Implementation

```xml
<mjml>
  <mj-head>
    <mj-attributes>
      <mj-all font-family="Arial, sans-serif" />
      <mj-text font-size="14px" color="#333333" />
    </mj-attributes>
  </mj-head>
  <mj-body background-color="#f4f4f5">
    <mj-section background-color="#ffffff">
      <!-- ... template content ... -->
    </mj-section>
  </mj-body>
</mjml>
```

#### Raw HTML Implementation

Use table-based layout for maximum compatibility:
- Use `<table>` for layout (not `<div>`)
- Inline all CSS styles
- Use `bgcolor` attribute for backgrounds
- Use `width` attribute on tables
- Test in Litmus or Email on Acid

### Step 4: Email Sending Integration

#### Resend (Recommended)

```typescript
// lib/email.ts
import { Resend } from 'resend';
import WelcomeEmail from '@/emails/welcome';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendWelcomeEmail(to: string, firstName: string) {
  const { data, error } = await resend.emails.send({
    from: 'Company <hello@company.com>',
    to,
    subject: `Welcome to Company, ${firstName}!`,
    react: WelcomeEmail({ firstName, dashboardUrl: `${process.env.APP_URL}/dashboard` }),
  });

  if (error) {
    console.error('Failed to send welcome email:', error);
    throw new Error(`Email send failed: ${error.message}`);
  }

  return data;
}
```

#### SendGrid

```typescript
import sgMail from '@sendgrid/mail';
sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

export async function sendEmail(to: string, subject: string, html: string) {
  await sgMail.send({
    to,
    from: 'hello@company.com',
    subject,
    html,
  });
}
```

#### AWS SES

```typescript
import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

const ses = new SESClient({ region: process.env.AWS_REGION });

export async function sendEmail(to: string, subject: string, html: string) {
  await ses.send(new SendEmailCommand({
    Destination: { ToAddresses: [to] },
    Message: {
      Subject: { Data: subject },
      Body: { Html: { Data: html } },
    },
    Source: 'hello@company.com',
  }));
}
```

### Step 5: Email Preview and Testing

Set up email preview for development:

#### React Email Dev Server
```json
{
  "scripts": {
    "email:dev": "email dev --dir emails --port 3001"
  }
}
```

#### Testing Checklist
- [ ] Renders correctly in Gmail (web + mobile)
- [ ] Renders correctly in Outlook (desktop + web)
- [ ] Renders correctly in Apple Mail
- [ ] Renders correctly in Yahoo Mail
- [ ] All links work and have proper UTM parameters
- [ ] Images have alt text
- [ ] Preheader text displays correctly
- [ ] Unsubscribe link works
- [ ] Dynamic data renders correctly
- [ ] Email passes spam checks (SPF, DKIM, DMARC)
- [ ] Total email size under 100KB
- [ ] Plain text fallback exists

### Step 6: Compliance

Ensure all templates include:

1. **CAN-SPAM compliance** (US):
   - Physical mailing address in footer
   - Clear unsubscribe mechanism
   - Accurate subject lines
   - Identified as advertisement (if marketing)

2. **GDPR compliance** (EU):
   - Unsubscribe link
   - Link to privacy policy
   - Data processing rationale

3. **Best practices**:
   - `List-Unsubscribe` header support
   - Double opt-in for marketing emails
   - Preference center link (manage email preferences)

### Important Notes

- ALL CSS must be inline for email compatibility -- do not use external stylesheets
- Use table-based layouts for Outlook compatibility
- Images should have absolute URLs and alt text
- Keep total email size under 100KB for deliverability
- Test with real email clients, not just browser preview
- Use system fonts (Arial, Helvetica, Georgia) for maximum compatibility
- Button CTAs should use `<a>` tags styled as buttons with padding, not `<button>` elements
- Dark mode support: add `@media (prefers-color-scheme: dark)` styles where supported
- Store email sending API keys in environment variables, never hardcode
- Add proper error handling and retry logic for sending failures
