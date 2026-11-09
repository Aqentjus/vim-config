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
    execute 'silent vimgrep /\V' . escape(l:query, '/\') . '/gj **/*'
    copen
  catch /^Vim\%((\a\+)\)\=:E480/
    echo 'No matching files or text found.'
  catch /^Vim/
    echo 'Search failed: ' . v:exception
  endtry
endfunction
nnoremap <silent> <leader>s :<C-U>call <SID>SearchProject()<CR>
