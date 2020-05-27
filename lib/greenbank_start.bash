#!/bin/bash

export MY_WORKSTATION="pictor"
export TWC_HOME=/users/tchamber
export SB=/home/sandboxes/tchamber
export PYENV_ROOT="$SB"/.pyenv
### PATH ###

PATH="$PATH:/home/gbt1/sublime_merge"
PATH="$PATH:/home/gbt1/sublime_text_3"
PATH="$PATH:$SB/programs/bin"
PATH="$PATH:/users/tchamber/bin"
PATH="$PATH:/opt/local/bin"
PATH="$PATH:$TWC_HOME/bin"
PATH="$PATH:$SB/repos/bash_scripts"
PATH="$PATH:/users/tchamber/.local/bin"
PATH="$PATH:/home/sandboxes/tchamber/haskell/install/bin"
export PROJ=$SB/projects
export REPOS=$SB/repos
export SUBLIME_PROJECTS="$SB/sublime_projects"

alias cdsb="cd \$SB"
alias cdp="cd \$SB/projects"
alias cdf="cdreal"
# cd to whichever virtual env you are currently in
alias cdv="cd \$VIRTUAL_ENV"


# Decide what color the username text is in the terminal based on who
# I currently am
if [ "$(whoami)" == "tchamber" ]
then
    USERCOLOR=$C_BGreen
elif [ "$(whoami)" == "monctrl" ] || [ "$(whoami)" == "lmonctrl" ]
then
    USERCOLOR=$C_BBlue
else
    USERCOLOR=$C_BRed
fi

# Set punctuation to white
PUNCCOLOR=$C_BBlack

# Decide what color the hostname text is based on which host I am currently on
if [ "$(hostname)" == "$MY_WORKSTATION" ]; then
    HOSTCOLOR=$C_BGreen
elif [ "$(hostname)" == "colossus" ] || [ "$(hostname)" == "galileo" ]; then
    HOSTCOLOR=$C_BBlue
elif [ "$(hostname)" == "trent" ] || [ "$(hostname)" == "gboweb" ] || [ "$(hostname)" == "trent2" ]; then
    HOSTCOLOR=$C_BPurple
else
    HOSTCOLOR=$C_BRed
fi

TIMECOLOR=$C_BPurple
NUMBCOLOR=$C_BCyan
PATHCOLOR="$C_Blue"
# PATHCOLOR=$C_BPurple
TEXTCOLOR=$C_Color_Off
