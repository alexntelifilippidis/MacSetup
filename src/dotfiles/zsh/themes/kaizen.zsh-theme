# vim:ft=zsh ts=2 sw=2 sts=2
# Kaizen — amuse layout with brand colors (orange / dark blue / white)
# Must use Powerline font, for  to render.

_KAIZEN_LEAF=$'🌿'   # git branch symbol
_KAIZEN_FOLDER=$'📁'  # folder glyph
_KAIZEN_CLOCK=$'⌚'   # clock glyph

_KAIZEN_C_ORANGE=208      # primary — arrows, separators, git branch
_KAIZEN_C_BLUE=033        # accent — path segments
_KAIZEN_C_LIGHT_BLUE=110  # accent light — last path segment
_KAIZEN_C_WHITE=255       # text — time

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{${_KAIZEN_C_LIGHT_BLUE}}on%b %B%F{${_KAIZEN_C_ORANGE}}${_KAIZEN_LEAF} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

_kaizen_path() {
  local p="${(%):-%~}"
  local out="" first=true
  local -a parts=("${(@s:/:)p}")

  local idx=0
  for part in "${parts[@]}"; do
    idx=$(( idx + 1 ))
    if $first; then
      [[ -z "$part" ]] && { out+="%F{${_KAIZEN_C_ORANGE}}/%{$reset_color%}"; first=false; continue; }
      out+="%F{${_KAIZEN_C_BLUE}}%B${part}%b%{$reset_color%}"
      first=false
    else
      [[ -z "$part" ]] && continue
      out+="%F{${_KAIZEN_C_ORANGE}}%B/%b%F{${_KAIZEN_C_BLUE}}%B${part}%b%{$reset_color%}"
    fi
  done

  print -rn -- "$out"
}

PROMPT='
%F{${_KAIZEN_C_ORANGE}}▶%F{${_KAIZEN_C_BLUE}}◀%{$reset_color%}  📁 %F{${_KAIZEN_C_BLUE}}%B$(_kaizen_path)%b%{$reset_color%}$(git_prompt_info) ⌚ %F{${_KAIZEN_C_LIGHT_BLUE}}%B%*%b%{$reset_color%}
$ '

RPROMPT='$(ruby_prompt_info)'
