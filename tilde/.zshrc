#
# ~/.zshrc
#

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Export path to root of dotfiles repo
export DOTFILES=${DOTFILES:="$HOME/Repositories/dotfiles"}

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

# Java
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates
_extend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    export PATH="$1:$PATH"
  fi
}

# Add custom bin to $PATH
[[ -d "$HOME/.bin" ]] && _extend_path "$HOME/.bin"
[[ -d "$DOTFILES/bin" ]] && _extend_path "$DOTFILES/bin"
[[ -d "$HOME/.npm-global" ]] && _extend_path "$HOME/.npm-global/bin"
[[ -d "/usr/local/bin" ]] && _extend_path "/usr/local/bin"
[[ -d "/usr/local/sbin" ]] && _extend_path "/usr/local/sbin"
[[ -d "$HOME/.local/bin" ]] && _extend_path "$HOME/.local/bin"


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
  if [ command -v vim >/dev/null 2>&1 ]; then
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
  if [ $? -eq 0 ]; then
      eval "$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  else
      if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
          . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
      else
          export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
      fi
  fi
}

# OMZ is managed by Sheldon
export ZSH="$HOME/.sheldon/repos/github.com/ohmyzsh/ohmyzsh"

plugins=(
  nvm
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
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  package       # Package version
  maven         # Maven section
  node          # Node.js section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  rust          # Rust section
  docker        # Docker section
  aws           # Amazon Web Services section
  awsume        # AWSume section
  venv          # virtualenv section
  condav        # conda virtualenv section
  pyenv         # Pyenv section
  kubectl       # Kubectl context section
  terraform     # Terraform workspace section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)