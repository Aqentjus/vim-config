"""Loader and bridge tests using real Vim and a simulated project helper."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[2]
VIM = shutil.which('vim')


def quote(path):
    return "'" + str(path).replace("'", "''") + "'"


@unittest.skipUnless(VIM and '+terminal' in subprocess.run([VIM, '--version'], capture_output=True, text=True).stdout, 'full Vim with +terminal required')
class VimTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='vim extensions ')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / 'config copy ä'
        self.repo.mkdir()
        self.vimrc = self.repo / 'vimrc'
        shutil.copy2(SOURCE / 'vimrc', self.vimrc)
        self.extension = self.repo / 'extensions/pico'
        self.extension.mkdir(parents=True)
        shutil.copy2(SOURCE / 'extensions/pico/init.vim', self.extension / 'init.vim')
        self.log = self.base / 'calls.json'
        (self.extension / 'pico.py').write_text('import json, os, pathlib, sys\npathlib.Path(os.environ["PICO_TEST_LOG"]).write_text(json.dumps({"args":sys.argv,"cwd":os.getcwd()}))\n')
        self.project = self.base / 'project space ää'
        (self.project / 'src').mkdir(parents=True)
        (self.project / 'CMakeLists.txt').write_text('project(blink)\n')
        self.file = self.project / 'src/main.c'
        self.file.write_text('original\n')
        self.errors = self.base / 'errors.txt'
        self.env = os.environ.copy()
        self.env.update({'HOME':str(self.base), 'PICO_TEST_LOG':str(self.log)})
        for key in ['VIMINIT', 'EXINIT', 'GVIMINIT']:
            self.env.pop(key, None)

    def run_vim(self, content):
        script = self.base / 'test.vim'
        script.write_text(content + '\ncall writefile(v:errors, ' + quote(self.errors) + ')\nif !empty(v:errors) | cquit | endif\nqa!\n')
        result = subprocess.run([VIM, '-N', '-n', '-i', 'NONE', '-es', '-u', str(self.vimrc), '-S', str(script)], cwd=self.base, env=self.env, capture_output=True, text=True, timeout=12)
        errors = self.errors.read_text() if self.errors.exists() else 'test did not finish'
        self.assertEqual(result.returncode, 0, (errors, result.stderr, result.stdout))
        self.assertEqual(errors, '')

    def edit(self):
        return 'execute "edit " . fnameescape(' + quote(self.file) + ')\n'

    def wait(self):
        return '\nfor attempt in range(80)\n  if filereadable(' + quote(self.log) + ') | break | endif\n  sleep 20m\nendfor\ncall assert_true(filereadable(' + quote(self.log) + '))\n'

    def check_call(self, action):
        call=json.loads(self.log.read_text())
        self.assertEqual(call['args'], [str(self.extension/'pico.py'), action, '--project', str(self.project)])
        self.assertEqual(call['cwd'], str(self.project))

    def test_auto_load_is_silent_and_does_not_run_python(self):
        self.run_vim("call assert_equal(2, exists(':BuildPico'))\ncall assert_equal(2, exists(':FlashPico'))\ncall assert_equal(2, exists(':PicoCheck'))\ncall assert_equal('', v:errmsg)\ncall assert_equal('', execute('messages'))")
        self.assertFalse(self.log.exists())

    def test_missing_extensions_folder_is_silent(self):
        shutil.rmtree(self.repo/'extensions')
        self.run_vim("call assert_equal(0, exists(':BuildPico'))\ncall assert_equal('', execute('messages'))\ncall assert_equal('', v:errmsg)")

    def test_missing_builder_is_silent(self):
        (self.extension/'pico.py').unlink()
        self.run_vim("call assert_equal(0, exists(':BuildPico'))\ncall assert_equal('', execute('messages'))")

    @unittest.skipIf(os.name == 'nt', 'Windows may resolve Python launchers outside PATH')
    def test_missing_python_is_silent(self):
        self.env['PATH'] = str(self.base/'empty-path')
        self.run_vim("call assert_equal(0, exists(':BuildPico'))\ncall assert_equal('', execute('messages'))")

    def test_broken_extension_does_not_block_other_extensions(self):
        broken=self.repo/'extensions/aaa-broken';broken.mkdir()
        (broken/'init.vim').write_text('call ThisFunctionDoesNotExist()\n')
        self.run_vim("call assert_equal(2, exists(':BuildPico'))\ncall assert_equal('', execute('messages'))")

    def test_current_source_file_finds_parent_project(self):
        self.run_vim(self.edit()+'PicoCheck\n'+self.wait())
        self.check_call('check')

    def test_current_folder_without_open_file(self):
        self.run_vim('execute "cd " . fnameescape('+quote(self.project)+')\nPicoCheck\n'+self.wait())
        self.check_call('check')

    def test_explorer_folder_finds_project(self):
        self.run_vim("setfiletype netrw\nlet b:netrw_curdir = "+quote(self.file.parent)+"\nPicoCheck\n"+self.wait())
        self.check_call('check')

    def test_build_saves_current_buffer(self):
        self.run_vim(self.edit()+"call setline(1, 'saved before build')\nBuildPico\n"+self.wait())
        self.assertEqual(self.file.read_text(),'saved before build\n')
        self.check_call('build')

    def test_unsaved_sibling_prevents_build(self):
        sibling=self.project/'other.c';sibling.write_text('old\n')
        self.run_vim('set hidden\nexecute "edit " . fnameescape('+quote(sibling)+")\ncall setline(1, 'unsaved')\n"+self.edit()+"let caught = ''\ntry\n  BuildPico\ncatch\n  let caught = v:exception\nendtry\ncall assert_match('save other project edits', caught)\n")
        self.assertFalse(self.log.exists())

    def test_explicit_missing_project_reports_error(self):
        self.run_vim("let caught = ''\ntry\n  BuildPico\ncatch\n  let caught = v:exception\nendtry\ncall assert_match('no CMakeLists.txt', caught)\n")
        self.assertFalse(self.log.exists())

    def test_lowercase_build_alias(self):
        self.run_vim(self.edit()+r'''call feedkeys(":build_pico\<CR>", 'xt')'''+self.wait())
        self.check_call('build')

    def test_lowercase_flash_alias(self):
        self.run_vim(self.edit()+r'''call feedkeys(":flash_pico\<CR>", 'xt')'''+self.wait())
        self.check_call('flash')

    def test_help_lists_extension_commands(self):
        self.run_vim("Keys\ncall assert_true(search(':build_pico', 'nw') > 0)\ncall assert_true(search(':PicoCheck', 'nw') > 0)")

    def test_project_local_helper_not_loaded_or_executed(self):
        (self.project/'tools').mkdir()
        (self.project/'tools/pico.py').write_text('raise RuntimeError("old project helper")\n')
        (self.project/'init.vim').write_text('let g:project_script_ran = 1\n')
        self.run_vim(self.edit()+"call assert_false(exists('g:project_script_ran'))\nPicoCheck\n"+self.wait())
        self.check_call('check')

if __name__=='__main__':
    unittest.main(verbosity=2)
