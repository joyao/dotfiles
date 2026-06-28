#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "Deploying dotfiles from $DOTFILES_DIR to $HOME_DIR..."

create_symlink() {
    local target="$1"
    local link="$2"

    if [ -e "$link" ] || [ -L "$link" ]; then
        if [ -L "$link" ]; then
            echo "Removing existing symlink: $link"
            rm -f "$link"
        else
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local backup_name="${link}.backup_${timestamp}"
            echo "Backing up existing file $link to $backup_name"
            mv "$link" "$backup_name"
        fi
    fi

    echo "Creating symlink: $link -> $target"
    ln -s "$target" "$link"
}

# 1. Deploy tmux config
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME_DIR/.tmux.conf"

# 2. Deploy zsh config
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME_DIR/.zshrc"

# 3. Deploy Gemini guidelines
GEMINI_DIR="$HOME_DIR/.gemini"
if [ ! -d "$GEMINI_DIR" ]; then
    echo "Creating directory: $GEMINI_DIR"
    mkdir -p "$GEMINI_DIR"
fi
create_symlink "$DOTFILES_DIR/gemini/GEMINI.md" "$GEMINI_DIR/GEMINI.md"

echo "Deployment complete!"
