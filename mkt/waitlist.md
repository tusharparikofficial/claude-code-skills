# Waitlist Page Builder

Build a pre-launch waitlist page with email capture, referral tracking, and launch countdown.

## Instructions

1. **Detect framework and set up the page**
   - Identify the project framework
   - Create the waitlist page/route
   - Determine data storage approach:
     - Database (if project has one): create waitlist table/model
     - Serverless: use a simple API with external storage (Supabase, PlanetScale, KV)
     - Minimal: use a third-party waitlist service API (Loops, Waitlist API)

2. **Build the waitlist landing page**
   - **Hero section:**
     - Product name and logo
     - Compelling headline: what the product does
     - Subheadline: key benefit or differentiator
     - Email capture form (single input + submit button)
     - Privacy note: "We'll never spam you. Unsubscribe anytime."
   - **Value proposition section:**
     - 3-4 key features/benefits with icons
     - Brief description of each
   - **Launch countdown timer:**
     - Configurable target date
     - Days, hours, minutes, seconds display
     - Real-time countdown using client-side JS
     - Fallback text if launch date has passed: "Launching soon"
   - **Social proof (if available):**
     - Current waitlist count: "Join X+ others"
     - Notable early signups or advisors
   - **Footer:**
     - Social media links
     - Company/founder info

3. **Build the email capture backend**
   - API endpoint to receive email submissions
   - Validate email format
   - Check for duplicate emails (return success but don't duplicate)
   - Generate a unique referral code per signup
   - Store: email, referral_code, referred_by, position, created_at, status
   - Send confirmation/welcome email (or integrate with email service)
   - Rate limit submissions (prevent abuse)

4. **Implement referral tracking system**
   - Generate a unique referral link per signup: `?ref={referral_code}`
   - On the thank-you page, show:
     - Waitlist position number
     - Unique referral link with copy button
     - Referral count
     - Reward tiers: "Refer 3 friends = early access, 10 friends = lifetime deal"
   - Track referral chain: who referred whom
   - Credit the referrer when someone signs up with their link

5. **Build the post-signup thank-you view**
   - Show after successful signup (same page or redirect)
   - Display:
     - Waitlist position: "#X on the waitlist"
     - Referral link with one-click copy
     - Share buttons (Twitter, LinkedIn, email) pre-filled with referral link
     - Referral progress: "You've referred X people"
     - Next reward tier and how many more referrals needed

6. **Build the invitation system**
   - Admin API endpoint to invite users from the waitlist
   - Update user status: waiting -> invited -> accepted
   - Send invitation email with unique signup/access link
   - Batch invite support (invite next N users)
   - Priority queue: users with more referrals get invited first

7. **Add analytics and tracking**
   - Track events:
     - `waitlist_page_view` - Page visits
     - `waitlist_signup` - Email submissions
     - `waitlist_referral_share` - Referral link shared
     - `waitlist_referral_signup` - Signup via referral
   - Dashboard data: total signups, daily signups, referral conversion rate
   - UTM parameter tracking on the waitlist page

8. **Add social sharing for virality**
   - Pre-written share messages for each platform
   - Twitter: "I just joined the waitlist for [Product]! {referral_link}"
   - LinkedIn: professional angle on the product
   - Email: subject + body template with referral link
   - Share buttons on the thank-you page

9. **SEO and performance**
   - Meta title and description for the waitlist page
   - OG tags for social sharing of the waitlist page itself
   - Fast loading: minimal JS, above-fold content priority
   - Mobile responsive

10. **Output summary**
    - Page URL path
    - API endpoints created
    - Database schema or storage setup
    - Environment variables needed
    - Referral system mechanics
    - Launch countdown configuration
