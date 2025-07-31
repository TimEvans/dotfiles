# Dotfiles

Personal configuration files for Linux desktop environment featuring Hyprland, Waybar, and various development tools.

## Features

- **Hyprland**: Wayland compositor with custom keybindings and window management
- **Waybar**: Status bar with system information and workspaces
- **Neovim**: Full-featured editor configuration with LSP, plugins, and themes
- **Zsh**: Shell configuration with Starship prompt
- **Lazygit**: Git TUI configuration
- **Zellij**: Terminal multiplexer setup
- **SwayNC**: Notification daemon styling
- **Rose Pine**: Consistent theming across all applications

## Installation

### Prerequisites

Install stow package manager:

```bash
# Arch Linux
sudo pacman -S stow

# Ubuntu/Debian
sudo apt install stow

# macOS
brew install stow
```

### Apply Dotfiles

Clone this repository and use the management script:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./manage-config.sh apply
```

This will:
1. Create a timestamped backup of your current `~/.config`
2. Remove existing config
3. Use stow to symlink the dotfiles to your home directory

## Management Script Usage

The `manage-config.sh` script provides easy management of your dotfiles:

### Commands

```bash
# Apply dotfiles (creates backup first)
./manage-config.sh apply

# Restore most recent backup
./manage-config.sh restore

# Check current status and available backups
./manage-config.sh status

# Show help
./manage-config.sh help
```

### What Each Command Does

- **apply**: Backs up your current config, removes it, and symlinks the dotfiles using stow
- **restore**: Removes stowed dotfiles and restores your most recent backup
- **status**: Shows whether dotfiles are active and lists available backups

### Backup System

- Backups are stored as `~/.config.backup.YYYYMMDD_HHMMSS`
- A symlink `~/.config.backup.current` always points to the most recent backup
- Multiple backups are preserved so you can recover from any point

## Configuration Overview

### Hyprland
- Custom keybindings with Super key as modifier
- Multi-monitor workspace assignments
- Rose Pine theming
- Window rules and animations

### Waybar
- System tray with clock, battery, network status
- Workspace indicators
- Custom styling matching Rose Pine theme

### Neovim
- LSP configuration for multiple languages
- Plugin management with lazy.nvim
- Custom keybindings and themes
- Debugging support

## Customization

Since the dotfiles are symlinked, any changes you make will be reflected in the git repository. This allows you to:

1. Track your configuration changes
2. Easily sync across multiple machines
3. Revert to previous configurations

## Troubleshooting

If something goes wrong during application:

```bash
# Check status
./manage-config.sh status

# Restore backup
./manage-config.sh restore
```

The script will automatically attempt to restore your backup if stow fails during application.
