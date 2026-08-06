#!/usr/bin/env bash
# Batman palette — mirrors src/dotfiles/zsh/themes/batman.zsh-theme
# gold 226 (primary) / slate 246 (accent) / light-gold 227 (accent light) / white 255
# The official Batman iTerm2 scheme is grayscale-heavy — its "blue" ANSI slots
# are desaturated grays, not actual blue. Slate (246) is the real nearest match.
# shellcheck disable=SC2034  # sourced by statusline-command.sh, vars used there
PRIMARY='\033[38;5;226m'      # primary — model label, branch, cost
ACCENT='\033[38;5;246m'       # accent — dir path
ACCENT_LIGHT='\033[38;5;227m' # accent light — PR, time
TEXT='\033[38;5;255m'         # text — duration
