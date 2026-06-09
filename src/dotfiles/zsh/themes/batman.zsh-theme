# vim:ft=zsh ts=2 sw=2 sts=2
# Batman — amuse layout with batman colors (fa0 orange / 36f blue / f06 pink)
# Requires Nerd Font (font-meslo-lg-nerd-font)
# Glyphs: U+E0A0 branch  U+F07B folder  U+F017 clock  U+F06DF bat

_BATMAN_BRANCH=$''     # nf-pl-branch
_BATMAN_FOLDER=$''     # nf-fa-folder
_BATMAN_CLOCK=$''      # nf-fa-clock-o
_BATMAN_BAT=$'󰭟'    # nf-md-bat 󰭟

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{225}on%b %B%F{63}${_BATMAN_BRANCH}%b %B%F{220}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%B%F{197}!%b"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%B%F{220}?%b"
ZSH_THEME_GIT_PROMPT_CLEAN=""

_batman_path() {
  local p="${(%):-%~}"
  local out="" first=true

  local parts=("${(@s:/:)p}")
  for part in "${parts[@]}"; do
    if $first; then
      [[ -z "$part" ]] && { out+="%B%F{63}/%b%{$reset_color%}"; first=false; continue; }
      [[ "$part" == "~" ]] && out+="%B%F{220}~%b%{$reset_color%}" || out+="%B%F{220}${part}%b%{$reset_color%}"
      first=false
    else
      [[ -z "$part" ]] && continue
      out+="%B%F{63}/%b%B%F{220}${part}%b%{$reset_color%}"
    fi
  done

  print -rn -- "$out"
}

PROMPT='
%F{220}${_BATMAN_BAT} %{$reset_color%} %F{63}${_BATMAN_FOLDER}%{$reset_color%} $(_batman_path)$(git_prompt_info) %F{63}${_BATMAN_CLOCK}%{$reset_color%} %B%F{255}%*%b%{$reset_color%}
%(?.%F{63}❯%F{214}❯%F{63}❯.%F{88}❯%F{124}❯%F{160}❯)%{$reset_color%} '

RPROMPT=''
