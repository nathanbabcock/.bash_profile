#!/bin/bash

# Git worktrees: sibling worktrees named <repo>.<branch>. Only a shell function
# can cd the caller, so this lives here rather than as a git alias.
#   wt [sw|switch] [-c|--create] [--code] [--claude [prompt]] [--no-install] <branch> [<base>]
#   wt rm|remove   [-f|--force] [-b|--branch] <branch>
#   wt ls|list     [<git worktree list args>]
#   wt help                                          show usage
wt() {
  case "$1" in
    -h|--help|help|"") _wt_help ;;
    rm|remove) shift; _wt_remove "$@" ;;
    ls|list) shift; _wt_list "$@" ;;
    sw|switch) shift; _wt_switch "$@" ;;
    *) _wt_switch "$@" ;;
  esac
}

_wt_help() {
  cat <<'EOF'
wt — git worktree helper. Worktrees are siblings of the main checkout named
<repo>.<branch> (slashes become dashes), with local .env*/.dev.vars copied in.

Usage:
  wt [sw|switch] [opts] <branch> [<base>]   create or switch to a worktree, cd in
  wt rm|remove   [opts] <branch>            remove a worktree (and maybe its branch)
  wt ls|list     [git args]                 list worktrees (git worktree list passthrough)
  wt help                                   show this help

switch options:
  -c, --create         create the worktree (git worktree add). If <branch>
                       already exists — locally or as a remote/PR branch — it's
                       checked out and tracked, so commits push straight back;
                       otherwise a new branch <branch> is forked off <base>
                       (default: the repo's default branch). Without -c, the
                       worktree must already exist. <base> is only valid with -c,
                       and only when forking a new branch.
      --code           open the worktree in VS Code
      --claude [text]  launch claude in the worktree (optional initial prompt)
      --no-install     skip installing dependencies

remove options:
  -f, --force          force-remove a dirty worktree (and -D the branch with -b)
  -b, --branch         also delete the branch
EOF
}

# Absolute path to the MAIN checkout — the shared git dir resolves to the main
# repo even when this is run from inside a linked worktree.
_wt_root() {
  local gitdir; gitdir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 1
  dirname "$gitdir"
}

# <repo>.<branch> sibling path; branch slashes become dashes for the dir name.
_wt_path() {
  echo "$(dirname "$1")/$(basename "$1").${2//\//-}"
}

# Repo's default branch: origin/HEAD if known, else local main/master, else the
# current branch. Used as the base when `wt -c <name>` is given no explicit base.
_wt_default_branch() {
  local root="$1" ref
  ref="$(git -C "$root" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)" \
    && { echo "${ref#refs/remotes/origin/}"; return 0; }
  for ref in main master; do
    git -C "$root" show-ref --verify --quiet "refs/heads/$ref" && { echo "$ref"; return 0; }
  done
  git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null
}

_wt_switch() {
  local create=0 base="" open_code=0 open_claude=0 claude_prompt="" install=1 branch="" have_base=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--create) create=1 ;;
      --code) open_code=1 ;;
      --claude) open_claude=1; [[ -n "$2" && "$2" != -* ]] && { shift; claude_prompt="$1"; } ;;
      --no-install) install=0 ;;
      -*) echo "wt: unknown option: $1" >&2; return 1 ;;
      *) if [[ -z "$branch" ]]; then branch="$1"; else base="$1"; have_base=1; fi ;;
    esac
    shift
  done
  [[ -z "$branch" ]] && { echo "wt: usage: wt [-c] [--code] [--claude [prompt]] [--no-install] <branch> [<base>]" >&2; return 1; }
  [[ "$have_base" == 1 && "$create" != 1 ]] && { echo "wt: <base> only applies with -c (you're switching to an existing worktree)" >&2; return 1; }

  local root; root="$(_wt_root)" || { echo "wt: not in a git repo" >&2; return 1; }
  local dest; dest="$(_wt_path "$root" "$branch")"

  if [[ -d "$dest" ]]; then
    echo "wt: switching to existing worktree"
  elif [[ "$create" != 1 ]]; then
    echo "wt: no worktree for '$branch' — pass -c to create it" >&2
    return 1
  else
    # -c creates the worktree. If <branch> already exists anywhere — a local
    # branch, or a remote/PR branch (git DWIMs it into a local tracking branch) —
    # check it out so commits push straight back; no new branch. Otherwise fork a
    # new branch <branch> off <base> (default: the repo's default branch).
    if git -C "$root" show-ref --verify --quiet "refs/heads/$branch" \
       || git -C "$root" rev-parse --verify --quiet "refs/remotes/origin/$branch" >/dev/null; then
      [[ "$have_base" == 1 ]] && { echo "wt: branch '$branch' already exists — <base> only applies when forking a new branch" >&2; return 1; }
      git -C "$root" worktree add "$dest" "$branch" || return 1
    else
      [[ -z "$base" ]] && base="$(_wt_default_branch "$root")"
      if [[ -n "$base" ]]; then
        git -C "$root" worktree add -b "$branch" "$dest" "$base" || return 1
      else
        git -C "$root" worktree add -b "$branch" "$dest" || return 1
      fi
    fi

    while IFS= read -r f; do
      mkdir -p "$dest/$(dirname "$f")" && cp "$root/$f" "$dest/$f" && echo "wt: copied ${f#./}"
    done < <(cd "$root" && find . \( -name node_modules -o -name .git \) -prune -o \
      -type f \( -name '.env' -o -name '.env.*' -o -name '.dev.vars' -o -name '.dev.vars.*' \) ! -name '*.example' -print)

    [[ "$install" == 1 && -f "$dest/package.json" ]] && ( cd "$dest" && p install --prefer-offline )
  fi

  [[ "$open_code" == 1 ]] && code "$dest"
  cd "$dest" || return 1
  if [[ "$open_claude" == 1 ]]; then
    if [[ -n "$claude_prompt" ]]; then claude "$claude_prompt"; else claude; fi
  fi
}

