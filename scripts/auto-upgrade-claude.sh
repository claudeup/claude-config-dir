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
