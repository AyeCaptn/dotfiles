#
# ~/.zshrc
#

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Optional startup profiling
if [[ -n "${DOTFILES_ZSH_PROFILE:-}" ]]; then
  zmodload zsh/zprof
  _dotfiles_zprof_enabled=1
fi

# Export path to root of dotfiles repo
export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# History
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Autoswitch
AUTOSWITCH_SILENT=true

# AWS Vault
export AWS_VAULT_PL_BROWSER=com.google.chrome

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates
_extend_path() {
  if ! $(echo "$PATH" | tr ":" "\n" | grep -qx "$1"); then
    export PATH="$1:$PATH"
  fi
}

# Add custom bin to $PATH
[[ -d "$HOME/.bin" ]] && _extend_path "$HOME/.bin"
[[ -d "$DOTFILES/bin" ]] && _extend_path "$DOTFILES/bin"
[[ -d "$HOME/.npm-global" ]] && _extend_path "$HOME/.npm-global/bin"
[[ -d "$HOME/.local/bin" ]] && _extend_path "$HOME/.local/bin"
[[ -d "/opt/homebrew/bin" ]] && _extend_path "/opt/homebrew/bin"
[[ -d "/opt/homebrew/sbin" ]] && _extend_path "/opt/homebrew/sbin"
[[ -d "$HOME/go/bin" ]] && _extend_path "$HOME/go/bin"

# Extend $NODE_PATH
if [ -d ~/.npm-global ]; then
  export NODE_PATH="$NODE_PATH:$HOME/.npm-global/lib/node_modules"
fi

# Default pager
export PAGER='less'

# less options
less_opts=(
  # Quit if entire file fits on first screen.
  -FX
  # Ignore case in searches that do not contain uppercase.
  --ignore-case
  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS
  # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
  --quiet
  # Do not complain when we are on a dumb terminal.
  --dumb
)
export LESS="${less_opts[*]}"

# Default editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
  # on the server
  if [ command -v vim ] >/dev/null 2>&1; then
    export EDITOR='vim'
  else
    export EDITOR='vi'
  fi
else
  export EDITOR='vim'
fi

# Source secrets
if [[ -f "$HOME/.secrets" ]]; then
  source "$HOME/.secrets"
fi

# Source local configuration
if [[ -f "$HOME/.zshlocal" ]]; then
  source "$HOME/.zshlocal"
fi

# setup pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Launch tmux
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_FIXTERM_WITH_256COLOR=true


# Setup java
export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Set k9s config directory
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Set Lazygit config directory
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# OMZ is managed by Sheldon
export ZSH="$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh"

# Engie specific
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export REQUESTS_CA_BUNDLE=~/.engie-full-ca.pem

plugins=(
  command-not-found
  docker
  extract
  gpg-agent
  macos
  sudo
  tmux
  vi-mode
)

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

eval "$(sheldon source)"

# Defer expensive setup until just before first prompt
if command -v zsh-defer >/dev/null 2>&1; then
  zsh-defer _dotfiles_pnpm_global_bin
  zsh-defer _dotfiles_fnm_env
else
  _dotfiles_pnpm_global_bin
  _dotfiles_fnm_env
fi

# Spaceship
SPACESHIP_PROMPT_ORDER=(
  time      # Time stamps section
  user      # Username section
  dir       # Current directory section
  host      # Hostname section
  git       # Git section (git_branch + git_status)
  package   # Package version
  node      # Node.js section
  xcode     # Xcode section
  swift     # Swift section
  golang    # Go section
  rust      # Rust section
  docker    # Docker section
  aws       # Amazon Web Services section
  venv      # virtualenv section
  kubectl   # Kubectl context section
  terraform # Terraform workspace section
  exec_time # Execution time
  line_sep  # Line break
  battery   # Battery level and status
  jobs      # Background jobs indicator
  exit_code # Exit code section
  char      # Prompt character
)

_dotfiles_pnpm_global_bin() {
  if command -v pnpm >/dev/null 2>&1; then
    local pnpm_bin
    pnpm_bin="$(pnpm root -g)/bin"
    [[ -d "$pnpm_bin" ]] && _extend_path "$pnpm_bin"
  fi
}

_dotfiles_fnm_env() {
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
  fi
}


_dotfiles_zprof_finish() {
  if [[ -n "${_dotfiles_zprof_enabled:-}" ]]; then
    zprof > "$HOME/.zsh_profile.log"
  fi
  add-zsh-hook -d precmd _dotfiles_zprof_finish
}

if [[ -n "${_dotfiles_zprof_enabled:-}" ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dotfiles_zprof_finish
fi
