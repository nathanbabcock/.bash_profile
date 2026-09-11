#!/bin/bash

# Get the directory of the script
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# ~/.bash_profile gets the login stub, ~/.bashrc gets the actual config. Both are
# needed: login shells read only the former, non-login interactive shells only
# the latter.
link_file() {
  local target="$1" source_file="$2"
  # Match on the marker, not the whole line: the same directory spells itself
  # /c/git/... or C:/git/... depending on how the shell was started, and a path
  # comparison would add a second copy rather than recognising the first.
  local marker="# installed by .bash_profile/install.sh (${source_file})"

  touch "$target"
  if grep -qF "$marker" "$target"; then
    echo "${target}: already sources ${source_file}. Nothing to do."
    return
  fi

  # Don't glue onto a last line that has no trailing newline.
  if [[ -s "$target" && -n "$(tail -c1 "$target")" ]]; then
    echo >> "$target"
  fi

  echo "source \"${script_directory}/${source_file}\"  ${marker}" >> "$target"
  echo "${target}: now sources ${source_file}."
}

link_file ~/.bash_profile .bash_profile
link_file ~/.bashrc .bashrc
