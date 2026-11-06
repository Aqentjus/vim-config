"""Host-side tests: no real compiler, SDK, network, or debug probe is used."""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('pico_helper', Path(__file__).with_name('pico.py'))
pico = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pico)


class PicoTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='pico shared ')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.project = self.base / 'school project ää'
        (self.project / 'src').mkdir(parents=True)
        (self.project / 'CMakeLists.txt').write_text('project(blink C CXX ASM)\n')
        self.source = self.project / 'src/main.c'
        self.source.write_text('int main(void) { return 0; }\n')
        self.sdk = self.base / 'sdk'
        self.sdk.mkdir()
        (self.sdk / 'pico_sdk_init.cmake').touch()
        self.tools = self.base / 'installed tools'
        self.tools.mkdir()
        env = {'PICO_SDK_PATH': str(self.sdk), 'PICO_TOOLS_HOME': str(self.tools)}
        for variable, name in [('PICO_CMAKE', 'cmake'), ('PICO_NINJA', 'ninja'),
                               ('PICO_CC', 'arm-none-eabi-gcc'), ('PICO_OPENOCD', 'openocd')]:
            tool = self.tools / name
            tool.touch()
            tool.chmod(0o755)
            env[variable] = str(tool)
        self.environment = patch.dict(os.environ, env, clear=True)
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.calls = []
        self.fail = None
        self.make_elf = True

    def fake_run(self, command, **kwargs):
        step = 'configure' if '-S' in command else 'build' if '--build' in command else 'flash'
        self.calls.append((step, command, kwargs))
        if self.fail == step:
            raise subprocess.CalledProcessError(7, command)
        if step == 'build' and self.make_elf:
            build = Path(command[command.index('--build') + 1])
            build.mkdir(exist_ok=True)
            (build / 'blink.elf').write_bytes(b'fake firmware')
        return subprocess.CompletedProcess(command, 0)

    def invoke(self, action, *extra):
        args = ['pico.py', action, '--project', str(self.project)] + list(extra)
        output = io.StringIO()
        with patch.object(sys, 'argv', args), patch.object(pico.subprocess, 'run', self.fake_run):
            with contextlib.redirect_stdout(output):
                pico.main()
        return output.getvalue()

    def test_project_root(self):
        self.assertEqual(pico.find_project(self.project), self.project)

    def test_nested_folder_and_file(self):
        self.assertEqual(pico.find_project(self.source.parent), self.project)
        self.assertEqual(pico.find_project(self.source), self.project)

    def test_nearest_cmake_is_used(self):
        (self.source.parent / 'CMakeLists.txt').touch()
        self.assertEqual(pico.find_project(self.source), self.source.parent)

    def test_missing_project_reports_error(self):
        with self.assertRaisesRegex(RuntimeError, 'No CMakeLists.txt'):
            pico.find_project(self.tools)

    def test_cli_defaults_to_current_folder(self):
        output = io.StringIO()
        with patch.object(sys, 'argv', ['pico.py', 'check']), patch.object(pico.os, 'getcwd', return_value=str(self.source.parent)):
            with contextlib.redirect_stdout(output):
                pico.main()
        self.assertIn('Project: ' + str(self.project), output.getvalue())

    def test_build_uses_selected_project_not_helper_location(self):
        self.invoke('build')
        self.assertEqual([x[0] for x in self.calls], ['configure', 'build'])
        configure = self.calls[0][1]
        self.assertEqual(configure[configure.index('-S') + 1], str(self.project))
        self.assertEqual(configure[configure.index('-B') + 1], str(self.project / 'build-pico'))
        self.assertFalse((self.project / 'tools/pico.py').exists())
        self.assertIn('--target', self.calls[1][1])
        self.assertIn('blink', self.calls[1][1])

    def test_build_does_not_require_openocd(self):
        os.environ['PICO_OPENOCD'] = str(self.base / 'missing-openocd')
        self.invoke('build')
        self.assertEqual(len(self.calls), 2)

    def test_check_is_read_only(self):
        self.invoke('check')
        self.assertEqual(self.calls, [])
        self.assertFalse((self.project / 'build-pico').exists())

    def test_flash_dry_run_never_runs_a_tool(self):
        self.invoke('flash', '--dry-run')
        self.assertEqual(self.calls, [])
        self.assertFalse((self.project / 'build-pico').exists())

    def test_flash_follows_successful_build(self):
        self.invoke('flash')
        self.assertEqual([x[0] for x in self.calls], ['configure', 'build', 'flash'])
        self.assertEqual(self.calls[-1][2]['cwd'], str(self.project / 'build-pico'))
        self.assertIn('program blink.elf verify reset exit', self.calls[-1][1])

    def test_configure_failure_stops_build_and_flash(self):
        self.fail = 'configure'
        with self.assertRaises(subprocess.CalledProcessError):
            self.invoke('flash')
        self.assertEqual([x[0] for x in self.calls], ['configure'])

    def test_build_failure_never_flashes(self):
        self.fail = 'build'
        with self.assertRaises(subprocess.CalledProcessError):
            self.invoke('flash')
        self.assertEqual([x[0] for x in self.calls], ['configure', 'build'])

    def test_missing_elf_never_flashes(self):
        self.make_elf = False
        with self.assertRaisesRegex(RuntimeError, 'refusing to flash'):
            self.invoke('flash')
        self.assertEqual([x[0] for x in self.calls], ['configure', 'build'])

    def test_missing_sdk_is_explicit_error(self):
        (self.sdk / 'pico_sdk_init.cmake').unlink()
        with self.assertRaisesRegex(RuntimeError, 'Pico SDK not found'):
            self.invoke('build')
        self.assertEqual(self.calls, [])

    def test_missing_tool_is_explicit_error(self):
        os.environ['PICO_CMAKE'] = str(self.base / 'not-installed')
        with self.assertRaisesRegex(RuntimeError, 'PICO_CMAKE'):
            self.invoke('build')
        self.assertEqual(self.calls, [])


if __name__ == '__main__':
    unittest.main()
