#!/bin/bash

# Package installation script for Arch Linux
# Installs essential development packages and applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing essential packages...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root${NC}" 
   exit 1
fi

# Update system first
echo -e "${YELLOW}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# Install official packages
echo -e "${YELLOW}Installing packages from official repositories...${NC}"
sudo pacman -S --needed --noconfirm \
    npm \
    nodejs \
    git \
    base-devel \
    syncthing

# Install AUR helper if not present
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}Installing yay AUR helper...${NC}"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

# Install AUR packages
echo -e "${YELLOW}Installing packages from AUR...${NC}"
yay -S --needed --noconfirm \
    claude-code \
    brave-bin

# Set Brave as default browser
echo -e "${YELLOW}Setting Brave as default browser...${NC}"
xdg-settings set default-web-browser brave-browser.desktop

echo -e "${GREEN}Package installation complete!${NC}"
echo -e "${YELLOW}Installed: Claude Code, Brave Browser, npm, nodejs, syncthing${NC}"
echo -e "${YELLOW}Claude Code: Use 'claude' command${NC}"
echo -e "${YELLOW}Brave is now your default browser${NC}"
echo -e "${YELLOW}Syncthing: Access web UI at http://localhost:8384 after starting service${NC}"