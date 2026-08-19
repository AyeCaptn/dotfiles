#!/usr/bin/env zsh

set -euo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

info() {
  print -P "%F{cyan}$*%f"
}

if ! command -v brew >/dev/null 2>&1; then
  print -u2 "Homebrew is required before bootstrap."
  exit 1
fi

info "Installing the minimal Homebrew bundle"
brew bundle --file "$DOTFILES/Brewfile"

info "Creating project folders"
mkdir -p \
  "$HOME/Projects/Forks" \
  "$HOME/Projects/Job" \
  "$HOME/Projects/Personal" \
  "$HOME/Projects/Playground" \
  "$HOME/Projects/Repos"
touch "$HOME/.hushlogin"
if ! git config --global --get core.excludesfile >/dev/null; then
  git config --global core.excludesfile "$HOME/.gitignore"
fi

if command -v tmux >/dev/null 2>&1; then
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info "Installing tmux plugin manager"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  catppuccin_tmux="$HOME/.config/tmux/plugins/catppuccin/tmux"
  if [[ ! -d "$catppuccin_tmux" ]]; then
    info "Installing Catppuccin for tmux"
    mkdir -p "${catppuccin_tmux:h}"
    git clone --branch v2.3.0 --depth 1 https://github.com/catppuccin/tmux.git "$catppuccin_tmux"
  fi

  info "Installing tmux plugins"
  tmux start-server \; set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

info "Bootstrap complete"
