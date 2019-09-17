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

# Not sure how this is getting set, but let's unset it
unset YGOR_TELESCOPE
unset YGOR_INSTALL


# Poetry stuff...
export PATH="$HOME/.poetry/bin:$PATH"
# Rust stuff...
export PATH="$HOME/.cargo/bin:$PATH"


# TODO: These are causing problems...
# export PYENV_ROOT=$SB/pyenv
# export PATH="/home/sandboxes/tchamber/pyenv/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source "/users/tchamber/.local/etc/bash_completion.d/dephell.bash-completion"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/local/stow/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/local/stow/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/local/stow/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/local/stow/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

function calc {
    python -c "print($*)"
}


# Sometimes we don't want this to print out (if we're just dumping
# the env, for example). So, check if current shell is interactive
if [[ $- == *i* ]]; then
    # Print the current redhat release version
    'cat' /etc/redhat-release >&2
    # If we don't have a key active in ssh-agent, prompt to add one
    if ! ssh-add -l >&/dev/null; then
        echo "No SSH key is active; add one now!" >&2
        ssh-add
    fi
    # Intended as the final output
    echo "Thomas's bash profile loaded" >&2
fi
