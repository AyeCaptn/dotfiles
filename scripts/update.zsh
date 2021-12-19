#!/usr/bin/env zsh

# Get System Updates, update NPM packages and dotfiles
# Source: https://raw.githubusercontent.com/denysdovhan/dotfiles/master/scripts/update.zsh

trap on_error SIGTERM

e='\033'
RESET="${e}[0m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
GREEN="${e}[0;92m"

_exists() {
  command -v $1 > /dev/null 2>&1
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

on_start() {
  info '           __        __   ____ _  __            '
  info '      ____/ /____   / /_ / __/(_)/ /___   _____ '
  info '     / __  // __ \ / __// /_ / // // _ \ / ___/ '
  info '  _ / /_/ // /_/ // /_ / __// // //  __/(__  )  '
  info ' (_)\__,_/ \____/ \__//_/  /_//_/ \___//____/   '
  info '                                                '
}

update_dotfiles() {
  info "Updating dotfiles..."

  cd $DOTFILES
  git pull origin master
  ./sync.py
  cd - > /dev/null 2>&1

  info "Updating Zsh plugins..."
  sheldon lock --update

  finish
}

update_brew() {
  if ! _exists brew; then
    return
  fi

  info "Updating Homebrew..."

  brew update
  brew upgrade
  brew cleanup

  finish
}

update_npm() {
  if ! _exists npm; then
    return
  fi

  info "Updating NPM..."

  npm install npm -g

  finish
}

update_pipx() {
  if ! _exists pipx; then
    return
  fi

  info "Updating pipx..."

  pipx upgrade-all

  finish
}

on_finish() {
  success "Done!"
}

on_error() {
  error "Wow... Something serious happened!"
  error "Though, I don't know what really happened :("
  exit 1
}

main() {
  echo "Before we proceed, please type your sudo password:"
  sudo -v

  on_start "$*"
  update_dotfiles "$*"
  update_brew "$*"
  update_npm "$*"
  update_pipx "$*"
  on_finish "$*"
}

main "$*"