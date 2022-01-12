#!/usr/bin/env zsh

# Bootstrap script for installing applications, tools, fonts and applying application config
# Source: https://raw.githubusercontent.com/denysdovhan/dotfiles/master/scripts/bootstrap.zsh

# Ask for the administrator password upfront
sudo -v

e='\033'
RESET="${e}[0m"
CYAN="${e}[0;96m"

_exists() {
  command -v $1 > /dev/null 2>&1
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
if _exists npm; then
  info "installing npm packages"
  npm install -g
else
  info "npm not installed"
fi

# Fonts
eval "find \"$DOTFILES/fonts\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0" | xargs -0 -I % cp "%" "$HOME/Library/Fonts/"

# Vim plug
info "Setting up vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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