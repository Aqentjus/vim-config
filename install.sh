#!/bin/sh
# Base install: Vim and standard shell utilities. No network or development tools.
set -eu
with_coc=0
check=0
dry_run=0
for arg in "$@"; do
  case "$arg" in
    --with-coc) with_coc=1 ;;
    --check) check=1 ;;
    --dry-run) dry_run=1 ;;
    --help|-h) echo 'Usage: sh install.sh [--with-coc] [--check|--dry-run]'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done
: "${HOME:?HOME is not set}"
command -v vim >/dev/null 2>&1 || { echo 'Install your system Vim package first.' >&2; exit 1; }
repo=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
source_root="$repo/config"
root="$HOME/.vim-config"
for file in vimrc core/options.vim core/theme.vim core/explorer.vim core/icons.vim core/search.vim core/clipboard.vim core/terminal.vim core/runner.vim core/completion.vim core/help.vim core/doctor.vim core/extensions.vim colors/kanagawa-dragon.vim local.vim.example coc-settings.json; do
  [ -f "$source_root/$file" ] || { echo "Incomplete checkout: config/$file is missing." >&2; exit 1; }
done
echo "Vim: $(command -v vim)"
echo "Config: $root"
if [ "$with_coc" -eq 1 ]; then
  for tool in node npm git; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Optional CoC needs $tool on PATH." >&2; exit 1; }
  done
  if ! vim -Nu NONE -i NONE -n -es -c "if !has('patch-9.0.0438') | cquit 1 | endif" -c 'qa!' </dev/null; then
    echo 'Optional CoC needs Vim 9.0.0438+. Omit --with-coc for the basic editor.' >&2; exit 1
  fi
  if ! node -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit(a>22||(a===22&&b>=15)?0:1)'; then
    echo 'Optional CoC needs Node 22.15+. Omit --with-coc for the basic editor.' >&2; exit 1
  fi
else
  echo 'Basic install: no Node, npm, Git, Python, compiler or downloads required.'
fi
if [ "$check" -eq 1 ]; then echo 'Check complete; nothing changed.'; exit 0; fi
if [ "$dry_run" -eq 1 ]; then
  echo "Would copy config modules/themes/extensions to $root and loader to $HOME/.vimrc."
  echo 'Changed files would be backed up; local.vim and coc-settings.json preserved.'
  if [ "$with_coc" -eq 1 ]; then echo 'Would install/enable optional CoC; no language extensions selected.'; fi
  exit 0
fi
for directory in "$root" "$root/core" "$root/colors" "$root/extensions"; do
  [ ! -L "$directory" ] || { echo "Use a real configuration directory: $directory" >&2; exit 1; }
done
if [ "$with_coc" -eq 1 ]; then
  plugin="$root/pack/coc/opt/coc.nvim"
  if [ -f "$root/pack/coc/start/coc.nvim/plugin/coc.vim" ]; then plugin="$root/pack/coc/start/coc.nvim"; fi
  if [ -e "$plugin" ]; then
    [ -f "$plugin/plugin/coc.vim" ] || { echo "Incomplete CoC installation: $plugin" >&2; exit 1; }
    echo "Keeping installed CoC: $plugin"
  else
    mkdir -p "$(dirname "$plugin")"
    temporary_plugin="$plugin.install.$$"
    if ! git clone --depth 1 --branch release https://github.com/neoclide/coc.nvim.git "$temporary_plugin"; then
      rm -rf "$temporary_plugin"
      echo 'CoC download failed; configuration was not replaced.' >&2; exit 1
    fi
    mv "$temporary_plugin" "$plugin"
  fi
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

# Install modules before switching the loader to the new layout.
for folder in core colors extensions; do
  (cd "$source_root" && find "$folder" -type f ! -name '*.pyc' ! -path '*/__pycache__/*' -print) | while IFS= read -r relative; do
    copy_managed "$source_root/$relative" "$root/$relative" "$relative"
  done
done
copy_managed "$source_root/vimrc" "$HOME/.vimrc" '.vimrc'
for file in coc-settings.json local.vim; do
  if [ ! -e "$root/$file" ] && [ ! -L "$root/$file" ]; then
    source_name=$file
    if [ "$file" = local.vim ]; then source_name=local.vim.example; fi
    copy_managed "$source_root/$source_name" "$root/$file" "$file"
  else
    echo "Keeping personal $file"
  fi
done
if [ "$with_coc" -eq 1 ]; then
  : > "$root/completion-enabled"
  echo 'CoC enabled. Choose languages explicitly with :CocInstall extension-name.'
fi
echo 'Installed. The checkout can be moved/deleted. Space h: help; :ConfigDoctor: optional tools.'
