# Minimal interactive zsh setup

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export LANG="${LANG:-en_US.UTF-8}"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BAT_THEME="Catppuccin Macchiato"
export COLORTERM="truecolor"
export FZF_DEFAULT_OPTS="--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796,fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6,marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796,selected-bg:#494d64"

typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$DOTFILES/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

[[ -f "$DOTFILES/lib/aliases.zsh" ]] && source "$DOTFILES/lib/aliases.zsh"
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
[[ -f "$HOME/.zshlocal" ]] && source "$HOME/.zshlocal"

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

if [[ -o interactive && "${TERM:-}" != "dumb" ]]; then
  command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
fi

if [[ -o interactive && -z "${TMUX:-}" && "${TERM:-}" != "dumb" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi
