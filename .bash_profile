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

# Search changed files for a pattern
# Limitations:
# - difficult to include via an official git alias
# - requires config.submodules.recurse=false
function git-diff-grep() {
  # bail if no arg passed
  if [ $# -eq 0 ]; then
    echo "Usage: git-diff-grep [<git grep options>…] <pattern>"
    return 1
  fi

  # First find the list of all changed files (tracked & untracked)
  changed_files=$(git --no-pager status -suall | awk '{print $2}')

  # Run `git grep` within that whitelist of files
  matching_lines_in_changed_files=$(git --no-pager grep --untracked --line-number --color=always --recursive "$@" -- $changed_files)

  # Bail if no matching lines
  if [ -z "$matching_lines_in_changed_files" ]; then
    echo "No results found."
    return 1
  fi

  # Loop over lines and check if they are in the diff
  untracked_files=$(git --no-pager ls-files --others --exclude-standard)
  git_diff=$(git --no-pager diff --unified=0)

  any_result_found=false
  while ifs= read -r line; do
    # Strip line endings
    line=$(echo -n "$line" | tr -d '\n' | tr -d '\r')

    # Isolate the filename (before first colon)
    filename=$(echo "$line" | cut -d: -f1 | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

    # Isolate the line text (after second colon)
    line_source_code=$(echo "$line" | cut -d: -f3- | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

    # Check if filename is in untracked
    if git --no-pager ls-files --error-unmatch "$filename" > /dev/null 2>&1; then
      # Check if the line occurs in the diff
      if grep -qF "$line_source_code" <<< "$git_diff"; then
        echo -e "$line"
        any_result_found=true
      fi
    else
      echo -e "$line"
      any_result_found=true
    fi
  done <<< "$matching_lines_in_changed_files"

  if ! $any_result_found; then
    echo "No results found."
    return 1
  fi

  return 0
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
alias update_claude="pnpm i -g @anthropic-ai/claude-code"

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded.\033[0m"
