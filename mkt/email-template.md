# Email Template Generator

Generate responsive, brand-consistent email templates that work across all major email clients, with sending integration.

## Arguments

$ARGUMENTS - Required `<type>`: one of `welcome`, `verify`, `reset`, `invoice`, `notification`, `newsletter`, `onboarding`, `abandoned-cart`. Specifies the email template type to generate.

## Instructions

### Step 1: Validate the Type Argument

Parse the `<type>` argument. It must be one of:
- `welcome` - Welcome email after signup with getting started steps
- `verify` - Email verification with confirmation link/code
- `reset` - Password reset with secure reset link
- `invoice` - Transaction receipt or invoice with line items
- `notification` - General notification (activity alerts, updates)
- `newsletter` - Newsletter format with multiple content sections
- `onboarding` - Multi-step onboarding drip email (generates a sequence)
- `abandoned-cart` - Cart abandonment recovery with product details

If the argument is missing or invalid, list the valid types and ask the user to specify one.

### Step 2: Detect Project Stack and Email Setup

Examine the codebase for:
- **Email library**: React Email, MJML, Handlebars, EJS, plain HTML
- **Sending service**: Resend, SendGrid, AWS SES, Postmark, Mailgun, Nodemailer
- **Existing templates**: Check for existing email templates to match style
- **Brand assets**: Look for logo, brand colors, fonts in the project
- **Framework**: Next.js API routes, Express, Django, etc.

If no email library is detected, default to **React Email** for React/Next.js projects or **MJML** for others, as both produce reliable cross-client HTML.

### Step 3: Extract Brand Configuration

Gather brand elements from the project:
- Logo URL or path
- Primary and secondary brand colors
- Font family (use web-safe fallbacks for email)
- Company name and support email
- Social media links
- Physical address (required for CAN-SPAM)

If brand info is not found in the project, create a brand config file with placeholder values that the user can fill in.

### Step 4: Generate the Email Template

Create the email template based on the specified type:

**Welcome Email:**
- Subject line: "Welcome to {Product}! Let's get started"
- Personalized greeting with user name
- Brief value reminder (why they signed up)
- 3 quick-start steps with icons/numbers
- Primary CTA button: "Get Started" / "Go to Dashboard"
- Social links and support contact

**Verify Email:**
- Subject line: "Verify your email address"
- Clear purpose statement
- Prominent verification button or code
- Code/link expiration notice
- "Didn't sign up?" disclaimer with support contact
- Security notice

**Reset Password:**
- Subject line: "Reset your password"
- Security context ("We received a request...")
- Prominent reset button with secure link
- Link expiration time (e.g., "This link expires in 1 hour")
- "Didn't request this?" disclaimer
- Security tips

**Invoice:**
- Subject line: "Your receipt from {Product} - {amount}"
- Invoice number and date
- Line items table with descriptions, quantities, prices
- Subtotal, tax, total
- Payment method used (last 4 digits)
- Download PDF link
- Support contact for billing questions

**Notification:**
- Subject line: Dynamic based on notification type
- Clear notification headline
- Context/details of the notification
- Action button relevant to the notification
- Notification preferences link
- Timestamp

**Newsletter:**
- Subject line: Dynamic with issue number or theme
- Header with logo and issue info
- Featured article with image, title, excerpt, read more link
- 2-3 secondary articles in a grid
- Curated links section
- CTA section
- Social sharing links
- Unsubscribe link

**Onboarding (sequence):**
Generate 3-5 emails in a drip sequence:
- Email 1 (Day 0): Welcome + first action
- Email 2 (Day 1): Key feature highlight
- Email 3 (Day 3): Tips and best practices
- Email 4 (Day 7): Check-in and advanced features
- Email 5 (Day 14): Feedback request or upgrade prompt

**Abandoned Cart:**
- Subject line: "You left something behind" or "Your cart is waiting"
- Product image and details from the cart
- Original price and any discounts
- Prominent "Complete Purchase" CTA
- Urgency element (stock availability, cart expiration)
- Customer support contact
- Alternative product suggestions (optional)

