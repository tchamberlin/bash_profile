#!/bin/bash

function gen_venv_path() {
    local python_version
    if [ -z "$PYTHON_EXEC" ]; then
        PYTHON_EXEC=python
    fi
    python_version="$("$PYTHON_EXEC" --version |& awk '{print $2}')"

    if [[ -z "$VENV_HOME" ]]; then
        VENV_HOME="/home/sandboxes/$USER/venvs"
        echo "Implicitly derived VENV_HOME=$VENV_HOME" >&2
    fi
    if [[ -z "$1" ]]; then
        name="$(basename "$(readlink -f .)")"
        echo "Derived venv name '$name' from working directory" >&2
    else
        name="$1"
    fi
    local rhel_version
    rhel_version="rhel$(lsb_release -i -r | grep Release | awk '{print $2}' | awk -F . '{print $1}')"
    local venv_path
    venv_path="$VENV_HOME/$USER@$HOSTNAME-$name-$rhel_version-python${python_version}-env"
    if normalized_path="$(readlink -f "$venv_path")"; then
        echo "$normalized_path"
    else
        echo "$venv_path"
    fi
}
alias gv=gen_venv_path

function _create_venv() {
    if [[ -z "$1" ]]; then
        echo "usage: _create_venv VENV_CMD NAME_STUB" >&2
        return 1
    fi
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Already in virtualenv $VIRTUAL_ENV; deactivating"
        deactivate
    fi
    local python_exec
    python_exec="$1"
    local name
    name="$2"
    local venv_path
    venv_path="$(PYTHON_EXEC="$python_exec" gen_venv_path "$name")"
    if [[ -e "$venv_path" ]]; then
        echo -e "$venv_path already exists. Delete? [y]/n\n  "
        local response
        read -r response
        if [[ "$response" == "y" ]] || [[ "$response" == "" ]]; then
            rm -r "$venv_path"
        fi
    else
        mkdir -p "$venv_path"
    fi
    if [[ "$python_exec" == "python2" ]]; then
        echo "Executing: virtualenv --always-copy --python python2 $venv_path"
        virtualenv --always-copy --python python2 "$venv_path"
    elif [[ "$python_exec" == "python3" ]]; then
        echo "Executing: python3 -m venv --copies $venv_path"
        python3 -m venv --copies "$venv_path"
    else
        echo "Invalid python exec: $python_exec" >&2
        return 1
    fi
    source "$venv_path/bin/activate"
    echo "Entered environment $venv_path"
    echo "Updating pip and setuptools"
    pip install --upgrade pip 
    pip install --upgrade setuptools
    if [[ -n "$3" ]]; then
        reqs_path="$3"
        echo "Installing requirements from given path: $reqs_path"
    elif [[ -f "./requirements.txt" ]]; then
        reqs_path="./requirements.txt"
        echo "Installing requirements from working directory:$reqs_path"
    fi
    if [[ -n "$reqs_path" ]]; then
        pip install --requirement "$reqs_path"
    fi
    echo "Done"
}
alias cvenv2="_create_venv python2"
alias cvenv3="_create_venv python3"
alias cvenv=cvenv3
alias cv=cvenv
alias cv2=cvenv2
alias cv3=cvenv3

function source_venv() {
    # Exit current venv, if we are in one
    if [[ -e "$VIRTUAL_ENV" ]]; then
        echo "Leaving current virtual environment: $VIRTUAL_ENV"
        deactivate || true
    fi

    local venv_path
    # If we have been given a valid path to a venv, simply use that
    if [[ -f "$1/bin/activate" ]]  && [[ "$1" == */* ]]; then
        venv_path="$1"
    # Otherwise, derive the path from current user, host, and (maybe) working dir
    else
        if [[ -z "$1" ]]; then
            name="$(basename "$(readlink -f .)")"
            echo "Derived venv name '$name' from working directory"
        else
            name="$1"
        fi
        venv_path="$(gen_venv_path "$name")"
    fi

    local activate_path
    activate_path="$venv_path/bin/activate"
    if [[ ! -f "$activate_path" ]]; then
        echo "ERROR: No virtual environment found at $venv_path (you should create one with $ cvenv)" >&2
        return 1
    fi

    if [[ "$venv_path" != *"$USER"* ]]; then
        echo "WARNING: Virtual environment $venv_path was not created by current user $USER!"
    fi
    if [[ "$venv_path" != *"$HOSTNAME"* ]]; then
        echo "WARNING: Virtual environment $venv_path was not created using current on host $HOSTNAME!"
    fi
    echo source "$activate_path"
    source "$activate_path"
}
alias sv2="PYTHON_EXEC=python2 source_venv"
alias sv3="PYTHON_EXEC=python3 source_venv"
alias sv=sv3

function rename_venv() {
    (
        set -e
        set -o pipefail

        if [[ -z "$1" ]] || [[ -z "$2" ]]; then
            echo "usage: rename_venv OLD_VENV_PATH NEW_VENV_PATH" >&2
            return 1
        fi
        local old_venv_path
        old_venv_path="$1"
        local old_venv_name
        old_venv_name="$(basename "$1")"
        local new_venv_path
        new_venv_path="$2"
        local new_venv_name
        new_venv_name="$(basename "$2")"
        
        echo "Executing sed..." >&2
        grep -RIl "$old_venv_name" "$old_venv_path" 2>/dev/null | xargs sed -i "s^$old_venv_name^$new_venv_name^g" || echo "No files contained $old_venv_name"
        # "rename" the virtual env directory
        mv "$old_venv_path" "$new_venv_path"
        echo "Success!"
    )
}

function audit_venv() {
    (
        set -e

        output="$(mktemp)"

        echo "{" > "$output"

        if [[ -z "$VENV_HOME" ]]; then
            VENV_HOME="/home/sandboxes/$USER/venvs"
            echo "Implicitly derived VENV_HOME=$VENV_HOME" >&2
        fi
        for venv in "$VENV_HOME"/*pictor*; do
            echo "venv: $venv"
            echo "\"$venv\": " >> "$output"
            (
                # deactivate || true
                source "$venv/bin/activate"
                pip freeze | /home/sandboxes/tchamber/venvs/tchamber@galileo-tchamber-rhel7-python3-env/bin/safety check --stdin --json >> "$output" || true
            )
            echo ", " >> "$output"
        done

        echo "}" >> "$output"
        # requirements="$VENV_HOME/**/requirements.txt"
        # ls "$VENV_HOME"/**/requirements.txt
        # safety check

        cat "$output"
        cp "$output"  /tmp/foo
        python -c "import json; print(json.load('$output'))"
    )
}
