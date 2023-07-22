# Aliases
alias reload="source ~/.bash_profile"
alias pnpm_update="powershell -Command \"iwr https://get.pnpm.io/install.ps1 -useb | iex\" && pnpm -v"
alias pnpmx="pnpm --exec"
alias p="pnpm"

# Starship shell prompt - https://starship.rs
eval "$(starship init bash)"

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded."
