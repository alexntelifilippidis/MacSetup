# vim:ft=zsh ts=2 sw=2 sts=2
# Kaizen — amuse layout with brand colors (orange / dark blue / white)
# Must use Powerline font, for  to render.

ZSH_THEME_GIT_PROMPT_PREFIX=" on %F{208} "   # dark blue branch
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
      [[ -z "$part" ]] && { out+="%F{208}/%{$reset_color%}"; first=false; continue; }
      out+="%F{033}%B${part}%b%{$reset_color%}"
      first=false
    else
      [[ -z "$part" ]] && continue
      out+="%F{208}%B/%b%F{033}%B${part}%b%{$reset_color%}"
    fi
  done

  print -rn -- "$out"
}

PROMPT='
%F{208}▶%F{033}◀%{$reset_color%}  📁 %F{033}%B$(_kaizen_path)%b%{$reset_color%}$(git_prompt_info) ⌚ %F{255}%B%*%b%{$reset_color%}
$ '

RPROMPT='$(ruby_prompt_info)'
