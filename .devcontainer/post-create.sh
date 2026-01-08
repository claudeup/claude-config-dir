#!/usr/bin/env bash
# ABOUTME: Runs once when the devcontainer is first created
# ABOUTME: Installs claudeup and allows direnv for this workspace

set -e

echo "Installing claudeup..."
curl -fsSL https://raw.githubusercontent.com/claudeup/claudeup/main/install.sh | bash

echo "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo "Adding default marketplaces..."
claude plugin marketplace add anthropics/claude-code || true
claude plugin marketplace add obra/superpowers-marketplace || true

echo "Allowing direnv for workspace..."
direnv allow .

echo "Post-create setup complete!"
