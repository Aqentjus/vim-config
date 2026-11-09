"""Offline integration checks using system Vim and temporary profiles only."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
VIM = shutil.which('vim')


def quote(path):
    return "'" + str(path).replace("'", "''") + "'"


@unittest.skipUnless(VIM and os.name != 'nt', 'Unix installer and system Vim required')
class ConfigTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="vim minimal ' ä ")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.home = self.base / 'home'
        self.home.mkdir()
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        # No Node/npm/Git/Python/compiler/clipboard tools are exposed to Vim.
        for tool in ['vim', 'dirname', 'mkdir', 'cp', 'mv', 'cmp', 'date', 'find', 'rm']:
            (self.bin / tool).symlink_to(shutil.which(tool))
        self.env = dict(os.environ, HOME=str(self.home), PATH=str(self.bin), TERM='xterm-256color')
        for key in ['VIMINIT', 'EXINIT', 'GVIMINIT', 'VIM_CONFIG_HOME', 'VIM', 'VIMRUNTIME']:
            self.env.pop(key, None)
        self.config = self.home / '.vim-config'

    def install(self, *args, ok=True):
        result = subprocess.run(['/bin/sh', str(REPO / 'install.sh'), *args],
                                env=self.env, cwd=self.base, text=True, capture_output=True, timeout=15)
        self.assertEqual(result.returncode == 0, ok, result.stdout + result.stderr)
        return result

    def vim(self, commands, startup=True):
        script = self.base / 'test.vim'
        errors = self.base / 'errors.txt'
        script.write_text(commands + '\ncall assert_equal("", v:errmsg)\ncall writefile(v:errors, ' + quote(errors) + ')\nif !empty(v:errors) | cquit | endif\nqa!\n')
        result = subprocess.run([VIM, '-V1' + str(self.base / 'vim.log'), '-N', '-n', '-i', 'NONE', '-es', '-u',
                                 str(self.home / '.vimrc') if startup else 'NONE', '-S', str(script)],
                                env=self.env, cwd=self.base, text=True, capture_output=True, timeout=15)
        self.assertEqual(result.returncode, 0, (errors.read_text() if errors.exists() else 'unfinished', result.stdout, result.stderr, (self.base / 'vim.log').read_text()))

    def snapshot(self):
        return {str(p.relative_to(self.home)): p.read_bytes() for p in self.home.rglob('*') if p.is_file()}

    def fake_coc_tools(self, git_script):
        for tool, body in [('node', 'echo 22.15.0'), ('npm', 'exit 0'), ('git', git_script)]:
            fake = self.bin / tool
            fake.write_text('#!/bin/sh\n' + body + '\n')
            fake.chmod(0o755)

    def test_basic_install_and_startup_without_development_tools(self):
        self.install()
        self.assertFalse((self.config / 'pack').exists())
        self.assertFalse((self.config / 'completion-enabled').exists())
        self.vim(r'''call assert_equal('kanagawa-dragon', g:colors_name)
call assert_match('^off', g:vim_config_completion_status)
call assert_equal(0, executable('node'))
call assert_equal(0, executable('python3'))
call assert_equal(0, exists(':CocInstall'))
call assert_equal('', maparg('<Tab>', 'i'))
call assert_equal(2, exists(':RunCode'))
Keys
call assert_match('Native word completion', join(getline(1, '$'), '\n'))
tabclose
ConfigDoctor
call assert_match('not on PATH', join(getline(1, '$'), '\n'))
tabclose''')

    def test_active_editor_highlight_and_gray_numbers(self):
        self.install()
        self.vim(r'''doautocmd VimEnter
wincmd l
call assert_equal(1, &cursorline)
let first = win_getid()
split
let second = win_getid()
call assert_equal(1, &cursorline)
call assert_equal(0, getwinvar(first, '&cursorline'))
call win_gotoid(first)
call assert_equal(1, &cursorline)
call assert_equal(0, getwinvar(second, '&cursorline'))
Keys
call assert_equal(0, &cursorline)
tabclose
call assert_equal(1, &cursorline)
call assert_equal('#A0A5A3', synIDattr(hlID('LineNr'), 'fg', 'gui'))
call assert_equal('#F0A45D', synIDattr(hlID('CursorLineNr'), 'fg', 'gui'))
call feedkeys(' e', 'xt')
call assert_equal('netrw', &filetype)
call assert_equal(0, &cursorline)
let v:errmsg = ""''')

    def test_help_tracks_personal_and_buffer_mappings(self):
        self.install()
        (self.config / 'local.vim').write_text('nnoremap <leader>z :echo "personal"<CR>\nnnoremap <leader>f :echo "override"<CR>\nnunmap <leader>r\n')
        commands = r'''nnoremap <buffer> <leader>z :echo "buffer wins"<CR>
Keys
let text = join(getline(1, '$'), "\n")
call assert_match('Space z.*buffer wins.*\[buffer\]', text)
call assert_match('Space f.*override', text)
call assert_notmatch('Save and run current file', text)
call assert_notmatch('Find file from current directory', text)
call assert_notmatch(':CocInstall', text)
call assert_match('Completion: off', text)
call assert_match('Native word completion', text)
tabclose
call assert_equal('<Nop>', maparg(' ', 'n'))'''
        self.vim(commands)
        # Exercise the compatibility path used by Vim versions without maplist().
        help_file = self.config / 'core/help.vim'
        help_file.write_text(help_file.read_text().replace("exists('*maplist')", '0'))
        self.vim(commands)

    def test_create_in_selected_nested_directory_and_beside_file(self):
        self.install()
        project = self.base / 'project'
        nested = project / 'folder with spaces' / 'nested'
        nested.mkdir(parents=True)
        (nested / 'existing.txt').write_text('keep me\n')
        self.vim("execute 'Lexplore ' . fnameescape(" + quote(project) + ")\nlet v:errmsg = ''\n" + r'''call search('folder with spaces/', 'w')
call feedkeys("\<CR>", 'xt')
call search('nested/', 'w')
call feedkeys(" ninside.txt\<CR>", 'xt')
''' + 'call assert_true(filereadable(' + quote(nested / 'inside.txt') + '))\n' + r'''call search('nested/', 'w')
call feedkeys("\<CR>", 'xt')
call search('existing.txt', 'w')
call feedkeys(" nbeside.txt\<CR>", 'xt')
''' + 'call assert_true(filereadable(' + quote(nested / 'beside.txt') + '))\n' + r'''call search('existing.txt', 'w')
call feedkeys(" nexisting.txt\<CR>", 'xt')
call search('existing.txt', 'w')
call feedkeys(" n/new folder\<CR>", 'xt')
''' + 'call assert_true(isdirectory(' + quote(nested / 'new folder') + '))\n' + r'''call feedkeys(" n\<CR>", 'xt')
let v:errmsg = ""''')
        self.assertEqual((nested / 'existing.txt').read_text(), 'keep me\n')
        self.assertFalse((project / 'inside.txt').exists())
        self.assertFalse((project / 'beside.txt').exists())

    def test_check_and_dry_run_write_nothing(self):
        for args in [('--check',), ('--dry-run',)]:
            self.install(*args)
            self.assertEqual(self.snapshot(), {})
        self.install()
        before = self.snapshot()
        self.install('--dry-run')
        self.install('--check')
        self.assertEqual(self.snapshot(), before)

    def test_with_coc_missing_tools_does_not_change_config(self):
        self.install('--with-coc', ok=False)
        self.assertEqual(self.snapshot(), {})

    def test_fresh_coc_install_is_explicit_and_uses_optional_package(self):
        self.fake_coc_tools('''while [ "$#" -gt 1 ]; do shift; done
mkdir -p "$1/plugin"
printf 'let g:fresh_coc_loaded = 1\\n' > "$1/plugin/coc.vim"''')
        self.install('--with-coc', '--check')
        self.install('--with-coc', '--dry-run')
        self.assertEqual(self.snapshot(), {})
        self.install('--with-coc')
        self.assertTrue((self.config / 'pack/coc/opt/coc.nvim/plugin/coc.vim').is_file())
        self.assertFalse((self.config / 'pack/coc/start').exists())
        self.vim("call assert_equal(1, g:fresh_coc_loaded)\ncall assert_equal([], g:coc_global_extensions)")

    def test_failed_optional_download_keeps_existing_files(self):
        self.install()
        before = self.snapshot()
        self.fake_coc_tools('exit 1')
        self.install('--with-coc', ok=False)
        self.assertEqual(self.snapshot(), before)

    def test_repeat_install_preserves_settings_and_backs_up_changes(self):
        (self.home / '.vimrc').write_text('" old configuration\n')
        self.install()
        self.assertTrue(list((self.config / 'backups').rglob('.vimrc')))
        (self.config / 'local.vim').write_text("set shiftwidth=7\nlet g:vim_config_icons = 'unicode'\n")
        (self.config / 'coc-settings.json').write_text('{"custom": true}\n')
        before = self.snapshot()
        self.install()
        self.assertEqual(self.snapshot(), before)
        self.vim("call assert_equal(7, &shiftwidth)\ncall assert_equal('unicode', g:vim_config_icons)")

    def test_old_coc_package_is_not_auto_loaded(self):
        plugin = self.config / 'pack/coc/start/coc.nvim/plugin'
        plugin.mkdir(parents=True)
        (plugin / 'coc.vim').write_text("let g:unwanted_coc = 1\n")
        self.install()
        self.vim("packloadall\ncall assert_equal(0, exists('g:unwanted_coc'))")

    def test_opt_in_reuses_existing_coc_without_extension_downloads(self):
        plugin = self.config / 'pack/coc/start/coc.nvim/plugin'
        plugin.mkdir(parents=True)
        (plugin / 'coc.vim').write_text("let g:optional_coc_loaded = 1\n")
        for tool in ['node', 'npm', 'git']:
            fake = self.bin / tool
            fake.write_text('#!/bin/sh\n' + ('echo 22.15.0\n' if tool == 'node' else 'exit 99\n'))
            fake.chmod(0o755)
        self.install('--with-coc', '--dry-run')
        self.assertFalse((self.config / 'completion-enabled').exists())
        self.install('--with-coc')
        self.vim("call assert_equal(1, g:optional_coc_loaded)\ncall assert_equal([], g:coc_global_extensions)\ncall assert_match('coc-definition', maparg('gd', 'n'))")
        (self.config / 'local.vim').write_text('nnoremap gd :echo "personal"<CR>\ninoremap <Tab> CUSTOM\n')
        self.vim("call assert_match('personal', maparg('gd', 'n'))\ncall assert_equal('CUSTOM', maparg('<Tab>', 'i'))")
        (self.config / 'local.vim').write_text('let g:vim_config_completion = 0\n')
        self.vim("call assert_equal(0, exists('g:optional_coc_loaded'))\ncall assert_equal('', maparg('gd', 'n'))")

    def test_enabled_but_unavailable_completion_is_quiet(self):
        self.install()
        (self.config / 'completion-enabled').touch()
        self.vim("call assert_match('^unavailable', g:vim_config_completion_status)\ncall assert_equal('', execute('messages'))\ncall assert_equal('', maparg('<Tab>', 'i'))")

    def test_runner_saves_file_and_retains_completed_output(self):
        self.install()
        (self.bin / 'bash').symlink_to('/bin/bash')
        script = self.base / "run ' ; $.sh"
        script.write_text('exit 99\n')
        output = self.base / 'ran.txt'
        self.env['RUN_TEST_OUTPUT'] = str(output)
        self.vim("execute 'edit ' . fnameescape(" + quote(script) + ")\n" + r'''call setline(1, 'printf saved > "$RUN_TEST_OUTPUT"')
RunCode
let task = t:vim_config_terminal
for attempt in range(100)
  if job_status(term_getjob(task)) !=# 'run' | break | endif
  sleep 10m
endfor
call assert_equal(0, job_info(term_getjob(task)).exitval)
call assert_true(bufexists(task))
call ToggleTerminal()
call assert_equal(0, bufexists(task))''')
        self.assertEqual(output.read_text(), 'saved')
        self.assertIn('printf saved', script.read_text())

    def test_real_startup_opens_tree_with_default_nerd_icons(self):
        import pty
        import select
        import time
        self.install()
        state = self.base / 'startup-state.txt'
        check = self.base / 'startup.vim'
        check.write_text('''function! CheckStartup() abort
  for w in range(1, winnr('$'))
    if getbufvar(winbufnr(w), '&filetype') ==# 'netrw'
      execute w . 'wincmd w'
      call VimConfigTreeIcons()
      call writefile([&filetype, string(len(sign_getplaced(bufnr('%'), {'group': 'VimConfigTree'})[0].signs)), sign_getdefined('VimConfigFolder')[0].text], ''' + quote(state) + ''')
    endif
  endfor
  qa!
endfunction
autocmd VimEnter * call CheckStartup()
''')
        master, slave = pty.openpty()
        try:
            process = subprocess.Popen([VIM, '-N', '-n', '-i', 'NONE', '-u', str(self.home / '.vimrc'),
                                        '-S', str(check), str(REPO / 'README.md')], stdin=slave, stdout=slave,
                                       stderr=slave, env=self.env, cwd=self.base)
            screen = b''
            deadline = time.monotonic() + 10
            while process.poll() is None and time.monotonic() < deadline:
                if select.select([master], [], [], 0.1)[0]:
                    screen += os.read(master, 65536)
            if process.poll() is None:
                process.kill()
            process.wait()
            self.assertEqual(process.returncode, 0, screen[-8000:].decode(errors='replace'))
            lines = state.read_text().splitlines()
            self.assertEqual(lines[0], 'netrw')
            self.assertGreater(int(lines[1]), 0)
            self.assertEqual(lines[2].strip(), '')
        finally:
            os.close(master)
            os.close(slave)

    def test_icons_do_not_change_netrw_filenames_or_open_action(self):
        self.install()
        project = self.base / 'project'
        project.mkdir()
        (project / 'folder').mkdir()
        file = project / 'hello world.py'
        file.write_text('print(42)\n')
        # netrw internally uses silent! unmap, which can leave v:errmsg set.
        self.vim("execute 'Lexplore ' . fnameescape(" + quote(project) + ")\nlet v:errmsg = ''\n" + r'''let original = getline(1, '$')
TreeIcons unicode
call assert_equal(original, getline(1, '$'))
call assert_true(len(sign_getplaced(bufnr('%'), {'group': 'VimConfigTree'})[0].signs) > 0)
TreeIcons nerd
call assert_equal(original, getline(1, '$'))
TreeIcons off
call assert_equal([], sign_getplaced(bufnr('%'), {'group': 'VimConfigTree'})[0].signs)
TreeIcons unicode
call search('hello world.py', 'w')
call feedkeys("\<CR>", 'xt')
''' + 'call assert_equal(' + quote(file) + ", expand('%:p'))")

    def test_static_file_icons_have_colors_and_survive_theme_changes(self):
        self.install()
        project = self.base / 'icon samples'
        project.mkdir()
        (project / 'folder').mkdir()
        expected = {
            'example.py': 'Python', 'example.js': 'JavaScript', 'example.ts': 'TypeScript',
            'example.c': 'C', 'capital.C': 'Cpp', 'example.cpp': 'Cpp', 'example.rs': 'Rust',
            'example.go': 'Go', 'README.md': 'Markdown', 'photo.png': 'Image',
            'archive.tar.gz': 'Archive', 'unknown.xyz': 'File', 'Dockerfile': 'Docker',
            'Makefile': 'Make', 'CMakeLists.txt': 'Make', '.gitignore': 'Git',
            'package.json': 'Npm', 'pyproject.toml': 'Python', '.env.local': 'Config',
            'with spaces.py': 'Python', 'run.sh': 'Shell', 'folder/': 'Folder',
            'linked.py@': 'Link',
        }
        for name in expected:
            if not name.endswith(('/', '@')):
                (project / name).write_text('sample\n')
        (project / 'run.sh').chmod(0o755)
        (project / 'linked.py').symlink_to(project / 'example.py')
        pairs = ', '.join(quote(name) + ': ' + quote(kind) for name, kind in expected.items())
        self.vim("execute 'Lexplore ' . fnameescape(" + quote(project) + ")\nlet v:errmsg = ''\n" +
                 'let expected = {' + pairs + '}\n' + r'''let original = getline(1, '$')
call VimConfigTreeIcons()
let signs = sign_getplaced(bufnr('%'), {'group': 'VimConfigTree'})[0].signs
for [name, kind] in items(expected)
  let found = 0
  for entry in signs
    let text = substitute(getline(entry.lnum), '^\%([-+|│] \)\+', '', '')
    let text = substitute(text, '\*$', '', '')
    let text = split(text, "\t")[0]
    if text ==# name
      call assert_equal('VimConfig' . kind, entry.name, name)
      let found = 1
    endif
  endfor
  call assert_equal(1, found, name . ': ' . string(original))
endfor
call assert_equal('#F0D36B', synIDattr(hlID('VimConfigIconPython'), 'fg', 'gui'))
call assert_equal('#80B9FA', synIDattr(hlID('VimConfigIconTypeScript'), 'fg', 'gui'))
call assert_equal('#EE7988', synIDattr(hlID('VimConfigIconGit'), 'fg', 'gui'))
set notermguicolors
call assert_notequal('', synIDattr(hlID('VimConfigIconPython'), 'fg', 'cterm'))
colorscheme default
call assert_equal('#F0D36B', synIDattr(hlID('VimConfigIconPython'), 'fg', 'gui'))
colorscheme kanagawa-dragon
call assert_equal('#80B9FA', synIDattr(hlID('VimConfigIconTypeScript'), 'fg', 'gui'))
highlight VimConfigIconPython guifg=#123456 ctermfg=24
TreeIcons unicode
call assert_equal('#123456', synIDattr(hlID('VimConfigIconPython'), 'fg', 'gui'))
call assert_equal('Py', sign_getdefined('VimConfigPython')[0].text)
call assert_equal(original, getline(1, '$'))
TreeIcons off
call assert_equal([], sign_getplaced(bufnr('%'), {'group': 'VimConfigTree'})[0].signs)
''')

    def test_terminal_tasks_are_per_tab_and_can_be_stopped(self):
        self.install()
        self.vim(r'''if has('terminal')
  let first = VimConfigTerminalRun(['/bin/sh', '-c', 'read value'], {})
  call assert_true(first > 0)
  let firstjob = term_getjob(first)
  call assert_equal(0, VimConfigTerminalAvailable())
  tabnew
  let second = VimConfigTerminalRun(['/bin/sh', '-c', 'read value'], {})
  call assert_notequal(first, second)
  call ToggleTerminal()
  call assert_equal(0, bufexists(second))
  call assert_equal('run', job_status(firstjob))
  tabprevious
  call ToggleTerminal()
  for attempt in range(100)
    if job_status(firstjob) !=# 'run' | break | endif
    sleep 10m
  endfor
  call assert_equal('dead', job_status(firstjob))
  call assert_equal(0, bufexists(first))
endif''')

    def test_clipboard_copy_all_and_repeat_visual_paste(self):
        # Fake OS tools avoid touching the user's real clipboard.
        self.install()
        (self.config / 'local.vim').write_text('let g:vim_config_native_clipboard = 0\nset clipboard=\n')
        clip = self.base / 'clipboard'
        self.env['FAKE_CLIPBOARD'] = str(clip)
        for tool, body in [('pbcopy', '/bin/cat > "$FAKE_CLIPBOARD"'), ('pbpaste', '/bin/cat "$FAKE_CLIPBOARD"'),
                           ('wl-copy', '/bin/cat > "$FAKE_CLIPBOARD"'), ('wl-paste', '/bin/cat "$FAKE_CLIPBOARD"')]:
            p = self.bin / tool
            p.write_text('#!/bin/sh\n' + body + '\n')
            p.chmod(0o755)
        self.env['WAYLAND_DISPLAY'] = 'fake'
        self.vim(r'''set clipboard=
call setline(1, ['héllo', 'world'])
call cursor(2, 3)
let position = getpos('.')
call feedkeys(' Y', 'xt')
call assert_equal(position, getpos('.'))
call assert_equal(['héllo', 'world'], readfile($FAKE_CLIPBOARD))
call writefile(['NEW'], $FAKE_CLIPBOARD, 'b')
call setline(1, ['old', 'old'])
normal! gg0viw
call feedkeys(' p', 'xt')
normal! j0viw
call feedkeys(' p', 'xt')
call assert_equal(['NEW', 'NEW'], getline(1, '$'))
call assert_equal(['NEW'], readfile($FAKE_CLIPBOARD))
normal! gg0
call feedkeys(' P', 'xt')
call assert_equal('NEWNEW', getline(1))''')


if __name__ == '__main__':
    unittest.main()
