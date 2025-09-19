#!/bin/bash

# macOS Installation Script for Dotfiles
# Uses chezmoi for cross-platform configurations

set -e

echo "🍎 macOS Dotfiles Installation Script"
echo "====================================="

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

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed"
    else
        print_status "Homebrew already installed"
    fi
}

# Install development tools
install_dev_tools() {
    print_status "Installing development tools..."

    # Essential development tools
    brew_packages=(
        "neovim"
        "fzf"
        "zoxide"
        "eza"
        "fd"
        "ripgrep"
        "lazygit"
        "lazydocker"
        "gh"
        "git"
        "tree"
        "jq"
        "chezmoi"
    )

    # Applications
    brew_casks=(
        "alacritty"
        "signal"
    )

    print_status "Installing command-line tools..."
    for package in "${brew_packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_status "$package already installed"
        else
            print_status "Installing $package..."
            brew install "$package"
        fi
    done

    print_status "Installing applications..."
    for app in "${brew_casks[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            print_status "$app already installed"
        else
            print_status "Installing $app..."
            brew install --cask "$app"
        fi
    done

    print_success "Development tools installed"
}

# Setup chezmoi
setup_chezmoi() {
    print_status "Setting up chezmoi..."

    if [ ! -d "$HOME/.local/share/chezmoi" ]; then
        print_status "Initializing chezmoi with jonnyace/dotfiles..."
        chezmoi init jonnyace/dotfiles
    else
        print_status "Chezmoi already initialized"
    fi

    print_status "Reviewing chezmoi changes..."
    chezmoi diff

    echo ""
    read -p "Apply chezmoi configurations? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "Skipping chezmoi apply"
    else
        print_status "Applying chezmoi configurations..."
        chezmoi apply
        print_success "Chezmoi configurations applied"
    fi
}

# Setup shell integration
setup_shell() {
    print_status "Setting up shell integration..."

    # Setup fzf shell integration
    if [ -d "/opt/homebrew/opt/fzf" ]; then
        print_status "Setting up fzf shell integration..."
        /opt/homebrew/opt/fzf/install --all --no-bash --no-fish
    fi

    print_success "Shell integration configured"
}

# Setup GitHub CLI
setup_github_cli() {
    echo ""
    read -p "Setup GitHub CLI authentication? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setting up GitHub CLI..."
        gh auth login
        gh auth setup-git
        print_success "GitHub CLI configured"
    fi
}

# Optional: Install additional applications
install_optional_apps() {
    echo ""
    print_status "Optional applications available:"
    echo "  - brave-browser: Privacy-focused browser"
    echo "  - 1password: Password manager"
    echo "  - spotify: Music streaming"
    echo "  - dropbox: Cloud storage"
    echo "  - docker: Containerization platform"

    echo ""
    read -p "Install optional applications? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        optional_apps=(
            "brave-browser"
            "1password"
            "spotify"
            "dropbox"
            "docker"
        )

        for app in "${optional_apps[@]}"; do
            read -p "Install $app? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installing $app..."
                brew install --cask "$app"
            fi
        done
    fi
}

# Main installation flow
main() {
    install_homebrew
    install_dev_tools
    setup_chezmoi
    setup_shell
    setup_github_cli
    install_optional_apps

    echo ""
    print_success "macOS setup completed!"

    echo ""
    echo "🎉 Next steps:"
    echo "  - Restart your terminal or run 'source ~/.zshrc'"
    echo "  - Run 'nvim' to setup LazyVim plugins"
    echo "  - Configure Alacritty terminal settings"
    echo "  - Use 'chezmoi edit' to customize configurations"

    echo ""
    echo "🔧 Useful commands:"
    echo "  - z <directory>    # Smart directory jumping with zoxide"
    echo "  - fzf              # Fuzzy file finder"
    echo "  - lazygit          # Terminal git interface"
    echo "  - lazydocker       # Terminal docker interface"
    echo "  - eza -la          # Enhanced ls command"
}

# Run main function
main "$@"