#!/bin/bash

### ls ###
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'
alias lr='ls -alFhrt'

### grep ###
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias finf="grep -rnI"

### clipboard ###

# Copy selection to clipboard
alias toclip="xclip -selection clipboard"
alias _clip=toclip
# Paste selection from clipboard
alias fromclip="xclip -selection clipboard -out"
alias clip_=fromclip

### git ###

alias gs='git status '
alias grl='git reflog --date=iso '
alias ga='git add '
alias gau='git add -u '
alias gb='git branch '
alias gc='git commit '
alias gd='git diff '
alias go='git checkout '
alias gom='git checkout master '
alias gh='git hist '
alias gsu='git status -uno'
alias grv='git remote -v'

alias gka="gk --all"
alias gcloc="cloc \$(git ls-files)"

### misc ###
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rl="readlink -f"

alias bfg='java -jar ~/.local/bin/bfg-1.13.0.jar'
