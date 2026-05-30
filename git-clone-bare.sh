#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

url=""
dir=""
fork=""
fork_regex=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --fork)
      fork="$2"
      shift 2
      ;;
    --fork-regex)
      fork_regex="$2"
      shift 2
      ;;
    *)
      if [ -z "$url" ]; then
        url="$1"
      elif [ -z "$dir" ]; then
        dir="$1"
      fi
      shift
      ;;
  esac
done

dir="${dir:-$(basename "$url" .git)}"

if [ -z "$url" ]; then
  echo "Usage: git-clone-bare <url> [directory] [--fork <reference> | --fork-regex <sed-pattern>]"
  exit 1
fi

if [ -n "$fork" ] && [ -n "$fork_regex" ]; then
  echo "Error: --fork and --fork-regex are mutually exclusive"
  exit 1
fi

if [ -e "$dir" ]; then
  echo "Error: $dir already exists"
  exit 1
fi

set -eu -o pipefail

git clone --bare "$url" "$dir/.bare"
echo "gitdir: .bare" > "$dir/.git"

git -C "$dir" config core.bare false
git -C "$dir" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git -C "$dir" fetch origin

if [ -n "$fork_regex" ]; then
  sed_pattern="$fork_regex"
  if [[ "$fork_regex" =~ ^/ ]]; then
    sed_pattern="s$fork_regex"
  elif [[ ! "$fork_regex" =~ ^s[^a-zA-Z0-9] ]]; then
    echo "Error: --fork-regex must be in format 's/pattern/replacement/' or '/pattern/replacement/'"
    exit 1
  fi

  fork=$(echo "$url" | sed "$sed_pattern")

  if [ -z "$fork" ]; then
    echo "Error: --fork-regex transformation failed: $fork_regex"
    exit 1
  fi

  if [ "$fork" = "$url" ]; then
    echo "Error: --fork-regex did not transform URL (pattern didn't match): $fork_regex"
    exit 1
  fi

  echo "Upstream: $url"
  echo "Generated fork: $fork"
  read -p "Continue with this fork? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
  fi
fi

if [ -n "$fork" ]; then
  git -C "$dir" remote rename origin upstream
  git -C "$dir" remote add origin "$fork"
  git -C "$dir" fetch origin
fi

cat >> "$dir/.bare/info/exclude" <<'EOF'
/main/
/fix/
/enhancement/
/feature/
EOF

# Detach HEAD so the 'main' branch isn't claimed by .bare
head_sha=$(git -C "$dir" rev-parse HEAD)
echo "$head_sha" > "$dir/.bare/HEAD"

git -C "$dir" worktree add main main

echo "Ready. cd $dir/main to start working."
