#!/bin/bash

# mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
"\e[1;5C": forward-word
"\e[1;5D": backward-word
"\e[5C": forward-word
"\e[5D": backward-word
"\e\e[C": forward-word
"\e\e[D": backward-word

# Ctrl+b deletes until slash
"\C-b": unix-filename-rubout

# For ambiguous completions, color the shared prefix in output
set colored-completion-prefix On
# Color completion output
set colored-stats On
# Briefly blink the matching paren when inputing its match
set blink-matching-paren
