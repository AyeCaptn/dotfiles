#!/usr/bin/env bash

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
DOTFILES_BRANCH="minimal"
DOTFILES_REPO="https://github.com/AyeCaptn/dotfiles.git"
HOMEBREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

info() {
  printf '\033[0;96m%s\033[0m\n' "$*"
}

if [[ ! -t 0 ]]; then
  printf 'Run this installer from an interactive terminal.\n' >&2
  exit 1
fi

read -r -p "Install the minimal family travel laptop setup? [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  exit 0
fi

dotfiles_exist=false
if [[ -e "$DOTFILES" || -L "$DOTFILES" ]]; then
  if ! git -C "$DOTFILES" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Existing path %s is not a Git worktree; refusing to replace it.\n' "$DOTFILES" >&2
    exit 1
  fi

  if [[ "$(git -C "$DOTFILES" branch --show-current)" != "$DOTFILES_BRANCH" ]]; then
    printf 'Existing dotfiles at %s are not on branch %s; refusing to replace them.\n' "$DOTFILES" "$DOTFILES_BRANCH" >&2
    exit 1
  fi

  remote_url="$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)"
  case "$remote_url" in
    https://github.com/AyeCaptn/dotfiles | https://github.com/AyeCaptn/dotfiles.git | git@github.com:AyeCaptn/dotfiles.git) ;;
    *)
      printf 'Existing dotfiles at %s do not use the expected origin; refusing to run them.\n' "$DOTFILES" >&2
      exit 1
      ;;
  esac

  dotfiles_exist=true
fi

if ! xcode-select -p >/dev/null 2>&1; then
  info "Opening the Apple Command Line Tools installer"
  xcode-select --install
  printf 'Finish that installation, then run this command again.\n'
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALLER")"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ "$dotfiles_exist" == false ]]; then
  info "Cloning the $DOTFILES_BRANCH dotfiles branch"
  git clone --branch "$DOTFILES_BRANCH" --single-branch "$DOTFILES_REPO" "$DOTFILES"
fi

info "Linking dotfiles"
"$DOTFILES/sync.py"

info "Bootstrapping applications and terminal tools"
"$DOTFILES/scripts/bootstrap.zsh"

info "Setup complete. Restart the terminal or open Ghostty."
