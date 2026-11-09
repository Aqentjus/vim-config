" Custom Kanagawa Dragon for Vim: Dragon UI + Justus' brighter syntax palette.
" Ported from Aqentjus/nvim-config config/lua/plugins/theme.lua.
" Kanagawa palette/highlights: Copyright (c) 2021 Tommaso Laurenzi (MIT).
" See THIRD_PARTY_NOTICES.md for attribution and the full license.
" Bundled Vimscript only; no plugins, parsers, downloads or Lua required.
" GUI/true-color values and precomputed xterm-256 approximations.

set background=dark
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'kanagawa-dragon'

highlight Normal guifg=#E5E8E5 guibg=#181616 gui=NONE ctermfg=254 ctermbg=233 cterm=NONE
highlight Cursor guifg=#181616 guibg=#E5E8E5 gui=NONE ctermfg=233 ctermbg=254 cterm=NONE
highlight CursorLine guifg=NONE guibg=#393836 gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
highlight ColorColumn guifg=NONE guibg=#282727 gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
highlight Conceal guifg=#7a8382 guibg=NONE gui=bold ctermfg=244 ctermbg=NONE cterm=bold
highlight EndOfBuffer guifg=#181616 guibg=NONE gui=NONE ctermfg=233 ctermbg=NONE cterm=NONE
highlight NonText guifg=#625e5a guibg=NONE gui=NONE ctermfg=59 ctermbg=NONE cterm=NONE
highlight SpecialKey guifg=#7a8382 guibg=NONE gui=NONE ctermfg=244 ctermbg=NONE cterm=NONE
highlight Whitespace guifg=#625e5a guibg=NONE gui=NONE ctermfg=59 ctermbg=NONE cterm=NONE
highlight LineNr guifg=#A0A5A3 guibg=#282727 gui=NONE ctermfg=247 ctermbg=235 cterm=NONE
highlight CursorLineNr guifg=#F0A45D guibg=#282727 gui=bold ctermfg=215 ctermbg=235 cterm=bold
highlight SignColumn guifg=#7a8382 guibg=#282727 gui=NONE ctermfg=244 ctermbg=235 cterm=NONE
highlight FoldColumn guifg=#625e5a guibg=#282727 gui=NONE ctermfg=59 ctermbg=235 cterm=NONE
highlight Folded guifg=#7a8382 guibg=#282727 gui=NONE ctermfg=244 ctermbg=235 cterm=NONE
highlight VertSplit guifg=#0d0c0c guibg=NONE gui=NONE ctermfg=232 ctermbg=NONE cterm=NONE
highlight StatusLine guifg=#C8C093 guibg=#0d0c0c gui=NONE ctermfg=180 ctermbg=232 cterm=NONE
highlight StatusLineNC guifg=#625e5a guibg=#0d0c0c gui=NONE ctermfg=59 ctermbg=232 cterm=NONE
highlight StatusLineTerm guifg=#C8C093 guibg=#0d0c0c gui=NONE ctermfg=180 ctermbg=232 cterm=NONE
highlight StatusLineTermNC guifg=#625e5a guibg=#0d0c0c gui=NONE ctermfg=59 ctermbg=232 cterm=NONE
highlight TabLine guifg=#7a8382 guibg=#0d0c0c gui=NONE ctermfg=244 ctermbg=232 cterm=NONE
highlight TabLineFill guifg=NONE guibg=#181616 gui=NONE ctermfg=NONE ctermbg=233 cterm=NONE
highlight TabLineSel guifg=#C8C093 guibg=#282727 gui=NONE ctermfg=180 ctermbg=235 cterm=NONE
highlight Visual guifg=NONE guibg=#223249 gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
highlight Search guifg=#E5E8E5 guibg=#2D4F67 gui=NONE ctermfg=254 ctermbg=239 cterm=NONE
highlight CurSearch guifg=#E5E8E5 guibg=#2D4F67 gui=bold ctermfg=254 ctermbg=239 cterm=bold
highlight IncSearch guifg=#223249 guibg=#FF9E3B gui=NONE ctermfg=236 ctermbg=215 cterm=NONE
highlight Substitute guifg=#E5E8E5 guibg=#C34043 gui=NONE ctermfg=254 ctermbg=131 cterm=NONE
highlight MatchParen guifg=#FF9E3B guibg=NONE gui=bold ctermfg=215 ctermbg=NONE cterm=bold
highlight QuickFixLine guifg=NONE guibg=#282727 gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
highlight Directory guifg=#80B9FA guibg=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight Title guifg=#80B9FA guibg=NONE gui=bold ctermfg=111 ctermbg=NONE cterm=bold
highlight ModeMsg guifg=#FF9E3B guibg=NONE gui=bold ctermfg=215 ctermbg=NONE cterm=bold
highlight MoreMsg guifg=#658594 guibg=NONE gui=NONE ctermfg=66 ctermbg=NONE cterm=NONE
highlight ErrorMsg guifg=#E82424 guibg=NONE gui=NONE ctermfg=160 ctermbg=NONE cterm=NONE
highlight WarningMsg guifg=#FF9E3B guibg=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
highlight Pmenu guifg=#DCD7BA guibg=#223249 gui=NONE ctermfg=187 ctermbg=236 cterm=NONE
highlight PmenuSel guifg=#DCD7BA guibg=#2D4F67 gui=NONE ctermfg=187 ctermbg=239 cterm=NONE
highlight PmenuSbar guifg=NONE guibg=#223249 gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
highlight PmenuThumb guifg=NONE guibg=#2D4F67 gui=NONE ctermfg=NONE ctermbg=239 cterm=NONE
highlight Comment guifg=#A0A5A3 guibg=NONE gui=italic ctermfg=247 ctermbg=NONE cterm=italic
highlight Constant guifg=#F0A45D guibg=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
highlight String guifg=#97D57F guibg=NONE gui=NONE ctermfg=114 ctermbg=NONE cterm=NONE
highlight Number guifg=#F0A45D guibg=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
highlight Boolean guifg=#F0A45D guibg=NONE gui=bold ctermfg=215 ctermbg=NONE cterm=bold
highlight Identifier guifg=#c4b28a guibg=NONE gui=NONE ctermfg=180 ctermbg=NONE cterm=NONE
highlight Function guifg=#80B9FA guibg=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight Statement guifg=#EE7988 guibg=NONE gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
highlight Conditional guifg=#EE7988 guibg=NONE gui=bold ctermfg=210 ctermbg=NONE cterm=bold
highlight Repeat guifg=#EE7988 guibg=NONE gui=bold ctermfg=210 ctermbg=NONE cterm=bold
highlight Keyword guifg=#C18DF2 guibg=NONE gui=NONE ctermfg=141 ctermbg=NONE cterm=NONE
highlight Operator guifg=#EE7988 guibg=NONE gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
highlight Exception guifg=#F0A45D guibg=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
highlight PreProc guifg=#EE7988 guibg=NONE gui=NONE ctermfg=210 ctermbg=NONE cterm=NONE
highlight Type guifg=#C18DF2 guibg=NONE gui=NONE ctermfg=141 ctermbg=NONE cterm=NONE
highlight Special guifg=#80B9FA guibg=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
highlight Delimiter guifg=#BEC5C1 guibg=NONE gui=NONE ctermfg=251 ctermbg=NONE cterm=NONE
highlight Underlined guifg=#80B9FA guibg=NONE gui=underline ctermfg=111 ctermbg=NONE cterm=underline
highlight Error guifg=#E82424 guibg=NONE gui=NONE ctermfg=160 ctermbg=NONE cterm=NONE
highlight Todo guifg=#223249 guibg=#658594 gui=bold ctermfg=236 ctermbg=66 cterm=bold
highlight DiffAdd guifg=NONE guibg=#2B3328 gui=NONE ctermfg=NONE ctermbg=236 cterm=NONE
highlight DiffDelete guifg=#C34043 guibg=#43242B gui=NONE ctermfg=131 ctermbg=236 cterm=NONE
highlight DiffChange guifg=NONE guibg=#252535 gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE
highlight DiffText guifg=NONE guibg=#49443C gui=NONE ctermfg=NONE ctermbg=238 cterm=NONE
highlight diffAdded guifg=#76946A guibg=NONE gui=NONE ctermfg=101 ctermbg=NONE cterm=NONE
highlight diffRemoved guifg=#C34043 guibg=NONE gui=NONE ctermfg=131 ctermbg=NONE cterm=NONE
highlight diffChanged guifg=#DCA561 guibg=NONE gui=NONE ctermfg=179 ctermbg=NONE cterm=NONE
highlight CocFloating guifg=#C8C093 guibg=#0d0c0c gui=NONE ctermfg=180 ctermbg=232 cterm=NONE
highlight CocFloatBorder guifg=#54546D guibg=#0d0c0c gui=NONE ctermfg=59 ctermbg=232 cterm=NONE
highlight CocHighlightText guifg=NONE guibg=#49443C gui=NONE ctermfg=NONE ctermbg=238 cterm=NONE
highlight CocErrorSign guifg=#E82424 guibg=#282727 gui=NONE ctermfg=160 ctermbg=235 cterm=NONE
highlight CocErrorHighlight guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#E82424
highlight CocErrorFloat guifg=#E82424 guibg=#0d0c0c gui=NONE ctermfg=160 ctermbg=232 cterm=NONE
highlight CocErrorVirtualText guifg=#E82424 guibg=NONE gui=NONE ctermfg=160 ctermbg=NONE cterm=NONE
highlight CocWarningSign guifg=#FF9E3B guibg=#282727 gui=NONE ctermfg=215 ctermbg=235 cterm=NONE
highlight CocWarningHighlight guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#FF9E3B
highlight CocWarningFloat guifg=#FF9E3B guibg=#0d0c0c gui=NONE ctermfg=215 ctermbg=232 cterm=NONE
highlight CocWarningVirtualText guifg=#FF9E3B guibg=NONE gui=NONE ctermfg=215 ctermbg=NONE cterm=NONE
highlight CocInfoSign guifg=#658594 guibg=#282727 gui=NONE ctermfg=66 ctermbg=235 cterm=NONE
highlight CocInfoHighlight guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#658594
highlight CocInfoFloat guifg=#658594 guibg=#0d0c0c gui=NONE ctermfg=66 ctermbg=232 cterm=NONE
highlight CocInfoVirtualText guifg=#658594 guibg=NONE gui=NONE ctermfg=66 ctermbg=NONE cterm=NONE
highlight CocHintSign guifg=#6A9589 guibg=#282727 gui=NONE ctermfg=66 ctermbg=235 cterm=NONE
highlight CocHintHighlight guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#6A9589
highlight CocHintFloat guifg=#6A9589 guibg=#0d0c0c gui=NONE ctermfg=66 ctermbg=232 cterm=NONE
highlight CocHintVirtualText guifg=#6A9589 guibg=NONE gui=NONE ctermfg=66 ctermbg=NONE cterm=NONE
highlight SpellBad guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#E82424
highlight SpellCap guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#FF9E3B
highlight SpellLocal guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#FF9E3B
highlight SpellRare guifg=NONE guibg=NONE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline guisp=#FF9E3B

