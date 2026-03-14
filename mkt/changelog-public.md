# Public Changelog Page

Build a public-facing changelog page auto-generated from git history and PRs.

## Instructions

1. **Detect project framework and data source**
   - Identify the framework for page rendering
   - Determine changelog data sources:
     - Git commit history (conventional commits)
     - GitHub PRs/releases (via GitHub API)
     - Manual changelog entries (markdown files or CMS)
   - Check for existing CHANGELOG.md or release notes

2. **Set up changelog data pipeline**
   - **From git/GitHub:**
     - Parse conventional commit messages: `feat:`, `fix:`, `perf:`, `refactor:`
     - Group by release tag or date range
     - Extract PR titles and descriptions if available
     - Use `gh api` or GitHub GraphQL to fetch PR metadata (labels, authors)
   - **From manual entries:**
     - Create a `changelog/` directory for markdown entries
     - Each entry: `YYYY-MM-DD-title.md` with frontmatter (category, version)
     - Parse and sort by date
   - Create a build script or API route that aggregates changelog data
   - Output structured data: `{ version, date, categories: { new: [], improved: [], fixed: [] } }`

3. **Categorize entries**
   - Map commits/PRs to categories:
     - **New**: `feat:` commits, PRs labeled `feature`
     - **Improved**: `perf:`, `refactor:`, `enhance:` commits, PRs labeled `enhancement`
     - **Fixed**: `fix:` commits, PRs labeled `bug`
   - Allow manual category override via frontmatter or PR labels
   - Filter out internal/chore commits (ci, chore, docs unless user-facing)

4. **Build the changelog page**
   - **Header:**
     - Page title: "Changelog" or "What's New"
     - Subtitle: "Follow our latest updates and improvements"
     - RSS feed link
     - Email subscription form (optional)
   - **Search and filter:**
     - Search bar to find entries by keyword
     - Category filter buttons: All / New / Improved / Fixed
     - Date range or version filter
   - **Entry list:**
     - Grouped by version or date
     - Each entry shows:
       - Category badge (color-coded: green=New, blue=Improved, orange=Fixed)
       - Title and description
       - Date
       - Link to PR or commit (if from git)
     - Newest entries first
   - **Pagination or infinite scroll** for long changelogs

5. **Generate RSS feed**
   - Create an RSS/Atom feed endpoint (`/changelog/rss.xml` or `/changelog/feed`)
   - Include title, description, date, category for each entry
   - Set proper `Content-Type: application/rss+xml`
   - Add `<link rel="alternate" type="application/rss+xml">` to the page head
   - Include last 50 entries in the feed

6. **Email notification system**
   - Optional email subscription form on the changelog page
   - When new entries are published, send a digest email
   - Email template: list of new changes grouped by category
   - Unsubscribe link in every email
   - Can integrate with existing email service or newsletter tool

7. **Auto-generation script**
   - Create a script/command to generate changelog entries:
     - From latest git commits since last release
     - From merged PRs since last changelog update
     - Output to the changelog data source (markdown files or JSON)
   - Can be run manually or integrated into CI/CD on release

8. **SEO optimization**
   - Unique meta title: "[Product] Changelog - Latest Updates"
   - Meta description summarizing recent changes
   - Structured data for the page
   - Each entry gets a permalink (anchor link)
   - Proper heading hierarchy

9. **Output summary**
   - Changelog page URL path
   - Data source configuration
   - RSS feed URL
   - Auto-generation script usage
   - How to add manual entries
   - Email notification setup (if implemented)
