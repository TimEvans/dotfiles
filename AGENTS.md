# AGENTS.md - Agentic Coding Guidelines

## Repository Overview
Linux dotfiles repository using GNU Stow for symlink-based configuration management. No build system - configuration changes apply immediately.

## Commands
```bash
# Apply dotfiles with backup
./manage-config.sh apply

# Restore most recent backup
./manage-config.sh restore

# Check status
./manage-config.sh status

# Stow/unstow individual packages
stow nvim -t $HOME
stow -D nvim -t $HOME

# Hyprland validation
hyprland --config ~/.config/hypr/hyprland.conf --check
```

## Code Style
- **Shell scripts**: Use existing logging functions (log_info, log_error), colored output, comprehensive error handling
- **Lua (Neovim)**: Modular structure with require() imports, consistent 2-space indentation
- **JSON/JSONC**: Standard formatting, comments allowed in .jsonc files
- **TOML**: Proper section headers, consistent key naming
- **KDL**: Node-based configuration with clear nesting
- **YAML**: Consistent 2-space indentation

## Key Patterns
- Backup system creates timestamped directories at ~/.config.backup.YYYYMMDD_HHMMSS
- Theme variants (Rose Pine, Everforest) across all applications
- Symlinks are live - changes immediately affect git repository
- Follow existing file naming and structure conventions
- Never commit without explicit permission
- Use conventional commits: `type(scope): description`