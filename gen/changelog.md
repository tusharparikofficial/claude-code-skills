# Generate CHANGELOG

Generate or update CHANGELOG.md from git commit history using conventional commits format.

## Arguments

$ARGUMENTS - Optional: a git tag (e.g., `v1.0.0`), date (e.g., `2024-01-01`), or commit SHA to start from. If empty, generates from the last tag or full history.

## Instructions

1. **Determine the starting point** from `$ARGUMENTS`:
   - If a tag is provided: use commits since that tag
   - If a date is provided: use commits since that date (`git log --since`)
   - If a commit SHA is provided: use commits since that commit
   - If empty: find the latest tag with `git describe --tags --abbrev=0` and use commits since then; if no tags exist, use the full git history

2. **Collect all commits** using:
   ```
   git log <since>..HEAD --pretty=format:"%H|%s|%an|%ad" --date=short
   ```
   Also collect PR/merge information:
   ```
   git log <since>..HEAD --merges --pretty=format:"%H|%s"
   ```

3. **Parse each commit message** according to conventional commits:
   - `feat:` or `feat(scope):` -> Features
   - `fix:` or `fix(scope):` -> Bug Fixes
   - `BREAKING CHANGE:` or `!:` -> Breaking Changes
   - `docs:` -> Documentation
   - `refactor:` -> Code Refactoring
   - `perf:` -> Performance Improvements
   - `test:` -> Tests
   - `chore:`, `build:`, `ci:` -> Maintenance
   - Non-conventional commits -> Other Changes

4. **Extract references** from commit messages:
   - PR numbers: `(#123)` or `Merge pull request #123`
   - Issue references: `fixes #456`, `closes #789`, `resolves #101`
   - Link them to the repository URL (detect from `git remote get-url origin`)

5. **Generate CHANGELOG.md** in this format:
   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
   and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

   ## [Unreleased] - YYYY-MM-DD

   ### Breaking Changes
   - Description of breaking change ([#PR](url)) - @author

   ### Features
   - Description of feature ([#PR](url)) - @author

   ### Bug Fixes
   - Description of fix ([#PR](url)) - @author

   ### Performance Improvements
   - Description - @author

   ### Documentation
   - Description - @author

   ### Maintenance
   - Description - @author

   ## [Previous Version] - Date
   ...existing content...
   ```

6. **If CHANGELOG.md already exists:**
   - Read the existing file
   - Prepend the new section(s) after the header
   - Preserve all existing content below
   - Do NOT regenerate sections that already exist for past versions

7. **If CHANGELOG.md does not exist:**
   - Create it with the full header and all parsed sections
   - Group commits into version sections based on tags

8. **Quality checks:**
   - Each entry is a clean, readable sentence (not raw commit messages)
   - PR/issue links are valid URLs
   - Dates are in ISO 8601 format (YYYY-MM-DD)
   - Breaking changes section appears first when present
   - No duplicate entries
