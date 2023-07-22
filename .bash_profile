#gpgconf --reload gpg-agent
#gpg-agent --max-cache-ttl 999999

# Aliases
#alias npm="echo -e '\033[0;34mUse pnpm ;)'; echo '...or use alias: oldnpm'"
#alias oldnpm="$(which npm)"
alias reload="source ~/.bash_profile"
alias pnpm_update="powershell -Command \"iwr https://get.pnpm.io/install.ps1 -useb | iex\" && pnpm -v"
alias pnpmx="pnpm --exec"
alias p="pnpm"

# Starship shell prompt - https://starship.rs
eval "$(starship init bash)"

# PNPM autocomplete
# https://pnpm.io/completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
echo -e "\033[0;34mBash profile loaded."
