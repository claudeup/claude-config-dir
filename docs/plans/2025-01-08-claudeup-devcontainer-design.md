# Claudeup Devcontainer Showcase Design

## Overview

Transform this repo into a living example showcasing claudeup usage in a devcontainer. Users clone it to get a sandbox for testing Claude Code configs with automatic updates.

## Audience

- Developers new to Claude Code learning setup
- Existing Claude Code users wanting automation patterns

## Repository Structure

```sql
claude-config-dir/
├── .devcontainer/
│   ├── devcontainer.json      # Container config, features, postCreate
│   └── Dockerfile             # Custom image with direnv
├── scripts/
│   ├── auto-upgrade-claude.sh # Daily claudeup update check
│   └── auto-update-plugins.sh # Daily plugin sync
├── .envrc                     # Triggers scripts on directory entry
├── plugins/
│   └── marketplaces.txt       # Plugin marketplace URLs
├── settings.json              # Claude Code settings
├── CLAUDE.md                  # User instructions
└── README.md                  # Usage instructions
```

## Devcontainer Configuration

**Base:** `mcr.microsoft.com/devcontainers/javascript-node:22`

**Dockerfile additions:**
- Install direnv
- Configure bashrc with `eval "$(direnv hook bash)"`

**devcontainer.json:**
- Features: git, common-utils (jq, curl, etc.)
- `postCreateCommand`: Install claudeup, run `direnv allow`
- `postStartCommand`: Run auto-update scripts
- Environment: `CLAUDE_CONFIG_DIR` set to workspace folder

## Auto-Update Scripts

**`scripts/auto-upgrade-claude.sh`:**
- Checks `.last_claude_update_check` timestamp
- If older than 24 hours: runs `claudeup`
- Runs in background (non-blocking)
- Silent on success

**`scripts/auto-update-plugins.sh`:**
- Checks `.last_plugin_check` timestamp
- If older than 24 hours: runs `claudeup plugins`
- Runs in foreground
- Reads from `plugins/marketplaces.txt`

**`.envrc`:**
```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/scripts/auto-upgrade-claude.sh" &
"$SCRIPT_DIR/scripts/auto-update-plugins.sh"
```

## README Structure

- What this is (one-liner)
- Quick Start (3 steps)
- What's included (file/folder table)
- How updates work (brief)
- Using outside devcontainer (note about direnv)

## Implementation Notes

- Container is ephemeral - destroy/recreate to test fresh installs
- Same pattern works for real `~/.claude` setup with direnv installed
- No 1Password or other external dependencies in the example
