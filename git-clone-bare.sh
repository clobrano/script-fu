#!/usr/bin/env bash
# -*- coding: UTF-8 -*-

url=""
dir=""
fork=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --fork)
      fork="$2"
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
  echo "Usage: git-clone-bare <url> [directory] [--fork <reference>]"
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
