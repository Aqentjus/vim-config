" Runner: save one file, select a command, show it in a new bottom terminal.
" C/C++ use a temporary executable, never an existing project binary.
function! s:RunnerFinished(output, job, status) abort
  if !empty(a:output)
    call delete(a:output)
  endif
  echom 'Runner: process exited with code ' . a:status
endfunction

function! s:CodeRunner() abort
  if !has('terminal')
    echo 'Runner: this Vim needs +terminal support.'
    return
  endif
  if &buftype !=# '' || empty(expand('%'))
    echo 'Runner: open a named source file first.'
    return
  endif

  if !VimConfigTerminalAvailable() | return | endif
  let l:file = expand('%:p')
  let l:extension = expand('%:e')
  let l:windows = has('win32') || has('win64')
  let l:args = []
  let l:output = ''
  let l:env = {}
  let l:compiled = index(['c', 'cpp', 'cc', 'cxx', 'C'], l:extension) >= 0

  if l:extension ==# 'py'
    if !empty($VIRTUAL_ENV) && executable($VIRTUAL_ENV . (l:windows ? '/Scripts/python.exe' : '/bin/python'))
      let l:tools = [$VIRTUAL_ENV . (l:windows ? '/Scripts/python.exe' : '/bin/python')]
    elseif l:windows && executable('py')
      let l:tools = ['py']
      let l:args = ['-3']
    else
      let l:tools = ['python3', 'python']
    endif
  elseif l:compiled
    let l:tools = l:extension ==# 'c' ? ['cc', 'gcc', 'clang'] : ['c++', 'g++', 'clang++']
  elseif index(['js', 'mjs', 'cjs'], l:extension) >= 0
    let l:tools = ['node']
  elseif l:extension ==# 'sh'
    let l:tools = ['bash']
  elseif l:extension ==# 'ps1'
    let l:tools = ['pwsh', 'powershell.exe']
    let l:args = ['-NoLogo', '-NoProfile', '-File']
  elseif l:extension ==# 'lua'
    let l:tools = ['lua', 'luajit']
  else
    echo 'Runner: supported files are .py, .c, .cpp/.cc/.cxx/.C, .js/.mjs/.cjs, .sh, .ps1 and .lua.'
    return
  endif

  let l:tool = ''
  for l:candidate in l:tools
    if executable(l:candidate)
      let l:tool = exepath(l:candidate)
      break
    endif
  endfor
  if empty(l:tool)
    echo 'Runner: install a matching tool and put it on PATH: ' . join(l:tools, ', ')
    return
  endif

  " A save failure aborts here: do not run stale code from disk.
  update
  if !filereadable(l:file)
    echo 'Runner: save this file before running it.'
    return
  endif

  if l:compiled
    let l:output = tempname() . (l:windows ? '.exe' : '')
    let l:standard = l:extension ==# 'c' ? 'c17' : 'c++17'
    let l:env = {'VIM_RUN_COMPILER': l:tool, 'VIM_RUN_SOURCE': l:file, 'VIM_RUN_OUTPUT': l:output}
    " Pass paths through quoted environment variables, not shell source text.
    " && runs the new executable only if compilation succeeds.
    if l:windows
      let l:shell = empty($COMSPEC) ? exepath('cmd.exe') : $COMSPEC
      let l:command = '"' . l:shell . '" /d /v:off /s /c ""%VIM_RUN_COMPILER%" -std=' . l:standard . ' -Wall -Wextra "%VIM_RUN_SOURCE%" -o "%VIM_RUN_OUTPUT%" && "%VIM_RUN_OUTPUT%""'
    else
      let l:command = ['/bin/sh', '-c', '"$VIM_RUN_COMPILER" -std=' . l:standard . ' -Wall -Wextra "$VIM_RUN_SOURCE" -o "$VIM_RUN_OUTPUT" && exec "$VIM_RUN_OUTPUT"']
    endif
  else
    " An argument list preserves spaces and bypasses shell interpretation.
    let l:command = [l:tool] + l:args + [l:file]
  endif

  " No auto-close option: the default keeps output visible, including on Vim 9.1.
  call VimConfigTerminalRun(l:command, { 'cwd': fnamemodify(l:file, ':h'),
        \ 'env': l:env, 'term_name': 'Run: ' . fnamemodify(l:file, ':t'),
        \ 'exit_cb': function('s:RunnerFinished', [l:output])})
endfunction

nnoremap <silent> <leader>r :<C-U>call <SID>CodeRunner()<CR>


command! RunCode call <SID>CodeRunner()
