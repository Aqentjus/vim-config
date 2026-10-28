" Use Vim defaults even when this file is selected explicitly with -u.
set nocompatible

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
filetype plugin indent on

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

" Runner: save one file, select a command, show it in a new bottom terminal.
" C/C++ use a temporary executable, never an existing project binary.
function! s:RunnerFinished(output, job, status) abort
  if !empty(a:output)
    call delete(a:output)
  endif
  echom 'Runner: process exited with code ' . a:status
endfunction

function! s:CodeRunner() abort
  if !has('terminal')
    echo 'Runner: this Vim needs +terminal support.'
    return
  endif
  if &buftype !=# '' || empty(expand('%'))
    echo 'Runner: open a named source file first.'
    return
  endif

  let l:file = expand('%:p')
  let l:extension = expand('%:e')
  let l:windows = has('win32') || has('win64')
  let l:args = []
  let l:output = ''
  let l:env = {}
  let l:compiled = index(['c', 'cpp', 'cc', 'cxx', 'C'], l:extension) >= 0

  if l:extension ==# 'py'
    if !empty($VIRTUAL_ENV) && executable($VIRTUAL_ENV . (l:windows ? '/Scripts/python.exe' : '/bin/python'))
      let l:tools = [$VIRTUAL_ENV . (l:windows ? '/Scripts/python.exe' : '/bin/python')]
    elseif l:windows && executable('py')
      let l:tools = ['py']
      let l:args = ['-3']
    else
      let l:tools = ['python3', 'python']
    endif
  elseif l:compiled
    let l:tools = l:extension ==# 'c' ? ['cc', 'gcc', 'clang'] : ['c++', 'g++', 'clang++']
  elseif l:extension ==# 'js'
    let l:tools = ['node']
  elseif l:extension ==# 'sh'
    let l:tools = ['bash']
  else
    echo 'Runner: supported files are .py, .c, .cpp/.cc/.cxx/.C, .js and .sh.'
    return
  endif

  let l:tool = ''
  for l:candidate in l:tools
    if executable(l:candidate)
      let l:tool = exepath(l:candidate)
      break
    endif
  endfor
  if empty(l:tool)
    echo 'Runner: install a matching tool and put it on PATH: ' . join(l:tools, ', ')
    return
  endif

  " A save failure aborts here: do not run stale code from disk.
  update
  if !filereadable(l:file)
    echo 'Runner: save this file before running it.'
    return
  endif

  if l:compiled
    let l:output = tempname() . (l:windows ? '.exe' : '')
    let l:standard = l:extension ==# 'c' ? 'c17' : 'c++17'
    let l:env = {'VIM_RUN_COMPILER': l:tool, 'VIM_RUN_SOURCE': l:file, 'VIM_RUN_OUTPUT': l:output}
    " Pass paths through quoted environment variables, not shell source text.
    " && runs the new executable only if compilation succeeds.
    if l:windows
      let l:shell = empty($COMSPEC) ? exepath('cmd.exe') : $COMSPEC
      let l:command = '"' . l:shell . '" /d /v:off /s /c ""%VIM_RUN_COMPILER%" -std=' . l:standard . ' -Wall -Wextra "%VIM_RUN_SOURCE%" -o "%VIM_RUN_OUTPUT%" && "%VIM_RUN_OUTPUT%""'
    else
      let l:command = ['/bin/sh', '-c', '"$VIM_RUN_COMPILER" -std=' . l:standard . ' -Wall -Wextra "$VIM_RUN_SOURCE" -o "$VIM_RUN_OUTPUT" && exec "$VIM_RUN_OUTPUT"']
    endif
  else
    " An argument list preserves spaces and bypasses shell interpretation.
    let l:command = [l:tool] + l:args + [l:file]
  endif

  " No auto-close option: the default keeps output visible, including on Vim 9.1.
  botright 12new
  call term_start(l:command, {'curwin': 1, 'cwd': fnamemodify(l:file, ':h'),
        \ 'env': l:env, 'term_name': 'Run: ' . fnamemodify(l:file, ':t'),
        \ 'exit_cb': function('s:RunnerFinished', [l:output])})
endfunction

nnoremap <silent> <leader>r :<C-U>call <SID>CodeRunner()<CR>

" Disable line numbers for navigation and terminal buffers.
augroup VimConfigEditing
  autocmd!
  autocmd FileType netrw setlocal nonumber norelativenumber
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd TermOpen * setlocal nonumber norelativenumber
augroup END

" Search: ordinary /, n, N for this file, plus one built-in project search.
set incsearch hlsearch ignorecase smartcase
set path+=**
nnoremap <leader>f :find<Space>
nnoremap <silent> <leader>c :nohlsearch<CR>

