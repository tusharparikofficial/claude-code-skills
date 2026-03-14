# Automate Release Process

Automate version bumping, changelog generation, git tagging, GitHub Release creation, and optional package publishing.

## Arguments

$ARGUMENTS - `<version-type>` where version-type is one of: major, minor, patch (or an explicit version like `1.2.3`)

## Instructions

1. Parse the argument to determine the new version:
   - If `major`, `minor`, or `patch`: read the current version from the project and bump accordingly.
   - If an explicit version (e.g., `1.2.3`): use it directly.
   - Detect current version from: `package.json`, `pyproject.toml`, `Cargo.toml`, `version.go`, or git tags.

2. Validate preconditions before proceeding:
   - Ensure the working directory is clean (`git status --porcelain` is empty). If not, abort with a message.
   - Ensure the current branch is `main` or `master` (or a release branch). Warn if on a different branch.
   - Ensure all tests pass by running the project's test command.
   - Ensure the branch is up to date with the remote (`git fetch && git status` shows no divergence).

3. Bump the version in all relevant files:
   - `package.json` and `package-lock.json` (Node.js)
   - `pyproject.toml` and `src/<name>/__init__.py` (Python)
   - `Cargo.toml` (Rust)
   - `version.go` or constants file (Go)
   - Any other files that contain the version string (search for the old version)

4. Update `CHANGELOG.md`:
   - Determine the previous version/tag.
   - Gather all commits since the last release using `git log <prev-tag>..HEAD --oneline --no-merges`.
   - Categorize commits into: Added, Changed, Fixed, Removed, Security, Deprecated.
   - Add a new section at the top of CHANGELOG.md:
     ```
     ## [<new-version>] - YYYY-MM-DD

     ### Added
     - ...

     ### Changed
     - ...

     ### Fixed
     - ...
     ```
   - Update the `[Unreleased]` section link if present.
   - Follow Keep a Changelog format (https://keepachangelog.com).

5. Create the release commit and tag:
   - Stage all changed files (version files + CHANGELOG.md).
   - Create a commit with message: `chore: release v<new-version>`
   - Create an annotated git tag: `git tag -a v<new-version> -m "Release v<new-version>"`

6. Push to remote:
   - Push the commit: `git push origin <branch>`
   - Push the tag: `git push origin v<new-version>`

7. Create a GitHub Release:
   - Use `gh release create v<new-version>` with:
     - Title: `v<new-version>`
     - Body: The changelog section for this version
     - Mark as latest release
     - Attach any build artifacts if they exist (e.g., binaries, tarballs)

8. Publish package if applicable (ask for confirmation before publishing):
   - **npm**: `npm publish` (check for `publishConfig` in package.json)
   - **PyPI**: `python -m build && twine upload dist/*`
   - **crates.io**: `cargo publish`
   - **Go**: No publish step needed (tags are sufficient for `go get`)
   - Skip publishing if no package registry is configured.

9. Print a summary of:
   - Previous version and new version
   - Changelog entries added
   - Git tag created
   - GitHub Release URL
   - Package published (if applicable)
   - Any follow-up actions needed
