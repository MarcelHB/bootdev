#!/bin/zsh
# ag
alias ag='ag --path-to-ignore ~/.ignore'

# git
alias gits='git status'
alias gitc='git commit'
alias gitp='git push'
alias gitpf='git push --force-with-lease'
alias gitpr='git pull --rebase'

alias ide='tmux new-session \"nvim\"'

# xclip
alias xc='xclip -selection clipboard'
alias xp='xclip -o -selection clipboard'

# type term, then arrow up/down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
