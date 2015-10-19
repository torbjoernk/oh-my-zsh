# forked this theme off kennethreitz's

if [ $UID -eq 0 ]; then PROMPTCOLOR="red"; else PROMPTCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# get the name of the ruby version
function rvm_prompt_info() {
  [[ -f $HOME/.rvm/bin/rvm-prompt ]] || return
  local rvm_prompt
  rvm_prompt=$($HOME/.rvm/bin/rvm-prompt v g)
  [[ "${rvm_prompt}" == "" ]] && return
  echo "${rvm_prompt} "
}

function pyenv_prompt_info() {
  if [[ -d "$PYENV_ROOT" ]]; then
    if [[ "$(pyenv version-name)" != "system" ]]; then
      echo "$(pyenv version-name) "
    fi
  fi
}

GIT_PROMPT_PREFIX=""
GIT_PROMPT_SUFFIX=""
GIT_PROMPT_SHA_BEFORE="%F{yellow}("
GIT_PROMPT_SHA_AFTER=")%f"
GIT_PROMPT_CLEAN="%F{green}✓%f"
GIT_PROMPT_STAGED="%F{orange}•NUM%f"
GIT_PROMPT_ADDED="%F{green}+NUM%f"
GIT_PROMPT_MODIFIED="%F{blue}±NUM%f"
GIT_PROMPT_RENAMED="%F{red}↝NUM%f"
GIT_PROMPT_DELETED="%F{red}-NUM%f"
GIT_PROMPT_UNTRACKED="%F{black}‥NUM%f"
GIT_PROMPT_STASHED="%F{yellow}\$NUM%f"
GIT_PROMPT_AHEAD="%F{cyan}↑NUM%f"
GIT_PROMPT_BEHIND="%F{magenta}↓NUM%f"
GIT_PROMPT_MERGING="%F{red}⚡︎%f"

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
function parse_git_state() {
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local GIT_STATUS_OUT="$(git status --porcelain)"

  ## compare to remotes
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  ## stash
  if git rev-parse --verify --quiet refs/stash >/dev/null 2>&1; then
    local NUM_STASHED=$(git rev-parse --verify --quiet refs/stash 2>/dev/null | wc -l)
    GIT_STATE=$GIT_STATE${GIT_PROMPT_STASHED//NUM/$NUM_STASHED}
  fi

  ## merging
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  ## local status
  if [[ -n "${GIT_STATUS_OUT}" ]]; then
    NUM_UNTRACKED="$(echo $GIT_STATUS_OUT | grep -ce '^?')"
    NUM_UNSTANGED="$(echo $GIT_STATUS_OUT | grep -ce '^ [MD]')"
    NUM_MOD_INDEX="$(echo $GIT_STATUS_OUT | grep -cE '^M')"
    NUM_MOD_TREE="$(echo $GIT_STATUS_OUT | grep -cE '^[ MARC]M')"
    NUM_ADD_INDEX="$(echo $GIT_STATUS_OUT | grep -cE '^A')"
    NUM_DEL_INDEX="$(echo $GIT_STATUS_OUT | grep -cE '^D')"
    NUM_DEL_TREE="$(echo $GIT_STATUS_OUT | grep -cE '^[ MARC]D')"
    NUM_REN_INDEX="$(echo $GIT_STATUS_OUT | grep -cE '^R')"
    NUM_STAGED=$((NUM_MOD_INDEX+NUM_ADD_INDEX+NUM_DEL_INDEX+NUM_REN_INDEX))

    if [[ "$NUM_UNTRACKED" -gt 0 ]]; then
      GIT_STATE=$GIT_STATE${GIT_PROMPT_UNTRACKED//NUM/$NUM_UNTRACKED}
    fi

    if [[ "$NUM_MOD_TREE" -gt 0 ]]; then
      GIT_STATE=$GIT_STATE${GIT_PROMPT_MODIFIED//NUM/$NUM_MOD_TREE}
    fi

    if [[ "$NUM_DEL_TREE" -gt 0 ]]; then
      GIT_STATE=$GIT_STATE${GIT_PROMPT_DELETED//NUM/$NUM_DEL_TREE}
    fi

    if [[ "$NUM_ADD_INDEX" -gt 0 ]]; then
      GIT_STATE=$GIT_STATE${GIT_PROMPT_ADDED//NUM/$NUM_ADD_INDEX}
    fi

    if [[ "$NUM_STAGED" -gt 0 ]]; then
      GIT_STATE=$GIT_STATE${GIT_PROMPT_STAGED//NUM/$NUM_STAGED}
    fi
  else
    GIT_STATE=$GIT_STATE$GIT_PROMPT_CLEAN
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

# If inside a Git repository, print its branch and state
function git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "[%F{blue}${git_where#(refs/heads/|tags/)}%f $(parse_git_state) $GIT_PROMPT_SHA_BEFORE$(git log -1 --format='%h')$GIT_PROMPT_SHA_AFTER]"
}

ZSH_THEME_ENV_PROMPT_PREFIX="%{$fg[cyan]%}["
ZSH_THEME_ENV_PROMPT_SUFFIX="] %{$reset_color%}"

function prompt_char {
  git branch >/dev/null 2>/dev/null && echo '±' && return
  hg root >/dev/null 2>/dev/null && echo '☿' && return
  echo '○'
}

function current_pwd {
  echo $(pwd | sed -e "s,^$HOME,~,")
}

PROMPT='
%F{$PROMPTCOLOR}%n%f%F{black}@%f%F{blue}$(hostname -s)%f %B%F{yellow}$(current_pwd)%f%b $(git_prompt_string)
$(prompt_char) '
export SPROMPT="Correct %F{red}%R%f to %F{green}%r%f [(y)es (n)o (a)bort (e)dit]? "
RPROMPT='${return_code} %F{green}$(pyenv_prompt_info)%f%F{yellow}$(rvm_prompt_info)%f[%D %*]'
