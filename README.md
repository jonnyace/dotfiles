# Arch Linux & macOS Dotfiles

Cross-platform configuration files and settings for Arch Linux and macOS using GNU Stow for easy management.

## Features

- **Cross-platform**: Works on both Arch Linux and macOS
- **GNU Stow integration**: Easy installation, removal, and management of dotfiles
- **Modular packages**: Install only the configurations you need
- **Automatic OS detection**: Installs appropriate packages for your system
- **Conflict resolution**: Safe handling of existing configuration files

## Package Structure

This repository is organized into platform-specific folders containing modular packages:

### Linux Packages (linux/)
- **shell**: Bash configuration, git config, and shell environment
- **terminal**: Alacritty terminal configuration
- **editors**: Neovim and Lazygit configurations
- **system-tools**: btop, fastfetch, and walker configurations
- **desktop**: Desktop environment files (fontconfig, mimeapps, etc.)
- **x11**: X11 configuration files
- **hyprland**: Hyprland window manager, Waybar, Mako notifications, SwayOSD

### macOS Packages (macos/)
- **macos-setup.sh**: Comprehensive macOS system configuration script

## Quick Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/jonnyace/arch-config.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the installation script:**
   ```bash
   ./install.sh
   ```

The script will:
- Detect your operating system (Arch Linux or macOS)
- Install GNU Stow if not present
- Install system packages appropriate for your OS
- Use Stow to create symbolic links for all configuration files
- Handle conflicts with existing files safely

## Manual Package Management

### Install specific packages:
```bash
# For Linux systems
cd linux/
stow shell
stow terminal
stow editors

# For macOS systems
cd macos/
./macos-setup.sh
```

### Remove packages:
```bash
# For Linux systems
cd linux/
stow -D shell
stow -D terminal editors system-tools desktop x11 hyprland
```

### Reinstall/update packages:
```bash
# For Linux systems
cd linux/
stow -R shell
```

## Package Contents

### shell
- `.bashrc` - Bash configuration with Omarchy integration
- `.bash_profile` - Bash profile settings
- `.gitconfig` - Global git configuration with aliases

### terminal
- `alacritty/` - Alacritty terminal emulator configuration

### editors
- `nvim/` - Complete Neovim configuration with LazyVim
- `lazygit/` - Lazygit configuration

### system-tools
- `btop/` - btop system monitor configuration and themes
- `fastfetch/` - System information display configuration
- `walker/` - Application launcher configuration

### desktop
- `fontconfig/` - Font configuration
- `environment.d/` - Environment variables
- `mimeapps.list` - Default application associations
- `user-dirs.dirs` - XDG user directories

### x11
- `.XCompose` - X11 compose key configuration

### hyprland (Linux only)
- `hypr/` - Hyprland compositor configuration
- `waybar/` - Waybar status bar configuration
- `mako/` - Mako notification daemon configuration
- `swayosd/` - SwayOSD configuration

### macos/
- `macos-setup.sh` - Comprehensive macOS system setup script

## System Packages

The installation script will install essential packages for your system:

### Arch Linux
- Base packages: npm, nodejs, git, base-devel, syncthing
- AUR packages: claude-code, brave-bin
- System tools: btop, fastfetch, lazygit, neovim

### macOS (via Homebrew)
- Base packages: node, npm, git, stow, neovim
- System tools: btop, fastfetch, lazygit
- Applications: alacritty, brave-browser
- Optional: claude-code

## Customization

### Adding new packages
1. Create a new directory (e.g., `mypackage/`)
2. Structure it like your home directory (e.g., `mypackage/.config/myapp/config.conf`)
3. Install with: `stow mypackage`

### Modifying existing packages
1. Edit files directly in the package directories
2. Reinstall with: `stow -R <package-name>`

### OS-specific configurations
- Add OS-specific packages to the appropriate arrays in `install.sh`
- Create separate package directories for OS-specific configurations

## Troubleshooting

### Conflicts with existing files
If Stow reports conflicts with existing files:

```bash
# Option 1: Backup existing files manually
mv ~/.bashrc ~/.bashrc.backup
stow shell

# Option 2: Let stow adopt existing files (overwrites them)
stow --adopt shell

# Option 3: Use the interactive installer
./install.sh  # It will prompt you for conflict resolution
```

### Package not installing
- Ensure the package directory exists
- Check that files follow the correct directory structure
- Verify Stow is installed: `which stow`

### Remove all dotfiles
```bash
# For Linux systems
cd ~/dotfiles/linux/
stow -D shell terminal editors system-tools desktop x11 hyprland

# For macOS systems
# macOS configurations are handled by the setup script and system preferences
```

## Requirements

- **GNU Stow**: Automatically installed by the setup script
- **Bash**: For the installation scripts
- **Git**: For cloning and managing the repository

### Platform-specific requirements
- **Arch Linux**: pacman, yay (installed automatically)
- **macOS**: Homebrew (installed automatically if missing)

## License

This project is open source. Feel free to fork and customize for your own use.