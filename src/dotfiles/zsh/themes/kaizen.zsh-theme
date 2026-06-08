# vim:ft=zsh ts=2 sw=2 sts=2
# Kaizen — amuse layout with brand colors (orange / dark blue / white)
# Must use Powerline font, for  to render.

ZSH_THEME_GIT_PROMPT_PREFIX=" on %F{033} "   # dark blue branch
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

PROMPT='
%F{208}▶%F{033}◀%{$reset_color%} 📁 %F{208}%B%~%b%{$reset_color%}$(git_prompt_info)$(virtualenv_prompt_info) ⌚ %F{255}%B%*%b%{$reset_color%}
$ '

RPROMPT='$(ruby_prompt_info)'

VIRTUAL_ENV_DISABLE_PROMPT=0
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=" %F{208}🐍 "
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
