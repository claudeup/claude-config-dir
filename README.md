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

git clone https://github.com/claudeup/claude-config-dir.git ~/.claude
cd ~/.claude
direnv allow
export CLAUDE_CONFIG_DIR=~/.claude
```
