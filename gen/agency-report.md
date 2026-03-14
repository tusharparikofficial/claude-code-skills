# Agency Status Report Generator

Generate a client-facing project status report from git history, open issues, PRs, and project metrics for the specified reporting period.

## Arguments

$ARGUMENTS - Optional: `<period>` - one of: `weekly`, `monthly`, or a date range like `2024-01-01..2024-01-31` (defaults to `weekly`)

## Instructions

You are generating a comprehensive client project status report. Follow each step carefully to auto-generate as much data as possible from the project.

### Step 1: Determine Reporting Period

1. Parse `$ARGUMENTS`:
   - `weekly` (default): Last 7 days from today
   - `monthly`: Last 30 days from today
   - `YYYY-MM-DD..YYYY-MM-DD`: Specific date range
   - Empty/no argument: Default to `weekly`

2. Calculate exact dates:
   - `PERIOD_START`: Start date of the reporting period
   - `PERIOD_END`: End date (today if not specified)
   - `PERIOD_LABEL`: "Week of Jan 6-12, 2025" or "January 2025" etc.

### Step 2: Gather Data from Git

Run the following git commands to extract project data:

#### Commits in Period
```bash
git log --after="PERIOD_START" --before="PERIOD_END" --oneline --no-merges
```

#### Commit Details (for categorization)
```bash
git log --after="PERIOD_START" --before="PERIOD_END" --format="%h %s (%an, %ar)" --no-merges
```

#### Code Changes Summary
```bash
git diff --stat $(git log --after="PERIOD_START" --before="PERIOD_END" --format="%H" | tail -1)..HEAD
```

#### Lines Added/Removed
```bash
git log --after="PERIOD_START" --before="PERIOD_END" --numstat --format="" | awk '{added+=$1; removed+=$2} END {print "Added:", added, "Removed:", removed}'
```

#### Files Changed Count
```bash
git log --after="PERIOD_START" --before="PERIOD_END" --name-only --format="" | sort -u | wc -l
```

#### Contributors in Period
```bash
git log --after="PERIOD_START" --before="PERIOD_END" --format="%an" | sort -u
```

### Step 3: Gather Data from GitHub (if available)

If the project has a GitHub remote, use `gh` CLI:

#### Merged PRs in Period
```bash
gh pr list --state merged --search "merged:>PERIOD_START" --json number,title,mergedAt,author --limit 100
```

#### Open PRs
```bash
gh pr list --state open --json number,title,createdAt,author,labels
```

#### Closed Issues in Period
```bash
gh issue list --state closed --search "closed:>PERIOD_START" --json number,title,closedAt,labels
```

#### Open Issues
```bash
gh issue list --state open --json number,title,createdAt,labels,assignees
```

#### Open Bugs
```bash
gh issue list --state open --label "bug" --json number,title,createdAt
```

If `gh` is not available or the project is not on GitHub, skip these steps and note that GitHub data was not available.

### Step 4: Gather Project Metrics

#### Test Coverage (if available)
Check for coverage reports:
- `coverage/lcov-report/index.html`
- `coverage/coverage-summary.json`
- `htmlcov/index.html` (Python)
- `.coverage` file

Run test coverage command if configured:
```bash
# Node.js
npm test -- --coverage --coverageReporters=json-summary 2>/dev/null

# Python
pytest --cov --cov-report=json 2>/dev/null

# Go
go test -cover ./... 2>/dev/null
```

#### Build Status
Check if the build passes:
```bash
# Node.js
npm run build 2>&1 | tail -5

# Or check CI status
gh run list --limit 5 --json status,conclusion,name,createdAt
```

#### Dependencies
Check for outdated/vulnerable dependencies:
```bash
# Node.js
npm audit --json 2>/dev/null | head -20

# Python
pip-audit 2>/dev/null
```

### Step 5: Generate Report

Compile all gathered data into a structured report:

