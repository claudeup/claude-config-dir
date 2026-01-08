# Claudeup Devcontainer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a working devcontainer sandbox showcasing claudeup auto-updates for Claude Code.

**Architecture:** Devcontainer with Node.js base, direnv for auto-loading, and scripts that throttle updates to once daily. Container mounts workspace as `$CLAUDE_CONFIG_DIR`.

**Tech Stack:** Docker, devcontainer.json, bash scripts, direnv

---

### Task 1: Create Dockerfile with Direnv

**Files:**
- Create: `.devcontainer/Dockerfile`

**Step 1: Create the Dockerfile**

```dockerfile
# ABOUTME: Custom devcontainer image with direnv pre-configured
# ABOUTME: Enables .envrc auto-loading for Claude Code auto-updates

FROM mcr.microsoft.com/devcontainers/javascript-node:22

# Install direnv
RUN apt-get update && apt-get install -y direnv && rm -rf /var/lib/apt/lists/*

# Configure direnv hook in bashrc for all users
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc
```

**Step 2: Verify Dockerfile syntax**

Run: `docker build -f .devcontainer/Dockerfile -t test-devcontainer . --dry-run` (or just visual inspection)
Expected: No syntax errors

**Step 3: Commit**

```bash
git add .devcontainer/Dockerfile
git commit -m "feat: add Dockerfile with direnv configuration"
```

---

### Task 2: Create devcontainer.json

**Files:**
- Create: `.devcontainer/devcontainer.json`

**Step 1: Create devcontainer.json**

```json
{
  "name": "Claude Code Sandbox",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": false,
      "configureZshAsDefaultShell": false,
      "installOhMyZsh": false,
      "installOhMyZshConfig": false,
      "upgradePackages": true
    }
  },
  "containerEnv": {
    "CLAUDE_CONFIG_DIR": "${containerWorkspaceFolder}"
  },
  "postCreateCommand": ".devcontainer/post-create.sh",
  "postStartCommand": ".devcontainer/post-start.sh",
  "customizations": {
    "vscode": {
      "extensions": []
    }
  }
}
```

**Step 2: Commit**

```bash
git add .devcontainer/devcontainer.json
git commit -m "feat: add devcontainer.json configuration"
```

---

### Task 3: Create Post-Create Script

**Files:**
- Create: `.devcontainer/post-create.sh`

**Step 1: Create the script**

```bash
#!/usr/bin/env bash
# ABOUTME: Runs once when the devcontainer is first created
# ABOUTME: Installs claudeup and allows direnv for this workspace

set -e

echo "Installing claudeup..."
curl -fsSL https://raw.githubusercontent.com/claudeup/claudeup/main/install.sh | bash

echo "Installing Claude Code..."
"$HOME/.local/bin/claudeup"

echo "Allowing direnv for workspace..."
direnv allow .

echo "Post-create setup complete!"
```

**Step 2: Make it executable**

Run: `chmod +x .devcontainer/post-create.sh`

**Step 3: Commit**

```bash
git add .devcontainer/post-create.sh
git commit -m "feat: add post-create script for claudeup installation"
```

---

### Task 4: Create Post-Start Script

**Files:**
- Create: `.devcontainer/post-start.sh`

**Step 1: Create the script**

```bash
#!/usr/bin/env bash
# ABOUTME: Runs each time the devcontainer starts
# ABOUTME: Ensures direnv is allowed and PATH includes claudeup

set -e

# Ensure ~/.local/bin is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Re-allow direnv in case .envrc changed
direnv allow . 2>/dev/null || true

echo "Container started. Run 'claude' to begin."
```

**Step 2: Make it executable**

Run: `chmod +x .devcontainer/post-start.sh`

**Step 3: Commit**

```bash
git add .devcontainer/post-start.sh
git commit -m "feat: add post-start script for container startup"
```

---

### Task 5: Create Auto-Upgrade Claude Script

