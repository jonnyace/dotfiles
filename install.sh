#!/bin/bash

# Dotfiles installation script using GNU Stow
# Works on both Arch Linux and macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Installing dotfiles from $DOTFILES_DIR using GNU Stow${NC}"

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/arch-release ]; then
        OS="arch"
    else
        OS="linux"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
fi

echo -e "${BLUE}Detected OS: $OS${NC}"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${YELLOW}GNU Stow is not installed. Installing...${NC}"
    case $OS in
        "arch")
            sudo pacman -S --needed --noconfirm stow
            ;;
        "mac")
            if command -v brew &> /dev/null; then
                brew install stow
            else
                echo -e "${RED}Please install Homebrew first, then run: brew install stow${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Please install GNU Stow manually for your system${NC}"
            exit 1
            ;;
    esac
fi

# Install packages first
echo -e "\n${GREEN}Installing system packages...${NC}"
case $OS in
    "arch")
        if [ -f "$DOTFILES_DIR/scripts/install-packages.sh" ]; then
            bash "$DOTFILES_DIR/scripts/install-packages.sh"
        else
            echo -e "${YELLOW}Arch package installation script not found, skipping...${NC}"
        fi
        ;;
    "mac")
        if [ -f "$DOTFILES_DIR/scripts/install-packages-mac.sh" ]; then
            bash "$DOTFILES_DIR/scripts/install-packages-mac.sh"
        else
            echo -e "${YELLOW}macOS package installation script not found, skipping...${NC}"
        fi
        ;;
esac

# Define available packages
COMMON_PACKAGES=("shell" "terminal" "editors" "system-tools" "desktop" "x11")
ARCH_PACKAGES=("hyprland")
MAC_PACKAGES=()

# Function to install a stow package
install_package() {
    local package="$1"
    echo -e "${GREEN}Installing $package package...${NC}"
    
    # Use stow to create symlinks
    if stow --target="$HOME" --dir="$DOTFILES_DIR" "$package" 2>/dev/null; then
        echo -e "${GREEN}✓ Successfully installed $package${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: Conflicts detected for $package. Use 'stow --adopt' to resolve or backup existing files.${NC}"
        read -p "Do you want to adopt existing files and overwrite them? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            stow --adopt --target="$HOME" --dir="$DOTFILES_DIR" "$package"
            echo -e "${GREEN}✓ Successfully adopted and installed $package${NC}"
        else
            echo -e "${YELLOW}⚠ Skipped $package due to conflicts${NC}"
        fi
    fi
}

# Install common packages
echo -e "\n${GREEN}Installing common packages...${NC}"
for package in "${COMMON_PACKAGES[@]}"; do
    if [ -d "$DOTFILES_DIR/$package" ]; then
        install_package "$package"
    else
        echo -e "${YELLOW}Package $package not found, skipping...${NC}"
    fi
done

# Install OS-specific packages
case $OS in
    "arch")
        echo -e "\n${GREEN}Installing Arch-specific packages...${NC}"
        for package in "${ARCH_PACKAGES[@]}"; do
            if [ -d "$DOTFILES_DIR/$package" ]; then
                install_package "$package"
            else
                echo -e "${YELLOW}Package $package not found, skipping...${NC}"
            fi
        done
        ;;
    "mac")
        echo -e "\n${GREEN}Installing macOS-specific packages...${NC}"
        for package in "${MAC_PACKAGES[@]}"; do
            if [ -d "$DOTFILES_DIR/$package" ]; then
                install_package "$package"
            else
                echo -e "${YELLOW}Package $package not found, skipping...${NC}"
            fi
        done
        ;;
esac

echo -e "\n${GREEN}Dotfiles installation complete!${NC}"
echo -e "${BLUE}Installed packages can be managed with GNU Stow:${NC}"
echo -e "${YELLOW}  - To uninstall a package: ${NC}stow -D <package>"
echo -e "${YELLOW}  - To reinstall a package: ${NC}stow -R <package>"
echo -e "${YELLOW}  - To install a new package: ${NC}stow <package>"
echo -e "\n${YELLOW}Note: You may need to restart your shell or logout/login for all changes to take effect.${NC}"