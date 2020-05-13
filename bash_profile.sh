#! /bin/bash

# Thomas Chamberlin's .bash_profile

umask 002

bash_profile_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

export TWC_HOME=/users/tchamber

# shellcheck disable=SC1090
source "$bash_profile_path/venv_utils.sh"
# shellcheck disable=SC1090
source "$bash_profile_path/git.sh"
# shellcheck disable=SC1090
source "$bash_profile_path/common.sh"
# shellcheck disable=SC1090
source "$bash_profile_path/greenbank.sh"

# Sometimes we don't want this to print out (if we're just dumping
# the env, for example). So, check if current shell is interactive
if [[ $- == *i* ]]; then
    # shellcheck disable=SC1090
    source "$bash_profile_path/interactive_only.sh"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
