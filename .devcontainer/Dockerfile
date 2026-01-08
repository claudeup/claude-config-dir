# ABOUTME: Custom devcontainer image with direnv pre-configured
# ABOUTME: Enables .envrc auto-loading for Claude Code auto-updates

FROM mcr.microsoft.com/devcontainers/javascript-node:22

# Install direnv
RUN apt-get update && apt-get install -y direnv && rm -rf /var/lib/apt/lists/*

# Configure direnv hook in bashrc for all users
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc
