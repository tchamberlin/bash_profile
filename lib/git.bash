#!/bin/bash

GIT_PS1_SHOWCOLORHINTS=yep
GIT_PS1_SHOWDIRTYSTATE=yep
GIT_PS1_SHOWUNTRACKEDFILES=yep
GIT_PS1_SHOWSTASHSTATE=yep
GIT_PS1_SHOWUPSTREAM=yep
source "$_BASH_REPO_PATH"/extern/git-prompt.sh
source "$_BASH_REPO_PATH"/extern/git-completion.bash



gk()
{
    do_local nohup gitk "$@"
}



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

