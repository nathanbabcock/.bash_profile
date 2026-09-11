# shellcheck shell=bash

# Login shells read ~/.bash_profile and never ~/.bashrc; interactive non-login
# shells read only ~/.bashrc. Git Bash always starts a login shell, but VS Code
# on macOS/Linux, WSL, tmux panes and `docker exec` start non-login ones. So all
# the real config lives in .bashrc and this just makes login shells pick it up.

if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi
