#!/usr/bin/env bash
# ABOUTME: Runs each time the devcontainer starts
# ABOUTME: Ensures direnv is allowed and PATH includes claudeup

set -e

# Ensure ~/.local/bin is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Re-allow direnv in case .envrc changed
direnv allow . 2>/dev/null || true

echo "Container started. Run 'claude' to begin."
