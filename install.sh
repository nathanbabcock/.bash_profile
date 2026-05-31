#!/bin/bash

# Get the directory of the script
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

line_to_add="source \"${script_directory}/.bash_profile\""

# Append the line to the bash_profile file if it doesn't exist already
if ! grep -qF "$line_to_add" ~/.bash_profile; then
    echo "$line_to_add" >> ~/.bash_profile
    echo "Line added to bash_profile."
else
    echo "Line already exists in bash_profile. Nothing to do."
fi
