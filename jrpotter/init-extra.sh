# ----------------------------------------
# Functions
# ----------------------------------------

function ssh-cache() {
  if [ -z "$1" ]; then
    >&2 echo "Must specify a private SSH keyfile."
    return 1
  else
    eval "$(ssh-agent -s)"
    ssh-add $1
  fi
}

export -f ssh-cache

# ----------------------------------------
# Statusline
# ----------------------------------------

function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]; then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
  else
    echo ""
  fi
}

function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | \
    grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | \
    grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | \
    grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | \
    grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | \
    grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | \
    grep "deleted:" &> /dev/null; echo "$?"`

  bits=""
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

PS1_GIT=""
if command -v git > /dev/null; then
  PS1_GIT='parse_git_branch'
fi
export PS1="\u\[\e[37m\]@\[\e[m\]\[\e[32m\]\W\[\e[m\]\[\e[33m\]\`$PS1_GIT\`\[\e[m\] "
