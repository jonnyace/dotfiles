# Cross-Platform Dotfiles

Modern development environment configurations for Arch Linux and macOS using a hybrid approach:
- **GNU Stow** for Linux-specific configurations (Hyprland, desktop environments)
- **chezmoi** for cross-platform tools and modern development setup

## Features

- **Dual management system**: GNU Stow for Linux, chezmoi for cross-platform
- **Platform-specific**: Optimized configurations for each operating system
- **Modern development tools**: LazyVim, shell enhancements, and productivity tools
- **Modular approach**: Install only what you need
- **Version controlled**: All configurations tracked and easily shareable

## Which Approach Should You Use?

### Use GNU Stow (Linux) when:
- You want traditional Linux dotfile management
- You need desktop environment configs (Hyprland, i3, etc.)
- You prefer simple symlink-based management
- You're setting up a Linux-only environment

### Use chezmoi (Cross-platform) when:
- You work across multiple operating systems
- You want modern development tools consistently
- You need templating or conditional configurations
- You prefer a more feature-rich dotfile manager

### Use Both (Hybrid) when:
- You want the best of both worlds
- You have Linux desktop configs AND cross-platform dev tools
- You want to gradually migrate from Stow to chezmoi

## Repository Structure

### Cross-Platform Configurations (chezmoi managed)
- **LazyVim**: Modern Neovim configuration with plugin management
- **Shell Tools**: Enhanced command-line experience
  - `fzf`: Fuzzy finder for files and commands
  - `zoxide`: Smart directory navigation
  - `eza`: Modern replacement for `ls`
  - `fd`: User-friendly alternative to `find`
  - `ripgrep`: Fast text search
  - `lazygit`: Terminal UI for git
  - `lazydocker`: Terminal UI for Docker
- **GitHub CLI**: Command-line interface for GitHub
- **Alacritty**: Cross-platform terminal emulator
- **Signal**: Secure messaging application

### Linux-Specific Configurations (GNU Stow managed)
Located in `linux/` directory:

#### `linux/shell/`
- `.bashrc` - Bash configuration with enhanced features
- `.bash_profile` - Bash profile settings
- `.gitconfig` - Global git configuration with aliases

#### `linux/terminal/`
- `alacritty/` - Alacritty terminal emulator configuration

#### `linux/editors/`
- `nvim/` - Traditional Neovim configuration
- `lazygit/` - Lazygit configuration

#### `linux/system-tools/`
- `btop/` - System monitor configuration and themes
- `fastfetch/` - System information display
- `walker/` - Application launcher

#### `linux/desktop/`
- `fontconfig/` - Font configuration
- `environment.d/` - Environment variables
- `mimeapps.list` - Default application associations
- `user-dirs.dirs` - XDG user directories

#### `linux/x11/`
- `.XCompose` - X11 compose key configuration

#### `linux/hyprland/`
- `hypr/` - Hyprland compositor configuration
- `waybar/` - Waybar status bar
- `mako/` - Notification daemon
- `swayosd/` - On-screen display

## Installation

### Quick Installation (Recommended)

**macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/jonnyace/dotfiles/main/install-macos.sh | bash
```

**Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/jonnyace/dotfiles/main/install-linux.sh | bash
```

### Manual Installation

Choose your installation method based on your operating system and preferences:

### macOS Setup (chezmoi + modern tools)

1. **Install chezmoi and initialize:**
   ```bash
   brew install chezmoi
   chezmoi init jonnyace/dotfiles
   chezmoi diff
   chezmoi apply
   ```

2. **Install development tools:**
   ```bash
   brew install neovim fzf zoxide eza fd ripgrep lazygit lazydocker gh
   brew install --cask alacritty signal
   ```

### Linux Setup (GNU Stow + optional chezmoi)

#### Option 1: GNU Stow (Traditional Linux approach)

