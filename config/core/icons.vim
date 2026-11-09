" Static file icons: no plugin, parser, filesystem scan or downloaded metadata.
" Glyph codepoints: https://github.com/ryanoasis/nerd-fonts/blob/master/glyphnames.json
" Each row is [Nerd Font glyph, plain-terminal label, GUI color, xterm-256 color].
" Nerd icons are the default; local.vim can select 'unicode' or 'off'.
let s:icons = {
      \ 'Folder': ['', '▸', '#80B9FA', 111],
      \ 'File': ['', '·', '#A0A5A3', 247],
      \ 'Link': ['', '↗', '#73DACA', 80],
      \ 'Python': ['', 'Py', '#F0D36B', 221],
      \ 'JavaScript': ['', 'JS', '#F0D36B', 221],
      \ 'TypeScript': ['', 'TS', '#80B9FA', 111],
      \ 'React': ['', 'Re', '#73DACA', 80],
      \ 'Vue': ['', 'Vu', '#97D57F', 114],
      \ 'Svelte': ['', 'Sv', '#F0A45D', 215],
      \ 'C': ['', 'C', '#80B9FA', 111],
      \ 'Cpp': ['', 'C+', '#C18DF2', 141],
      \ 'Go': ['', 'Go', '#73DACA', 80],
      \ 'Rust': ['', 'Rs', '#F0A45D', 215],
      \ 'Java': ['', 'Jv', '#F0A45D', 215],
      \ 'Kotlin': ['', 'Kt', '#C18DF2', 141],
      \ 'Swift': ['', 'Sw', '#F0A45D', 215],
      \ 'Dart': ['', 'Dt', '#73DACA', 80],
      \ 'Ruby': ['', 'Rb', '#EE7988', 210],
      \ 'PHP': ['', 'Ph', '#C18DF2', 141],
      \ 'Lua': ['', 'Lu', '#80B9FA', 111],
      \ 'Vim': ['', 'Vi', '#97D57F', 114],
      \ 'Shell': ['', 'Sh', '#97D57F', 114],
      \ 'PowerShell': ['', 'PS', '#80B9FA', 111],
      \ 'HTML': ['', '<>', '#F0A45D', 215],
      \ 'CSS': ['', '#', '#80B9FA', 111],
      \ 'Sass': ['', 'Sc', '#EE7988', 210],
      \ 'JSON': ['', '{}', '#F0D36B', 221],
      \ 'YAML': ['', 'Y', '#C18DF2', 141],
      \ 'XML': ['', '<>', '#F0A45D', 215],
      \ 'Config': ['', '⚙', '#A0A5A3', 247],
      \ 'Markdown': ['', 'Md', '#80B9FA', 111],
      \ 'Text': ['', '·', '#A0A5A3', 247],
      \ 'Git': ['', 'Gt', '#EE7988', 210],
      \ 'Docker': ['', 'Dk', '#80B9FA', 111],
      \ 'Make': ['', 'Mk', '#F0A45D', 215],
      \ 'Npm': ['', 'Np', '#EE7988', 210],
      \ 'Database': ['', 'Db', '#73DACA', 80],
      \ 'Image': ['', '◇', '#C18DF2', 141],
      \ 'Archive': ['', 'Z', '#F0A45D', 215],
      \ 'Font': ['', 'Aa', '#EE7988', 210],
      \ 'PDF': ['', 'Pd', '#EE7988', 210],
      \ 'Lock': ['', 'Lk', '#F0D36B', 221],
      \ 'License': ['', '§', '#F0D36B', 221],
      \ 'Coffee': ['', 'Cf', '#F0A45D', 215],
      \ 'Haskell': ['', 'Hs', '#C18DF2', 141],
      \ 'Elixir': ['', 'Ex', '#C18DF2', 141],
      \ 'Clojure': ['', 'Cl', '#97D57F', 114],
      \ 'TeX': ['', 'Tx', '#97D57F', 114],
      \ 'R': ['', 'R', '#80B9FA', 111],
      \ }

