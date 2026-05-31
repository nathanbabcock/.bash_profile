#!/bin/bash

# Aliases
alias reload="source ~/.bash_profile"
alias g="git"
alias p="p"
alias px="pnpm exec"
alias pnpm_update="corepack prepare pnpm@latest --activate && pnpm --version"
alias node_update="pnpm env use latest --global && node --version"

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

# Starship shell prompt - https://starship.rs
eval "$(starship init bash)"

# scrcpy
alias mirror="scrcpy --tcpip=192.168.1.71:5555 --turn-screen-off --stay-awake --power-off-on-close"

# Fix Steam "Disk Write Error"
alias fixsteam="rm -rfv D:/SteamLibrary/steamapps/downloading/*"

# Shared history across sessions
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# cd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Atuin history search & sync
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash --disable-up-arrow)"

# Claude Code
# alias yolo="claude --dangerously-skip-permissions"
alias yolo=claude # trying auto mode for a while

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded.\033[0m"
