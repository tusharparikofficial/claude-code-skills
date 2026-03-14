# Git Issue Debugger

Diagnose and safely resolve git issues including merge conflicts, detached HEAD, accidental commits, and repository corruption.

## Arguments

$ARGUMENTS - Description of the git issue, e.g., "merge conflict", "detached head", "accidentally committed secrets", "wrong branch", "rebase gone wrong"

## Instructions

Follow these steps to diagnose and safely resolve the git issue. Safety is paramount -- always prefer non-destructive operations and create backups before any potentially destructive action.

### Step 1: Assess Current Git State

Run these diagnostic commands to understand the current state:

```bash
git status
```

```bash
git log --oneline -10
```

```bash
git branch -a
```

```bash
git stash list
```

These provide the foundation for understanding what happened and what options are available.

### Step 2: Classify the Issue

Based on `$ARGUMENTS` and the git state output, classify the issue:

| Issue | Key Indicators |
|-------|---------------|
| **Merge Conflict** | `CONFLICT` in status, `both modified`, `Unmerged paths` |
| **Detached HEAD** | `HEAD detached at <commit>` in status |
| **Accidental Commit** | User says they committed something wrong (secrets, wrong files, wrong branch) |
| **Wrong Branch** | Work committed to wrong branch, need to move commits |
| **Rebase Conflict** | `rebase in progress`, `REBASE` in prompt |
| **Large Files** | Push rejected due to file size, or repo is bloated |
| **Corrupted Repo** | `fatal: bad object`, `error: object file is empty`, fsck errors |
| **Lost Commits** | Commits seem to have disappeared after reset/rebase |
| **Submodule Issues** | Submodule-related errors in status or operations |
| **Stash Issues** | Lost stash, stash apply conflicts |

Proceed to the relevant section below.

### Scenario A: Merge Conflicts

**Understand the conflict:**
```bash
git diff --name-only --diff-filter=U
```

This lists all files with conflicts.

For each conflicted file, read it using the Read tool. Look for conflict markers:
```
<<<<<<< HEAD
(your changes)
=======
(incoming changes)
>>>>>>> branch-name
```

**Resolution strategy:**

1. For each conflict, analyze both sides to understand the intent
2. Search the codebase for related tests or documentation that clarifies the correct behavior
3. Resolve the conflict by editing the file to combine changes correctly (remove conflict markers)
4. Use the Edit tool to apply the resolution

**After resolving all conflicts:**
Inform the user that the conflicts are resolved and they should:
- Review the resolved files
- Stage them with `git add <file>`
- Complete the merge with `git commit` (or `git rebase --continue` if rebasing)

Do NOT run `git add` or `git commit` automatically -- let the user verify the resolution first.

### Scenario B: Detached HEAD

**Explain the situation clearly:**
The HEAD is pointing directly to a commit instead of a branch. Any new commits will be orphaned if you switch to a branch without saving them.

**Check if there are uncommitted changes:**
```bash
git status
```

**Check if there are commits on the detached HEAD that are not on any branch:**
```bash
git log --oneline HEAD --not --branches --remotes -10
```

**Resolution options (explain each before suggesting):**

1. **Create a new branch from current position** (safest if you have work to keep):
   ```bash
   git branch <new-branch-name>
   git checkout <new-branch-name>
   ```
   Explain: "This creates a branch at your current position, preserving all your work."

2. **Return to an existing branch** (if no work to keep):
   ```bash
   git checkout <branch-name>
   ```
   Explain: "This returns you to the branch. Any commits made while detached will become unreachable (but recoverable via reflog for ~30 days)."

3. **Return to branch and bring commits** (if you have commits to keep):
   ```bash
   git branch temp-save
   git checkout <target-branch>
   git cherry-pick <commit-hash>
   ```
   Explain: "This saves your commits on a temporary branch, then cherry-picks them onto your target branch."

Suggest the most appropriate option based on the situation.

### Scenario C: Accidental Commit

**Determine what was accidentally committed:**
```bash
git log --oneline -5
```

```bash
git diff HEAD~1 --stat
```

**If secrets were committed:**

This is urgent. First, check if the commit has been pushed:
```bash
git log --oneline origin/<branch>..HEAD
```

If NOT pushed (commit is local only):
```bash
git reset HEAD~1
```
Explain: "This undoes the last commit but keeps your changes. Remove the secret file, then recommit."

If PUSHED (commit is on remote):
1. Warn the user: "The secret has been exposed in the remote repository's history. Even after removing it, anyone with prior access may have seen it. You MUST rotate the secret."
2. Remove from current branch:
   ```bash
   git rm --cached <secret-file>
   ```
3. Add to `.gitignore`
4. For history cleanup, explain (but do NOT run automatically):
   - `git filter-branch` or BFG Repo Cleaner can rewrite history
   - This requires force push and coordination with all collaborators
   - Provide the exact BFG command but let the user decide

