# Claude Code Sandbox

A devcontainer-based sandbox for testing Claude Code configurations with automatic updates.

## Quick Start (Devcontainer)

1. Clone this repo
2. Open in VS Code with Dev Containers extension (or GitHub Codespaces)
3. Run `claude` to start

The devcontainer automatically installs Claude Code, claudeup, and default marketplaces.

## Quick Start (Local)

```bash
git clone https://github.com/claudeup/claude-config-dir.git ~/.claude
cd ~/.claude
./setup.sh
```

The interactive setup will:
1. Install Claude Code and claudeup
2. Add default marketplaces (Anthropic official + Superpowers)
3. Configure direnv for auto-updates

## What's Included

| Path | Purpose |
|------|---------|
| `setup.sh` | Post-clone setup script |
| `.devcontainer/` | Container configuration with direnv |
| `scripts/auto-upgrade-claude.sh` | Daily Claude Code + claudeup updates |
| `scripts/auto-update-plugins.sh` | Daily plugin/marketplace sync |
| `.envrc` | Triggers update scripts on directory entry |
| `plugins/setup-marketplaces.json` | Marketplace configuration |
| `CLAUDE.md` | User instructions for Claude |
| `settings.json` | Claude Code settings |

## Setup Modes

**Interactive mode (default):**
```bash
./setup.sh
```

**Auto mode (for CI/containers):**
```bash
SETUP_MODE=auto ./setup.sh
```

## How Auto-Updates Work

When you enter this directory, `.envrc` runs:
1. `auto-upgrade-claude.sh` (background) - updates claudeup and Claude Code
2. `auto-update-plugins.sh` - syncs plugins from marketplaces

Both scripts throttle to once per day using timestamp files.

**Requirements:**
- direnv installed and hooked into your shell
- Run `direnv allow` after cloning

## Customization

### Adding Marketplaces

Edit `plugins/setup-marketplaces.json`:

```json
{
  "marketplaces": {
    "my-marketplace": {
      "source": "github",
      "repo": "username/repo",
      "description": "My custom plugins"
    }
  }
}
```

Then run `./setup.sh` or manually:
```bash
claude plugin marketplace add username/repo
```

### Private Marketplaces

Create `plugins/setup-marketplaces.local.json` (gitignored):

```json
{
  "marketplaces": {
    "private-plugins": {
      "source": "github",
      "repo": "myorg/private-repo",
      "description": "Private plugins"
    }
  }
}
```

## Useful Commands

```bash
# List installed marketplaces
claude plugin marketplace list

# Browse plugins in a marketplace
claudeup plugin list superpowers-marketplace

# Install a plugin
claude plugin install superpowers@superpowers-marketplace

# Check for updates
claudeup outdated

# Force update check
./scripts/auto-upgrade-claude.sh --force
./scripts/auto-update-plugins.sh --force
```
