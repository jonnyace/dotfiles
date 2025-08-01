#!/bin/bash

# Dotfiles installation script for Arch Linux
# This script symlinks configuration files to their proper locations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Installing dotfiles from $DOTFILES_DIR${NC}"

# Install packages first
echo -e "\n${GREEN}Installing packages...${NC}"
if [ -f "$DOTFILES_DIR/scripts/install-packages.sh" ]; then
    bash "$DOTFILES_DIR/scripts/install-packages.sh"
else
    echo -e "${YELLOW}Package installation script not found, skipping...${NC}"
fi

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${YELLOW}Backing up existing $target to $target.backup${NC}"
        mv "$target" "$target.backup"
    fi
    
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    echo -e "${GREEN}Linked $source -> $target${NC}"
}

# Install home directory dotfiles
echo -e "\n${GREEN}Installing home directory dotfiles...${NC}"
for file in "$DOTFILES_DIR/home"/{.*,*} 2>/dev/null; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    create_symlink "$file" "$HOME/$filename"
done

# Install config directory files
echo -e "\n${GREEN}Installing config directory files...${NC}"
for dir in "$DOTFILES_DIR/config"/*; do
    [ -d "$dir" ] || continue
    dirname=$(basename "$dir")
    create_symlink "$dir" "$HOME/.config/$dirname"
done

# Install individual config files
for file in "$DOTFILES_DIR/config"/{mimeapps.list,user-dirs.dirs} 2>/dev/null; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    create_symlink "$file" "$HOME/.config/$filename"
done

echo -e "\n${GREEN}Dotfiles installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or logout/login for all changes to take effect.${NC}"