function! s:SearchProject() abort
  let l:query = input('Search recursively from current directory: ')
  redraw
  if empty(l:query)
    return
  endif
  " Very nomagic treats the user's query as literal text.
  try
    execute 'silent vimgrep /\V' . escape(l:query, '/\') . '/gj **/*
    copen
  catch /^Vim\%((\a\+)\)\=:E480/
    echo 'No matching files or text found.'
  catch /^Vim/
    echo 'Search failed: ' . v:exception
  endtry
endfunction
nnoremap <silent> <leader>s :<C-U>call <SID>SearchProject()<CR>

" Completion: no language server, no plugin. Tab offers words from buffers.
" Python gets a compact curated list of common built-in calls (including print()).
let s:python_calls = [
      \ 'print()', 'input()', 'range()', 'len()', 'enumerate()',
      \ 'int()', 'float()', 'str()', 'list()', 'dict()', 'set()',
      \ 'tuple()', 'type()', 'isinstance()', 'open()', 'sum()',
      \ 'min()', 'max()', 'sorted()', 'zip()', 'map()', 'filter()',
      \ 'abs()', 'all()', 'any()', 'bool()', 'dir()', 'help()',
      \ 'super()', 'repr()', 'round()', 'next()', 'iter()'
      \ ]

function! s:PythonComplete(findstart, base) abort
  if a:findstart
    let l:start = col('.') - 1
    let l:line = getline('.')
    while l:start > 0 && l:line[l:start - 1] =~# '\k'
      let l:start -= 1
    endwhile
    return l:start
  endif
  return filter(copy(s:python_calls), 'stridx(v:val, a:base) == 0')
endfunction

augroup VimConfigCompletion
  autocmd!
  autocmd FileType python let &l:completefunc = expand('<SID>') . 'PythonComplete'
augroup END

set completeopt=menuone,noinsert
function! s:SmartTab() abort
  if pumvisible()
    return "\<C-n>"
  endif
  let l:before = strpart(getline('.'), 0, col('.') - 1)
  let l:prefix = matchstr(l:before, '\k\+$')
  if empty(l:prefix)
    return "\<Tab>"
  endif
  if &filetype ==# 'python' && !empty(filter(copy(s:python_calls), 'stridx(v:val, l:prefix) == 0'))
    return "\<C-x>\<C-u>"
  endif
  return "\<C-n>"
endfunction
inoremap <expr> <Tab> <SID>SmartTab()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" Self-contained cheat sheet. Native :help is untouched.
function! s:ShowQuickHelp() abort
  tabnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal modifiable nowrap nonumber norelativenumber
  let l:lines = [
        \ 'VIM CONFIGURATION - QUICK HELP',
        \ '==============================================',
        \ '',
        \ 'KEY OR COMMAND         MODE          ACTION',
        \ '----------------------------------------------',
        \ 'Space e                Normal        Focus left explorer',
        \ 'Space n                Explorer      Create file or /folder',
        \ 'Enter                  Explorer      Open file or directory',
        \ 'Space r                Normal        Save and run source file',
        \ 'Space f                Normal        Find file by name (:find)',
        \ 'Space s                Normal        Search text under Vim cwd',
        \ 'Space c                Normal        Clear search highlight',
        \ 'Space h                Normal        Show this page',
        \ 'Tab                    Insert        Suggest word or indent',
        \ 'Tab / Shift+Tab        Completion    Next/previous suggestion',
        \ 'Enter                  Completion    Accept suggestion',
        \ 'Ctrl+E                 Completion    Cancel suggestions',
        \ '/text / ?text          Normal        Search forward / backward',
        \ 'n / N                  Normal        Next / previous match',
        \ ':cnext / :cprev        Command       Next / previous search result',
        \ ':copen / :cclose      Command       Show / hide search results',
        \ 'Ctrl+W, W              Normal        Next window',
        \ 'Ctrl+W, N              Terminal      Leave terminal input mode',
        \ ':pwd / :cd {path}       Command       Check / change working directory',
        \ ':Lexplore               Command       Toggle explorer manually',
        \ ':w / :q / :wq         Command       Save / quit / save and quit',
        \ ':Keys                  Command       Show this page',
        \ ':terminal               Command       Start built-in terminal',
        \ ':help {topic}          Command       Vim built-in documentation',
        \ '',
        \ 'C / C++: single file only. Python: selected common built-ins + buffer words.',
        \ 'Search from :pwd; :cd {directory} changes the search root.',
        \ 'Press q to close this help tab.'
        \ ]
  call setline(1, l:lines)
  setlocal nomodified nomodifiable
  nnoremap <silent> <buffer> q :tabclose<CR>
  normal! gg
endfunction
command! Keys call <SID>ShowQuickHelp()
nnoremap <silent> <leader>h :<C-U>Keys<CR>
