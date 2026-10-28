" Use Vim defaults even when this file is selected explicitly with -u.
set nocompatible

" Theme only. Requires a full Vim build with syntax support.
" Resolve this file's location so `vim -u /path/to/vimrc` finds our colour file.
let s:config_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let &runtimepath = escape(s:config_dir, ',') . ',' . &runtimepath

set background=dark
syntax enable
let g:gruvbox_contrast_dark = 'medium'

" Use exact colours when Vim detects a working Windows virtual console,
" or the terminal advertises true-colour support.
" Otherwise keep Vim's existing setting and use Gruvbox's 256-colour palette.
if has('termguicolors') && (has('vcon') || $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  set termguicolors
endif

let s:theme_supported = has('gui_running') || &t_Co == 256 || (has('termguicolors') && &termguicolors)
if filereadable(s:config_dir . '/colors/gruvbox.vim') && s:theme_supported
  colorscheme gruvbox
else
  " Keep editing usable if the colour file or terminal capabilities are missing.
  colorscheme default
endif
