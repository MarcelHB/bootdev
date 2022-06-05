#!/bin/zsh
# ag
alias ag='ag --path-to-ignore ~/.ignore'

alias ide='tmux new-session \"nvim\"'

# xclip
alias xc='xclip -selection clipboard'
alias xp='xclip -o -selection clipboard'

# type term, then arrow up/down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias dpkg-bloat='dpkg-query -Wf '"'"'${db:Status-Status} ${Installed-Size}\t${Package}\n'"'"' | sed -ne '"'"'s/^installed //p'"'"' | sort -n'
