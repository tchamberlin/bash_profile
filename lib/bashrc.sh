#!/bin/bash


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export TWC_BASH_REPO_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/..


# some more ls aliases
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'
alias lr='ls -lrtha'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


if [[ "$(hostname -f)" == *gb.nrao.edu ]]; then
    # shellcheck disable=SC1090
    source "$TWC_BASH_REPO_PATH/lib/greenbank.sh"
elif [[ "$(hostname -f)" == "potato" ]]; then
    export TWC_HOME="$HOME"
    export MY_WORKSTATION="potato"
    export PYENV_ROOT=~/.pyenv
else
    echo "UNKNOWN DOMAIN $(hostname -f); skipping domain-specific setup" >&2
fi

# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/venv_utils.sh"

# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/git.sh"

# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/colors.sh"

# if [[ $? ]]; then
#     prompt_token_color="$C_Red"
# else
#     prompt_token_color="$C_Color_Off"
# fi

# Needs to be set after git and colors, but before tools
read -r -d '' PROMPT_COMMAND <<'EOF'
if [[ $? -ne 0 ]]; then
    prompt_token_color="$C_BRed"
else
    prompt_token_color="$C_Color_Off"
fi
path_part="${PWD/#$HOME/~}"
path_part="${path_part/$SB/\$SB}"
echo -en "\033]0;${USER}@${HOSTNAME}:${path_part}\a"

__git_ps1 "$C_Cyan\u@\h$C_Color_Off:$C_Blue\w" "$prompt_token_color\\\$ $C_Color_Off"
EOF

# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/common.sh"
# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/tools.sh"

### THINGS THAT DO THINGS GO BELOW THIS

# Intended as the final output
echo "Thomas's bash profile loaded" >&2