**Files:**
- Create: `scripts/auto-upgrade-claude.sh`

**Step 1: Create scripts directory**

Run: `mkdir -p scripts`

**Step 2: Create the script**

```bash
#!/usr/bin/env bash
# ABOUTME: Automatically upgrade Claude Code and claudeup daily
# ABOUTME: Called by .envrc when entering the directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAST_CHECK_FILE="$SCRIPT_DIR/../.last_claude_update_check"

# Parse arguments
FORCE=false
if [ "$1" = "--force" ]; then
    FORCE=true
fi

# Check if we've already run today (unless --force)
if [ "$FORCE" = false ] && [ -f "$LAST_CHECK_FILE" ]; then
    LAST_CHECK=$(cat "$LAST_CHECK_FILE")
    TODAY=$(date +%Y-%m-%d)

    if [ "$LAST_CHECK" = "$TODAY" ]; then
        exit 0
    fi
fi

# Ensure claudeup is in PATH
export PATH="$HOME/.local/bin:$PATH"

echo "Checking for Claude Code updates..."

# Get current version before upgrading
OLD_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not installed")

# Run the upgrade via claudeup
claudeup 2>&1 || true

# Get new version after upgrading
NEW_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "not installed")

if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    echo "Claude Code upgraded: $OLD_VERSION -> $NEW_VERSION"
else
    echo "Claude Code is up to date ($NEW_VERSION)"
fi

# Update claudeup itself
echo "Checking for claudeup updates..."
claudeup update 2>&1 || true

# Mark as checked today
date +%Y-%m-%d > "$LAST_CHECK_FILE"
```

**Step 3: Make it executable**

Run: `chmod +x scripts/auto-upgrade-claude.sh`

**Step 4: Commit**

```bash
git add scripts/auto-upgrade-claude.sh
git commit -m "feat: add auto-upgrade script for Claude Code and claudeup"
```

---

### Task 6: Create Auto-Update Plugins Script

**Files:**
- Create: `scripts/auto-update-plugins.sh`

**Step 1: Create the script**

```bash
#!/usr/bin/env bash
# ABOUTME: Automatically update Claude Code plugins and marketplaces daily
# ABOUTME: Called by .envrc when entering the directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAST_CHECK_FILE="$SCRIPT_DIR/../.last_plugin_check"

# Parse arguments
FORCE=false
if [ "$1" = "--force" ]; then
    FORCE=true
fi

# Check if we've already run today (unless --force)
if [ "$FORCE" = false ] && [ -f "$LAST_CHECK_FILE" ]; then
    LAST_CHECK=$(cat "$LAST_CHECK_FILE")
    TODAY=$(date +%Y-%m-%d)

    if [ "$LAST_CHECK" = "$TODAY" ]; then
        exit 0
    fi
fi

# Ensure claudeup is in PATH
export PATH="$HOME/.local/bin:$PATH"

echo "Checking for plugin/marketplace updates..."

# Use claudeup to sync marketplaces and plugins
claudeup upgrade 2>&1 || true

# Mark as checked today
date +%Y-%m-%d > "$LAST_CHECK_FILE"
```

**Step 2: Make it executable**

Run: `chmod +x scripts/auto-update-plugins.sh`

**Step 3: Commit**

```bash
git add scripts/auto-update-plugins.sh
git commit -m "feat: add auto-update script for plugins and marketplaces"
```

---

### Task 7: Create .envrc

**Files:**
- Create: `.envrc`

**Step 1: Create the .envrc file**

```bash
#!/usr/bin/env bash
# ABOUTME: Auto-upgrade Claude Code when entering this directory
# ABOUTME: Requires direnv to be installed and hooked into your shell

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure claudeup is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Auto-upgrade Claude Code and claudeup daily (runs in background)
"$SCRIPT_DIR/scripts/auto-upgrade-claude.sh" &

# Auto-update plugins and marketplaces daily
"$SCRIPT_DIR/scripts/auto-update-plugins.sh"
```

