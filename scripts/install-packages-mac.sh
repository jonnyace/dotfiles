#!/bin/bash

# Package installation script for macOS
# Installs essential development packages and applications using Homebrew

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing essential packages for macOS...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root${NC}" 
   exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -d "/opt/homebrew" ]]; then
        # Apple Silicon Macs
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Update Homebrew
echo -e "${YELLOW}Updating Homebrew...${NC}"
brew update

# Install core packages
echo -e "${YELLOW}Installing packages from Homebrew...${NC}"
brew install --quiet \
    node \
    npm \
    git \
    stow \
    neovim \
    btop \
    fastfetch \
    lazygit

# Install cask applications
echo -e "${YELLOW}Installing applications from Homebrew Cask...${NC}"
brew install --cask --quiet \
    alacritty \
    brave-browser

# Install Claude Code if available
echo -e "${YELLOW}Attempting to install Claude Code...${NC}"
if brew list claude-code &>/dev/null; then
    echo -e "${GREEN}Claude Code already installed${NC}"
elif brew install claude-code &>/dev/null; then
    echo -e "${GREEN}Claude Code installed successfully${NC}"
else
    echo -e "${YELLOW}Claude Code not available via Homebrew. Please install manually from https://claude.ai/code${NC}"
fi

# Set Brave as default browser (if possible)
echo -e "${YELLOW}Setting Brave as default browser...${NC}"
if command -v defaultbrowser &> /dev/null; then
    defaultbrowser brave
elif [ -f "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ]; then
    open -b com.brave.Browser --args --make-default-browser 2>/dev/null || true
    echo -e "${YELLOW}Please manually set Brave as your default browser in System Preferences${NC}"
else
    echo -e "${YELLOW}Brave Browser not found. Please set your preferred browser manually.${NC}"
fi

echo -e "${GREEN}macOS package installation complete!${NC}"
echo -e "${YELLOW}Installed: Node.js, npm, git, stow, neovim, btop, fastfetch, lazygit${NC}"
echo -e "${YELLOW}Applications: Alacritty (terminal), Brave Browser${NC}"
echo -e "${YELLOW}Note: You may need to restart your terminal for all changes to take effect.${NC}"
echo -e "${YELLOW}Claude Code: Use 'claude' command (if successfully installed)${NC}"