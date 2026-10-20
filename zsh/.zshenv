# ~/.zshenv is read by every zsh: login, interactive, and non-interactive
# (including `ssh host cmd`, cron, and hooks). Keep it to environment only.
# Aliases, prompt, completion, and plugins belong in ~/.zshrc.

export BUN_INSTALL="$HOME/.bun"

# PATH as a deduplicated array. Earlier entries win.
typeset -U path
path=(
  "$HOME/magnetic_rose/repos/dotfiles/scripts"
  "$HOME/Github/magnetic_rose/repos/dotfiles/scripts"
  "$HOME/dotfiles/scripts"
  "$HOME/.npm-global/bin"
  "$HOME/.opencode/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.local/bin"
  $path
  /usr/local/go/bin
)
# Keep only entries that exist as directories on this machine.
path=($^path(N-/))
export PATH
