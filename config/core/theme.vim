set background=dark
syntax enable

" Match the tested Mac Terminal colours even when COLORTERM is unset.
" Other platforms use their advertised true-colour capabilities.
if has('termguicolors') && (has('macunix') || has('vcon') || $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  set termguicolors
endif

let s:theme_supported = has('gui_running') || &t_Co == 256 || (has('termguicolors') && &termguicolors)
" Gruvbox keeps the darker #181616 background used by the earlier Kanagawa theme.
function! s:GruvboxBackground() abort
  if &background ==# 'dark'
    highlight Normal guibg=#181616 ctermbg=233
    highlight VertSplit guibg=#181616 ctermbg=233
  endif
endfunction
augroup VimConfigTheme
  autocmd!
  autocmd ColorScheme gruvbox call s:GruvboxBackground()
augroup END

if filereadable(g:vim_config_home . '/colors/gruvbox.vim') && s:theme_supported
  colorscheme gruvbox
else
  " The editor remains usable in terminals with insufficient colour support.
  colorscheme default
endif