### Step 5: Ensure Cross-Client Compatibility

Apply email client compatibility best practices:
- Use table-based layouts for Outlook compatibility
- Inline critical CSS styles
- Use web-safe fonts with fallbacks (Arial, Helvetica, Georgia)
- Maximum width of 600px for the email body
- Use `<td>` for spacing instead of margin/padding where needed for Outlook
- Use `<!--[if mso]>` conditional comments for Outlook-specific fixes
- Alt text on all images
- Background colors on `<td>` instead of `<div>` for Outlook
- VML background images for Outlook if using background images
- Test rendering considerations:
  - Gmail (web and mobile)
  - Outlook (2016, 2019, 365, and Outlook.com)
  - Apple Mail (macOS and iOS)
  - Yahoo Mail

If using React Email or MJML, these handle most cross-client issues automatically. Document any known limitations.

### Step 6: CAN-SPAM and Legal Compliance

Ensure every email template includes:
- Physical mailing address in the footer
- Unsubscribe link (one-click unsubscribe where possible)
- Clear sender identification
- Honest subject lines (no deception)
- For marketing emails: Opt-out mechanism that is processed within 10 business days
- Privacy policy link

Add a `List-Unsubscribe` header recommendation in the sending code.

### Step 7: Create Sending Integration

Implement the email sending function:

**If Resend is used/chosen:**
```typescript
import { Resend } from 'resend';
const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendWelcomeEmail(to: string, data: WelcomeEmailData) {
  return resend.emails.send({
    from: 'Your App <noreply@yourdomain.com>',
    to,
    subject: `Welcome to ${data.productName}!`,
    react: WelcomeEmail(data),
  });
}
```

**If SendGrid is used/chosen:**
```typescript
import sgMail from '@sendgrid/mail';
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

export async function sendWelcomeEmail(to: string, data: WelcomeEmailData) {
  return sgMail.send({
    to,
    from: 'noreply@yourdomain.com',
    subject: `Welcome to ${data.productName}!`,
    html: renderWelcomeEmail(data),
  });
}
```

**If AWS SES is used/chosen:**
```typescript
import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

export async function sendWelcomeEmail(to: string, data: WelcomeEmailData) {
  const client = new SESClient({ region: process.env.AWS_REGION });
  return client.send(new SendEmailCommand({ ... }));
}
```

Create the sending utility in a shared location (e.g., `src/lib/email.ts`, `src/services/email.ts`).

Include:
- Type definitions for each email's data requirements
- Error handling with retries
- Rate limiting awareness
- Environment variable validation at startup

### Step 8: Add Preview Route (Development)

If using React Email, set up the preview server:
- Create email preview routes or use React Email's dev server
- Enable hot reload for email template development

If not using React Email:
- Create a development route that renders the email template with sample data
- Example: `GET /api/email-preview/welcome` renders the welcome email with mock data

### Step 9: Summary

Report what was created:

```
## Email Template Summary

- Type: {template type}
- Library: {React Email / MJML / HTML}
- Sending: {Resend / SendGrid / SES}

### Files Created
- Template: [file path]
- Sending utility: [file path]
- Preview route: [file path]
- Brand config: [file path] (if created)
- Types: [file path] (if TypeScript)

### TODOs for the User
- [ ] Set environment variable: {API_KEY_NAME}
- [ ] Update brand config with real values
- [ ] Verify sending domain is configured with your email provider
- [ ] Replace placeholder logo/images
- [ ] Test with https://www.emailonacid.com/ or https://litmus.com/
- [ ] Add List-Unsubscribe header in production
- [ ] Update physical mailing address for CAN-SPAM compliance

### Required Environment Variables
- {SERVICE}_API_KEY - API key for email sending service
- EMAIL_FROM - Sender email address
- NEXT_PUBLIC_SITE_URL - Base URL for links in emails
```
