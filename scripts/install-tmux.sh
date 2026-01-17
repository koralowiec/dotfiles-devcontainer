#!/usr/bin/env bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$REPO_ROOT/config/tmux.conf"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux not found, attempting installation..."
    
    sudo apt-get update -y
    sudo apt-get install -y tmux
    
    if command -v tmux &> /dev/null; then
        echo "tmux installed successfully"
    else
        echo "ERROR: Failed to install tmux"
        exit 1
    fi
else
    echo "tmux is already installed"
fi

# Always copy tmux config
if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
fi

if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$HOME/.tmux.conf"
    echo "tmux configuration installed to ~/.tmux.conf"
else
    echo "ERROR: Config file not found at $CONFIG_FILE"
    exit 1
fi
