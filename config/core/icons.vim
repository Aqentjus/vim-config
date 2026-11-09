" Optional signs decorate netrw without editing its filename text.
" Set g:vim_config_icons to 'unicode' or 'nerd' in local.vim; default is 'off'.
function! VimConfigTreeIcons() abort
  if &filetype !=# 'netrw' || !exists('*sign_place') | return | endif
  let l:mode = get(g:, 'vim_config_icons', 'off')
  let l:state = [b:changedtick, l:mode, get(b:, 'netrw_liststyle', -1)]
  if get(b:, 'vim_config_icon_state', []) ==# l:state | return | endif
  let b:vim_config_icon_state = l:state
  call sign_unplace('VimConfigTree', {'buffer': bufnr('%')})
  " Wide/long listings do not have one filename per line.
  if index(['unicode', 'nerd'], l:mode) < 0 || &encoding !=# 'utf-8'
        \ || index([0, 3], get(b:, 'netrw_liststyle', 3)) < 0
    setlocal signcolumn=auto
    return
  endif
  let l:icons = l:mode ==# 'nerd'
        \ ? {'Folder': '', 'File': '', 'Code': '', 'Config': '', 'Image': ''}
        \ : {'Folder': '▸', 'File': '·', 'Code': 'λ', 'Config': '⚙', 'Image': '◇'}
  for [l:kind, l:icon] in items(l:icons)
    if strdisplaywidth(l:icon) > 2 | let l:icon = '*' | endif
    call sign_define('VimConfig' . l:kind, {'text': l:icon,
          \ 'texthl': l:kind ==# 'Folder' ? 'Directory' : 'Special'})
  endfor
  setlocal signcolumn=yes
  let l:line = 0
  for l:text in getline(1, '$')
    let l:line += 1
    if empty(l:text) || l:text =~# '^"' | continue | endif
    let l:name = substitute(l:text, '^\%([-+|│] \)\+', '', '')
    let l:kind = 'File'
    if l:name =~# '/$'
      let l:kind = 'Folder'
    elseif l:name =~? '\.\%(py\|c\|h\|cpp\|hpp\|js\|ts\|lua\|vim\|sh\|ps1\|go\|rs\)\*\?$'
      let l:kind = 'Code'
    elseif l:name =~? '\.\%(json\|yaml\|yml\|toml\|ini\|conf\)\*\?$'
      let l:kind = 'Config'
    elseif l:name =~? '\.\%(png\|jpg\|jpeg\|gif\|svg\)\*\?$'
      let l:kind = 'Image'
    endif
    call sign_place(l:line, 'VimConfigTree', 'VimConfig' . l:kind, bufnr('%'), {'lnum': l:line})
  endfor
endfunction

function! s:SetIcons(mode) abort
  if index(['off', 'unicode', 'nerd'], a:mode) < 0
    echo 'Use :TreeIcons off, unicode or nerd.'
    return
  endif
  let g:vim_config_icons = a:mode
  call VimConfigTreeIcons()
endfunction
command! -nargs=1 TreeIcons call <SID>SetIcons(<q-args>)
augroup VimConfigTreeIcons
  autocmd!
  autocmd FileType netrw call VimConfigTreeIcons()
  autocmd BufEnter,TextChanged,CursorMoved * if &filetype ==# 'netrw' | call VimConfigTreeIcons() | endif
augroup END
