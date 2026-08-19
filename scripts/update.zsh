#!/usr/bin/env zsh

set -euo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

info() {
  print -P "%F{cyan}$*%f"
}

info "Updating dotfiles"
git -C "$DOTFILES" pull --ff-only
"$DOTFILES/sync.py"

if command -v brew >/dev/null 2>&1; then
  info "Updating Homebrew"
  brew update
  brew bundle --file "$DOTFILES/Brewfile"
  brew upgrade
  brew cleanup
fi

if [[ -x "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]]; then
  info "Updating tmux plugins"
  "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
fi

info "Update complete"
