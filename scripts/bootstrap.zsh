#!/usr/bin/env zsh

# Bootstrap script for installing applications, tools, fonts and applying application config
# Source: https://raw.githubusercontent.com/denysdovhan/dotfiles/master/scripts/bootstrap.zsh

# Ask for the administrator password upfront
sudo -v

_exists() {
  command -v $1 > /dev/null 2>&1
}

export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

# Go to dotfiles directory
cd $DOTFILES/scripts

# Homebrew Bundle
if _exists brew; then
  brew bundle
fi

# Python global packages
if _exists pipx; then
  cat python-packages.txt | xargs -I % pipx install %
fi

# NPM global packages
if _exists npm; then
  npm install -g
fi

# Fonts
eval "find \"$DOTFILES/fonts\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0" | xargs -0 -I % cp "%" "$HOME/Library/Fonts/"

# Vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# TODO: Restic restore

# TODO: Set up backups

# Folders
mkdir -p ~/Projects/Forks
mkdir -p ~/Projects/Job
mkdir -p ~/Projects/Playground
mkdir -p ~/Projects/Repos

# Get back to previous directory
cd -