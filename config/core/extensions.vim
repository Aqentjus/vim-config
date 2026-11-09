" Load our own installed extensions, never scripts from the opened project.
" Missing folders are fine; a broken optional extension must not block startup.
for s:extension in globpath(escape(g:vim_config_home . '/extensions', ','), '*/init.vim', 0, 1)
  try
    execute 'silent source ' . fnameescape(s:extension)
  catch
    " Skip unavailable extensions quietly. Explicit build/flash errors stay visible.
  endtry
endfor
unlet! s:extension
