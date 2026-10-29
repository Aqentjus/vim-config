" Pico commands, loaded by the generic extensions/*/init.vim loader.
" The helper lives here; projects only need their own CMake files and sources.
let s:helper = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/pico.py'
if !has('terminal') || !filereadable(s:helper)
  finish
endif
if (has('win32') || has('win64')) && executable('py')
  let s:python = ['py', '-3']
elseif executable('python3')
  let s:python = ['python3']
elseif executable('python')
  let s:python = ['python']
else
  " No Python on this machine: leave the ordinary editor alone.
  finish
endif

function! s:Pico(action) abort
  " Use the folder being browsed, the current source file, or Vim's cwd.
  if &filetype ==# 'netrw'
    let l:start = get(b:, 'netrw_curdir', getcwd())
  elseif &buftype ==# '' && !empty(expand('%'))
    let l:start = expand('%:p:h')
  else
    let l:start = getcwd()
  endif
  let l:root = fnamemodify(l:start . '/.', ':p:h')
  while !filereadable(l:root . '/CMakeLists.txt')
    let l:parent = fnamemodify(l:root, ':h')
    if l:parent ==# l:root
      echoerr 'Pico: no CMakeLists.txt found. Open a project file or :cd to its folder.'
      return
    endif
    let l:root = l:parent
  endwhile

  if a:action !=# 'check'
    " Save this source; do not silently build stale sibling buffers.
    if &buftype ==# ''
      update
    endif
    let l:prefix = substitute(resolve(l:root), '\\', '/', 'g')
    let l:prefix = substitute(l:prefix, '/$', '', '') . '/'
    for l:buffer in getbufinfo({'bufmodified': 1})
      if empty(l:buffer.name)
        continue
      endif
      let l:path = substitute(resolve(fnamemodify(l:buffer.name, ':p')), '\\', '/', 'g')
      if has('win32') || has('win64')
        let l:path = tolower(l:path)
        let l:prefix = tolower(l:prefix)
      endif
      if stridx(l:path, l:prefix) == 0
        echoerr 'Pico: save other project edits first (:wall). Not built or flashed.'
        return
      endif
    endfor
  endif

  botright 12new
  call term_start(s:python + [s:helper, a:action, '--project', l:root],
        \ {'curwin': 1, 'cwd': l:root, 'term_name': 'Pico: ' . a:action})
endfunction

command! BuildPico call <SID>Pico('build')
command! FlashPico call <SID>Pico('flash')
command! PicoCheck call <SID>Pico('check')
" Vim user commands start uppercase. These exact typed aliases keep your spelling.
cnoreabbrev <expr> build_pico getcmdtype() ==# ':' && getcmdline() ==# 'build_pico' ? 'BuildPico' : 'build_pico'
cnoreabbrev <expr> flash_pico getcmdtype() ==# ':' && getcmdline() ==# 'flash_pico' ? 'FlashPico' : 'flash_pico'

" Add this extension's rows to Space+h without hard-coding Pico in the core.
let g:vim_config_extension_help = get(g:, 'vim_config_extension_help', {})
let g:vim_config_extension_help.pico = [
      \ '',
      \ 'PICO EXTENSION',
      \ ':build_pico            Command       Build the current CMake project',
      \ ':flash_pico            Command       Build, then SWD program/verify/reset',
      \ ':PicoCheck             Command       Show paths/commands; no hardware access'
      \ ]
