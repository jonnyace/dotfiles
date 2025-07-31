# Arch Linux Dotfiles

Personal configuration files and settings for Arch Linux setup with custom Omarchy theme.

## Contents

- **home/**: Home directory dotfiles (`.bashrc`, `.gitconfig`, etc.)
- **config/**: Configuration directories from `~/.config/`
  - Hyprland configuration
  - Waybar configuration  
  - Neovim configuration
  - Alacritty terminal configuration
  - And many more...

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jonnyace/arch-config.git ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   cd ~/dotfiles
   ./install.sh
   ```

The script will:
- Create backups of existing configuration files
- Create symbolic links to the dotfiles in this repository
- Preserve your existing configurations as `.backup` files

## Manual Installation

If you prefer to install configurations manually:

```bash
# Link home directory files
ln -sf ~/dotfiles/home/.bashrc ~/.bashrc
ln -sf ~/dotfiles/home/.gitconfig ~/.gitconfig

# Link config directories
ln -sf ~/dotfiles/config/hypr ~/.config/hypr
ln -sf ~/dotfiles/config/waybar ~/.config/waybar
# ... and so on
```

## Included Configurations

- **Shell**: Bash configuration
- **Window Manager**: Hyprland
- **Status Bar**: Waybar
- **Terminal**: Alacritty
- **Editor**: Neovim
- **Git**: Global git configuration
- **System Tools**: btop, fastfetch, lazygit
- **And more...**