highlight! link lCursor Cursor
highlight! link CursorIM Cursor
highlight! link CursorColumn CursorLine
highlight! link CursorLineSign SignColumn
highlight! link CursorLineFold FoldColumn
highlight! link LineNrAbove LineNr
highlight! link LineNrBelow LineNr
highlight! link VisualNOS Visual
highlight! link Question MoreMsg
highlight! link WildMenu Pmenu
highlight! link Character String
highlight! link Float Number
highlight! link Label Statement
highlight! link Include PreProc
highlight! link Define PreProc
highlight! link Macro PreProc
highlight! link PreCondit PreProc
highlight! link StorageClass Type
highlight! link Structure Type
highlight! link Typedef Type
highlight! link SpecialChar Special
highlight! link Tag Special
highlight! link SpecialComment Special
highlight! link Debug Special
highlight! link Ignore NonText
highlight! link qfLineNr LineNr
highlight! link qfFileName Directory
highlight! link markdownCode String
highlight! link markdownCodeBlock String
highlight! link netrwDir Directory
highlight! link netrwClassify Directory
highlight! link netrwExe String
highlight! link netrwSymLink Special
highlight! link CocMenuSel PmenuSel
highlight! link CocHighlightRead CocHighlightText
highlight! link CocHighlightWrite CocHighlightText

" Vim's built-in terminal uses Dragon's ANSI palette when supported.
let g:terminal_ansi_colors = [
      \ '#0d0c0c', '#c4746e', '#8a9a7b', '#c4b28a',
      \ '#8ba4b0', '#a292a3', '#8ea4a2', '#C8C093',
      \ '#a6a69c', '#E46876', '#87a987', '#E6C384',
      \ '#7FB4CA', '#938AA9', '#7AA89F', '#c5c9c5',
      \ ]
