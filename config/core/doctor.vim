" Read-only, on-demand information; missing optional tools never block editing.
function! s:Doctor() abort
  let l:lines = ['VIM CONFIGURATION', '',
        \ 'Config: ' . g:vim_config_home,
        \ 'Completion: ' . get(g:, 'vim_config_completion_status', 'off'),
        \ 'Terminal: ' . (has('terminal') ? 'available' : 'not in this Vim build'),
        \ 'Clipboard: ' . VimConfigClipboardBackend(),
        \ 'Tree icons: ' . get(g:, 'vim_config_icons', 'nerd'), '',
        \ 'OPTIONAL TOOLS (only needed for their feature)']
  for l:tool in ['node', 'npm', 'git', 'python3', 'python', 'cc', 'c++', 'clangd', 'bash', 'pwsh', 'lua', 'cmake', 'ninja', 'arm-none-eabi-gcc', 'openocd']
    call add(l:lines, printf('  %-18s %s', l:tool, executable(l:tool) ? exepath(l:tool) : 'not on PATH'))
  endfor
  call extend(l:lines, ['', 'No tools were installed or run by this report.',
        \ 'Native completion: Ctrl-n / Ctrl-p. Add CoC only if needed.',
        \ 'SSH clipboard tools may address the remote desktop; terminal paste works independently.',
        \ 'Pico: :PicoCheck checks configured SDK/tool overrides.', 'Press q to close.'])
  call VimConfigHelpBuffer('ConfigDoctor', l:lines)
endfunction
command! ConfigDoctor call <SID>Doctor()
