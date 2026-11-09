" Silence Vim bells, including invalid cursor movements, and prevent screen flashes.
set belloff=all
set noerrorbells
set visualbell
set t_vb=

" Editing: absolute line numbers and predictable two-space indents.
" Python uses its conventional four spaces.
set number
set autoindent expandtab
set tabstop=2 shiftwidth=2 softtabstop=2


let mapleader = ' '
nnoremap <Space> <Nop>
set mouse=a
set selectmode=
set mousemodel=extend
filetype plugin indent on
augroup VimConfigEditing
  autocmd!
  autocmd FileType netrw setlocal nonumber norelativenumber
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  if exists('##TerminalWinOpen')
    autocmd TerminalWinOpen * setlocal nonumber norelativenumber
  endif
augroup END
