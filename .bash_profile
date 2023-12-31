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

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded."
