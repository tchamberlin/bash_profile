#! /bin/bash

export HISTSIZE=
export HISTFILESIZE=
export HISTFILE=$ABS_HOME/.bash_eternal_history
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

###

### General-purpose functions ###

# Shortcut to become another user via ssh
be()
{
    sshcd "$1@$HOSTNAME"
}

searchpdfs()
{
    local path
    local query
    if [ "$#" -eq 2 ]; then
        path="$1"
        query="$2"
    elif [ "$#" -eq 1 ]; then
        path="."
        query="$1"
    else
        echo "Usage: searchpdfs [ path ] query"
    fi

    for file in *.pdf; do
        echo "Results for '$query' in $file:"
        pdftotext "$file" - | grep --with-filename --label="$file" -ni --color "$query"
        echo "--------------------------------------------------------"
        echo
    done
    # find "$path" -name '*.pdf' -exec sh -c "pdftotext {} - | grep --with-filename --label={} -ni --color $query" \;
}

# Replace string in argument one with string in argument two for ALL
# instances of argument 1 in the filename given by argument 3
# WILL FAIL (safely) if either string contains a "^"; that is used as the sed
# delimiter for this function
findreplace() {
    if [ "$#" -ne 3 ]; then
        echo "usage: findreplace STR_TO_FIND STR_TO_REPLACE FILENAMES"
        return 1
    fi

    if echo "$1 $2 $3" | grep -wiq "^"; then
        echo "No args may contain '^'"
        return 1
    fi

    if [ ! -f "$3" ]; then
        echo "Given file does not exist"
        return 1
    fi

    echo "sed -i -e 's^${1}^${2}^g' ${3}"
    eval "sed -i -e 's^${1}^${2}^g' ${3}"
}

# Given a filename, and optionally a comment symbol, count the number of
# non-comment lines in a file. Very, very basic comment type detection
# included
linecount() {
    if [ -n "$2" ]; then
        comment_symbol="$2"
    fi

    if [ -n "$1" ]; then
        ext="${1##*.}"
        if [ "$ext" == "c" ] || [ "$ext" == "cc" ] || [ "$ext" == "h" ]; then
            comment_symbol="\/\/"
        else
            comment_symbol="#"
        fi

    else
        echo "usage:"
        echo -e "\tlinecount FILENAME [extension]"
    fi

    sed "/^\s*${comment_symbol}/d;/^\s*$/d" "$1" | wc -l
}

# File Find
ff()
{
    if [ "$#" -ge 2 ]; then
        dir="$2"
    else
        dir="."
    fi

    find "$dir" -type f -name "$1"
}

replace_symlinks() {
    while IFS= read -r -d '' link; do
        folder="$(dirname "$link")"
        name="$(basename "$link")"
        rm "$link"
        cp "$(readlink -f "$link")" "$folder/$name"
        echo "Replaced symlink $folder/$name with $(readlink -f "$link")"
    done < <(find "$@" -maxdepth 1 -type l -print0)
}

