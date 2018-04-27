#!/usr/bin/env bash

# Installs brew, bash, zsh and git, then clones this repo to ~/.dotfiles.
# Run this script by executing the following command:
#
# Curl -s https://raw.githubusercontent.com/AyeCaptn/dotfiles/master/bootstrap_macos.sh

export DOTFILES=~/.dotfiles

set -e

msg() {
    printf "\r\033[2K\033[0;32m[ .. ] %s\033[0m\n" "$*";
}

msg "Bootstrapping your machine"

if test ! $(which brew); then
    msg "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    msg "Homebrew is already installed..."
fi

brew update
brew upgrade

msg "Installing GNU core utilities..."
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install grep --with-default-names

msg "Installing GNU find..."
brew install findutils

msg "Installing git..."
brew install git

msg "Installing zsh..."
brew install zsh zsh-completions


if [[ ! -d ~/.dotfiles ]]; then
    msg "Deploying dotfiles repository..."
    git clone --recursive git@github.com:AyeCaptn/dotfiles.git "$DOTFILES"
fi

msg "Finished bootstrapping your machine!"

