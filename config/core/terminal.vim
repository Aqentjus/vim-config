" One managed shell/task per tab. Finished output remains until closed/replaced.
function! VimConfigTerminalAvailable() abort
  if !has('terminal')
    echo 'This Vim has no +terminal support; use your shell to run commands.'
    return 0
  endif
  let l:buf = get(t:, 'vim_config_terminal', -1)
  if bufexists(l:buf) && getbufvar(l:buf, '&buftype') ==# 'terminal'
        \ && job_status(term_getjob(l:buf)) ==# 'run'
    echo 'A task is running in this tab. Space t stops and closes it.'
    return 0
  endif
  return 1
endfunction

function! VimConfigTerminalClose() abort
  let l:buf = get(t:, 'vim_config_terminal', -1)
  unlet! t:vim_config_terminal
  if bufexists(l:buf)
    if getbufvar(l:buf, '&buftype') ==# 'terminal'
      let l:job = term_getjob(l:buf)
      if job_status(l:job) ==# 'run' | call job_stop(l:job, 'kill') | endif
    endif
    execute 'bwipeout! ' . l:buf
  endif
  if exists('t:vim_config_terminal_origin')
    call win_gotoid(t:vim_config_terminal_origin)
  endif
endfunction

function! VimConfigTerminalRun(command, options) abort
  if !VimConfigTerminalAvailable() | return 0 | endif
  let l:origin = win_getid()
  if bufexists(get(t:, 'vim_config_terminal', -1))
    call VimConfigTerminalClose()
    call win_gotoid(l:origin)
  endif
  let t:vim_config_terminal_origin = win_getid()
  botright 12new
  let l:options = extend({'curwin': 1, 'term_kill': 'kill', 'stoponexit': 'kill'}, a:options)
  try
    let l:buf = term_start(a:command, l:options)
    if l:buf == 0
      close!
      echo 'Could not start terminal command.'
      return 0
    endif
    let t:vim_config_terminal = l:buf
    setlocal nonumber norelativenumber
    return l:buf
  catch
    close!
    echo 'Could not start terminal: ' . v:exception
    return 0
  endtry
endfunction

function! ToggleTerminal() abort
  if bufexists(get(t:, 'vim_config_terminal', -1))
    call VimConfigTerminalClose()
  else
    call VimConfigTerminalRun(&shell, {'term_name': 'Shell'})
  endif
endfunction
nnoremap <silent> <leader>t :<C-U>call ToggleTerminal()<CR>
if has('terminal')
  tnoremap <silent> <leader>t <C-W>N:call ToggleTerminal()<CR>
endif
