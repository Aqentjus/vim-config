" Use Vim defaults even when this file is selected explicitly with -u.
set nocompatible

" Silence Vim bells, including invalid cursor movements, and prevent screen flashes.
set belloff=all
set noerrorbells
set visualbell
set t_vb=

" Requires a full Vim build with syntax support and the bundled netrw explorer.
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

" Explorer: always visible from startup. Space+e only changes keyboard focus.
" Enter keeps netrw's normal open behavior.
let mapleader = ' '
nnoremap <Space> <Nop>
let g:netrw_winsize = 25
filetype plugin on

" Open the sidebar once at startup and keep focus on the editing window.
" Passing an explicit directory ensures 'vim path/to/file' browses that folder.
function! s:OpenExplorerOnStart() abort
  let l:file = expand('%:p')
  if empty(expand('%'))
    let l:directory = getcwd()
  elseif isdirectory(l:file)
    let l:directory = l:file
  else
    let l:directory = fnamemodify(l:file, ':h')
  endif

  let l:editor_window = win_getid()
  execute 'Lexplore ' . fnameescape(l:directory)
  if win_id2win(l:editor_window) > 0
    call win_gotoid(l:editor_window)
  endif
endfunction

function! s:FocusExplorer() abort
  for window in range(1, winnr('$'))
    if getbufvar(winbufnr(window), '&filetype') ==# 'netrw'
      execute window . 'wincmd w'
      return
    endif
  endfor
  echo 'Explorer is not open. Use :Lexplore to open it.'
endfunction

function! s:CreateEntry() abort
  let directory = get(b:, 'netrw_curdir', '')
  if !isdirectory(directory)
    echo 'Browse a local directory before creating an entry.'
    return
  endif

  let entry = input('New file or /folder: ')
  redraw
  if empty(entry)
    return
  endif

  let is_directory = entry[0] ==# '/'
  let name = is_directory ? strpart(entry, 1) : entry
  if empty(name) || index(['.', '..'], name) >= 0 || name =~# '[/\\]'
    echo 'Use a single file name or /folder name in the directory shown.'
    return
  endif

  let path = directory . '/' . name
  if getftype(path) !=# ''
    echo 'Already exists: ' . name
    return
  endif

  try
    if is_directory
      call mkdir(path)
    else
      " Empty append creates a file without truncating an existing one.
      call writefile([], path, 'a')
    endif
  catch /^Vim/
    echo 'Could not create entry: ' . v:exception
    return
  endtry

  " Use netrw's own refresh mapping and keep focus in the explorer.
  execute "normal \<C-L>"
endfunction

nnoremap <silent> <leader>e :<C-U>call <SID>FocusExplorer()<CR>
augroup VimConfigExplorer
  autocmd!
  autocmd VimEnter * call <SID>OpenExplorerOnStart()
  autocmd FileType netrw nnoremap <silent> <buffer> <leader>n :<C-U>call <SID>CreateEntry()<CR>
augroup END
