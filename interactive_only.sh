#! /bin/bash

# Enable poetry
PATH="$PATH:$HOME/.poetry/bin"
# Enable rust
PATH="$PATH:$HOME/.cargo/bin"
# Enable pyenv
export PYENV_ROOT=$SB/.pyenv
PATH="$PYENV_ROOT/bin:$PATH"

PATH="$PATH:/home/gbt1/sublime_merge"
PATH="$PATH:/home/gbt1/sublime_text_3"
PATH="$PATH:$SB/programs/bin"
PATH="$PATH:/users/tchamber/bin"
PATH="$PATH:/opt/local/bin"
PATH="$PATH:$TWC_HOME/bin"
PATH="$PATH:$SB/repos/bash_scripts"
PATH="$PATH:/users/tchamber/.local/bin"
PATH="$PATH:/home/sandboxes/tchamber/haskell/install/bin"

# Init pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Enable dephell completions
# shellcheck disable=SC1091
source "/users/tchamber/.local/etc/bash_completion.d/dephell.bash-completion"

# Enable fzf
# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# shellcheck disable=SC1091
source "/home/gbt1/manage_apache_configs/completions.sh"

# Not sure how this is getting set, but let's unset it
unset YGOR_TELESCOPE
unset YGOR_INSTALL

# Print the current redhat release version
'cat' /etc/redhat-release >&2
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
# Intended as the final output
echo "Thomas's bash profile loaded" >&2



export MANPATH=$MANPATH:$SB/programs/share/man

#echo -en "\033]0;$USER@$HOSTNAME\a"

function prompt_command {
    ~/.bash_prompt_command
}

PROMPT_COMMAND=prompt_command

