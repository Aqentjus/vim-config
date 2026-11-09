" Completion is optional; no extension downloads are requested at startup.
function! VimConfigCompletionSetup() abort
  let g:vim_config_completion_status = 'off (native Vim completion is available)'
  if !get(g:, 'vim_config_completion', filereadable(g:vim_config_home . '/completion-enabled'))
    return
  endif
  if !has('patch-9.0.0438') || !executable('node')
    let g:vim_config_completion_status = 'unavailable: CoC needs Vim 9.0.0438+ and Node 22.15+'
    return
  endif
  let l:version = system('node -p "process.versions.node"')
  let l:parts = split(l:version, '\.')
  if v:shell_error || len(l:parts) < 2 || str2nr(l:parts[0]) < 22 || (str2nr(l:parts[0]) == 22 && str2nr(l:parts[1]) < 15)
    let g:vim_config_completion_status = 'unavailable: CoC needs Node 22.15+'
    return
  endif
  let l:plugin = g:vim_config_home . '/pack/coc/opt/coc.nvim'
  if !filereadable(l:plugin . '/plugin/coc.vim')
    let l:plugin = g:vim_config_home . '/pack/coc/start/coc.nvim'
  endif
  if !filereadable(l:plugin . '/plugin/coc.vim')
    let g:vim_config_completion_status = 'not installed: rerun installer with --with-coc (Windows: -WithCoc)'
    return
  endif
  let g:coc_config_home = g:vim_config_home
  let g:coc_data_home = g:vim_config_home . '/coc-data'
  let g:coc_global_extensions = []
  let &runtimepath = escape(l:plugin, ',') . ',' . &runtimepath
  execute 'source ' . fnameescape(l:plugin . '/plugin/coc.vim')
  let g:vim_config_completion_status = 'enabled; install only desired languages with :CocInstall'
  set updatetime=300
  set signcolumn=yes

  function! s:CompletionBackspace() abort
    let l:col = col('.') - 1
    return !l:col || getline('.')[l:col - 1] =~# '\s'
  endfunction

  " Respect personal mappings from local.vim.
  if empty(maparg('<Tab>', 'i'))
    inoremap <silent><expr> <Tab> coc#pum#visible()
          \ ? coc#pum#next(1)
          \ : <SID>CompletionBackspace() ? "\<Tab>" : coc#refresh()
  endif
  if empty(maparg('<S-Tab>', 'i'))
    inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  endif
  if empty(maparg('<CR>', 'i'))
    inoremap <silent><expr> <CR> coc#pum#visible()
          \ ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  endif
  for [l:key, l:action] in items({'gd': 'definition', 'gr': 'references', '[d': 'diagnostic-prev', ']d': 'diagnostic-next', g:mapleader . 'R': 'rename'})
    if empty(maparg(l:key, 'n'))
      execute 'nmap <silent> ' . substitute(l:key, ' ', '<Space>', 'g') . ' <Plug>(coc-' . l:action . ')'
    endif
  endfor
  if empty(maparg('K', 'n'))
    nnoremap <silent> K :call CocActionAsync('doHover')<CR>
  endif

endfunction
