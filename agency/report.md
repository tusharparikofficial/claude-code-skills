# Generate Client Status Report

Generate a client-facing status report by analyzing git activity, PRs, and project metrics.

## Arguments

$ARGUMENTS - Optional reporting period: "weekly" or "monthly" (defaults to "weekly")

## Instructions

1. **Determine the reporting period.** Parse `$ARGUMENTS` for "weekly" or "monthly". Default to "weekly" if not specified or empty.
   - Weekly: last 7 days
   - Monthly: last 30 days

2. **Gather data from git.** Run the following commands to collect project activity:

   ```bash
   # Determine the date range
   # Weekly: 7 days ago, Monthly: 30 days ago

   # Completed work - merged PRs (if GitHub repo)
   gh pr list --state merged --search "merged:>YYYY-MM-DD" --json title,number,mergedAt,author

   # In-progress work - open PRs
   gh pr list --state open --json title,number,createdAt,author,isDraft

   # Commit activity
   git log --since="YYYY-MM-DD" --oneline --format="%h %s (%an, %ad)" --date=short

   # Lines changed
   git diff --stat HEAD~$(git rev-list --count --since="YYYY-MM-DD" HEAD)

   # Test coverage (attempt to find and run coverage)
   # Look for package.json, pytest, go test, etc.

   # Contributors
   git shortlog -sn --since="YYYY-MM-DD"
   ```

3. **If not a git repo or GitHub repo**, note what data is unavailable and generate the report template with placeholder sections for manual filling.

4. **Generate the status report** with this structure:

### Output Structure

```markdown
# Status Report: [Project Name]

**Period:** [Start Date] - [End Date]
**Report Type:** [Weekly/Monthly]
**Generated:** [Current Date]

---

## Executive Summary

2-3 sentence overview of progress during this period. Highlight key achievements and any concerns.

## Completed Work

| # | Item | PR/Commit | Completed |
|---|------|-----------|-----------|
| 1 | [Description] | [#PR or hash] | [Date] |
| 2 | [Description] | [#PR or hash] | [Date] |

**Total items completed:** X

## In Progress

| # | Item | PR/Branch | Status | Assignee |
|---|------|-----------|--------|----------|
| 1 | [Description] | [#PR or branch] | [Draft/Review/Changes Requested] | [Name] |

## Velocity Metrics

| Metric | This Period | Previous Period | Trend |
|--------|------------|----------------|-------|
| PRs Merged | X | X | [up/down/stable] |
| Commits | X | X | [up/down/stable] |
| Lines Added | X | X | [up/down/stable] |
| Lines Removed | X | X | [up/down/stable] |
| Contributors Active | X | X | [up/down/stable] |

## Test Coverage

| Metric | Current | Previous | Delta |
|--------|---------|----------|-------|
| Overall Coverage | XX% | XX% | +/-X% |
| Unit Tests | XX | XX | +/-X |
| Integration Tests | XX | XX | +/-X |

## System Health

| Metric | Status |
|--------|--------|
| Uptime | XX.X% (if available) |
| Error Rate | X.X% (if available) |
| Avg Response Time | Xms (if available) |
| Open Issues/Bugs | X |

## Planned (Next Period)

- [ ] [Planned item 1]
- [ ] [Planned item 2]
- [ ] [Planned item 3]

## Blockers & Risks

| # | Blocker/Risk | Impact | Mitigation | Owner |
|---|-------------|--------|------------|-------|
| 1 | [Description] | [High/Medium/Low] | [Action] | [Name] |

## Budget Tracking

| Category | Budget | Spent | Remaining | % Used |
|----------|--------|-------|-----------|--------|
| Development | $XX,XXX | $XX,XXX | $XX,XXX | XX% |
| Infrastructure | $X,XXX | $X,XXX | $X,XXX | XX% |
| Third-party | $X,XXX | $X,XXX | $X,XXX | XX% |
| **Total** | **$XX,XXX** | **$XX,XXX** | **$XX,XXX** | **XX%** |

*Note: Budget figures require manual input if not tracked in the repository.*

---

*Report auto-generated from git activity. Sections marked with placeholders require manual review.*
```

5. **Fill in as much data as possible** from git/GitHub. For sections where data is unavailable (uptime, budget), include the section with placeholder values and a note indicating manual input is needed.

6. **Compare with previous period** where possible by running the same git commands for the prior period.

7. **Output the complete report** as formatted Markdown directly to the user.
