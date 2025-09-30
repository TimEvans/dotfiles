# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for a Linux desktop environment using Hyprland (Wayland compositor) with various development tools and applications. The repository uses GNU Stow for symlink-based configuration management.

## Architecture

### Stow-Based Structure

Each top-level directory (e.g., `hypr/`, `nvim/`, `waybar/`) is a stow "package" containing a `.config/` subdirectory. When stowed, these create symlinks from `~/.config/<package>` to the repository directories, keeping configurations in sync with the git repo.

Key packages:
- **hypr/**: Hyprland compositor configuration with theme files and startup scripts
- **nvim/**: Neovim configuration using lazy.nvim plugin manager (Lua-based, structure: `init.lua` → `lua/vim-options.lua` and `lua/config/` + `lua/plugins/`)
- **waybar/**: Status bar configuration (JSON + CSS)
- **zsh/**: Shell configuration with Oh My Zsh
- **zellij/**: Terminal multiplexer (KDL config format)
- **lazygit/**: Git TUI configuration (YAML)
- **wireplumber/**: Audio routing configuration
- **pipewire/**: Audio system configuration

Files at repository root (like `default-layout.kdl`, `.gtkrc-2.0`) are stowed directly to `~/`.

### Theme System

Multiple theme variants available (Rose Pine, Everforest) with dedicated config files:
- Hyprland sources theme via `source=~/.config/hypr/<theme>.conf`
- Each theme has corresponding variants in lazygit, waybar, etc.

## Common Commands

### Dotfiles Management

```bash
# Apply all dotfiles (creates backup, uses stow)
./manage-config.sh apply

# Restore most recent backup
./manage-config.sh restore

# Check status and list backups
./manage-config.sh status

# Stow individual package
stow nvim -t $HOME

# Unstow individual package
stow -D nvim -t $HOME
```

### Hyprland

```bash
# Reload Hyprland configuration
hyprctl reload

# Check Hyprland configuration for errors
hyprland --config ~/.config/hypr/hyprland.conf --check
```

### Neovim

Neovim uses lazy.nvim for plugin management. Configuration is modular with plugins in `lua/plugins/` including LSP, debugging, themes, telescope, harpoon, and more.

No build/test commands - configuration changes apply on next nvim launch.

## Important Notes

- **Symlinks are live**: Changes to stowed configs immediately affect the git repository
- **Backups**: Located at `~/.config.backup.YYYYMMDD_HHMMSS`, with `~/.config.backup.current` symlink to most recent
- **Theme changes**: Update `source=` line in `hypr/.config/hypr/hyprland.conf` and corresponding theme files in other packages
- **Dependencies**: Requires `stow` package manager
- **Git ignores**: `default-layout.kdl`, GTK bookmarks, and dconf settings