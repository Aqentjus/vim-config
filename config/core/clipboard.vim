" Prefer Vim's own clipboard registers when the build and desktop support them.
" Linux uses + for the desktop clipboard; Windows/macOS use * when needed.
if has('clipboard') && (has('win32') || has('win64') || has('macunix') || !empty($DISPLAY) || !empty($WAYLAND_DISPLAY))
  if (has('win32') || has('win64') || has('macunix')) || !has('unnamedplus')
    set clipboard^=unnamed
  else
    set clipboard^=unnamedplus
  endif
endif

" Use OS tools only when this Vim has no native desktop clipboard.
" Clipboard fallback uses the operating system, without a clipboard plugin.
function! s:ClipboardBackend() abort
  if get(g:, 'vim_config_native_clipboard', 1) && has('clipboard') && (has('win32') || has('win64') || has('macunix') || !empty($DISPLAY) || !empty($WAYLAND_DISPLAY))
    return (has('win32') || has('win64') || has('macunix') || !has('unnamedplus')) ? 'vim*' : 'vim+'
  endif
  if has('macunix') && executable('pbcopy') && executable('pbpaste')
    return 'mac'
  endif
  if (has('win32') || has('win64')) && executable('clip.exe') && executable('powershell.exe')
    return 'windows'
  endif
  if !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
    return 'wayland'
  endif
  if !empty($DISPLAY) && executable('xclip')
    return 'xclip'
  endif
  if !empty($DISPLAY) && executable('xsel')
    return 'xsel'
  endif
  return ''
endfunction

function! s:ClipboardCopy() abort
  let l:backend = s:ClipboardBackend()
  if empty(l:backend)
    echohl WarningMsg | echom 'Vim copied internally; system clipboard unavailable. See :ClipboardHealth.' | echohl None
    return
  endif
  if l:backend ==# 'vim+'
    call setreg('+', getreg('"'), getregtype('"'))
    return
  elseif l:backend ==# 'vim*'
    call setreg('*', getreg('"'), getregtype('"'))
    return
  endif

  if l:backend ==# 'mac'
    let l:command = 'pbcopy'
  elseif l:backend ==# 'windows'
    let l:command = 'clip.exe'
  elseif l:backend ==# 'wayland'
    let l:command = 'wl-copy'
  elseif l:backend ==# 'xclip'
    let l:command = 'xclip -selection clipboard'
  else
    let l:command = 'xsel --clipboard --input'
  endif
  call system(l:command, getreg('"'))
  if v:shell_error
    echohl WarningMsg | echom 'Clipboard copy failed via ' . l:backend | echohl None
  endif
endfunction

" Read the OS clipboard once, then use a temporary register for all pastes.
function! s:ClipboardPaste(replace, before) abort
  let l:backend = s:ClipboardBackend()
  if empty(l:backend)
    echo 'System clipboard unavailable. Use terminal paste or :ClipboardHealth.'
    return
  endif
  let l:native = l:backend ==# 'vim+' ? '+' : (l:backend ==# 'vim*' ? '*' : '')
  if !empty(l:native)
    let l:text = getreg(l:native)
    let l:type = getregtype(l:native)
  else
    let l:commands = {'mac': 'pbpaste', 'windows': 'powershell.exe -NoProfile -NonInteractive -Command "[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding; Get-Clipboard -Raw"',
          \ 'wayland': 'wl-paste --no-newline', 'xclip': 'xclip -selection clipboard -o', 'xsel': 'xsel --clipboard --output'}
    let l:text = system(l:commands[l:backend])
    if v:shell_error | echo 'Clipboard read failed.' | return | endif
    let l:type = l:text =~# "\n$" ? 'V' : 'v'
  endif
  if empty(l:text) | return | endif
  let l:prior = getreg('z')
  let l:prior_type = getregtype('z')
  try
    call setreg('z', l:text, l:type)
    if a:replace
      normal! gv"zp
    elseif a:before
      normal! "zP
    else
      normal! "zp
    endif
  finally
    call setreg('z', l:prior, l:prior_type)
    " Visual put deletes into the unnamed register; restore the OS clipboard.
    if !empty(l:native) | call setreg(l:native, l:text, l:type) | endif
  endtry
endfunction

function! s:CopyAll() abort
  call setreg('"', getline(1, '$'), 'V')
  call s:ClipboardCopy()
endfunction

function! VimConfigClipboardBackend() abort
  let l:backend = s:ClipboardBackend()
  return empty(l:backend) ? 'unavailable (terminal paste still works)' : l:backend
endfunction

function! s:ClipboardHealth() abort
  echo 'Clipboard: ' . (empty(s:ClipboardBackend()) ? 'unavailable' : s:ClipboardBackend())
        \ . ' | Vim +clipboard: ' . has('clipboard')
        \ . ' | mouse: ' . &mouse
endfunction
command! ClipboardHealth call <SID>ClipboardHealth()

" Leader actions work without terminal-specific Ctrl/Cmd key forwarding.
xnoremap <silent> <leader>y y:<C-U>call <SID>ClipboardCopy()<CR>
nnoremap <silent> <leader>y yy:<C-U>call <SID>ClipboardCopy()<CR>
nnoremap <silent> <leader>Y :<C-U>call <SID>CopyAll()<CR>
nnoremap <silent> <leader>p :<C-U>call <SID>ClipboardPaste(0, 0)<CR>
nnoremap <silent> <leader>P :<C-U>call <SID>ClipboardPaste(0, 1)<CR>
xnoremap <silent> <leader>p :<C-U>call <SID>ClipboardPaste(1, 0)<CR>
xnoremap <silent> <leader>P :<C-U>call <SID>ClipboardPaste(1, 1)<CR>
xnoremap <silent> <C-c> y:<C-U>call <SID>ClipboardCopy()<CR>
nnoremap <silent> <C-v> :<C-U>call <SID>ClipboardPaste(0, 0)<CR>
inoremap <silent> <C-v> <C-o>:call <SID>ClipboardPaste(0, 0)<CR>
xnoremap <silent> <C-v> :<C-U>call <SID>ClipboardPaste(1, 0)<CR>
if has('macunix') && has('gui_running')
  xnoremap <silent> <D-c> y:<C-U>call <SID>ClipboardCopy()<CR>
  nnoremap <silent> <D-v> :<C-U>call <SID>ClipboardPaste(0, 0)<CR>
  inoremap <silent> <D-v> <C-o>:call <SID>ClipboardPaste(0, 0)<CR>
  xnoremap <silent> <D-v> :<C-U>call <SID>ClipboardPaste(1, 0)<CR>
endif
