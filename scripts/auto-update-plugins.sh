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

# Update claudeup
claudeup update

# Use claudeup to sync marketplaces and plugins
claudeup upgrade 2>&1 || true

# Mark as checked today
date +%Y-%m-%d > "$LAST_CHECK_FILE"

claudeup plugin list --enabled --format table
