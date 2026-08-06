#!/usr/bin/env bash
# Kaizen palette — mirrors src/dotfiles/zsh/themes/kaizen.zsh-theme
# orange 208 (primary) / blue 33 (accent) / light-blue 110 (accent light) / white 255
# shellcheck disable=SC2034  # sourced by statusline-command.sh, vars used there
PRIMARY='\033[38;5;208m'      # primary — model label, branch, cost
ACCENT='\033[38;5;33m'        # accent — dir path
ACCENT_LIGHT='\033[38;5;110m' # accent light — PR, time
TEXT='\033[38;5;255m'         # text — duration
