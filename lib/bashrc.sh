#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

set -u

export TWC_BASH_REPO_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/..


if [ -f "$TWC_BASH_REPO_PATH"/lib/bash_aliases.sh ]; then
    source "$TWC_BASH_REPO_PATH"/lib/bash_aliases.sh
fi

### SITE-SPECIFIC LOGIC ###
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


### Set prompt/PS1/PROMPT_COMMAND ###
# Needs to be set after git and colors, but before tools
read -r -d '' PROMPT_COMMAND <<'EOF'
if [[ $? -ne 0 ]]; then
    prompt_token_color="$C_BRed"
else
    prompt_token_color="$C_Color_Off"
fi
path_part="${PWD/#$HOME/~}"
if [[ -n "${SB-}" ]]; then
    path_part="${path_part/$SB/\$SB}"
fi
echo -en "\033]0;${USER}@${HOSTNAME}:${path_part}\a"

__git_ps1 "$C_Cyan\u@\h$C_Color_Off:$C_Blue\w" "$prompt_token_color\\\$ $C_Color_Off"
EOF

# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/common.sh"
# shellcheck disable=SC1090
source "$TWC_BASH_REPO_PATH/lib/tools.sh"

# Turn off unset variable detection; don't want this in an interactive shell!
set +u

# Intended as the final output
echo "Thomas's bash profile loaded" >&2
