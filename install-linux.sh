#!/bin/bash

# Linux Installation Script for Dotfiles
# Supports Arch Linux with GNU Stow approach

set -e

echo "🐧 Linux Dotfiles Installation Script"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/arch-release ]; then
        DISTRO="arch"
        PKG_MANAGER="pacman"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
        PKG_MANAGER="apt"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
        PKG_MANAGER="dnf"
    else
        DISTRO="unknown"
        print_warning "Unknown distribution. Package installation may not work."
    fi
    print_status "Detected distribution: $DISTRO"
}

# Install system packages
install_packages() {
    print_status "Installing system packages..."

    case $DISTRO in
        "arch")
            # Install essential packages
            sudo pacman -S --needed --noconfirm \
                stow git neovim alacritty \
                btop fastfetch lazygit \
                zsh bash fish \
                fzf ripgrep fd eza zoxide

            # Install AUR helper if not present
            if ! command -v yay &> /dev/null; then
                print_status "Installing yay AUR helper..."
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay
                makepkg -si --noconfirm
                cd -
            fi

            # Install AUR packages
            yay -S --needed --noconfirm github-cli lazydocker
            ;;
        "debian")
            sudo apt update
            sudo apt install -y \
                stow git neovim alacritty \
                btop fastfetch \
                zsh bash fish \
                fzf ripgrep fd-find
            ;;
        "fedora")
            sudo dnf install -y \
                stow git neovim alacritty \
                btop fastfetch \
                zsh bash fish \
                fzf ripgrep fd-find
            ;;
        *)
            print_warning "Skipping package installation for unknown distribution"
            ;;
    esac
}

# Install dotfiles with Stow
install_dotfiles() {
    print_status "Installing dotfiles with GNU Stow..."

    # Ensure we're in the dotfiles directory
    if [ ! -d "linux" ]; then
        print_error "linux/ directory not found. Are you in the dotfiles repository?"
        exit 1
    fi

    cd linux/

    # Available packages
    PACKAGES=("shell" "terminal" "editors" "system-tools")
    OPTIONAL_PACKAGES=("desktop" "x11" "hyprland")

    # Install essential packages
    for package in "${PACKAGES[@]}"; do
        if [ -d "$package" ]; then
            print_status "Installing $package..."
            stow "$package"
            print_success "$package installed"
        else
            print_warning "$package directory not found, skipping"
        fi
    done

    # Ask about optional packages
    echo ""
    print_status "Optional packages available:"
    for package in "${OPTIONAL_PACKAGES[@]}"; do
        if [ -d "$package" ]; then
            echo "  - $package"
        fi
    done

    echo ""
    read -p "Install optional packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for package in "${OPTIONAL_PACKAGES[@]}"; do
            if [ -d "$package" ]; then
                print_status "Installing $package..."
                stow "$package"
                print_success "$package installed"
            fi
        done
    fi

    cd ..
}

# Optional: Install chezmoi for cross-platform tools
install_chezmoi() {
    echo ""
    read -p "Also install chezmoi for cross-platform tools? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing chezmoi..."

        case $DISTRO in
            "arch")
                sudo pacman -S --needed --noconfirm chezmoi
                ;;
            *)
                sh -c "$(curl -fsLS get.chezmoi.io)"
                ;;
        esac

        print_status "Initializing chezmoi with jonnyace/dotfiles..."
        chezmoi init jonnyace/dotfiles

        print_status "Review chezmoi changes:"
        chezmoi diff

        echo ""
        read -p "Apply chezmoi configurations? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chezmoi apply
            print_success "Chezmoi configurations applied"
        fi
    fi
}

# Main installation flow
main() {
    detect_distro
    install_packages
    install_dotfiles
    install_chezmoi

    echo ""
    print_success "Installation completed!"
    print_status "You may need to restart your shell or run 'source ~/.bashrc' to apply changes"

    echo ""
    echo "Next steps:"
    echo "  - Configure your terminal (colors, fonts, etc.)"
    echo "  - Run 'nvim' to setup Neovim plugins"
    echo "  - Customize configurations in ~/dotfiles/linux/"
}

# Run main function
main "$@"