# Cross-Platform Dotfiles

Modern development environment configurations for Arch Linux and macOS using chezmoi for dotfile management.

## Features

- **Cross-platform**: Works on both Arch Linux and macOS
- **Chezmoi integration**: Secure, templated dotfile management
- **Modern development tools**: LazyVim, shell enhancements, and productivity tools
- **Automated setup**: One-command installation and synchronization
- **Version controlled**: All configurations tracked and easily shareable

## Current Setup

This dotfiles repository includes configurations for:

### Development Tools
- **LazyVim**: Modern Neovim configuration with plugin management
- **Alacritty**: Fast, cross-platform terminal emulator
- **Shell Tools**: Enhanced command-line experience
  - `fzf`: Fuzzy finder for files and commands
  - `zoxide`: Smart directory navigation
  - `eza`: Modern replacement for `ls`
  - `fd`: User-friendly alternative to `find`
  - `ripgrep`: Fast text search
  - `lazygit`: Terminal UI for git
  - `lazydocker`: Terminal UI for Docker
- **GitHub CLI**: Command-line interface for GitHub

### Applications
- **Signal**: Secure messaging application

## Installation

### Prerequisites
- **macOS**: Homebrew (will be installed automatically if missing)
- **Linux**: Package manager (pacman for Arch, apt for Ubuntu, etc.)

### Install with chezmoi

1. **Install chezmoi and initialize with this repository:**
   ```bash
   # macOS
   brew install chezmoi
   chezmoi init jonnyace/dotfiles

   # Linux (Arch)
   pacman -S chezmoi
   chezmoi init jonnyace/dotfiles

   # Other Linux distributions
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init jonnyace/dotfiles
   ```

2. **Review and apply the dotfiles:**
   ```bash
   chezmoi diff
   chezmoi apply
   ```

### Install Development Tools

**macOS:**
```bash
# Install all development tools and applications
brew install neovim fzf zoxide eza fd ripgrep lazygit lazydocker gh
brew install --cask alacritty signal
```

**Linux (Arch):**
```bash
# Install development tools
pacman -S neovim fzf zoxide eza fd ripgrep lazygit lazydocker github-cli alacritty
```

## Managing Dotfiles

### Adding new configurations
```bash
# Add a file to chezmoi management
chezmoi add ~/.config/newapp/config.yaml

# Edit files directly with chezmoi
chezmoi edit ~/.zshrc
```

### Updating configurations
```bash
# Pull latest changes from repository
chezmoi update

# View differences before applying
chezmoi diff

# Apply changes
chezmoi apply
```

### Pushing changes
```bash
# Add and commit changes
chezmoi cd
git add .
git commit -m "Update configurations"
git push
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