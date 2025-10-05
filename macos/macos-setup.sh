#!/bin/sh

# Cross-platform macOS Setup Script
# Installs only essential cross-platform tools: homebrew, dev dependencies, dropbox, spotify, 1password

set -e

RC='\033[0m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

# Debug: Show that script is starting
echo "Starting macOS setup script..."

command_exists() {
for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}

brewprogram_exists() {
for cmd in "$@"; do
    brew list "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}


checkPackageManager() {
    ## Check if brew is installed
    if command_exists "brew"; then
        printf "%b\n" "${GREEN}Homebrew is installed${RC}"
    else
        printf "%b\n" "${RED}Homebrew is not installed${RC}"
        printf "%b\n" "${YELLOW}Installing Homebrew...${RC}"

        # Install Homebrew using standard installation
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        install_result=$?

        if [ $install_result -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Homebrew${RC}"
            exit 1
        fi

        printf "%b\n" "${GREEN}Homebrew installed successfully${RC}"

        # Add Homebrew to PATH for current session and permanently
        if [ -f "/opt/homebrew/bin/brew" ]; then
            # Apple Silicon Mac
            printf "%b\n" "${YELLOW}Adding Homebrew to PATH for Apple Silicon Mac...${RC}"
            eval "$(/opt/homebrew/bin/brew shellenv)"

            # Add to shell profile permanently
            if [ -f "$HOME/.zprofile" ]; then
                grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/.zprofile" || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            else
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi

        elif [ -f "/usr/local/bin/brew" ]; then
            # Intel Mac
            printf "%b\n" "${YELLOW}Adding Homebrew to PATH for Intel Mac...${RC}"
            eval "$(/usr/local/bin/brew shellenv)"

            # Add to shell profile permanently
            if [ -f "$HOME/.zprofile" ]; then
                grep -q '/usr/local/bin/brew shellenv' "$HOME/.zprofile" || echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi
        else
            printf "%b\n" "${RED}Homebrew installation failed - brew binary not found${RC}"
            exit 1
        fi

        printf "%b\n" "${GREEN}Homebrew PATH configured${RC}"
    fi
}

checkCurrentDirectoryWritable() {
    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [ ! -w "$GITPATH" ]; then
        printf "%b\n" "${RED}Can't write to $GITPATH${RC}"
        exit 1
    fi
}

checkEnv() {
    checkPackageManager
}

installDepend() {
    ## Install development dependencies and cross-platform tools
    DEV_DEPENDENCIES='tree multitail tealdeer unzip cmake make jq fd ripgrep automake autoconf rustup python pipx stow git node npm'
    APPLICATIONS='dropbox spotify 1password alacritty brave-browser'

    printf "%b\n" "${YELLOW}Installing development dependencies...${RC}"
    for dep in $DEV_DEPENDENCIES; do
        if brew list "$dep" >/dev/null 2>&1; then
            printf "%b\n" "${GREEN}✓ $dep already installed${RC}"
        else
            printf "%b\n" "${CYAN}Installing $dep...${RC}"
            brew install "$dep" || printf "%b\n" "${YELLOW}⚠ Failed to install $dep, continuing...${RC}"
        fi
    done

    printf "%b\n" "${YELLOW}Installing applications...${RC}"
    for app in $APPLICATIONS; do
        if brew list --cask "$app" >/dev/null 2>&1; then
            printf "%b\n" "${GREEN}✓ $app already installed${RC}"
        else
            printf "%b\n" "${CYAN}Installing $app...${RC}"
            brew install --cask "$app" || printf "%b\n" "${YELLOW}⚠ Failed to install $app, continuing...${RC}"
        fi
    done

    printf "%b\n" "${YELLOW}Installing Claude CLI...${RC}"
    if brew list --cask claude-cli >/dev/null 2>&1; then
        printf "%b\n" "${GREEN}✓ claude-cli already installed${RC}"
    else
        printf "%b\n" "${CYAN}Installing claude-cli...${RC}"
        brew install --cask claude-cli || printf "%b\n" "${YELLOW}⚠ Failed to install claude-cli, continuing...${RC}"
    fi
}

configure_terminal() {
    ## Configure macOS Terminal.app to use zsh by default
    printf "%b\n" "${YELLOW}Configuring Terminal.app for zsh...${RC}"

    # Check if zsh is installed
    if ! command -v zsh >/dev/null 2>&1; then
        printf "%b\n" "${RED}zsh is not installed${RC}"
        return 1
    fi

    # Get the path to zsh
    ZSH_PATH=$(command -v zsh)
    printf "%b\n" "${CYAN}Found zsh at: $ZSH_PATH${RC}"

    # Check if zsh is in the list of valid shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        printf "%b\n" "${YELLOW}Adding zsh to /etc/shells...${RC}"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    # Change default shell to zsh
    CURRENT_SHELL=$(dscl . -read ~/ UserShell | sed 's/UserShell: //')
    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        printf "%b\n" "${CYAN}Changing default shell to zsh...${RC}"
        chsh -s "$ZSH_PATH"
        printf "%b\n" "${GREEN}✓ Default shell changed to zsh${RC}"
        printf "%b\n" "${YELLOW}Note: You may need to restart your terminal for this change to take effect${RC}"
    else
        printf "%b\n" "${GREEN}✓ zsh is already the default shell${RC}"
    fi
}


install_dotfiles() {
    printf "%b\n" "${YELLOW}Installing dotfiles using GNU Stow...${RC}"
    
    # Check if we're running from a downloaded script or from the repo
    DOTFILES_DIR="$HOME/dotfiles"
    if [ -d "$DOTFILES_DIR" ]; then
        printf "%b\n" "${YELLOW}Dotfiles directory already exists, updating...${RC}"
        cd "$DOTFILES_DIR"
        git pull
    else
        printf "%b\n" "${CYAN}Cloning dotfiles repository...${RC}"
        git clone https://github.com/jonnyace/dotfiles.git "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
    fi
    
    # Define macOS-compatible packages
    MACOS_PACKAGES=("shell" "terminal" "editors" "system-tools")
    
    # Function to install a stow package
    install_package() {
        local package="$1"
        printf "%b\n" "${CYAN}Installing $package package...${RC}"
        
        # Use stow to create symlinks
        if stow --target="$HOME" --dir="$DOTFILES_DIR/linux" "$package" 2>/dev/null; then
            printf "%b\n" "${GREEN}✓ Successfully installed $package${RC}"
        else
            printf "%b\n" "${YELLOW}⚠ Warning: Conflicts detected for $package. Adopting existing files...${RC}"
            stow --adopt --target="$HOME" --dir="$DOTFILES_DIR/linux" "$package" 2>/dev/null || true
            printf "%b\n" "${GREEN}✓ Successfully adopted and installed $package${RC}"
        fi
    }
    
    # Install macOS-compatible packages
    for package in "${MACOS_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/linux/$package" ]; then
            install_package "$package"
        else
            printf "%b\n" "${YELLOW}Package $package not found, skipping...${RC}"
        fi
    done
    
    printf "%b\n" "${GREEN}Dotfiles installation complete!${RC}"
}

main() {
    echo "Debug: main function called"
    printf "%b\n" "${GREEN}Starting Cross-Platform macOS Setup...${RC}"

    echo "Debug: calling checkEnv"
    checkEnv

    echo "Debug: calling installDepend"
    printf "%b\n" "${GREEN}1. Installing development dependencies and applications...${RC}"
    installDepend

    echo "Debug: calling configure_terminal"
    printf "%b\n" "${GREEN}2. Configuring terminal for zsh...${RC}"
    configure_terminal

    echo "Debug: calling install_dotfiles"
    printf "%b\n" "${GREEN}3. Installing dotfiles...${RC}"
    install_dotfiles

    printf "%b\n" "${GREEN}Cross-Platform macOS Setup Complete!${RC}"
    printf "%b\n" "${YELLOW}Please restart your terminal or logout/login for dotfiles to take effect.${RC}"
}

# Run main function
main "$@"