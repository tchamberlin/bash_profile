#!/bin/bash

GIT_PS1_SHOWCOLORHINTS=yep
GIT_PS1_SHOWDIRTYSTATE=yep
GIT_PS1_SHOWUNTRACKEDFILES=yep
GIT_PS1_SHOWSTASHSTATE=yep
GIT_PS1_SHOWUPSTREAM=yep
source "$TWC_BASH_REPO_PATH"/extern/git-prompt.sh
source "$TWC_BASH_REPO_PATH"/extern/git-completion.bash

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

gk()
{
    do_local nohup gitk "$@"
}

alias gka="gk --all"


__git_complete gs __git_main
__git_complete ga __git_main
__git_complete gau __git_main
__git_complete gb _git_branch
__git_complete gc _git_branch
__git_complete gd __git_main
__git_complete go _git_checkout
__git_complete gom _git_checkout
__git_complete gpom __git_main
__git_complete gh __git_main
__git_complete gr __git_main

alias gcloc="cloc \$(git ls-files)"
