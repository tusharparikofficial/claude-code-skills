# Generate Release Notes

Generate user-facing release notes for a specific version or version range.

## Arguments

$ARGUMENTS - Required: either a single version tag (e.g., `v2.1.0`) or a range (e.g., `v2.0.0..v2.1.0`). Can also be `latest` to generate notes for the most recent tag.

## Instructions

1. **Parse the version argument** from `$ARGUMENTS`:
   - Single tag (e.g., `v2.1.0`): find commits between this tag and the previous tag
   - Range (e.g., `v2.0.0..v2.1.0`): find commits between these two tags
   - `latest`: find the latest tag and generate notes since the previous tag
   - If the tag doesn't exist yet, use commits from the last tag to HEAD (upcoming release)

2. **Collect all changes:**
   ```bash
   # Commits in range
   git log <from>..<to> --pretty=format:"%H|%s|%b" --no-merges

   # Merge commits (for PR references)
   git log <from>..<to> --merges --pretty=format:"%H|%s"

   # Contributors
   git log <from>..<to> --pretty=format:"%an" | sort -u
   ```

3. **Also check for PR details** if the remote is GitHub:
   - Use `gh pr list --state merged` to get PR titles and descriptions
   - Extract user-facing descriptions from PR bodies
   - Link to PR numbers

4. **Categorize changes** (from a user's perspective, NOT developer's):
   - **Highlights**: The 1-3 most impactful changes (headline features)
   - **New Features**: New capabilities users can now use
   - **Improvements**: Enhancements to existing features (better UX, performance, etc.)
   - **Bug Fixes**: Issues that were resolved
   - **Breaking Changes**: Changes that require user action (migration, config changes, etc.)
   - **Known Issues**: Outstanding issues users should be aware of
   - Skip internal changes (refactoring, CI, tests) unless they affect users

5. **Generate release notes** written for end-users (not developers):

   ```markdown
   # Release Notes - [Version]

   **Release Date:** [date of tag or today]

   ## Highlights

   ### [Feature Name]
   2-3 sentence description of the most exciting change, written for users.
   Explain what they can now do that they couldn't before.

   ### [Feature Name]
   Another highlight if applicable.

   ## New Features

   - **[Feature Name]:** User-friendly description of what's new and how to use it. ([#PR](url))
   - **[Feature Name]:** Description. ([#PR](url))

   ## Improvements

   - **[Area]:** What got better and how it benefits users. ([#PR](url))
   - **[Area]:** Description. ([#PR](url))

   ## Bug Fixes

   - Fixed an issue where [user-visible symptom]. ([#PR](url))
   - Fixed [description of what was broken]. ([#PR](url))

   ## Breaking Changes

   ### [Change Title]
   **What changed:** Description of the breaking change.

   **Why:** Reason for the change.

   **Migration guide:**
   1. Step-by-step instructions to migrate
   2. Code examples if relevant
   ```before
   old way
   ```
   ```after
   new way
   ```

   ## Known Issues

   - Description of known issue and workaround if available. ([#Issue](url))

   ## Contributors

   Thank you to everyone who contributed to this release:
   - @contributor1
   - @contributor2

   ---

   **Full Changelog:** [link to compare view on GitHub]
   ```

6. **Writing style guidelines:**
   - Write for end-users, not developers
   - Use plain language, avoid technical jargon where possible
   - Focus on what users can DO, not what code changed
   - Each bullet should be a complete, understandable sentence
   - Use active voice: "You can now..." instead of "Added support for..."
   - Group related changes together
   - Order by impact within each section (most impactful first)

7. **Write the file** to `docs/releases/[version].md`. Create directories if needed. Also offer to prepend to a top-level `RELEASE_NOTES.md` if one exists. Report the file path to the user.
