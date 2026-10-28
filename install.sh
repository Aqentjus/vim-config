#!/bin/sh
# Install this checkout's Vim configuration on macOS or Linux.
# The only installed item is a link to this repository's vimrc.
set -eu

if [ -z "${HOME:-}" ]; then
  echo 'Cannot install: HOME is not set.' >&2
  exit 1
fi

if ! command -v vim >/dev/null 2>&1; then
  echo 'Cannot install: install Vim first (the full build with +terminal).' >&2
  exit 1
fi

repo_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
source_file="$repo_dir/vimrc"
if [ ! -f "$source_file" ] || [ ! -f "$repo_dir/colors/gruvbox.vim" ]; then
  echo 'Cannot install: run this script from a complete vim-config checkout.' >&2
  exit 1
fi

target="$HOME/.vimrc"
if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_file" ]; then
  echo "Already installed: $target points to $source_file"
  exit 0
fi

backup=''
if [ -e "$target" ] || [ -L "$target" ]; then
  stamp=$(date '+%Y%m%d-%H%M%S')
  backup="$target.backup.$stamp"
  i=1
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$target.backup.$stamp.$i"
    i=$((i + 1))
  done
  mv "$target" "$backup"
  echo "Previous configuration backed up to: $backup"
fi

if ln -s "$source_file" "$target"; then
  echo "Installed: $target -> $source_file"
  echo 'Future git pull updates this Vim setup on its next launch.'
else
  echo 'Failed to create the configuration link.' >&2
  if [ -n "$backup" ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
    mv "$backup" "$target"
    echo 'Previous configuration restored.' >&2
  fi
  exit 1
fi
