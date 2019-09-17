#!/bin/bash

alias gs='git status -uno '
alias ga='git add '
alias gau='git add -u '
alias gb='git branch '
alias gc='git commit '
alias gd='git diff '
alias go='git checkout '
alias gom='git checkout master '
alias gh='git hist '
alias gsu='git status '

gk()
{
    do_local nohup gitk "$@"
}

alias gka="gk --all"

# git magic
# adds the current branch to the bash prompt
source "$TWC_HOME"/.git-prompt.sh

# allows tab completion of branches and commands and such
if [ -f "$TWC_HOME"/.git-completion.bash ]; then
    source "$TWC_HOME"/.git-completion.bash
fi

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

alias gcloc="cloc \$(git ls-files)"
