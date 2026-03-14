# Generate PR Description

Generate a comprehensive pull request description by analyzing all commits and changes on the current branch.

## Arguments

$ARGUMENTS - Optional: the base branch to compare against (e.g., `main`, `develop`). Defaults to `main`, falling back to `master`.

## Instructions

1. **Determine the base branch:**
   - Use `$ARGUMENTS` if provided
   - Otherwise, detect the default branch: check for `main`, then `master`, then the remote HEAD
   - Verify the base branch exists

2. **Gather branch information:**
   ```bash
   # Current branch name
   git branch --show-current

   # All commits since diverging from base
   git log <base>..HEAD --pretty=format:"%h %s" --reverse

   # Full diff of all changes
   git diff <base>...HEAD --stat
   git diff <base>...HEAD

   # List of changed files with change type
   git diff <base>...HEAD --name-status
   ```

3. **Analyze all changes thoroughly:**
   - Read every commit message (not just the latest)
   - Review the full diff to understand what changed and why
   - Identify which components/modules are affected
   - Detect new dependencies added
   - Detect database migrations
   - Detect configuration changes
   - Detect new or modified tests

4. **Generate the PR description:**

   ```markdown
   ## Summary

   [2-3 sentence description of what this PR does and why]

   ## Changes

   ### [Category 1: e.g., "New Feature", "Bug Fix", "Refactoring"]
   - Specific change with context on why
   - Another change

   ### [Category 2]
   - Specific change

   ## Modified Components

   | Component | Type of Change | Files |
   |-----------|---------------|-------|
   | Auth module | Modified | `src/auth/login.ts`, `src/auth/guard.ts` |
   | User model | New | `src/models/user.ts` |
   | ... | ... | ... |

   ## New Dependencies

   | Package | Version | Purpose |
   |---------|---------|---------|
   | ... | ... | ... |

   (Omit this section if no new dependencies)

   ## Database Changes

   - Migration: `NNNN_description.sql` - what it does
   - Schema changes: describe

   (Omit this section if no database changes)

   ## Configuration Changes

   - New env var: `VAR_NAME` - purpose and default
   - Modified config: what changed

   (Omit this section if no config changes)

   ## Testing

   ### How to Test
   1. Step-by-step instructions to verify the changes
   2. Include specific test scenarios
   3. Include edge cases to check

   ### Automated Tests
   - [ ] Unit tests added/updated
   - [ ] Integration tests added/updated
   - [ ] E2E tests added/updated
   - [ ] All existing tests pass

   ## Screenshots

   <!-- Add screenshots if UI changes are involved -->

   ## Deployment Notes

   - Any special deployment steps needed
   - Feature flags to enable
   - Environment variables to add
   - Services to restart

   (Omit this section if standard deployment)

   ## Checklist

   - [ ] Code follows project conventions
   - [ ] Self-review completed
   - [ ] Tests cover the changes
   - [ ] Documentation updated (if needed)
   - [ ] No hardcoded secrets or credentials
   ```

5. **Output the description** directly to the console (do NOT write to a file). The user can then copy-paste it into their PR.

6. **If the user wants to create the PR directly**, suggest they run `/gen pr-description` first to review, then use `gh pr create` with the generated description.
