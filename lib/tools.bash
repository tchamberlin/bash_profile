#!/bin/bash


### poetry
# Enable poetry
PATH="$PATH:$HOME/.poetry/bin"
###

### rust
# Enable rust
PATH="$PATH:$HOME/.cargo/bin"
###

### pyenv ###
# Enable pyenv
PATH="$PYENV_ROOT/bin:$PATH"
# # Init pyenv
eval "$(pyenv init -)"
# SLOW; disabled for now
# eval "$(pyenv virtualenv-init -)"
###

### dephell
# Enable dephell completions
# shellcheck disable=SC1091
[[ -r "$ABS_HOME/.local/etc/bash_completion.d/dephell.bash-completion" ]] && \
    source "$ABS_HOME/.local/etc/bash_completion.d/dephell.bash-completion"
###

### fzf
# Enable fzf
# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
###
