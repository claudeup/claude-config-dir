#!/usr/bin/env bash
# ABOUTME: Bootstraps Claude Code with claudeup, marketplaces, and auto-updates.
# ABOUTME: Supports interactive mode (default) and auto mode for CI/containers.

set -e

SETUP_MODE="${SETUP_MODE:-interactive}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Claude Code Sandbox..."
echo ""

if [ "$SETUP_MODE" = "auto" ]; then
    echo "-> Auto mode: Installing defaults without prompts..."
else
    echo "-> Interactive mode: Will prompt for options..."
fi
echo ""

# Install Claude Code CLI
echo "Installing Claude Code CLI..."
if command -v claude &> /dev/null; then
    CURRENT_VERSION=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
    echo "  Already installed ($CURRENT_VERSION)"
else
    npm install -g @anthropic-ai/claude-code
    echo "  Installed successfully"
fi
echo ""

# Install claudeup
echo "Installing claudeup..."
if command -v claudeup &> /dev/null; then
    CURRENT_VERSION=$(claudeup --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo "  Already installed (v$CURRENT_VERSION)"
else
    curl -fsSL https://raw.githubusercontent.com/claudeup/claudeup/main/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    echo "  Installed successfully"
fi
echo ""

# Install marketplaces from config
install_marketplaces() {
    local config_file="$SCRIPT_DIR/plugins/setup-marketplaces.json"

    if [ ! -f "$config_file" ]; then
        echo "  No marketplace config found, using defaults..."
        claude plugin marketplace add anthropics/claude-code
        claude plugin marketplace add obra/superpowers-marketplace
        return
    fi

    python3 << PYTHON_SCRIPT
import json
import subprocess
import sys

with open("$config_file") as f:
    config = json.load(f)

for name, marketplace in config.get("marketplaces", {}).items():
    source = marketplace.get("source")
    desc = marketplace.get("description", "")

    if source == "github":
        repo = marketplace.get("repo")
        print(f"  Installing {name}...")
        try:
            subprocess.run(
                ["claude", "plugin", "marketplace", "add", repo],
                check=True, capture_output=True
            )
            print(f"    Added {name}")
        except subprocess.CalledProcessError as e:
            if b"already" in e.stderr.lower() or b"already" in e.stdout.lower():
                print(f"    {name} (already installed)")
            else:
                print(f"    {name} failed: {e.stderr.decode()[:100]}")
    elif source == "git":
        url = marketplace.get("url")
        print(f"  Installing {name}...")
        try:
            subprocess.run(
                ["claude", "plugin", "marketplace", "add", url],
                check=True, capture_output=True
            )
            print(f"    Added {name}")
        except subprocess.CalledProcessError:
            print(f"    {name} (already installed or failed)")
PYTHON_SCRIPT
}

echo "Installing marketplaces..."
install_marketplaces
echo ""

# Run health check
echo "Running health check..."
if command -v claudeup &> /dev/null; then
    claudeup doctor || true
fi
echo ""

# Configure direnv (interactive mode only)
if [ "$SETUP_MODE" = "interactive" ]; then
    if command -v direnv &> /dev/null; then
        echo "direnv detected. Auto-updates will run when you enter this directory."
        echo ""
        read -r -p "Allow direnv for this directory? [Y/n] " response
        case $response in
            [nN][oO]|[nN])
                echo "Skipping direnv setup. Run 'direnv allow' later to enable."
                ;;
            *)
                direnv allow .
                echo "  direnv enabled"
                ;;
        esac
    else
        echo "direnv not installed. To enable auto-updates:"
        if command -v brew &> /dev/null; then
            echo "  brew install direnv"
        elif command -v apt-get &> /dev/null; then
            echo "  sudo apt-get install direnv"
        else
            echo "  https://direnv.net/docs/installation.html"
        fi
        echo "  Then add to your shell: eval \"\$(direnv hook bash)\""
    fi
    echo ""
fi

# Auto mode: just allow direnv
if [ "$SETUP_MODE" = "auto" ]; then
    if command -v direnv &> /dev/null; then
        direnv allow . 2>/dev/null || true
    fi
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  Run 'claude' to start using Claude Code"
echo "  Run 'claudeup plugin list <marketplace>' to browse available plugins"
echo "  Run 'claude plugin install <plugin>@<marketplace>' to install plugins"
