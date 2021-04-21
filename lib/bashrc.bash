#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Turn on for debug
# trap 'rc=$?; echo "ERR at line ${BASH_SOURCE}:${LINENO} (rc: $rc)"' ERR
set -u

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

export ABS_HOME="${ABS_HOME-$HOME}"
export REPOS="${REPOS-$ABS_HOME/repos}"
export _BASH_REPO_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/..

if [ -f "$_BASH_REPO_PATH"/lib/bash_aliases.bash ]; then
    source "$_BASH_REPO_PATH"/lib/bash_aliases.bash
fi

# shellcheck disable=SC1090
source "$_BASH_REPO_PATH/lib/colors.bash"

if [[ -e "$HOME/.site_specific_bashrc_start" ]]; then
    source "$HOME/.site_specific_bashrc_start"
fi

export PYENV_ROOT="${PYENV_ROOT-$HOME/.pyenv}"
USERCOLOR="${USERCOLOR-$C_Cyan}"
HOSTCOLOR="${HOSTCOLOR-$C_Cyan}"
PATHCOLOR="${PATHCOLOR-$C_Blue}"

# shellcheck disable=SC1090
source "$_BASH_REPO_PATH/lib/git.bash"

### Set prompt/PS1/PROMPT_COMMAND ###
# Needs to be set after git and colors, but before tools
read -r -d '' PROMPT_COMMAND <<'EOF'
code="$?"
if [[ "$code" -ne 0 ]] && [[ "$code" -ne 130 ]]; then
    prompt_token_color="$C_BRed"
elif [[ "$code" -eq 130 ]]; then
    prompt_token_color="$C_BYellow"
else
    prompt_token_color="$C_BBlack"
fi
path_part="${PWD/#$HOME/~}"
if [[ -n "${SB-}" ]]; then
    path_part="${path_part/$SB/\$SB}"
fi
echo -en "\033]0;${USER}@${HOSTNAME}⁍${path_part}\a"

if [[ -n "${VIRTUAL_ENV-}" ]]; then
    venv_part="(\$(basename "${VIRTUAL_ENV}"))\n"
else
    venv_part=""
fi

__git_ps1 "${venv_part}${USERCOLOR}\u${C_Color_Off}@${HOSTCOLOR}\h${C_Color_Off}⁍${PATHCOLOR}\w${C_Color_Off}" "${prompt_token_color}\\\$ ${C_Color_Off}"
EOF

# shellcheck disable=SC1090
source "$_BASH_REPO_PATH/lib/common.bash"
# shellcheck disable=SC1090
source "$_BASH_REPO_PATH/lib/tools.bash"
export PROMPT_DIRTRIM=3

### SITE-SPECIFIC LOGIC ###
if [[ -e "$HOME/.site_specific_bashrc_end" ]]; then
    source "$HOME/.site_specific_bashrc_end"
fi

handle_go_to_repo

# Turn off unset variable detection; don't want this in an interactive shell!
set +u

# Intended as the final output
echo "Thomas's bash profile loaded" >&2

