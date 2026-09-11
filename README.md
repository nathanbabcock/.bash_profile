# `.bash_profile`

Run `install.sh` to add this config to `~/.bash_profile` and `~/.bashrc`.

- `.bashrc` — the actual config (aliases, functions, history, prompt). Bash reads
  `~/.bashrc` for interactive non-login shells: VS Code's integrated terminal on
  macOS/Linux, WSL, tmux panes, `docker exec`.
- `.bash_profile` — a stub that sources `~/.bashrc`. Bash reads `~/.bash_profile`
  *instead of* `~/.bashrc` for login shells, which is what Git Bash on Windows
  always starts.