**If wrong files were committed (not secrets):**

If NOT pushed:
```bash
git reset HEAD~1
```
Then recommit with the correct files.

If PUSHED:
```bash
git revert HEAD
```
Explain: "This creates a new commit that undoes the last commit, without rewriting history."

### Scenario D: Wrong Branch

**Determine the situation:**
- Commits made on wrong branch, need to move them to correct branch
- Work in progress that should be on a different branch

**If commits are NOT pushed:**

1. First, create a backup branch:
   ```bash
   git branch backup-<branch-name>
   ```

2. Note the commits to move:
   ```bash
   git log --oneline -5
   ```

3. Move to the correct branch and cherry-pick:
   ```bash
   git checkout <correct-branch>
   git cherry-pick <commit-hash1> <commit-hash2>
   ```

4. Remove from wrong branch:
   ```bash
   git checkout <wrong-branch>
   git reset --hard HEAD~<N>
   ```
   Where N is the number of commits to remove.

**If work is uncommitted (not yet committed):**

```bash
git stash
git checkout <correct-branch>
git stash pop
```

Explain each step before suggesting it.

### Scenario E: Rebase Issues

**Check rebase state:**
```bash
git status
```

Look for "rebase in progress" indicator.

**If in the middle of a conflicted rebase:**

1. Show the conflicts:
   ```bash
   git diff --name-only --diff-filter=U
   ```

2. For each conflict, read and resolve it (same as Scenario A)

3. After resolution:
   ```bash
   git add <resolved-files>
   git rebase --continue
   ```

**If the rebase has gone completely wrong:**

Explain: "You can safely abort the rebase to return to the state before you started:"
```bash
git rebase --abort
```

**If rebase already completed but result is wrong:**

Use reflog to find the pre-rebase state:
```bash
git reflog -20
```

Find the commit before the rebase started, then:
```bash
git branch backup-pre-rebase-fix
git reset --hard <pre-rebase-commit>
```

### Scenario F: Large Files

**Identify large files:**
```bash
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sort -rnk3 | head -20
```

Or for the current working tree:
```bash
find . -not -path './.git/*' -type f -size +10M 2>/dev/null
```

**Prevention:**
- Add large files to `.gitignore`
- Suggest Git LFS for files that need to be tracked
- Add a `.gitattributes` for LFS tracking patterns

**Removal from history:**
Explain (but do NOT run automatically) that BFG Repo Cleaner or `git filter-repo` can remove large files from history. Provide the exact command but let the user decide, as this requires force push.

### Scenario G: Corrupted Repository

**Run diagnostics:**
```bash
git fsck --full 2>&1
```

**Common fixes:**

1. **Missing objects**: try fetching from remote:
   ```bash
   git fetch --all
   ```

2. **Broken refs**: check and fix:
   ```bash
   git for-each-ref --format='%(refname)' 2>&1
   ```

3. **Last resort**: if remote is intact, re-clone:
   ```bash
   # Rename corrupted repo
   mv <repo> <repo>-corrupted
   git clone <remote-url>
   ```
   Then copy over any uncommitted work from the corrupted repo.

### Scenario H: Lost Commits

**Use reflog to find lost commits:**
```bash
git reflog -30
```

The reflog records all HEAD movements. Find the commit hash from before the destructive operation.

**Recover the commits:**
```bash
git branch recovered-work <commit-hash>
```

Explain: "Git keeps all commits for ~30 days even after they become unreachable. The reflog shows the history of where HEAD pointed."

### Step 3: Create Safety Net

Before ANY potentially destructive operation:

1. Create a backup branch:
   ```bash
   git branch backup-<timestamp>
   ```

2. Explain what the command will do in plain language
3. Explain how to undo it if something goes wrong
4. Let the user confirm before proceeding

### Step 4: Report

```
## Git Issue Resolution

**Issue**: <classification>
**Branch**: <current branch>
**State Before**: <description of the problem state>

### Diagnosis

<explanation of what happened and why>

### Resolution Applied

| Step | Command | Purpose |
|------|---------|---------|
| 1 | git branch backup-fix | Safety backup |
| 2 | <command> | <explanation> |

### Safety

- Backup branch: `backup-fix` (safe to delete after verification)
- Undo command: `<how to revert if needed>`

### Prevention

<suggestion to prevent this issue in the future>
```

**Critical safety rules:**
- NEVER use `--force` without explicit user confirmation and a backup
- NEVER rewrite published history without explaining the consequences to all collaborators
- ALWAYS create a backup branch before destructive operations
- ALWAYS explain what each git command does before suggesting it
- NEVER run `git push --force` to main/master -- warn the user if they request it