**Step 2: Commit**

```bash
git add .envrc
git commit -m "feat: add .envrc for automatic update triggers"
```

---

### Task 8: Add Example Marketplaces

**Files:**
- Create: `plugins/marketplaces.txt`

**Step 1: Create example marketplaces file**

```text
# ABOUTME: Example plugin marketplaces for Claude Code
# ABOUTME: Add marketplace URLs here, one per line

# Official Anthropic plugins
anthropics/claude-code

# Community marketplaces
ccplugins/marketplace
obra/superpowers-marketplace
```

**Step 2: Remove .gitkeep since we now have content**

Run: `rm plugins/.gitkeep`

**Step 3: Commit**

```bash
git add plugins/marketplaces.txt
git rm plugins/.gitkeep 2>/dev/null || true
git commit -m "feat: add example marketplaces configuration"
```

---

### Task 9: Update README

**Files:**
- Modify: `README.md`

**Step 1: Replace README content**

```markdown
# Claude Code Sandbox

A devcontainer-based sandbox for testing Claude Code configurations with automatic updates.

## Quick Start

1. Clone this repo
2. Open in VS Code with Dev Containers extension (or GitHub Codespaces)
3. Run `claude` to start

## What's Included

| Path | Purpose |
|------|---------|
| `.devcontainer/` | Container configuration with direnv |
| `scripts/auto-upgrade-claude.sh` | Daily Claude Code + claudeup updates |
| `scripts/auto-update-plugins.sh` | Daily plugin/marketplace sync |
| `.envrc` | Triggers update scripts on directory entry |
| `plugins/marketplaces.txt` | Example marketplace sources |
| `CLAUDE.md` | User instructions for Claude |
| `settings.json` | Claude Code settings |

## How Updates Work

When you enter this directory (or the container starts), `.envrc` runs:
1. `auto-upgrade-claude.sh` (background) - updates claudeup and Claude Code
2. `auto-update-plugins.sh` - syncs plugins from marketplaces

Both scripts throttle to once per day using timestamp files.

## Using Outside Devcontainer

This also works as a standalone `$CLAUDE_CONFIG_DIR`:

```bash
# Install direnv and hook it into your shell
# See: https://direnv.net/docs/installation.html

git clone https://github.com/your-org/claude-config-dir.git ~/.claude
cd ~/.claude
direnv allow
export CLAUDE_CONFIG_DIR=~/.claude
```
```sql

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README with sandbox usage instructions"
```

---

### Task 10: Add Timestamp Files to .gitignore

**Files:**
- Modify: `.gitignore` (create if needed)

**Step 1: Create/update .gitignore**

```gitignore
# Timestamp files for update throttling
.last_claude_update_check
.last_plugin_check

# Plugin cache (downloaded plugins)
plugins/cache/

# Local settings that shouldn't be shared
*.local.md
```

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add gitignore for timestamp and cache files"
```

---

### Task 11: Test the Setup (Manual Verification)

**Verification steps:**

1. Open the repo in VS Code with Dev Containers extension
2. Wait for container to build and post-create to complete
3. Open a terminal in the container
4. Verify `claude --version` shows a version
5. Verify `claudeup --version` shows a version
6. Verify `direnv status` shows the .envrc is loaded
7. Run `scripts/auto-upgrade-claude.sh --force` to test the script
8. Run `scripts/auto-update-plugins.sh --force` to test the script

---

## Execution Complete Checklist

- [ ] Dockerfile created with direnv
- [ ] devcontainer.json configured
- [ ] post-create.sh installs claudeup
- [ ] post-start.sh sets up environment
- [ ] auto-upgrade-claude.sh works
- [ ] auto-update-plugins.sh works
- [ ] .envrc triggers both scripts
- [ ] marketplaces.txt has examples
- [ ] README explains usage
- [ ] .gitignore excludes temp files
- [ ] Manual testing in devcontainer passes
