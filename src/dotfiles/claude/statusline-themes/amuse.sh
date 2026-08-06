#!/usr/bin/env bash
# Amuse palette — mirrors oh-my-zsh's built-in amuse.zsh-theme
# bold green (primary) / magenta (accent) / bright magenta (accent light) / bold red
# shellcheck disable=SC2034  # sourced by statusline-command.sh, vars used there
PRIMARY='\033[1;32m'    # primary — model label, branch, cost
ACCENT='\033[35m'       # accent — dir path
ACCENT_LIGHT='\033[95m' # accent light — PR, time
TEXT='\033[1;31m'       # text — duration
