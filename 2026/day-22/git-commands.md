# Git Commands Cheat Sheet

## Setup & Config

### Check Git Version

```bash
git --version
```

Checks the installed Git version.

### Configure Username

```bash
git config --global user.name "Your Name"
```

Sets the Git username globally.

### Configure Email

```bash
git config --global user.email "your-email@example.com"
```

Sets the Git email globally.

### View Configuration

```bash
git config --global --list
```

Displays the current global Git configuration.

---

## Basic Workflow

### Initialize Repository

```bash
git init
```

Creates a new Git repository in the current directory.

### Check Repository Status

```bash
git status
```

Shows modified, staged and untracked files.

### Stage File

```bash
git add filename
```

Adds a file to the staging area.

### Commit Changes

```bash
git commit -m "commit message"
```

Saves staged changes into Git history.

---

## Viewing Changes

### View Commit History

```bash
git log
```

Shows detailed commit history.

### Compact Commit History

```bash
git log --oneline
```

Shows commit history in compact format.

### View Changes

```bash
git diff
```

Shows unstaged changes.

---

## More Useful Commands

### Show Staged Changes

```bash
git diff --staged
```

Shows changes that have already been added to the staging area.

### Show Repository Files

```bash
git ls-files
```

Shows files currently tracked by Git.

### Show Current Branch

```bash
git branch
```

Shows local Git branches and identifies the current branch.

### Show Recent Commit

```bash
git show
```

Displays information and changes from the latest commit.