# Remove a worktree by branch name; -b also deletes the branch. cd's out first
# if you're standing inside the one being removed.
_wt_remove() {
  local force=0 del_branch=0 branch=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=1 ;;
      -b|--branch) del_branch=1 ;;
      -*) echo "wt: unknown option: $1" >&2; return 1 ;;
      *) branch="$1" ;;
    esac
    shift
  done
  [[ -z "$branch" ]] && { echo "wt: usage: wt rm [-f] [-b] <branch>" >&2; return 1; }

  local root; root="$(_wt_root)" || { echo "wt: not in a git repo" >&2; return 1; }
  local dest; dest="$(_wt_path "$root" "$branch")"
  local dest_real; dest_real="$(cd "$dest" 2>/dev/null && pwd)" \
    || { echo "wt: no worktree at $dest" >&2; return 1; }

  case "$PWD/" in "$dest_real/"*) cd "$root" || return 1 ;; esac

  echo "wt: removing $dest…"
  # core.longpaths lets git unlink deeply-nested node_modules paths past Windows'
  # 260-char MAX_PATH; without it `git worktree remove` half-deletes and bails.
  if [[ "$force" == 1 ]]; then
    git -C "$root" -c core.longpaths=true worktree remove --force "$dest" || return 1
  else
    git -C "$root" -c core.longpaths=true worktree remove "$dest" || return 1
  fi
  echo "wt: removed worktree $dest"

  [[ "$del_branch" == 1 ]] || return 0
  if [[ "$force" == 1 ]]; then
    git -C "$root" branch -D "$branch"
  else
    git -C "$root" branch -d "$branch"
  fi
}

_wt_list() {
  local root; root="$(_wt_root)" || { echo "wt: not in a git repo" >&2; return 1; }
  git -C "$root" worktree list "$@"
}
