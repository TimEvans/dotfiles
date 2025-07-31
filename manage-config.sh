#!/bin/bash

# Dotfiles management script using stow
# Usage: ./manage-config.sh [apply|restore|status]

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
CURRENT_BACKUP_LINK="$HOME/.config.backup.current"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    if ! command -v stow &> /dev/null; then
        log_error "stow is not installed. Please install it first:"
        log_info "  Ubuntu/Debian: sudo apt install stow"
        log_info "  Arch: sudo pacman -S stow"
        log_info "  macOS: brew install stow"
        exit 1
    fi
}

backup_current_config() {
    if [[ -d "$CONFIG_DIR" ]]; then
        log_info "Backing up current ~/.config to $BACKUP_DIR"
        cp -r "$CONFIG_DIR" "$BACKUP_DIR"
        
        # Update current backup symlink
        if [[ -L "$CURRENT_BACKUP_LINK" ]]; then
            rm "$CURRENT_BACKUP_LINK"
        fi
        ln -s "$BACKUP_DIR" "$CURRENT_BACKUP_LINK"
        
        log_success "Backup created successfully"
    else
        log_warning "No ~/.config directory found to backup"
    fi
}

apply_dotfiles() {
    log_info "Applying dotfiles from $DOTFILES_DIR"
    
    # Check if .config exists in dotfiles repo
    if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
        log_error "No .config directory found in $DOTFILES_DIR"
        exit 1
    fi
    
    # Create backup first
    backup_current_config
    
    # Remove existing .config if it exists
    if [[ -d "$CONFIG_DIR" ]]; then
        log_info "Removing existing ~/.config"
        rm -rf "$CONFIG_DIR"
    fi
    
    # Use stow to symlink the dotfiles
    cd "$DOTFILES_DIR"
    if stow . -t "$HOME" 2>/dev/null; then
        log_success "Dotfiles applied successfully using stow"
        log_info "Your dotfiles are now active and will stay in sync with the repository"
    else
        log_error "Failed to apply dotfiles with stow"
        log_info "Attempting to restore backup..."
        restore_backup
        exit 1
    fi
}

restore_backup() {
    if [[ -L "$CURRENT_BACKUP_LINK" ]] && [[ -d "$(readlink "$CURRENT_BACKUP_LINK")" ]]; then
        local backup_path=$(readlink "$CURRENT_BACKUP_LINK")
        log_info "Restoring backup from $backup_path"
        
        # Remove stowed dotfiles
        cd "$DOTFILES_DIR"
        stow -D . -t "$HOME" 2>/dev/null || true
        
        # Remove current .config and restore backup
        if [[ -d "$CONFIG_DIR" ]] || [[ -L "$CONFIG_DIR" ]]; then
            rm -rf "$CONFIG_DIR"
        fi
        
        cp -r "$backup_path" "$CONFIG_DIR"
        log_success "Backup restored successfully"
    else
        log_error "No current backup found to restore"
        exit 1
    fi
}

show_status() {
    echo -e "${BLUE}=== Dotfiles Status ===${NC}"
    
    if [[ -L "$CONFIG_DIR" ]]; then
        local link_target=$(readlink "$CONFIG_DIR")
        if [[ "$link_target" == "$DOTFILES_DIR/.config" ]]; then
            log_success "Dotfiles are currently active (stowed)"
            echo "  Target: $link_target"
        else
            log_warning "~/.config is a symlink but not pointing to dotfiles repo"
            echo "  Target: $link_target"
        fi
    elif [[ -d "$CONFIG_DIR" ]]; then
        log_info "Using original ~/.config directory (not stowed)"
    else
        log_warning "No ~/.config directory found"
    fi
    
    if [[ -L "$CURRENT_BACKUP_LINK" ]]; then
        local backup_path=$(readlink "$CURRENT_BACKUP_LINK")
        if [[ -d "$backup_path" ]]; then
            log_info "Current backup available: $backup_path"
        else
            log_warning "Backup link exists but target directory missing"
        fi
    else
        log_info "No current backup found"
    fi
    
    # Show available backups
    echo -e "\n${BLUE}Available backups:${NC}"
    ls -la "$HOME"/.config.backup.* 2>/dev/null | grep -v current || echo "  No backups found"
}

show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  apply     Backup current config and apply dotfiles using stow"
    echo "  restore   Restore the most recent backup and remove stowed dotfiles"
    echo "  status    Show current status and available backups"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 apply      # Apply dotfiles (with backup)"
    echo "  $0 restore    # Restore backup"
    echo "  $0 status     # Check current status"
}

main() {
    check_dependencies
    
    case "${1:-help}" in
        "apply")
            apply_dotfiles
            ;;
        "restore")
            restore_backup
            ;;
        "status")
            show_status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"