#! /bin/bash

# Thomas Chamberlin's .bash_profile

export TWC_BASH_REPO_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/..

# If we don't have a key active in ssh-agent, prompt to add one
if [[ "$MY_WORKSTATION" == "$HOSTNAME" ]]; then
    if ! ssh-add -l >&/dev/null; then
        echo "No SSH key is active; add one now!" >&2
        ssh-add
    fi

    if ! pgrep -f "redshift" >&/dev/null; then
        echo "redshift is not running; starting now!" >&2
        setsid redshift >/dev/null 2>&1 < /dev/null &
    fi
fi

[[ -r "$TWC_BASH_REPO_PATH"/lib/bashrc.sh ]] && . "$TWC_BASH_REPO_PATH"/lib/bashrc.sh

# NOTHING SHOULD GO BELOW HERE (our bashrc expects to be sourced last)!