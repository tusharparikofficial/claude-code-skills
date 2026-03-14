# E2E Test Generator

Generate end-to-end tests from user stories or page URLs, using Playwright (primary) or Cypress as fallback, with Page Object Models and comprehensive user flow coverage.

## Arguments

$ARGUMENTS - `<user-story-description>` or `<page-url>` — A user story describing the flow to test (e.g., "User signs up, verifies email, and completes onboarding") or a page URL to generate tests for.

## Instructions

### Step 1: Analyze the User Story or Page

#### If a user story was provided:
1. Break the story into discrete user actions (steps):
   - Navigation actions (go to URL, click link)
   - Input actions (fill form, select dropdown, upload file)
   - Assertion points (see confirmation, redirected to page, data visible)
   - Wait points (loading spinner, API response, animation)
2. Identify all pages/views involved in the flow.
3. Identify form fields, buttons, and interactive elements needed.

#### If a page URL was provided:
1. Search the codebase for the component/template that renders this page.
2. Identify all interactive elements on the page.
3. Map out the primary user flows on this page.
4. Identify navigation targets (where links/buttons lead).

### Step 2: Detect E2E Testing Framework

1. Check for existing E2E setup:
   - `playwright.config.ts` or `playwright.config.js` — use Playwright
   - `cypress.config.ts` or `cypress.config.js` or `cypress/` — use Cypress
   - If neither exists, default to **Playwright** and note that setup is needed
2. Find existing E2E tests to match patterns:
   - File location (`e2e/`, `tests/e2e/`, `cypress/e2e/`)
   - Page Object Model usage and location
   - Helper utilities (login helpers, data factories)
   - Base URL configuration
   - Authentication handling in tests
3. Check for existing Page Object Models to reuse or extend.

### Step 3: Create Page Object Models

For each page/view involved in the user flow, create or update a Page Object Model:

```
PageObjectModel should contain:
- URL/route for the page
- Locators for all interactive elements (prefer data-testid selectors)
- Action methods (fillLoginForm, submitForm, clickNavItem)
- Assertion methods (isLoaded, hasError, showsSuccessMessage)
- Wait methods (waitForLoad, waitForAPIResponse)
```

**Locator priority (most reliable to least):**
1. `data-testid` attributes
2. ARIA roles and labels (`getByRole`, `getByLabel`)
3. Text content (`getByText`)
4. CSS selectors (last resort)

If `data-testid` attributes are missing from the source components, note which components need them added (but do not modify source components).

### Step 4: Generate E2E Test File

#### 4a: Test Setup
- Import Page Object Models
- Configure test fixtures (authenticated user, seeded data)
- Set up test isolation (each test starts from clean state)
- Configure viewport for desktop tests (1280x720 default)

#### 4b: Primary Flow Test (Happy Path)
Generate a test that walks through the entire user story:
- Each step maps to a Page Object action
- Include explicit assertions at each milestone
- Use proper waits between navigation and API calls
- Verify the final state matches expectations

#### 4c: Form Validation Tests
For each form in the flow:
- Submit with empty required fields — verify error messages
- Submit with invalid data (bad email, short password) — verify field-level errors
- Submit with valid data — verify success
- Test field interactions (show/hide password, character counters)

#### 4d: Navigation Tests
- Verify all links in the flow lead to correct pages
- Test browser back/forward button behavior
- Test direct URL access (deep linking)
- Test redirect behavior (unauthenticated user redirected to login)

#### 4e: Loading and Error State Tests
- Simulate slow network — verify loading indicators appear
- Simulate API failure — verify error messages shown to user
- Simulate network offline — verify offline handling
- Test retry mechanisms if they exist

#### 4f: Responsive Behavior Tests
- Run critical flow tests at mobile viewport (375x667)
- Verify mobile navigation (hamburger menu, drawer)
- Verify forms are usable on mobile
- Check for horizontal scroll issues

#### 4g: Accessibility Checks (if applicable)
- Keyboard navigation through the flow (Tab, Enter, Escape)
- Focus management after actions (modal open/close, page navigation)
- Screen reader landmarks and ARIA labels

### Step 5: Configure Failure Handling

Add to each test:
- Screenshot capture on failure (automatic in Playwright)
- Console error capture
- Network request logging for debugging
- Meaningful error messages in assertions

```
// Playwright example pattern:
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== testInfo.expectedStatus) {
    await testInfo.attach('screenshot', {
      body: await page.screenshot(),
      contentType: 'image/png',
    });
  }
});
```

### Step 6: Validate and Run

1. Write the test file and Page Object Models to the correct locations.
2. Run the E2E tests:
   - Playwright: `npx playwright test <file> --reporter=list`
   - Cypress: `npx cypress run --spec <file>`
3. If tests fail due to missing selectors or incorrect locators, analyze the failure and fix the test code.
4. Report summary:
   - User flows covered
   - Pages and components involved
   - Missing `data-testid` attributes that should be added to source
   - Any flows that could not be fully automated and why

### Important Guidelines

- NEVER use arbitrary sleeps (`page.waitForTimeout(3000)`). Use proper waits:
  - `waitForSelector` / `waitForLoadState` / `waitForResponse`
  - `expect(locator).toBeVisible()` with auto-waiting
- NEVER use fragile selectors (`.btn-primary`, `div > span:nth-child(3)`).
- Each test should be independent — do not rely on other tests running first.
- Use test fixtures for authentication, not UI login in every test (except the login test itself).
- Keep tests deterministic — seed test data, do not rely on existing database state.
- Prefer `data-testid` selectors, then ARIA roles, then text content.
- Group related tests in describe blocks by feature area.
- Name tests as user actions: `should allow user to sign up with valid email`.
- Do not test third-party services (payment providers, OAuth) — mock at the API level.