let s:extensions = {
      \ 'py': 'Python', 'pyw': 'Python', 'pyi': 'Python',
      \ 'js': 'JavaScript', 'mjs': 'JavaScript', 'cjs': 'JavaScript',
      \ 'ts': 'TypeScript', 'mts': 'TypeScript', 'cts': 'TypeScript',
      \ 'jsx': 'React', 'tsx': 'React',
      \ 'vue': 'Vue',
      \ 'svelte': 'Svelte',
      \ 'c': 'C', 'h': 'C',
      \ 'cc': 'Cpp', 'cpp': 'Cpp', 'cxx': 'Cpp', 'hpp': 'Cpp', 'hxx': 'Cpp', 'hh': 'Cpp',
      \ 'go': 'Go',
      \ 'rs': 'Rust',
      \ 'java': 'Java', 'class': 'Java', 'jar': 'Java',
      \ 'kt': 'Kotlin', 'kts': 'Kotlin',
      \ 'swift': 'Swift',
      \ 'dart': 'Dart',
      \ 'rb': 'Ruby', 'erb': 'Ruby', 'rake': 'Ruby',
      \ 'php': 'PHP', 'phtml': 'PHP',
      \ 'lua': 'Lua',
      \ 'vim': 'Vim',
      \ 'sh': 'Shell', 'bash': 'Shell', 'zsh': 'Shell', 'fish': 'Shell', 'ksh': 'Shell',
      \ 'ps1': 'PowerShell', 'psm1': 'PowerShell', 'psd1': 'PowerShell',
      \ 'html': 'HTML', 'htm': 'HTML',
      \ 'css': 'CSS', 'less': 'CSS',
      \ 'scss': 'Sass', 'sass': 'Sass',
      \ 'json': 'JSON', 'jsonc': 'JSON', 'json5': 'JSON',
      \ 'yaml': 'YAML', 'yml': 'YAML',
      \ 'xml': 'XML', 'xsl': 'XML', 'xsd': 'XML',
      \ 'conf': 'Config', 'cfg': 'Config', 'ini': 'Config', 'toml': 'Config', 'env': 'Config', 'properties': 'Config',
      \ 'md': 'Markdown', 'markdown': 'Markdown', 'mdx': 'Markdown',
      \ 'txt': 'Text', 'log': 'Text', 'rst': 'Text',
      \ 'diff': 'Git', 'patch': 'Git',
      \ 'dockerfile': 'Docker',
      \ 'mk': 'Make', 'cmake': 'Make',
      \ 'sql': 'Database', 'db': 'Database', 'sqlite': 'Database', 'sqlite3': 'Database',
      \ 'png': 'Image', 'jpg': 'Image', 'jpeg': 'Image', 'gif': 'Image', 'webp': 'Image', 'svg': 'Image', 'bmp': 'Image', 'ico': 'Image', 'tiff': 'Image', 'tif': 'Image', 'ai': 'Image', 'psd': 'Image',
      \ 'zip': 'Archive', 'tar': 'Archive', 'gz': 'Archive', 'tgz': 'Archive', 'bz2': 'Archive', 'xz': 'Archive', 'zst': 'Archive', 'rar': 'Archive', '7z': 'Archive',
      \ 'ttf': 'Font', 'otf': 'Font', 'woff': 'Font', 'woff2': 'Font',
      \ 'pdf': 'PDF',
      \ 'lock': 'Lock',
      \ 'coffee': 'Coffee',
      \ 'hs': 'Haskell', 'lhs': 'Haskell',
      \ 'ex': 'Elixir', 'exs': 'Elixir',
      \ 'clj': 'Clojure', 'cljs': 'Clojure', 'cljc': 'Clojure', 'edn': 'Clojure',
      \ 'tex': 'TeX', 'bib': 'TeX',
      \ 'r': 'R', 'rmd': 'R',
      \ }

" Exact filenames take priority over extensions (e.g. package.json, Cargo.toml).
let s:filenames = {
      \ '.gitignore': 'Git',
      \ '.gitattributes': 'Git',
      \ '.gitmodules': 'Git',
      \ '.gitconfig': 'Git',
      \ '.gitkeep': 'Git',
      \ 'dockerfile': 'Docker',
      \ 'containerfile': 'Docker',
      \ '.dockerignore': 'Docker',
      \ 'docker-compose.yml': 'Docker',
      \ 'docker-compose.yaml': 'Docker',
      \ 'compose.yml': 'Docker',
      \ 'compose.yaml': 'Docker',
      \ 'makefile': 'Make',
      \ 'gnumakefile': 'Make',
      \ 'cmakelists.txt': 'Make',
      \ 'package.json': 'Npm',
      \ 'package-lock.json': 'Npm',
      \ 'yarn.lock': 'Lock',
      \ 'pnpm-lock.yaml': 'Lock',
      \ 'tsconfig.json': 'TypeScript',
      \ 'jsconfig.json': 'JavaScript',
      \ 'pyproject.toml': 'Python',
      \ 'requirements.txt': 'Python',
      \ 'pipfile': 'Python',
      \ 'pipfile.lock': 'Lock',
      \ 'poetry.lock': 'Lock',
      \ 'cargo.toml': 'Rust',
      \ 'cargo.lock': 'Lock',
      \ 'go.mod': 'Go',
      \ 'go.sum': 'Go',
      \ 'gemfile': 'Ruby',
      \ 'gemfile.lock': 'Lock',
      \ '.bashrc': 'Shell',
      \ '.bash_profile': 'Shell',
      \ '.zshrc': 'Shell',
      \ '.zprofile': 'Shell',
      \ '.profile': 'Shell',
      \ '.vimrc': 'Vim',
      \ '_vimrc': 'Vim',
      \ 'license': 'License',
      \ 'license.txt': 'License',
      \ 'license.md': 'License',
      \ 'copying': 'License',
      \ }

