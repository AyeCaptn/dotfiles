#
# Aliases
#

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

_exists() {
  command -v $1 >/dev/null 2>&1
}

# Avoid stupidity with trash-cli:
# 	https://github.com/sindresorhus/trash-cli
# or use default rm -i
if _exists trash; then
  alias rm='trash'
fi

# Folders Shortcuts
[ -d ~/Downloads ] && alias dl='cd ~/Downloads'
[ -d ~/Desktop ] && alias dt='cd ~/Desktop'
[ -d ~/Projects ] && alias pj='cd ~/Projects'
[ -d ~/Projects/Forks ] && alias pjf='cd ~/Projects/Forks'
[ -d ~/Projects/Job ] && alias pjj='cd ~/Projects/Job'
[ -d ~/Projects/Playground ] && alias pjp='cd ~/Projects/Playground'
[ -d ~/Projects/Repos ] && alias pjr='cd ~/Projects/Repos'

# Open aliases
alias o='open'
alias oo='open .'

# Get updates, and update npm and its installed packages
alias update="source $DOTFILES/scripts/update.zsh"

# Quick jump to dotfiles
alias dotfiles="cd $DOTFILES"

# My IP
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Password generator
# Gemnerate random password, copies it into clipboard and outputs it to terminal
if _exists pbcopy; then
  alias password='openssl rand -base64 ${1:-9} | pbcopy ; echo "$(pbpaste)"'
elif _exists xcopy; then
  alias password='openssl rand -base64 ${1:-9} | xcopy ; echo "$(xpaste)"'
else
  alias password='openssl rand -base64 ${1:-9}; echo "$(xpaste)"'
fi

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Use tldr as help util
if _exists tldr; then
  alias help="tldr"
fi

alias git-root='cd $(git rev-parse --show-toplevel)'

# VPN aliases
alias porphyriovpn="openfortivpn -c ~/.vpn/porphyrio"

# Docker
alias dstop='docker stop $(docker ps -a -q)'
alias dstart='docker restart $(docker ps -q -f "status=exited" -f "name=$1")'

# Shortcuts
alias lg=lazygit

# AWSume
alias awsume=". awsume"

# Private repo token fetch before pip
alias pip="pip-login && pip"

# Backup all files
alias backup="resticprofile -c ~/.resticprofiles.conf --name full-backup backup"
