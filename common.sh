#! /bin/bash

### General-purpose aliases ###

alias ll="ls -alFh"
alias lr="ll -rt"

# Copy selection to clipboard
alias toclip="xclip -selection clipboard"
# Paste selection from clipboard
alias fromclip="xclip -selection clipboard -out"
alias _clip=toclip
alias clip_=fromclip

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

alias finf="grep -rnI"

# Remove tilde files (backups from text editors)
rmt()
{
    find . -type f -name '*~' -delete
}

# My default path (with no .bash_profile at all) is:
# /usr/kerberos/sbin:/usr/kerberos/bin:/bin:/sbin:/usr/bin:/usr/sbin:
#/opt/local/bin:/usr/local/bin:/usr/X11R6/bin:/users/tchamber/bin:.
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
