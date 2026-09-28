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
  brew bundle --file "$DOTFILES/Brewfile"
else
  info "brew not installed"
fi

# Accept xcode license
sudo xcodebuild -license accept

# Developer language runtimes
if _exists mise; then
  info "installing mise development environments"
  mise install
  eval "$(mise activate zsh)"
else
  info "mise not installed"
fi

# Rust follows upstream rustup, as in Omarchy.
if ! _exists rustup; then
  info "installing Rust with rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if _exists rustup; then
  rustup toolchain install stable --component clippy,rust-analyzer,rust-src,rustfmt
fi

# uv and Python CLI applications stay in the Python ecosystem rather than mise.
if ! _exists uv; then
  info "installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if _exists uv; then
  info "installing Python CLI applications"
  while IFS= read -r package; do
    [[ -n "$package" ]] && uv tool install "$package" --force
  done < "$DOTFILES/python-packages.txt"
fi

# pnpm owns globally installed JavaScript CLIs; application dependencies remain
# in each project's package.json and lockfile.
if _exists pnpm; then
  info "installing pnpm CLI applications"
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"
  pnpm config set global-bin-dir "$PNPM_HOME"
  while IFS= read -r package; do
    [[ -n "$package" ]] && pnpm add --global "$package"
  done < "$DOTFILES/pnpm-packages.txt"
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

    info "setting up restic backup schedules"
    resticprofile --config ~/.resticprofiles.conf schedule --all --start
  else
    info "1Password CLI not installed"
  fi
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

# Install SbarLua for SketchyBar Lua config
if _exists sketchybar && _exists git && _exists make; then
  if [ ! -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ]; then
    info "installing SbarLua"
    rm -rf /tmp/SbarLua
    git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
    make -C /tmp/SbarLua -f makefile install
    rm -rf /tmp/SbarLua
  fi
fi

# Make OmniWM the default desktop at login. The switcher keeps yabai and its
# original skhd profile available through `desktop-wm yabai`.
desktop_wm_agent="$DOTFILES/tilde/Library/LaunchAgents/com.sem.desktop-wm.plist"
if [[ -f "$desktop_wm_agent" ]]; then
  info "installing OmniWM login agent"
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$desktop_wm_agent" "$HOME/Library/LaunchAgents/com.sem.desktop-wm.plist"
  launchctl bootout "gui/$(id -u)/com.sem.desktop-wm" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.sem.desktop-wm.plist"
  launchctl enable "gui/$(id -u)/com.sem.desktop-wm"
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

# Dock
info "configuring dock"
defaults write com.apple.dock autohide-delay -float 0
defaults delete com.apple.dock autohide-delay
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock tilesize -int 32
killall Dock

# Get back to previous directory
cd -
