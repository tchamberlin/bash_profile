#!/bin/bash


umask 002

export TWC_HOME=/users/tchamber

### General-purpose aliases and functions ###

export HISTSIZE=
export HISTFILESIZE=
export HISTFILE=$TWC_HOME/.bash_eternal_history
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Reload my environment
alias twc="source $TWC_HOME/.bash_profile"

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

###

export PYENV_ROOT=$SB/.pyenv


# Shortcut to be monctrl via ssh
bem()
{
    sshcd "monctrl@$HOSTNAME"
}

reset_google_earth() {
    rm -rf /users/tchamber/.googleearth
    rm -f /users/tchamber/.config/Google/*
}


export SB=/home/sandboxes/tchamber
export PROJ=$SB/projects
export REPOS=$SB/repos
export SUBLIME_PROJECTS="$SB/sublime_projects"

alias sc="sshcd colossus"

alias cdsb="cd \$SB"
alias cdp="cd \$SB/projects"
alias cdf="cdreal"
# cd to whichever virtual env you are currently in
alias cdv="cd \$VIRTUAL_ENV"

function gen_subl_proj() {
    python3.7 "$REPOS/gen-sublime-proj/gen.py" "$1" "$SUBLIME_PROJECTS"
}


function getres() {
    xrandr --current | grep '\*' | uniq | awk '{print $1}'
}

export MY_WORKSTATION="pictor"

function subl_proj() {
    (
        set -e
        shopt -s nullglob
        projects_dir=/home/sandboxes/tchamber/sublime_projects
        files=("$projects_dir"/$1*.sublime-project)

        if [ ${#files[@]} -lt 1 ]; then
            echo "No projects matched given glob '$1*'. Known projects:"
            for file in "$projects_dir"/*.sublime-project; do
                echo "  * $(basename "${file%%.sublime-project}")"
            done
            return 1
        elif [ ${#files[@]} -gt 1 ]; then
            echo "Glob '$1*' matched multiple projects in $projects_dir; be more specific!"
            for file in "${files[@]}"; do
                echo "  * $(basename "${file%%.sublime-project}")"
            done
            return 1
        fi
        proj_file="${files[0]}"
        do_local /home/gbt1/sublime_text_3/sublime_text --project "$proj_file" --wait
        proj_path=$(python -c "import json; print(json.load(open('$proj_file'))['folders'][0]['path'])")
        echo "Moving to project directory: $proj_path"
        cd "$proj_path"
        if [ "${HOSTNAME%%.*}" != "colossus" ]; then
            sshcd colossus 2>/dev/null
        fi
    )
}
export -f subl_proj
alias sp=subl_proj

function subl() {
    if [[ "--project" == *"${*}"* ]]; then
        if wmctrl -l | awk '{print substr($0, index($0, $4))}' | grep 'Sublime Text' | grep "($1)" >/dev/null; then
            _debug "Project with name '$repo' is already open in Sublime Text"
            return 1
        fi
    fi
    do_local _subl "$@"
}

function cdn() {
    cd "$REPOS/nrqz_admin" || return 1
    source "/home/sandboxes/tchamber/venvs/nrqz-admin-py3.7/bin/activate"
    export PYTHONPATH=.:$PYTHONPATH || return 1
    export DJANGO_SETTINGS_MODULE=nrqz_admin.settings.local || return 1
    echo "Successfully entered NRQZ Admin Dev Env"
}

function cdnb() {
    cd "$REPOS/nrqz_admin_beta" || return 1
    source_venv || return 1
    export PYTHONPATH=.:$PYTHONPATH || return 1
    export DJANGO_SETTINGS_MODULE=nrqz_admin.settings.staging || return 1
    echo "Successfully entered NRQZ Admin Beta Env"
}

function cdnp() {
    if [ "$USER" != "nrqz" ]; then
        echo "Must be nrqz user!" >&2
        return 1
    fi
}

function cddid() {
    cd "$REPOS/django-import-data/example_project" || return 1
    source_venv || return 1
    export PYTHONPATH=.:$PYTHONPATH || return 1
    export DJANGO_SETTINGS_MODULE=example_project.settings || return 1
    echo "Successfully entered Django Import Data Environment"
}

alias lcl=do_local
alias l=lcl

alias hl="history | less +G" 


# https://gist.github.com/tchamberlin/ed67f70ec5837b36a8ac2b025cad6700
# Shortcut to open up an rdesktop session
function rdesk() {
    local host
    if [ -n "$1" ]; then
        host="$1"
        shift
    else
        host="gbtsb"
    fi

    local x_scale_factor
    x_scale_factor="1"
    local x
    x=$(getres | cut -d 'x' -f1)
    local x_scaled
    x_scaled=$(python -c "print(int(${x} * $x_scale_factor))")
    local y_scale_factor
    y_scale_factor=".95"
    local y
    y=$(getres | cut -d 'x' -f2)
    local y_scaled
    y_scaled=$(python -c "print(int(${y} * $y_scale_factor))")
    echo "Connecting to $host as $USER, scaled to: ${x_scaled}x${y_scaled} from current (single-monitor) resolution of: ${x}x${y}"
    
    if [ "$(get_rhel_version)" == "6" ]; then
        echo rdesktop -u "AD\\${USER}" -p - -g "${x_scaled}x${y_scaled}" "$host" "$@"
        rdesktop -u "AD\\${USER}" -p - -g "${x_scaled}x${y_scaled}" "$host" "$@"
    else
        echo xfreerdp "/size:${x_scaled}x${y_scaled}" /bpp:16 /d:"AD" /v:"$host" /u:"$USER" "$@"
        xfreerdp "/size:${x_scaled}x${y_scaled}" /bpp:16 /d:"AD" /v:"$host" /u:"$USER" "$@"
    fi
}

### git ###


## DSS ##
alias conundrum='source /home/dss/conundrum/conundrum.bash'
alias dssenv="source \$SB/repos/nell/env/dss.bash"

drs() {
	conundrum
	cd /home/dss/release/nell || return 1
	echo "Opening DSS release's shell in $(pwd)"
	./manage.py shell
	cd - || return 1
}

cddss()
{
    cd $SB/repos/nell || return 1
    if [ -z "$VIRTUAL_ENV" ]; then
        PYTHONPATH=$SB/repos/nell/:$PYTHONPATH
        dssenv
    fi
}

rff() {
    killall firefox
    firefox &
    disown
}

## M&C ##

export MC=$SB/mc

export DEVTELE="$SB/simulator/telescope"
export SORTER="$MC/ygor/doc/example/src/devices/Sorter"

alias cdmc="cd \$MC"

### FLAG/Beamformer ###

export PAF="$MC/gbt/devices/receivers/RcvrArray1_2"
alias cdpaf="cd \$SB/mc/gbt/devices/receivers/RcvrArray1_2/"

# Source the DIBAS environment
alias dibasenv="source /home/sandboxes/tchamber/bf/dibas/dibas.bash"

# Check status of important environmental variables
chenv()
{
    echo "YGOR_TELESCOPE=$YGOR_TELESCOPE"
    echo "YGOR_INSTALL=$YGOR_INSTALL"
    echo "YGOR_ROOT=$YGOR_ROOT"
    echo "GB_ROOT=$GB_ROOT"
    echo "SPARROW_ROOT=$SPARROW_ROOT"
    echo "SPARROW_DIR=$SPARROW_DIR"
    echo "SPARROW_VERSION=$SPARROW_VERSION"

}

mcdev() {
    cd $MC || return 1
    export YGOR_ROOT=$MC/ygor
    export GB_ROOT=$MC/gb
    source $YGOR_ROOT/ygor.bash

    unset YGOR_INSTALL
    echo "Remember to set YGOR_INSTALL!"
}

# Enter the current development telescope environment
devtele()
{
    export YGOR_ROOT=$MC/ygor
    export GB_ROOT=$MC/gb
    export SPARROW_LOG_DIR=/home/sandboxes/tchamber/simulator/telescope/logs/sparrow_logs
    source $SB/simulator/telescope/gbt.bash || return 1
    # TODO: Is this needed?
    usegcc53
    echo "Now in dev environment"
}

alias cdsparrow="cd $REPOS/sparrow/sandbox/sparrow"

# Enter simulation environment
simenv()
{
    export YGOR_TELESCOPE="/home/sim"
    source /home/sim/gbt.bash
    source /home/sim/sparrow/sparrow.bash
    echo "Now in simulator environment"
}

# Enter real environment
gbtenv()
{
    source /home/gbt/gbt.bash
    source /home/gbt/sparrow/sparrow.bash
    echo "Now in GBT environment"
}

# Find an M&C library
findlib()
{
    find $MC/ygor/libraries -type f -iname "*$1*"
}


### GBORS ###

export GBORS=$SB/projects/gbors/sandbox/gbors

function _debug() {
    if [ -n "${_LOG_DEBUG-}" ]; then
        echo "DEBUG: $*" >&2
    fi
}


### CDR ###
# Enable tab completion for cdr function
complete -W "$(ls $REPOS)" 'cdr'
function cdr() {
    if [ -z "$1" ]; then
        _debug "no arg given; cd'ing to repos dir"
        cd "$REPOS"
        return 0
    fi

    local repo
    repo="$1"

    export CURRENT_REPO="$repo"

    if [ ! -d "$REPOS/$repo" ]; then
        echo "ERROR: $REPOS/$repo does not exist!" >&2
        return 1
    fi

    _debug "Derived target repo: $repo"

    ssh_target_host="galileo"

    # # Now, try a few different versions of project name. Sometimes we use -;
    # # sometimes we use _, so let's try some common permutations
    # # v1: No changes
    # sublime_project_path_v1="$SUBLIME_PROJECTS/$repo.sublime-project"
    # # v2: Use - instead of _
    # sublime_project_path_v2="$SUBLIME_PROJECTS/${repo//_/-}.sublime-project"
    # # v3: Use _ instead of -
    # sublime_project_path_v3="$SUBLIME_PROJECTS/${repo//-/_}.sublime-project"
    # for sublime_project_path in "$sublime_project_path_v1" "$sublime_project_path_v2" "$sublime_project_path_v3"; do
    #     _debug "Attempting to find Sublime Text project at: $sublime_project_path"
    #     if [ -f "$sublime_project_path" ]; then
    #         _debug "Found $sublime_project_path; attempting to open in Sublime Text"
    #         _subl --project "$sublime_project_path"
    #         # Break out after we've made a single attempt to open the project
    #         break
    #     else
    #         _debug "No project found at $sublime_project_path"
    #     fi
    # done

    if [ "$(hostname)" != "$ssh_target_host" ]; then
        echo "Setting tab title to $USER@$HOSTNAME: $repo"
        _debug "Not currently on target host $ssh_target_host; ssh'ing now"
        # This is where the magic happens! We ssh to our target host, then open a new
        # bash shell with two variables set:
        # _LOG_DEBUG: this is carried over from the current environment, to enable
        #             logging to continue if it has been enabled
        # GO_TO_REPO: This is set to the path of the target repo. When the new
        #             shell opens, handle_go_to_repo will pick up this variable
        #             and perform the relevant actions!
        ssh -qt "$ssh_target_host" _LOG_DEBUG="$_LOG_DEBUG" GO_TO_REPO="$repo" bash
    else
        _debug "Already on target host $ssh_target_host"
        # In this case, we trigger handle_go_to_repo manually
        GO_TO_REPO="$repo" handle_go_to_repo
    fi
}

function handle_go_to_repo() {
    if [ -n "${GO_TO_REPO-}" ]; then
        repo="$GO_TO_REPO"
        _debug "handle_go_to_repo: GO_TO_REPO found; derived repo $repo"
        cd "$REPOS/$repo"
        if [[ "$repo" == "gbors" ]]; then
            _debug "Rules found for repo $repo"
            source ./env/gbors.bash
            export DJANGO_SETTINGS_MODULE=gbors.settings.development
            export PATH=/home/gbors/node/bin:$PATH
        elif [[ "$repo" == "nrqz_admin" ]]; then
            source /home/sandboxes/tchamber/venvs/nrqz-admin-py3.7/bin/activate
            export DJANGO_SETTINGS_MODULE=nrqz_admin.settings.local
        elif [[ "$repo" == "SDDdocs" ]]; then
            sv
            ./bin/builddocs --host "$HOSTNAME" --port 8189
        else
            echo "No explicit rules defined for $repo; attempting to find virtualenv" >&2
            sv
        fi
        path_part="${PWD/#$HOME/~}"
	path_part="${path_part/$SB/\$SB}"
	echo -en "\033]0;${USER}@${HOSTNAME}:${path_part}\a"

    else
        _debug "handle_go_to_repo: GO_TO_REPO is not defined; NOP"
    fi
}
### END CDR ###

# MISC. #

### Task Warrior Aliases ###
alias tl='task list'
alias ta='task add'
alias tn='task next'
alias t='task'

# Clean build
mncclean()
{
    if [ -z "$1" ]; then
        local cores="12"
    else
        local cores="$1"
    fi
    make -j "$cores" clean -s
    make -j "$cores" depend -s
    make -j "$cores" -s
}

mmi()
{
    if [ -z "$1" ]; then
        local cores="12"
    else
        local cores="$1"
    fi
    make -j "$cores" -s
    make -j "$cores" install -s
}

mcmi()
{
    if [ -z "$1" ]; then
        local cores="12"
    else
        local cores="$1"
    fi
    make -j "$cores" clean
    mmi "$cores"
}

mcm()
{
    if [ -z "$1" ]; then
        local cores="12"
    else
        local cores="$1"
    fi
    make -j "$cores" clean -s
    make -j "$cores" -s
}

mi()
{
    if [ -z "$1" ]; then
        local cores="12"
    else
        local cores="$1"
    fi
    make install -j "$cores" -s
}

usegcc53()
{
    if [ ! -f /opt/rh/devtoolset-4/enable ]; then
        echo "gcc53 not installed on this host"
        return 1;
    fi
    if [ "$(type g++ | grep -c devtool)" == "0" ]; then
        source /opt/rh/devtoolset-4/enable
    fi
}


### Haskell ###

export STACK_ROOT=/home/sandboxes/tchamber/haskell/.stack



# Decide what color the username text is in the terminal based on who
# I currently am
if [ "$(whoami)" == "tchamber" ]
then
    USERCOLOR=$BGreen
elif [ "$(whoami)" == "monctrl" ] || [ "$(whoami)" == "lmonctrl" ]
then
    USERCOLOR=$BBlue
else
    USERCOLOR=$BRed
fi

# Set punctuation to white
PUNCCOLOR=$BBlack

# Decide what color the hostname text is based on which host I am currently on
if [ "$(hostname)" == "$MY_WORKSTATION" ]; then
    HOSTCOLOR=$BGreen
elif [ "$(hostname)" == "colossus" ] || [ "$(hostname)" == "galileo" ]; then
    HOSTCOLOR=$BBlue
elif [ "$(hostname)" == "trent" ] || [ "$(hostname)" == "gboweb" ] || [ "$(hostname)" == "trent2" ]; then
    HOSTCOLOR=$BPurple
else
    HOSTCOLOR=$BRed
fi

TIMECOLOR=$BPurple
NUMBCOLOR=$BCyan
PATHCOLOR=$BPurple
TEXTCOLOR=$Color_Off

handle_go_to_repo

get_rhel_version() {
    lsb_release -i -r | grep Release | awk '{print $2}' | awk -F . '{print $1}'
}

# If RHEL7...
if [ "$(get_rhel_version)" == "7" ]; then
    # Enables behavior from 4.1 where variables were properly expanded via tab
    # https://stackoverflow.com/questions/103316/in-bash-environmental-variables-not-tab-expanding-correctly
    shopt -s direxpand

    source /opt/rh/rh-git29/enable
    # source /opt/rh/devtoolset-7/enable
    # alias p3="source \$SB/venvs/twc_python3.6/bin/activate"
    export -f gen_subl_proj
    alias gsp=gen_subl_proj
elif [ $(get_rhel_version) == "6" ]; then
    # Needed for git 2.7
    export GIT_EXEC_PATH=/opt/local/libexec/git-core
    
    # Shortcuts to my two general-purpose python virtual environments
    alias p2="source \$SB/venvs/twc_python2/bin/activate"
    alias p3="source \$SB/venvs/twc_python3/bin/activate"
else
    echo "WARNING: Unknown RHEL version!" >&2
fi

function pres_ps1() {
   PS1='<\u@\h>$(__git_ps1) $ '
}

alias turtlecli=~monctrl/bin/turtlecli


if [[ "$HOSTNAME" == "galileo" ]] || [[ "$HOSTNAME" == "trent2" ]]; then
    source /opt/rh/rh-postgresql96/enable
fi

export VENV_HOME=$SB/venvs/

alias sshg="ssh galileo"

function qlocate {
    if [ -z "$1" ]; then
        echo "usage: qlocate QUERY" >&2
        return 1
    fi

    # Use zgrep to parse all monctrl qdirstat caches. Turn off filenames for easier
    # column parsing, and force coloring to see which highlighting of search terms
    # in the results
    # Grab the second column with awk, then use sed to replace references to the
    # haktar mirror with references to the live filesystem (for ease of use)
    zgrep --no-filename --color=always "$1" ~monctrl/qdirstat/qdirstat*.gz |
        awk '{print $2}' | sed 's^/data/filer_mirror/vol2/code/monctrl^/home^' |
        sed 's^/data/filer_mirror/vol2/users/monctrl^/users/monctrl^'
}

alias ql=qlocate

export HOSTALIASES=~/.config/.hosts

alias pr="poetry run"
alias p="poetry"

initconda() {
    if [[ -z "$CONDA_PREFIX" ]]; then
        __conda_setup="$('/opt/local/stow/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/opt/local/stow/anaconda3/etc/profile.d/conda.sh" ]; then
                . "/opt/local/stow/anaconda3/etc/profile.d/conda.sh"
            else
                export PATH="/opt/local/stow/anaconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
    else
        echo "Conda already initialized" >&2
    fi
}

alias rl='readlink -f '
function lc() {
    local link
    link="$(readlink -f "$1")"
    echo "$link"
    echo "$link" | _clip
    echo "Copied to clipboard" >&2
}

function ce() {
    sshcron "$*" -e
}

function cl() {
    sshcron "$*"
}


# function goprod() {
#     if [[ "$1" == "gbors" ]]; then
        
#     fi
# }
# complete -W "gbors foo" 'goprod'
# complete -W "gbors foo" 'gop'
# alias gop=goprod

alias sdb='rclone copy dropbox:twc.kdbx /home/sandboxes/tchamber/downloads'

complete -W "$(while read -r path; do echo ${path%%\.md}; done <<< "$(find ~/.local/share/tldr/pages/{linux,common} -printf '%f\n')")" tldr

export TLDR_TITLE_STYLE="Newline Space Bold Black"
export TLDR_DESCRIPTION_STYLE="Space Black"
export TLDR_EXAMPLE_STYLE="Newline Space Bold Green"
export TLDR_CODE_STYLE="Space Bold Blue"
export TLDR_VALUE_ISTYLE="Space Bold Cyan"
# The Value style (above) is an Inline style: doesn't take Newline or Space
# Inline styles for help text: default, URL, option, platform, command, header
export TLDR_DEFAULT_ISTYLE="White"
export TLDR_URL_ISTYLE="Black"
export TLDR_HEADER_ISTYLE="Bold"
export TLDR_OPTION_ISTYLE="Bold Black"
export TLDR_PLATFORM_ISTYLE="Bold Blue"
export TLDR_COMMAND_ISTYLE="Bold Cyan"
export TLDR_FILE_ISTYLE="Bold Magenta"
# Color/BG (Newline and Space also allowed) for error and info messages
export TLDR_ERROR_COLOR="Newline Space Red"
export TLDR_INFO_COLOR="Newline Space Green"

export MANPATH=$MANPATH:$SB/programs/share/man


### Manage Apache Configs
# shellcheck disable=SC1091
source "/home/gbt1/manage_apache_configs/completions.sh"
###



### THINGS THAT DO THINGS GO BELOW THIS

# Print the current redhat release version
'cat' /etc/redhat-release >&2

