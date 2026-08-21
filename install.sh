#!/bin/sh
# Symlink this repo's agent skills into ~/.agents/skills.
# Existing real directories are left alone — move or delete them first.
set -e
cd "$(dirname "$0")"
mkdir -p "$HOME/.agents/skills"
for src in "$PWD"/agents/skills/*/; do
  name=$(basename "$src")
  dst="$HOME/.agents/skills/$name"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "skip $name (real directory at $dst)"
    continue
  fi
  ln -sfn "${src%/}" "$dst"
  echo "link $name"
done
