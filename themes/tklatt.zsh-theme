# forked this theme off kennethreitz's

if [ $UID -eq 0 ]; then PROMPTCOLOR="red"; else PROMPTCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

function git_prompt_info() {
  if [[ "$(git config --get oh-my-zsh.hide-status)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
      ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$(git_prompt_status)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# get the name of the ruby version
function rvm_prompt_info() {
  [ -f $HOME/.rvm/bin/rvm-prompt ] || return
  local rvm_prompt
  rvm_prompt=$($HOME/.rvm/bin/rvm-prompt i v g)
  [[ "${rvm_prompt}" == "" ]] && return
  echo "${ZSH_THEME_ENV_PROMPT_PREFIX:=(}\xE2\x8B\x84: ${rvm_prompt}${ZSH_THEME_ENV_PROMPT_SUFFIX:=)}"
}

function pyenv_prompt_info() {
  if [[ -d $PYENV_ROOT/bin ]]; then
    echo "${ZSH_THEME_ENV_PROMPT_PREFIX}Py: $(pyenv version-name)${ZSH_THEME_ENV_PROMPT_SUFFIX}"
  fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

function ruby_python_prompt_info() {
  echo "$(rvm_prompt_info)$(pyenv_prompt_info)"
}

PROMPT='%{$fg[$PROMPTCOLOR]%}%c%{$reset_color%} $(git_prompt_info)$(ruby_python_prompt_info)%{$fg[$PROMPTCOLOR]%}%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPROMPT='$(git_prompt_short_sha)%{$fg[blue]%}%~%{$reset_color%} ${return_code} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}:: %{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%} "
ZSH_THEME_ENV_PROMPT_PREFIX="%{$fg[cyan]%}["
ZSH_THEME_ENV_PROMPT_SUFFIX="] %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SHA_AFTER=$ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✓%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}•%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}+%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%}±%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_RENAMED="⸛"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}-%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[black]%}‥%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_STASHED="S"
ZSH_THEME_GIT_PROMPT_AHEAD="↑"
ZSH_THEME_GIT_PROMPT_BEHIND="↓"
ZSH_THEME_GIT_PROMPT_DIVERGED="↝"
  
