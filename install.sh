#!/bin/bash

# Get the directory of the script
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# ~/.bash_profile gets the login stub, ~/.bashrc gets the actual config. Both are
# needed: login shells read only the former, non-login interactive shells only
# the latter.
link_file() {
  local target="$1" source_file="$2"
  local line_to_add="source \"${script_directory}/${source_file}\""

  touch "$target"
  if grep -qF "$line_to_add" "$target"; then
    echo "${target}: already sources ${source_file}. Nothing to do."
    return
  fi

  echo "$line_to_add" >> "$target"
  echo "${target}: now sources ${source_file}."
}

link_file ~/.bash_profile .bash_profile
link_file ~/.bashrc .bashrc
