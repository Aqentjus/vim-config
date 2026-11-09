function! VimConfigHelpBuffer(name, lines) abort
  tabnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal nowrap nonumber norelativenumber nocursorline
  execute 'file ' . a:name
  call setline(1, a:lines)
  setlocal nomodified nomodifiable
  nnoremap <silent> <buffer> q :tabclose<CR>
  normal! gg
endfunction

" Match actions, not keys: a personal override must never keep an old label.
let s:descriptions = {
      \ ':<C-U>call FocusExplorer()<CR>': 'Focus file explorer',
      \ ':<C-U>call CreateEntry()<CR>': 'Create inside folder / beside file',
      \ ':find<Space>': 'Find file from current directory',
      \ ':<C-U>call SearchProject()<CR>': 'Search text from current directory',
      \ ':nohlsearch<CR>': 'Clear search highlighting',
      \ ':<C-U>call ToggleTerminal()<CR>': 'Open shell / stop this tab''s task',
      \ '<C-W>N:call ToggleTerminal()<CR>': 'Stop this tab''s task',
      \ ':<C-U>call CodeRunner()<CR>': 'Save and run current file',
      \ 'yy:<C-U>call ClipboardCopy()<CR>': 'Copy line to system clipboard',
      \ 'y:<C-U>call ClipboardCopy()<CR>': 'Copy selection to system clipboard',
      \ ':<C-U>call CopyAll()<CR>': 'Copy whole file without moving cursor',
      \ ':<C-U>call ClipboardPaste(0, 0)<CR>': 'Paste after cursor',
      \ ':<C-U>call ClipboardPaste(0, 1)<CR>': 'Paste before cursor',
      \ ':<C-U>call ClipboardPaste(1, 0)<CR>': 'Replace selection, keep clipboard',
      \ ':<C-U>call ClipboardPaste(1, 1)<CR>': 'Replace selection, keep clipboard',
      \ ':<C-U>Keys<CR>': 'Open this help',
      \ '<Plug>(coc-rename)': 'Rename symbol (CoC)',
      \ }
let s:original_leader = get(g:, 'mapleader', '\')

function! s:MappingKeys(mode) abort
  if exists('*maplist')
    return map(maplist(), 'v:val.lhs')
  endif
  " Older system Vims predate maplist(). :map and maparg() are sufficient.
  let l:keys = []
  for l:line in split(execute(a:mode . 'map'), "\n")
    let l:lhs = matchstr(l:line, '^.\{3}\s*\zs\S\+')
    if !empty(l:lhs)
      call add(l:keys, l:lhs)
    endif
  endfor
  return l:keys
endfunction

function! s:LeaderMappings() abort
  let l:lines = []
  let l:leaders = [s:original_leader, get(g:, 'mapleader', '\')]
  for [l:mode, l:title] in [['n', 'Normal'], ['x', 'Visual'], ['i', 'Insert'], ['t', 'Terminal']]
    if l:mode ==# 't' && !has('terminal') | continue | endif
    let l:rows = []
    for l:key in uniq(sort(s:MappingKeys(l:mode)))
      let l:plain = substitute(l:key, '<Space>', ' ', 'g')
      if empty(filter(copy(l:leaders), 'stridx(l:plain, v:val) == 0 && l:plain !=# v:val'))
        continue
      endif
      " maparg resolves a buffer-local override before a global mapping.
      let l:mapping = maparg(l:key, l:mode, 0, 1)
      if empty(l:mapping) | continue | endif
      let l:rhs = l:mapping.rhs
      let l:action = substitute(l:rhs, '<SNR>\d\+_', '', 'g')
      let l:description = get(s:descriptions, l:action, l:rhs)
      let l:label = substitute(l:key, '<Space>', 'Space ', 'g')
      let l:label = substitute(l:label, '^ ', 'Space ', '')
      call add(l:rows, printf('  %-18s %s%s', l:label, l:description,
            \ get(l:mapping, 'buffer', 0) ? ' [buffer]' : ''))
    endfor
    if !empty(l:rows)
      call extend(l:lines, [l:title . ' mode:'] + l:rows + [''])
    endif
  endfor
  return l:lines
endfunction

function! s:Keys() abort
  " Collect before opening the help tab, while buffer-local mappings apply.
  let l:lines = ['VIM — QUICK HELP', '', 'CURRENT LEADER SHORTCUTS',
        \ 'Personal mappings and buffer overrides are included.', '']
  call extend(l:lines, s:LeaderMappings())
  call extend(l:lines, ['EXPLORER',
        \ 'Enter             Open file / expand folder',
        \ 'Creation          Inside selected folder / beside selected file',
        \ '                  The prompt shows the destination directory.',
        \ 'Open help from the explorer to see its buffer shortcuts.',
        \ ':TreeIcons MODE   off / unicode / nerd (Nerd Font in your terminal)',
        \ '', 'EVERYDAY EDITING',
        \ ':w / :q / :wq     Save / quit / save and quit',
        \ '/text, n / N      Search, next / previous match',
        \ 'u / Ctrl-r        Undo / redo',
        \ 'v / V             Select characters / whole lines',
        \ 'yy / dd / p       Yank line / delete line / paste',
        \ 'gg / G / :30      First line / last line / line 30',
        \ 'Ctrl-w w          Next window',
        \ ':cnext / :cprev   Next / previous project search result',
        \ ':pwd / :cd PATH   Show / change search working directory',
        \ 'Ctrl-n / Ctrl-p   Native word completion (no plugin needed)',
        \ ':ClipboardHealth  Show available clipboard backend',
        \ ':ConfigDoctor     Optional feature/tool report',
        \ '', 'OPTIONAL FEATURES',
        \ 'Tree icons: ' . get(g:, 'vim_config_icons', 'nerd'),
        \ 'Terminal: ' . (has('terminal') ? 'available; Ctrl-w N leaves terminal input' : 'unavailable in this Vim build'),
        \ 'Completion: ' . get(g:, 'vim_config_completion_status', 'off')])
  if get(g:, 'vim_config_completion_status', '') =~# '^enabled'
    call extend(l:lines, ['CoC mappings (personal overrides take precedence):'])
    for [l:mode, l:keys] in [['i', ['<Tab>', '<S-Tab>', '<CR>']], ['n', ['gd', 'gr', 'K', '[d', ']d']]]
      for l:key in l:keys
        let l:rhs = maparg(l:key, l:mode)
        if !empty(l:rhs)
          call add(l:lines, '  ' . l:key . ' → ' . l:rhs)
        endif
      endfor
    endfor
    call add(l:lines, ':CocInstall NAME  Explicitly install a chosen language extension')
  endif
  for l:name in sort(keys(get(g:, 'vim_config_extension_help', {})))
    call extend(l:lines, g:vim_config_extension_help[l:name])
  endfor
  call extend(l:lines, ['', 'Personal settings: ' . g:vim_config_home . '/local.vim',
        \ 'Help opens explicitly with :Keys; plain Space never opens a popup.',
        \ 'Press q to close. :help opens Vim''s own documentation.'])
  call VimConfigHelpBuffer('Keys', l:lines)
endfunction
command! Keys call <SID>Keys()
nnoremap <silent> <leader>h :<C-U>Keys<CR>
nnoremap <silent> <leader>? :<C-U>Keys<CR>
