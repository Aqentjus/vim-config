" Optional Pico commands. Load explicitly; the main vimrc is not changed.
" :source tools/pico.vim  OR  :runtime optional/pico.vim
" Requires Python 3 and a trusted project's tools/pico.py.

function! s:Pico(action) abort
  if !has('terminal')
    echoerr 'Pico: this Vim needs +terminal support.'
    return
  endif
  let l:root = (&buftype ==# '' && !empty(expand('%'))) ? expand('%:p:h') : getcwd()
  while !filereadable(l:root . '/tools/pico.py') || !filereadable(l:root . '/CMakeLists.txt')
    let l:parent = fnamemodify(l:root, ':h')
    if l:parent ==# l:root
      echoerr 'Pico: open a project file, or :cd to a project containing tools/pico.py.'
      return
    endif
    let l:root = l:parent
  endwhile

  if (has('win32') || has('win64')) && executable('py')
    let l:python = ['py', '-3']
  elseif executable('python3')
    let l:python = ['python3']
  elseif executable('python')
    let l:python = ['python']
  else
    echoerr 'Pico: install Python 3 and make it available on PATH.'
    return
  endif

  " Save this file, but never silently build with unsaved project buffers.
  if a:action !=# 'check'
    if &buftype ==# ''
      update
    endif
    for l:buffer in getbufinfo({'bufmodified': 1})
      let l:path = substitute(fnamemodify(l:buffer.name, ':p'), '\\', '/', 'g')
      let l:prefix = substitute(l:root, '\\', '/', 'g') . '/'
      if stridx(l:path, l:prefix) == 0
        echoerr 'Pico: save other project edits first (:wall). Not built or flashed.'
        return
      endif
    endfor
  endif

  botright 12new
  call term_start(l:python + [l:root . '/tools/pico.py', a:action],
        \ {'curwin': 1, 'cwd': l:root, 'term_name': 'Pico: ' . a:action})
endfunction

command! BuildPico call <SID>Pico('build')
command! FlashPico call <SID>Pico('flash')
command! PicoCheck call <SID>Pico('check')

" Vim command names must start uppercase; expand just these exact typed names.
cnoreabbrev <expr> build_pico getcmdtype() ==# ':' && getcmdline() ==# 'build_pico' ? 'BuildPico' : 'build_pico'
cnoreabbrev <expr> flash_pico getcmdtype() ==# ':' && getcmdline() ==# 'flash_pico' ? 'FlashPico' : 'flash_pico'