```markdown
# Project Status Report

**Project:** {Project Name}
**Period:** {PERIOD_LABEL}
**Date:** {Today's Date}
**Prepared by:** {Author / Agency Name}

---

## Overall Status: {ON TRACK / AT RISK / BLOCKED}

{1-2 sentence summary of overall project health and progress}

| Category | Status |
|----------|--------|
| Development | {On Track / At Risk / Blocked} |
| Timeline | {On Track / Ahead / Behind} |
| Quality | {Good / Needs Attention / Critical} |
| Budget | {On Track / Over / Under} |

---

## Completed This Period

### Features & Enhancements
{List completed features/enhancements from git commits and merged PRs, grouped logically}

| # | Item | Type | PR/Commit |
|---|------|------|-----------|
| 1 | {Feature/fix description} | Feature | #{PR number} |
| 2 | {Feature/fix description} | Bug Fix | {commit hash} |
| 3 | {Feature/fix description} | Enhancement | #{PR number} |

### Bug Fixes
| # | Bug | Severity | Resolution |
|---|-----|----------|------------|
| 1 | {Bug description} | {High/Medium/Low} | Fixed in #{PR} |

### Other Work
- {Infrastructure changes}
- {Documentation updates}
- {Dependency updates}
- {Refactoring / tech debt reduction}

---

## In Progress

### Active Development
{List open PRs and branches with active work}

| # | Item | Status | Assignee | ETA |
|---|------|--------|----------|-----|
| 1 | {Work item} | In Review | {person} | {date} |
| 2 | {Work item} | In Development | {person} | {date} |

### Open Pull Requests
| PR | Title | Author | Status | Age |
|----|-------|--------|--------|-----|
| #{num} | {title} | {author} | {review status} | {days} |

---

## Planned for Next Period

{List upcoming work based on open issues, milestones, and roadmap}

| # | Item | Priority | Estimated Effort |
|---|------|----------|-----------------|
| 1 | {Planned work} | High | {X days} |
| 2 | {Planned work} | Medium | {X days} |
| 3 | {Planned work} | Low | {X days} |

---

## Metrics

### Development Velocity
| Metric | This Period | Previous Period | Trend |
|--------|-------------|-----------------|-------|
| Commits | {count} | {count} | {up/down/same} |
| PRs Merged | {count} | {count} | {up/down/same} |
| Issues Closed | {count} | {count} | {up/down/same} |

### Code Changes
| Metric | Value |
|--------|-------|
| Lines Added | {count} |
| Lines Removed | {count} |
| Net Change | {+/- count} |
| Files Changed | {count} |
| Contributors | {count} |

### Quality
| Metric | Value | Target |
|--------|-------|--------|
| Test Coverage | {X}% | 80% |
| Open Bugs | {count} | <5 |
| Build Status | {Passing/Failing} | Passing |
| Security Vulnerabilities | {count} | 0 |

### Uptime (if monitoring configured)
| Metric | Value |
|--------|-------|
| Uptime | {X}% |
| Avg Response Time | {X}ms |
| Error Rate | {X}% |
| Incidents | {count} |

*Note: Metrics marked as N/A indicate data was not available for auto-generation.*

---

## Blockers & Risks

### Current Blockers
{List any items that are blocked and need client input or external resolution}

| # | Blocker | Impact | Owner | Action Needed |
|---|---------|--------|-------|---------------|
| 1 | {Description} | {Impact on timeline} | {Who can resolve} | {What needs to happen} |

### Risks
| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| 1 | {Risk description} | {High/Med/Low} | {High/Med/Low} | {Mitigation plan} |

---

## Budget & Hours

*Note: Populate this section with actual time tracking data if available.*

| Category | Hours Allocated | Hours Used | Remaining | % Used |
|----------|----------------|------------|-----------|--------|
| Design | {X} | {X} | {X} | {X}% |
| Development | {X} | {X} | {X} | {X}% |
| QA/Testing | {X} | {X} | {X} | {X}% |
| PM/Meetings | {X} | {X} | {X} | {X}% |
| **Total** | **{X}** | **{X}** | **{X}** | **{X}%** |

{If time tracking data is not available, mark this section as "Manual input required" and leave placeholders}

---

## Screenshots & Visual Progress

*Note: Add screenshots of completed features here.*

### {Feature 1 Name}
<!-- Screenshot placeholder: Add screenshot of feature 1 -->
{Description of what's shown}

### {Feature 2 Name}
<!-- Screenshot placeholder: Add screenshot of feature 2 -->
{Description of what's shown}

---

## Action Items

| # | Action | Owner | Due Date | Status |
|---|--------|-------|----------|--------|
| 1 | {Action item for client} | Client | {date} | Pending |
| 2 | {Action item for team} | Team | {date} | In Progress |

---

## Next Report

The next status report will be delivered on {NEXT_REPORT_DATE}.

---

*This report was auto-generated from project data on {GENERATION_DATE}.*
```

### Step 6: Categorize Commits

Group commits intelligently by analyzing commit messages:

- **feat/feature**: New features
- **fix/bugfix**: Bug fixes
- **refactor**: Code refactoring
- **docs**: Documentation
- **test**: Testing
- **chore**: Maintenance
- **perf**: Performance improvements
- **ci**: CI/CD changes
- **style**: Code style changes

If commits don't follow conventional commits format, infer categories from the commit message content.

### Step 7: Determine Overall Status

Set the overall status based on:

- **ON TRACK**: No blockers, development velocity is consistent, quality metrics are good
- **AT RISK**: Minor blockers exist, some metrics are below target, timeline pressure
- **BLOCKED**: Critical blockers preventing progress, client input urgently needed

### Step 8: Compare with Previous Period

If possible, gather the same metrics for the previous period to show trends:

```bash
# Previous period commits
git log --after="PREV_PERIOD_START" --before="PREV_PERIOD_END" --oneline --no-merges | wc -l
```

Use arrows or labels to indicate trends: trending up, trending down, stable.

### Step 9: Output

1. If `docs/` directory exists, write to `docs/reports/status-{PERIOD_LABEL}.md`
2. Also output the full report content to the console
3. Provide a summary of what was auto-generated vs what needs manual input

### Important Notes

- Auto-generate as much as possible from git and GitHub data
- Clearly mark sections that need manual input with "TODO" or placeholder comments
- Use client-friendly language -- avoid internal technical details
- Categorize commits into business-meaningful groups (features, fixes, improvements)
- Include "Action Items" that clearly state what the client needs to do
- If this is a weekly report, keep it concise (2-3 pages)
- If this is a monthly report, provide more detail and trend analysis
- Always include the next report date for expectation setting
- Budget/hours section should be marked as requiring manual input unless time tracking is integrated
- Screenshots section uses placeholder comments -- remind the user to add actual screenshots
- If git history is not available (no git repo), note this and generate a template-only report