#From: http://www.linuxjournal.com/content/bash-regular-expressions
testregex()
{
    if [[ $# -lt 2 ]]; then
        echo "Usage: testregex PATTERN STRINGS..."
        return 1
    fi
    regex=$1
    shift
    echo "regex: $regex"
    echo

    while [[ $1 ]]
    do
        if [[ $1 =~ $regex ]]; then
            echo "$1 matches"
            i=1
            n=${#BASH_REMATCH[*]}
            while [[ $i -lt $n ]]
            do
                echo "  capture[$i]: ${BASH_REMATCH[$i]}"
                let i++
            done
        else
            echo "$1 does not match"
        fi
        shift
    done
}


# Remove tilde files (backups from text editors)
rmt()
{
    find . -type f -name '*~' -delete
}

pathadd()
{
    # If the directory given in the argument exists...
    if [ -d "$1" ]; then
        if [[ ":$PATH:" != *":$1:"* ]]; then
            echo "The directory \"$1\" does not yet exist in the PATH. Adding..."
            PATH="$1:$PATH"
            # echo "New path is: $PATH"
        fi
    else
        echo "The directory \"$1\" does not exist. Exiting..."
    fi
}

findlg()
{
    find . -type f -size +"$1"k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
}

vnclist() {
    findinstances Xvnc
}

mostrecent()
{
    local path
    if [ -n "$1" ]; then
        path="$1"
    else
        path="."
    fi
    # Modified from https://stackoverflow.com/a/4561987/1883424
    find "$path" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "
}

fvl() {
    fv "$(mostrecent "$1")"
}

tocamel() {
    shift
    for f in "$@"; do
        mv "$f" "$(echo "$f" | sed -r 's/(^|_)([a-z])/\U\2/g')"
    done

}

tosnake() {
    shift
    for f in "$@"; do
        mv "$f" "$(echo "$f" | sed -e 's/\([A-Z]\)/_\L\1/g' -e 's/^_//')"
    done
}

rmlog() {
    ls -- *.{stdout,stderr}.*.log
    rm -vI -- *.{stdout,stderr}.*.log
}

test_log() {
    echo "SUCCESSFUL COMMAND" >&1
    echo "FAILED COMMAND" >&2
}

color() {
    "$@" \
        2> >(awk '{ print "\033[01;31m"$0"\033[0m" }')
}


colordiff() {
    diff --old-group-format=$'\e[0;31m%<\e[0m' \
        --new-group-format=$'\e[0;31m%>\e[0m' \
        --unchanged-group-format=$'\e[0;32m%=\e[0m' \
        "$@"
}


colorwdiff() {
    wdiff -n \
        --start-delete=$'\033[0;31m' --end-delete=$'\033[0m' \
        --start-insert=$'\033[0;32m' --end-insert=$'\033[0m' \
        "$@"
}

mdrst() {
    local input; input="$1"
    local args; args=()
    for arg in "$@"; do
        case "$arg" in
            -d|--delete ) do_delete=true;;
            *) args+=("$arg")
        esac
    done
    output="${input%.*}.rst"
    if [ -f "$output" ]; then
        rm "$output"
    fi
    pandoc "$input" --to=rst --wrap=none --output="$output" "${args[@]}"
    if [ -n "$do_delete" ]; then
        rm "$input"
    fi

}

countfiles() {
    if [ -n "$1" ]; then
        path="$1"
    else
        path=.
    fi
    (
        cd "$path" || return 1
        du -a | cut -d/ -f2 | sort | uniq -c | sort -nr
    )
}

cdreal() {
    cd "$(readlink -f .)"
}

function tabtitle() {
    if [[ -n "$1" ]]; then
        echo -ne "\033]30;$1\007"
        return 0
    else
        return 1
    fi
}


set-konsole-tab-title-type ()
{
    local _title=$1
    local _type=${2:-0}
    [[ -z "${_title}" ]]               && return 1
    [[ -z "${KONSOLE_DBUS_SERVICE}" ]] && return 1
    [[ -z "${KONSOLE_DBUS_SESSION}" ]] && return 1
    qdbus >/dev/null "${KONSOLE_DBUS_SERVICE}" "${KONSOLE_DBUS_SESSION}" setTabTitleFormat "${_type}" "${_title}"
}
set-konsole-tab-title ()
{
    set-konsole-tab-title-type $1 && set-konsole-tab-title-type $1 1
}

function run_gitstats_for_all_repos() {
    local output_root
    local output
    local full_repo_path
    output_root="/home/www.gb.nrao.edu/homes/monctrl/gitstats"
    for repo in /home/gbt2/git/integration-bare/*; do
        (
            # echo "repo $repo"
            full_repo_path="$(readlink -f "$repo")"
            # echo "frp $full_repo_path"
            cd "$full_repo_path"
            repo_name="$(basename "$repo")"

            echo "Processing $repo..."
            output="$output_root/$repo_name"
            # echo "output $output"
            date_of_latest_commit="$(git log -n 1 --pretty=format:%ad --date=iso)"
            echo "Last commit was at: $date_of_latest_commit"
            if [[ "$(date --date "$date_of_latest_commit" +%s)" -ge "$(date -d yesterday +%s)" ]]; then
                if gitstats . "$output" >/dev/null; then
                    echo "  Wrote report to $output"
                else
                    echo "  Failed..."
                fi
            else
                echo "  No commits in the last day; skipping..."
            fi
        )
    done
}

pretty_path() {
    python -c "print('\n  '.join('$1'.split(':')))"
}

function calc {
    python -c "print($*)"
}

init_ssh_agent() {
    if [[ -z "${1-}" ]]; then
        echo "usage: init_ssh_agent key_path [key_path ...]" >&2
        return 1
    fi

    local ssh_agent_keys
    ssh_agent_keys="$(ssh-add -l || true)"

    for path in "$@"; do
        # Add key to SSH agent if it isn't already there
        if [[ "$ssh_agent_keys" != *" $path "* ]]; then
            ssh-add "$path"
        fi
    done
}

init_ssh_master() {
    if [[ -z "${1-}" ]]; then
        echo "usage: init_ssh_master remote_host [local_port]" >&2
        return 1
    fi

    local remote_host
    remote_host="$1"
    local local_port
    local_port="${2-}"

    local ssh_cmd
    if [[ -n "$local_port" ]]; then
        ssh_cmd="ssh -D localhost:$local_port -L 5901:localhost:5901 -f -q -N -A -M $remote_host"
    else
        ssh_cmd="ssh -f -q -N -A -M $remote_host"
    fi

    if ! pgrep -f "$ssh_cmd" >/dev/null; then
        eval "$ssh_cmd"
    fi
}

export EDITOR=vim

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

    ssh_target_host="${SSH_TARGET_HOST-}"

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

    if [[ -n "$ssh_target_host" ]] && [ "$(hostname)" != "$ssh_target_host" ]; then
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
        _debug "Already on target host $ssh_target_host (or no target host)"
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
        elif [[ "$repo" == "nrqz_admin" ]]; then
            source /home/sandboxes/tchamber/venvs/nrqz-admin-py3.7/bin/activate
            export DJANGO_SETTINGS_MODULE=nrqz_admin.settings.local
        elif [[ "$repo" == "SDDdocs" ]]; then
            sv
            ./bin/builddocs --host "$HOSTNAME" --port 8189
        else
            echo "No explicit rules defined for $repo; attempting to find virtualenv" >&2
            # sv
        fi
        path_part="${PWD/#$HOME/~}"
    path_part="${path_part/$SB/\$SB}"
    echo -en "\033]0;${USER}@${HOSTNAME}:${path_part}\a"

    else
        _debug "handle_go_to_repo: GO_TO_REPO is not defined; NOP"
    fi
}
### END CDR ###

export PYTHONBREAKPOINT=ipdb.set_trace
