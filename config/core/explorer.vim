" Explorer: always visible from startup. Space+e only changes keyboard focus.
" Enter keeps netrw's normal open behavior.
let g:netrw_winsize = 25
" Built-in explorer: compact expandable tree without a plugin manager.
let g:netrw_liststyle = 3
let g:netrw_banner = 0
" Use netrw's designated editing window, not its current explorer window.
let g:netrw_browse_split = 0

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
  " Remember the actual editor window for netrw's Enter action.
  " This avoids relying on netrw's possibly stale/default window number.
  let l:editor_nr = win_id2win(l:editor_window)
  if l:editor_nr > 0
    let g:netrw_chgwin = l:editor_nr
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

" Use netrw's mapping API so expanded ancestors and names with spaces resolve
" exactly as they do for Enter. Preserve the user's view and search pattern.
function! s:CreationDirectory() abort
  let l:directory = get(b:, 'netrw_curdir', '')
  if !isdirectory(l:directory)
    return ''
  endif
  let l:view = winsaveview()
  let l:search = @/
  try
    let l:name = netrw#Call('NetrwGetWord')
    if l:name ==# '../'
      return fnamemodify(l:directory, ':h')
    endif
    if get(w:, 'netrw_liststyle', g:netrw_liststyle) == 3 && exists('w:netrw_treetop')
      " TreePath returns a directory for ordinary files and a path for links.
      let l:path = netrw#Call('NetrwTreePath', w:netrw_treetop)
    else
      let l:path = l:directory . '/' . substitute(l:name, '[/@*=|]$', '', '')
    endif
    return isdirectory(l:path) ? l:path : fnamemodify(l:path, ':h')
  finally
    call winrestview(l:view)
    let @/ = l:search
  endtry
endfunction

function! s:CreateEntry() abort
  let directory = s:CreationDirectory()
  if !isdirectory(directory)
    echo 'Browse a local directory before creating an entry.'
    return
  endif

  let entry = input('New file or /folder in ' . directory . ': ')
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

  " In tree mode Ctrl-L can move netrw into the editor window.
  " Refresh the existing tree buffer without changing its destination.
  call netrw#LocalBrowseCheck(b:netrw_curdir)
endfunction

nnoremap <silent> <leader>e :<C-U>call <SID>FocusExplorer()<CR>
augroup VimConfigExplorer
  autocmd!
  autocmd VimEnter * call <SID>OpenExplorerOnStart()
  autocmd FileType netrw nnoremap <silent> <buffer> <leader>n :<C-U>call <SID>CreateEntry()<CR>
augroup END
