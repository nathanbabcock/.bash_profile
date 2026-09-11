# shellcheck shell=bash

# Interactive shell config. Login shells reach this via .bash_profile -> ~/.bashrc.

# Only run for interactive shells. Non-interactive ones (ssh command, scp/rsync,
# `bash -c`) must not get prompts or stray output on stdout/stderr.
case $- in *i*) ;; *) return ;; esac

# Aliases
# Replaces the shell rather than re-sourcing: `source`-ing this file again would
# re-run the atuin/starship inits, appending a second copy of their precmd and
# preexec hooks to the ones already registered.
alias reload='exec bash -l'
alias g="git"
alias px="pnpm dlx"
alias node-update="pnpm env use latest --global && node --version"
alias cc="claude"

# cd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# scrcpy
alias mirror="scrcpy --tcpip=192.168.1.71:5555 --turn-screen-off --stay-awake --power-off-on-close"

# Fix Steam "Disk Write Error"
alias fixsteam="rm -rfv D:/SteamLibrary/steamapps/downloading/*"

# Run a command with the project's package manager: whatever package.json's
# "packageManager" field names, else whichever lockfile is present. Walks up from
# $PWD so it still picks the right one from a monorepo subdirectory.
p() {
  local dir="$PWD" pm=""
  while [[ -n "$dir" ]]; do
    if [[ -f "$dir/package.json" ]]; then
      pm="$(sed -n 's/.*"packageManager"[[:space:]]*:[[:space:]]*"\([^@"]*\).*/\1/p' \
            "$dir/package.json" | head -1)"
      [[ -n "$pm" ]] && break
    fi
    # bun.lock is Bun >= 1.2's text lockfile; bun.lockb the older binary one.
    if [[ -f "$dir/bun.lock" || -f "$dir/bun.lockb" ]]; then pm=bun; break; fi
    [[ -f "$dir/pnpm-lock.yaml" ]]    && { pm=pnpm; break; }
    [[ -f "$dir/yarn.lock" ]]         && { pm=yarn; break; }
    [[ -f "$dir/package-lock.json" ]] && { pm=npm;  break; }
    [[ "$dir" == "/" ]] && break
    dir="$(dirname "$dir")"
  done
  command "${pm:-pnpm}" "$@"
}

# Git worktrees helper — `wt`. See worktrees.sh. Superseded by worktrunk below,
# which also defines a `wt` function — don't enable both.
# source "$(dirname "${BASH_SOURCE[0]}")/worktrees.sh"

# pnpm completion. The file is generated per-machine by `pnpm install-completion`.
# shellcheck disable=SC1090
[[ -f ~/completion-for-pnpm.bash ]] && source ~/completion-for-pnpm.bash

# worktrunk — defines the `wt` function. `command wt` so reloading doesn't
# recurse into the function this defines.
if command -v wt &>/dev/null; then
  eval "$(command wt config shell init bash)"
fi

# Shared history across sessions. atuin (below) owns cross-session search and
# sync, so this only has to keep ~/.bash_history appended rather than truncated.
# Deliberately not exported — an exported PROMPT_COMMAND is inherited by
# non-interactive children, which then run it on every prompt of their own.
HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=100000                   # big big history
HISTFILESIZE=100000               # big big history
shopt -s histappend               # append to history, don't overwrite it
# Flush each command as it's run, so concurrent shells see each other's history.
[[ ${PROMPT_COMMAND[*]} == *"history -a"* ]] || PROMPT_COMMAND+=('history -a')

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

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# echo -e "\033[0;34mBash profile loaded.\033[0m"
