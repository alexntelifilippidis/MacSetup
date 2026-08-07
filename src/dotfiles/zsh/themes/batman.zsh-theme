# vim:ft=zsh ts=2 sw=2 sts=2
# Batman — amuse layout with batman colors (gold trio + slate accent)
# Colors sourced from the official Batman iTerm2/Terminal scheme:
# https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/terminal/Batman.terminal
# The scheme itself is grayscale-heavy — its "blue"/"cyan" ANSI slots (4/6/12)
# are all desaturated grays, not actual blue. Stale "36f blue" from an earlier
# draft has been replaced with the real nearest match (slate, code 246).
# Requires Nerd Font (font-meslo-lg-nerd-font)
# Glyphs: U+E0A0 branch  U+F07B folder  U+F017 clock  U+F06DF bat

_BATMAN_BRANCH=$''     # nf-pl-branch 
_BATMAN_FOLDER=$''     # nf-fa-folder 
_BATMAN_CLOCK=$''      # nf-fa-clock-o 
_BATMAN_BAT=$'󰭟'        # nf-md-bat 󰭟

_BATMAN_C_GOLD=226     # primary — bat, branch name, last path segment (scheme ANSIYellow/Cursor #fcef0c)
_BATMAN_C_LIGHT_GOLD=227 # primary light — clock, separators (scheme ANSIBrightYellow #fef56c)
_BATMAN_C_GOLD_DIM=179 # primary dim — middle path segments (scheme ANSIGreen #c8be46, muted olive-gold)
_BATMAN_C_SLATE=246  # accent — glyphs, separators, branch icon (scheme ANSIBrightBlack/ANSIBrightBlue #949595, muted slate gray)
_BATMAN_C_WHITE=255   # text — labels, time
_BATMAN_C_DIRTY=197   # git dirty marker
_BATMAN_C_OK_MID=214  # ok prompt gradient middle
_BATMAN_C_ERR_1=88    # error prompt gradient low
_BATMAN_C_ERR_2=124   # error prompt gradient mid
_BATMAN_C_ERR_3=160   # error prompt gradient high

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{${_BATMAN_C_WHITE}}on%b %B%F{${_BATMAN_C_SLATE}}${_BATMAN_BRANCH}%b %B%F{${_BATMAN_C_LIGHT_GOLD}}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%B%F{${_BATMAN_C_DIRTY}}!%b"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%B%F{${_BATMAN_C_GOLD}}?%b"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

_batman_path() {
  local p="${(%):-%~}"
  local out="" first=true
  local -a parts=("${(@s:/:)p}")

  local last_idx=0 i
  for (( i = ${#parts[@]}; i >= 1; i-- )); do
    if [[ -n "${parts[$i]}" ]]; then
      last_idx=$i
      break
    fi
  done

  local idx=0 col
  for part in "${parts[@]}"; do
    idx=$(( idx + 1 ))
    col=${_BATMAN_C_GOLD_DIM}
    [[ $idx -eq $last_idx ]] && col=${_BATMAN_C_LIGHT_GOLD}

    if $first; then
      [[ -z "$part" ]] && { out+="%B%F{${_BATMAN_C_LIGHT_GOLD}}/%b%{$reset_color%}"; first=false; continue; }
      [[ "$part" == "~" ]] && out+="%B%F{${col}}~%b%{$reset_color%}" || out+="%B%F{${col}}${part}%b%{$reset_color%}"
      first=false
    else
      [[ -z "$part" ]] && continue
      out+="%B%F{${_BATMAN_C_SLATE}}/%b%B%F{${col}}${part}%b%{$reset_color%}"
    fi
  done

  print -rn -- "$out"
}

PROMPT='
%F{${_BATMAN_C_SLATE}}╭─%{$reset_color%} %F{${_BATMAN_C_GOLD}}${_BATMAN_BAT}%{$reset_color%} %F{${_BATMAN_C_SLATE}}${_BATMAN_FOLDER}%{$reset_color%} $(_batman_path)$(git_prompt_info) %F{${_BATMAN_C_SLATE}}${_BATMAN_CLOCK}%{$reset_color%} %B%F{${_BATMAN_C_GOLD_DIM}}%*%b%{$reset_color%}
%F{${_BATMAN_C_SLATE}}╰─%{$reset_color%}%(?.%B%F{${_BATMAN_C_LIGHT_GOLD}}❯%b.%B%F{${_BATMAN_C_ERR_2}}❯%b)%{$reset_color%} '

RPROMPT=''
