#! /bin/bash

# Thomas Chamberlin's .bash_profile

export _BASH_REPO_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/..

[[ -r "$_BASH_REPO_PATH"/lib/bashrc.bash ]] && . "$_BASH_REPO_PATH"/lib/bashrc.bash
# NOTHING SHOULD GO BELOW HERE (our bashrc expects to be sourced last)!
