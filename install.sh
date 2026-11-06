#!/bin/sh
# Install a standalone Vim configuration on macOS and Linux.
# Requirements: Vim >= 9.0.0438, Node.js >= 22.15, npm and Git.
set -eu

if [ -z "$HOME" ]; then
  echo 'HOME is not set.' >&2
  exit 1
fi
for tool in vim node npm git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing $tool; install it before running this installer." >&2
    exit 1
  fi
done
if ! vim -Nu NONE -n -es -c "if !has('patch-9.0.0438') | cquit 1 | endif" -c 'qa!' </dev/null; then
  echo 'coc.nvim requires Vim 9.0.0438 or newer.' >&2
  exit 1
fi
if ! node -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit(a>22||(a===22&&b>=15)?0:1)'; then
  echo 'coc.nvim requires Node.js 22.15.0 or newer.' >&2
  exit 1
fi

repo=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
source_root="$repo/config"
root="$HOME/.vim-config"
if [ ! -f "$source_root/vimrc" ] || [ ! -f "$source_root/coc-settings.json" ] || [ ! -f "$source_root/colors/gruvbox.vim" ]; then
  echo 'Incomplete checkout: config/vimrc, coc-settings.json or colors/gruvbox.vim is missing.' >&2
  exit 1
fi

mkdir -p "$root/pack/coc/start"
plugin="$root/pack/coc/start/coc.nvim"
if [ -e "$plugin" ] || [ -L "$plugin" ]; then
  if [ ! -f "$plugin/plugin/coc.vim" ]; then
    echo "Existing coc.nvim installation appears incomplete: $plugin" >&2
    exit 1
  fi
  echo "Keeping installed coc.nvim: $plugin"
else
  temporary_plugin="$root/pack/coc/start/.coc.nvim.install.$$"
  if ! git clone --depth 1 --branch release https://github.com/neoclide/coc.nvim.git "$temporary_plugin"; then
    rm -rf "$temporary_plugin"
    echo 'coc.nvim download failed; the existing Vim configuration was not replaced.' >&2
    exit 1
  fi
  mv "$temporary_plugin" "$plugin"
  echo "Installed coc.nvim: $plugin"
fi

stamp=$(date '+%Y%m%d-%H%M%S')
backup_root="$root/backups/$stamp"
index=1
while [ -e "$backup_root" ]; do
  backup_root="$root/backups/$stamp.$index"
  index=$((index + 1))
done

copy_managed() {
  from=$1
  to=$2
  backup_name=$3
  if [ -d "$to" ] && [ ! -L "$to" ]; then
    echo "Refusing to replace a directory: $to" >&2
    return 1
  fi
  if [ -f "$to" ] && [ ! -L "$to" ] && cmp -s "$from" "$to"; then
    return 0
  fi
  mkdir -p "$(dirname "$to")"
  temporary_file="$to.install.$$"
  cp "$from" "$temporary_file"
  if [ -e "$to" ] || [ -L "$to" ]; then
    backup="$backup_root/$backup_name"
    mkdir -p "$(dirname "$backup")"
    mv "$to" "$backup"
    if ! mv "$temporary_file" "$to"; then
      mv "$backup" "$to"
      return 1
    fi
    echo "Backed up previous file: $backup"
  else
    mv "$temporary_file" "$to"
  fi
  echo "Installed: $to"
}

copy_managed "$source_root/vimrc" "$HOME/.vimrc" ".vimrc"
for folder in colors extensions; do
  (cd "$source_root" && find "$folder" -type f -print) | while IFS= read -r relative; do
    copy_managed "$source_root/$relative" "$root/$relative" "$relative"
  done
done

# User-edited CoC settings survive future installs.
if [ ! -e "$root/coc-settings.json" ] && [ ! -L "$root/coc-settings.json" ]; then
  copy_managed "$source_root/coc-settings.json" "$root/coc-settings.json" "coc-settings.json"
else
  echo 'Keeping existing coc-settings.json; custom settings are preserved.'
fi

echo ''
echo 'Installed. You can now move or delete the Git checkout.'
echo 'On first Vim start, CoC installs coc-clangd and coc-pyright (internet required).'
echo 'In Vim run :CocInfo to check completion and language servers.'
