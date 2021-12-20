#!/usr/bin/env bash

# Dotfiles and bootstrap installer
# Installs git, clones repository and symlinks dotfiles to your home directory

# Source: https://raw.githubusercontent.com/denysdovhan/dotfiles/master/installer.sh

set -e
trap on_error SIGTERM

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Success reporter
info() {
  echo -e "${CYAN}${*}${RESET}"
}

# Error reporter
error() {
  echo -e "${RED}${*}${RESET}"
}

# Success reporter
success() {
  echo -e "${GREEN}${*}${RESET}"
}

# End section
finish() {
  success "Done!"
  echo
  sleep 1
}

# Set directory
export DOTFILES=${1:-"$HOME/.dotfiles"}
GITHUB_REPO_URL_BASE="https://github.com/AyeCaptn/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

on_start() {
  info "           __        __   ____ _  __           "
  info "      ____/ /____   / /_ / __/(_)/ /___   _____"
  info "     / __  // __ \ / __// /_ / // // _ \ / ___/"
  info "  _ / /_/ // /_/ // /_ / __// // //  __/(__  ) "
  info " (_)\__,_/ \____/ \__//_/  /_//_/ \___//____/  "
  info "                                               "

  info "This script will guide you through installing git, zsh and dofiles itself."
  echo "It will not install anything without your direct agreement!"
  echo
  read -p "Do you want to proceed with installation? [y/N] " -n 1 answer
  echo
  if [ "${answer}" != "y" ]; then
    exit 1
  fi
}

install_cli_tools() {
  info "Trying to detect installed Command Line Tools..."

  if ! [ "$(xcode-select -p)" ]; then
    echo "You don't have Command Line Tools installed!"
    read -p "Do you agree to install Command Line Tools? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "Installing Command Line Tools..."
    echo "Please, wait until Command Line Tools will be installed, before continue."

    xcode-select --install
  else
    success "Seems like you have installed Command Line Tools. Skipping..."
  fi

  finish
}

install_homebrew() {
  info "Trying to detect installed Homebrew..."

  if ! _exists brew; then
    echo "Seems like you don't have Homebrew installed!"
    read -p "Do you agree to proceed with Homebrew installation? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALLER_URL})"

    eval "$(/opt/homebrew/bin/brew shellenv)"

    brew update
    brew upgrade
    brew cleanup
  else
    success "You already have Homebrew installed. Skipping..."
  fi

  finish
}

install_git() {
  info "Trying to detect installed Git..."

  if ! _exists git; then
    echo "Seems like you don't have Git installed!"
    read -p "Do you agree to proceed with Git installation? [y/N] " -n 1 answer
    echo
    if [ "${answer}" != "y" ]; then
      exit 1
    fi

    info "Installing Git..."
    
    brew install git
  else
    success "You already have Git installed. Skipping..."
  fi

  finish
}

install_dotfiles() {
  info "Trying to detect installed dotfiles in $DOTFILES..."

  if [ ! -d $DOTFILES ]; then
    echo "Seems like you don't have dotfiles installed!"
    read -p "Do you agree to proceed with dotfiles installation? [y/N] " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
      exit 1
    fi

    git clone --recursive "$GITHUB_REPO_URL_BASE.git" $DOTFILES
    cd $DOTFILES && ./sync.py && cd -
  else
    success "You already have dotfiles installed. Skipping..."
  fi

  info "Linking dotfiles..."
  cd $DOTFILES && ./sync.py && cd -

  finish
}

bootstrap() {
  read -p "Would you like to bootstrap your environment? [y/N] " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
    return
  fi

  $DOTFILES/scripts/bootstrap.zsh

  finish
}

on_finish() {
  echo
  success "Setup was successfully done!"
  info "P.S: Don't forget to restart a terminal :)"
  echo
}

on_error() {
  echo
  error "Wow... Something serious happened!"
  echo
  exit 1
}

main() {
  on_start "$*"
  install_cli_tools "$*"
  install_homebrew "$*"
  install_git "$*"
  install_dotfiles "$*"
  bootstrap "$*"
  on_finish "$*"
}

main "$*"