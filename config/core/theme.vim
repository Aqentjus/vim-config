set background=dark
syntax enable

" Match the tested Mac Terminal colours even when COLORTERM is unset.
" Other platforms use their advertised true-colour capabilities.
if has('termguicolors') && (has('macunix') || has('vcon') || $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  set termguicolors
endif

let s:theme_supported = has('gui_running') || &t_Co == 256 || (has('termguicolors') && &termguicolors)
if filereadable(g:vim_config_home . '/colors/kanagawa-dragon.vim') && s:theme_supported
  colorscheme kanagawa-dragon
else
  " The editor remains usable in terminals with insufficient colour support.
  colorscheme default
endif