1. **Clone and setup:**
   ```bash
   git clone https://github.com/jonnyace/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install system packages (Arch Linux):**
   ```bash
   sudo pacman -S stow git neovim alacritty btop fastfetch lazygit
   ```

3. **Install configurations selectively:**
   ```bash
   cd linux/

   # Essential configs
   stow shell
   stow terminal
   stow editors
   stow system-tools

   # Desktop environment (optional)
   stow desktop
   stow x11

   # Hyprland setup (if using Hyprland)
   stow hyprland
   ```

#### Option 2: Hybrid approach (Stow + chezmoi)

1. **Setup GNU Stow for Linux configs:**
   ```bash
   git clone https://github.com/jonnyace/dotfiles.git ~/dotfiles
   cd ~/dotfiles/linux
   stow shell terminal editors system-tools
   ```

2. **Setup chezmoi for cross-platform tools:**
   ```bash
   # Install chezmoi
   sudo pacman -S chezmoi  # or: sh -c "$(curl -fsLS get.chezmoi.io)"

   # Initialize and apply cross-platform configs
   chezmoi init jonnyace/dotfiles
   chezmoi apply
   ```

## Managing Dotfiles

### For Cross-Platform Configs (chezmoi)

```bash
# Add new configurations
chezmoi add ~/.config/newapp/config.yaml
chezmoi edit ~/.zshrc

# Update and sync
chezmoi update    # Pull latest changes
chezmoi diff      # View differences
chezmoi apply     # Apply changes

# Push changes
chezmoi cd
git add .
git commit -m "Update configurations"
git push
```

### For Linux Configs (GNU Stow)

```bash
# Add new package
cd ~/dotfiles/linux
mkdir newpackage
# Structure files like: newpackage/.config/app/config.conf
stow newpackage

# Update existing package
cd ~/dotfiles/linux
# Edit files in the package directory
stow -R packagename    # Restow to apply changes

# Remove package
stow -D packagename

# Push changes to git
cd ~/dotfiles
git add .
git commit -m "Update Linux configurations"
git push
```

### Package Management (Linux Stow)

```bash
# Install specific packages
cd ~/dotfiles/linux
stow shell terminal editors

# Remove packages
stow -D hyprland desktop

# Reinstall (useful after editing)
stow -R system-tools
```

## Configuration Files

### Shell Configuration (`.zshrc`)
- Homebrew path configuration
- Zoxide initialization for smart directory navigation
- FZF shell integration for fuzzy finding
- Aliases for modern command replacements:
  - `ls` → `eza`
  - `ll` → `eza -la`

### LazyVim (`.config/nvim/`)
- Modern Neovim configuration with lazy loading
- Plugin management with lazy.nvim
- Sensible defaults and key mappings
- LSP integration for development

### Alacritty (`.config/alacritty/`)
- Cross-platform terminal emulator configuration
- Performance-optimized settings
- Custom themes and fonts

## Key Features

### Command Line Enhancements
- **fzf**: Press `Ctrl+R` for fuzzy command history search
- **zoxide**: Use `z <directory>` for smart directory jumping
- **eza**: Enhanced file listing with git status and colors
- **fd**: Fast file searching with intuitive syntax
- **ripgrep**: Blazing fast text search across files

### Development Workflow
- **LazyVim**: Feature-rich Neovim setup with LSP, treesitter, and modern plugins
- **lazygit**: Visual git interface in terminal
- **lazydocker**: Docker container management UI
- **GitHub CLI**: Repository management from command line

### Quick Start Commands
```bash
# Smart directory navigation
z ~/projects/myapp

# Fuzzy find files
fd myfile

# Search in files
rg "function myFunc"

# Git operations
lazygit

# Docker management
lazydocker
```

## Troubleshooting

### Chezmoi Issues
```bash
# Check what chezmoi would change
chezmoi diff

# Force apply all changes
chezmoi apply --force

# Reset to clean state
chezmoi update --force
```

### Shell Tools Not Working
```bash
# Reload shell configuration
source ~/.zshrc

# Check if tools are installed
which fzf zoxide eza fd rg lazygit gh

# Reinstall missing tools (macOS)
brew install fzf zoxide eza fd ripgrep lazygit lazydocker gh
```

### LazyVim Issues
```bash
# Update LazyVim plugins
nvim +Lazy update

# Check health
nvim +checkhealth
```

## Requirements

- **chezmoi**: Dotfile management
- **Git**: Version control and repository management
- **Shell**: zsh or bash

### Platform-specific requirements
- **macOS**: Homebrew for package management
- **Linux**: System package manager (pacman, apt, etc.)

## License

This project is open source. Feel free to fork and customize for your own use.