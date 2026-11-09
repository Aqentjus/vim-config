function! VimConfigHelpBuffer(name, lines) abort
  tabnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal nowrap nonumber norelativenumber
  execute 'file ' . a:name
  call setline(1, a:lines)
  setlocal nomodified nomodifiable
  nnoremap <silent> <buffer> q :tabclose<CR>
  normal! gg
endfunction

function! s:Keys() abort
  let l:lines = ['VIM — QUICK HELP', '',
        \ 'Space e           Focus file explorer',
        \ 'Space n           Create file or /folder in explorer',
        \ 'Enter             Open file / expand folder in explorer',
        \ ':TreeIcons MODE   off / unicode / nerd (Nerd Font in your terminal)',
        \ 'Space f / s       Find file / search text from current directory',
        \ 'Space c           Clear search highlighting',
        \ 'Space t           Open shell / stop and close this tab''s task',
        \ 'Space r           Save and run current file (:RunCode)',
        \ 'Ctrl-w N          Leave terminal input mode',
        \ 'Space y           Copy line / visual selection to system clipboard',
        \ 'Space Y           Copy whole file without moving the cursor',
        \ 'Space p / P       Paste after / before; Visual: replace, keep clipboard',
        \ ':ClipboardHealth  Show available clipboard backend',
        \ 'Ctrl-n / Ctrl-p   Native word completion (no plugin needed)',
        \ 'Space h / ?       This help (:Keys); plain Space never opens a popup',
        \ ':ConfigDoctor     Optional feature/tool report',
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
        \ '', 'OPTIONAL COMPLETION',
        \ get(g:, 'vim_config_completion_status', 'off'),
        \ 'When enabled: Tab/Shift-Tab, Enter, gd/gr, K, [d/]d, Space R',
        \ ':CocInstall NAME  Explicitly install a chosen language extension',
        \ '', 'Personal settings: ' . g:vim_config_home . '/local.vim']
  for l:extra in values(get(g:, 'vim_config_extension_help', {}))
    call extend(l:lines, l:extra)
  endfor
  call extend(l:lines, ['', 'Press q to close. :help opens Vim''s own documentation.'])
  call VimConfigHelpBuffer('Keys', l:lines)
endfunction
command! Keys call <SID>Keys()
nnoremap <silent> <leader>h :<C-U>Keys<CR>
nnoremap <silent> <leader>? :<C-U>Keys<CR>
