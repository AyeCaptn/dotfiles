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
sudo xcodebuild -license accept

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

# Restic restore
if _exists restic; then
  if _exists op; then
    #TODO: Ask me to sign in using 1password app and enable cli integration
    info "restoring the restic password from 1password"
    op read "op://Private/Restic Password/password" > ~/.restic-password
    op item get "Restic AWS ENV" --format json | jq -r '.details.notesPlain // (.fields[]? | select(.id=="notesPlain" or .label=="notesPlain") | .value)' > ~/.restic-env
    chmod 600 ~/.restic-password

    #TODO: list all available tags and ask the user what tags to restore
    info "restoring all files from restic backup"
    awk -F\" '/^tag = /{print $2}' ~/.resticprofiles.conf \
    | tr , '\n' | awk '{$1=$1}1' | sort -u \
    | while IFS= read -r TAG; do
      resticprofile -c ~/.resticprofiles.conf --name full-backup restore latest --tag "$TAG" --overwrite if-changed --target /
    done

    info "set up schedule for restic backups"
    #resticprofile --config ~/.resticprofiles.conf schedule --all
else
  info "restic not installed"
fi

info "setting desktop background"
osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$DOTFILES/wallpapers/midnight-reflections-moonlit-sea.jpg\""

info "setting screensaver"
osascript -e 'tell application "System Events" to set current screen saver to screen saver "Drift"'

# Install tmux plugins
if _exists tmux; then
  info "installing tmux plugins"
  
  # Clone TPM if it doesn't exist
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    info "cloning TPM (Tmux Plugin Manager)"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  
  # Source tmux config and install plugins
  tmux source-file ~/.tmux.conf 2>/dev/null || true
  ~/.tmux/plugins/tpm/bin/install_plugins
else
  info "tmux not installed"
fi

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