function! s:Kind(text) abort
  let l:name = substitute(a:text, '^\%([-+|│] \)\+', '', '')
  " Some netrw versions show symlinks as name@<Tab> --> target.
  if l:name =~# '@\%($\|\t\)' | return 'Link' | endif
  if l:name =~# '/$' | return 'Folder' | endif
  " netrw appends classification marks to executable/special entries.
  let l:name = substitute(l:name, '[*=|]$', '', '')
  " Unix distinguishes .C (C++) from .c; other lookups are case-insensitive.
  if l:name =~# '\.C$' | return 'Cpp' | endif
  let l:name = tolower(l:name)
  if has_key(s:filenames, l:name) | return s:filenames[l:name] | endif
  if l:name ==# '.env' || l:name =~# '^\.env\.' | return 'Config' | endif
  return get(s:extensions, fnamemodify(l:name, ':e'), 'File')
endfunction

function! s:Define(mode) abort
  for [l:kind, l:spec] in items(s:icons)
    let l:glyph = a:mode ==# 'nerd' ? l:spec[0] : l:spec[1]
    if strdisplaywidth(l:glyph) > 2 | let l:glyph = '*' | endif
    let l:group = 'VimConfigIcon' . l:kind
    " default lets personal highlight definitions win.
    execute 'highlight default ' . l:group . ' guifg=' . l:spec[2]
          \ . ' ctermfg=' . l:spec[3] . ' guibg=NONE ctermbg=NONE gui=NONE cterm=NONE'
    call sign_define('VimConfig' . l:kind, {'text': l:glyph, 'texthl': l:group})
  endfor
  let s:defined_mode = a:mode
endfunction

function! VimConfigTreeIcons() abort
  if &filetype !=# 'netrw' || !exists('*sign_place') | return | endif
  let l:mode = get(g:, 'vim_config_icons', 'nerd')
  let l:state = [b:changedtick, l:mode, get(b:, 'netrw_liststyle', -1)]
  if get(b:, 'vim_config_icon_state', []) ==# l:state | return | endif
  let b:vim_config_icon_state = l:state
  call sign_unplace('VimConfigTree', {'buffer': bufnr('%')})
  " Wide/long listings do not have one filename per line.
  if index(['unicode', 'nerd'], l:mode) < 0 || &encoding !=# 'utf-8'
        \ || index([0, 3], get(b:, 'netrw_liststyle', 3)) < 0
    setlocal signcolumn=auto
    return
  endif
  if get(s:, 'defined_mode', '') !=# l:mode | call s:Define(l:mode) | endif
  setlocal signcolumn=yes
  let l:line = 0
  for l:text in getline(1, '$')
    let l:line += 1
    if empty(l:text) || l:text =~# '^"' | continue | endif
    call sign_place(l:line, 'VimConfigTree', 'VimConfig' . s:Kind(l:text), bufnr('%'), {'lnum': l:line})
  endfor
endfunction

function! s:ColorsChanged() abort
  if exists('*sign_place') && exists('s:defined_mode')
    call s:Define(s:defined_mode)
  endif
endfunction

function! s:SetIcons(mode) abort
  if index(['off', 'unicode', 'nerd'], a:mode) < 0
    echo 'Use :TreeIcons off, unicode or nerd.'
    return
  endif
  let g:vim_config_icons = a:mode
  call VimConfigTreeIcons()
endfunction
command! -nargs=1 TreeIcons call <SID>SetIcons(<q-args>)
augroup VimConfigTreeIcons
  autocmd!
  autocmd FileType netrw call VimConfigTreeIcons()
  autocmd BufEnter,TextChanged,CursorMoved * if &filetype ==# 'netrw' | call VimConfigTreeIcons() | endif
  autocmd ColorScheme * call <SID>ColorsChanged()
augroup END
