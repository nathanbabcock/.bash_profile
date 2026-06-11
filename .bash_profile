#!/bin/bash

# Aliases
alias reload="source ~/.bash_profile && echo -e \"\033[0;34mBash profile reloaded.\033[0m\""
alias g="git"
alias px="pnpm dlx"
alias pnpm-update="corepack use pnpm@latest && pnpm --version"
alias node-update="pnpm env use latest --global && node --version"

# cd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# scrcpy
alias mirror="scrcpy --tcpip=192.168.1.71:5555 --turn-screen-off --stay-awake --power-off-on-close"

# Fix Steam "Disk Write Error"
alias fixsteam="rm -rfv D:/SteamLibrary/steamapps/downloading/*"

# Claude Code
alias yolo=claude # trying auto mode for a while

# determine local package manager and run command with it
p() {
  if [[ -f bun.lockb ]]; then
    command bun "$@"
  elif [[ -f pnpm-lock.yaml ]]; then
    command pnpm "$@"
  elif [[ -f yarn.lock ]]; then
    command yarn "$@"
  elif [[ -f package-lock.json ]]; then
    command npm "$@"
  else
    command pnpm "$@"
  fi
}

# Git worktrees helper — `wt`. See worktrees.sh.
# source "$(dirname "${BASH_SOURCE[0]}")/worktrees.sh"

# Shared history across sessions
# Guarded so re-sourcing (`reload`) doesn't stack duplicate history commands.
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
case "$PROMPT_COMMAND" in
  *"history -a; history -c; history -r;"*) ;;
  *) export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND" ;;
esac

# Atuin history search & sync
# shellcheck disable=SC1090
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
if command -v atuin &>/dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi

# Starship shell prompt - https://starship.rs
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# On Windows Git Bash, load .bashrc on first login
if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# echo -e "\033[0;34mBash profile loaded.\033[0m"
