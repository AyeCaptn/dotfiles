#!/usr/bin/env zsh

# Bootstrap script for installing applications, tools, fonts and applying application config
# Source: https://raw.githubusercontent.com/denysdovhan/dotfiles/master/scripts/bootstrap.zsh

# Ask for the administrator password upfront
sudo -v

e='\033'
RESET="${e}[0m"
CYAN="${e}[0;96m"

_exists() {
  command -v $1 >/dev/null 2>&1
}

# Success reporter
info() {
  echo -e "${CYAN}${*}${RESET}"
}

export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

# Go to dotfiles directory
cd $DOTFILES

# Homebrew Bundle
if _exists brew; then
  info "running brew bundle"
  brew bundle
else
  info "brew not installed"
fi

# Accept xcode license
xcodebuild -license accept

# Python global packages
if _exists pipx; then
  info "installing python packages"
  cat python-packages.txt | xargs -I % pipx install %
else
  info "pipx not installed"
fi

# NPM global packages
if _exists pnpm; then
  info "installing pnpm packages"
  cat pnpm-packages.txt | xargs -n1 pnpm add -g
else
  info "pnpm not installed"
fi


# TODO: Restic restore

# TODO: Set up backups

# Remove terminal last login text
touch ~/.hushlogin

# Folders
info "creating project folders"
mkdir -p ~/Projects/Forks
mkdir -p ~/Projects/Job
mkdir -p ~/Projects/Playground
mkdir -p ~/Projects/Repos
mkdir -p ~/Projects/Personal

# Get back to previous directory
cd -
