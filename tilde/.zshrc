#
# ~/.zshrc
#

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

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

# Conda
export CONDA_CHANGEPS1=no

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

# Source local configuration
if [[ -f "$HOME/.zshlocal" ]]; then
  source "$HOME/.zshlocal"
fi

# setup miniconda
_conda_init() {
  local __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
      . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
      [[ -d "/opt/homebrew/Caskroom/miniconda/base/bin" ]] && _extend_path "/opt/homebrew/Caskroom/miniconda/base/bin"
    fi
  fi
}

# setup pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# OMZ is managed by Sheldon
export ZSH="$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh"

plugins=(
  sudo
  extract
  gpg-agent
  macos
  command-not-found
  docker
)

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

eval "$(sheldon source)"

zsh-defer _conda_init

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
  orbstack  # Docker section
  aws       # Amazon Web Services section
  awsume    # AWSume section
  venv      # virtualenv section
  condav    # conda virtualenv section
  kubectl   # Kubectl context section
  terraform # Terraform workspace section
  exec_time # Execution time
  line_sep  # Line break
  battery   # Battery level and status
  jobs      # Background jobs indicator
  exit_code # Exit code section
  char      # Prompt character
)

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
