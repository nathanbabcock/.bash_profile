# Aliases
alias reload="source ~/.bash_profile"
alias pnpm_update="powershell -Command \"iwr https://get.pnpm.io/install.ps1 -useb | iex\" && pnpm -v"
alias pnpmx="pnpm --exec"
alias p="p"
alias g="git"

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

# Switch node version
alias oldnode="pnpm env use 8.17.0 --global"
alias nocapnode="pnpm env use 18.16.0 --global"
alias newnode="pnpm env use latest --global"

# Fix Steam "Disk Write Error"
alias fixsteam="rm -rfv D:/SteamLibrary/steamapps/downloading/*"

# Shared history across sessions
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Atuin history search & sync
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash --disable-up-arrow)"

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded."
