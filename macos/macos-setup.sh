#!/bin/sh -e

# Cross-platform macOS Setup Script
# Installs only essential cross-platform tools: homebrew, dev dependencies, dropbox, spotify, 1password

RC=''
RED=''
YELLOW=''
CYAN=''
GREEN=''

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

setup_askpass() {
    # Create a temporary askpass helper script
    ASKPASS_SCRIPT="/tmp/macutil_askpass_$$"
    cat > "$ASKPASS_SCRIPT" << 'EOF'
#!/bin/sh
osascript -e 'display dialog "Administrator password required for MacUtil setup:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null
EOF
    chmod +x "$ASKPASS_SCRIPT"
    export SUDO_ASKPASS="$ASKPASS_SCRIPT"
}

cleanup_askpass() {
    # Clean up the temporary askpass script
    if [ -n "$ASKPASS_SCRIPT" ] && [ -f "$ASKPASS_SCRIPT" ]; then
        rm -f "$ASKPASS_SCRIPT"
    fi
}

checkPackageManager() {
    ## Check if brew is installed
    if command_exists "brew"; then
        printf "%b\n" "${GREEN}Homebrew is installed${RC}"
    else
        printf "%b\n" "${RED}Homebrew is not installed${RC}"
        printf "%b\n" "${YELLOW}Installing Homebrew...${RC}"

        # Setup askpass helper for automated password handling
        setup_askpass

        # Use sudo with askpass for non-interactive installation
        SUDO_ASKPASS="$ASKPASS_SCRIPT" sudo -A /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        install_result=$?

        # Cleanup askpass helper
        cleanup_askpass

        if [ $install_result -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Homebrew${RC}"
            exit 1
        fi

        # Add Homebrew to PATH for the current session
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        trap cleanup_askpass EXIT INT TERM
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
    APPLICATIONS='dropbox spotify 1password'

    printf "%b\n" "${YELLOW}Installing development dependencies...${RC}"
    brew install $DEV_DEPENDENCIES

    printf "%b\n" "${YELLOW}Installing applications...${RC}"
    brew install --cask $APPLICATIONS
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
    printf "%b\n" "${GREEN}Starting Cross-Platform macOS Setup...${RC}"

    checkEnv

    printf "%b\n" "${GREEN}1. Installing development dependencies and applications...${RC}"
    installDepend

    printf "%b\n" "${GREEN}2. Installing dotfiles...${RC}"
    install_dotfiles

    printf "%b\n" "${GREEN}Cross-Platform macOS Setup Complete!${RC}"
    printf "%b\n" "${YELLOW}Please restart your terminal or logout/login for dotfiles to take effect.${RC}"
}

# Run main function if script is executed directly
if [ "${0##*/}" = "macos-setup.sh" ]; then
    main "$@"
fi