# Profile configuration for shells
# Common environment settings and aliases

# Environment variables
export EDITOR=vi
export PAGER=less
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# PATH additions
export PATH=$PATH:/usr/local/bin:/opt/local/bin:$HOME/bin

# Ruby environment
export GEM_HOME=$HOME/.gem
export PATH=$PATH:$GEM_HOME/bin

# Node.js environment  
export NODE_PATH=/usr/local/lib/node_modules
export PATH=$PATH:/usr/local/bin/node

# Aliases
alias ll='ls -la'
alias la='ls -la'
alias l='ls -l'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias tree='tree -I ".git|node_modules|.bundle"'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Set prompt
PS1='\u@\h:\w$ '

# History settings
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups