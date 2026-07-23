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
export BAT_THEME='Catppuccin Macchiato'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
  --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
  --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
  --color=selected-bg:#494d64"

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

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Setup java
export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Set k9s config directory
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Set Lazygit config directory
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Let pi use an XDG-style config directory
export PI_CODING_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.config/pi/agent}"

# Engie specific
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export REQUESTS_CA_BUNDLE=~/.engie-full-ca.pem

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"

eval "$(sheldon source)"

# Defer expensive setup until just before first prompt
if command -v zsh-defer >/dev/null 2>&1; then
  zsh-defer _dotfiles_pnpm_global_bin
  zsh-defer _dotfiles_fnm_env
else
  _dotfiles_pnpm_global_bin
  _dotfiles_fnm_env
fi

_dotfiles_pnpm_global_bin() {
  if command -v pnpm >/dev/null 2>&1; then
    local pnpm_bin
    pnpm_bin="$(pnpm root -g)/bin"
    [[ -d "$pnpm_bin" ]] && _extend_path "$pnpm_bin"
  fi
}

_dotfiles_fnm_env() {
  if ! command -v mise >/dev/null 2>&1 && command -v fnm >/dev/null 2>&1; then
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

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v tv >/dev/null 2>&1 && eval "$(tv init zsh)"

# Search history by substring and retain Zsh's newest-first source order.
if (( $+functions[_tv_shell_history] )); then
  _tv_shell_history() {
    emulate -L zsh
    zle -I

    _disable_bracketed_paste

    local current_prompt
    current_prompt=$LBUFFER
    local output
    output=$(history -n -1 0 | tv --exact --no-sort --no-status-bar --input "$current_prompt" --inline "$@")

    zle reset-prompt
    if [[ -n "$output" ]]; then
      RBUFFER=""
      LBUFFER="$output"
    fi

    _enable_bracketed_paste
  }
fi

# bun completions
[ -s "/Users/sem/.bun/_bun" ] && source "/Users/sem/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide should be initialized late so it can hook directory changes reliably.
export _ZO_DOCTOR=0
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"

# Automatically enter tmux from interactive top-level shells.
if [[ -o interactive && -z "$TMUX" && "$TERM" != "dumb" ]] &&
  command -v tmux >/dev/null 2>&1; then
  main_session="main"

  if ! tmux has-session -t "=$main_session" 2>/dev/null; then
    # Create the persistent main session.
    tmux new-session -d -s "$main_session"
    tmux set-option -t "=$main_session" destroy-unattached off
    exec tmux attach-session -t "=$main_session"
  fi

  # Count clients currently attached to the main session.
  client_count="$(
    tmux list-clients -t "=$main_session" -F '#{client_name}' \
      2>/dev/null | wc -l | tr -d ' '
  )"

  if (( client_count == 0 )); then
    # Main exists but is currently unattended, so reconnect to it.
    tmux set-option -t "=$main_session" destroy-unattached off
    exec tmux attach-session -t "=$main_session"
  else
    # Main is in use, so create an automatically cleaned-up session.
    temporary_session="terminal-$(date +%s)-$$"

    exec tmux new-session -s "$temporary_session" 'zsh; tmux detach-client'
  fi
fi
