# Pico build/flash extension

The Vim commands and Python helper now live together in `extensions/pico/`.
The core vimrc loads `init.vim` automatically and quietly. Projects no longer
need `tools/pico.py`, `tools/pico.vim`, or an explicit `:source` command.
The normal Space+r single-file runner is unchanged.

## Commands

| Type in Vim | Action |
| --- | --- |
| `:build_pico` / `:BuildPico` | Save the active source, configure and build. |
| `:flash_pico` / `:FlashPico` | Build first, then SWD program/verify/reset on success. |
| `:PicoCheck` | Show tools, project path and commands without running tools or touching hardware. |

The lowercase names are exact command-line abbreviations; use the uppercase
names in scripts. Output remains visible in a bottom terminal. The commands
also appear in the Space+h / :Keys table when this extension is available.

## Finding the project

The bridge starts from the folder currently shown in netrw, the directory of
the active source file, or Vim's current directory when no source is active.
It walks **upwards** and chooses the nearest folder containing `CMakeLists.txt`.
It never searches random subfolders or derives the project path from where
`pico.py` is installed. If no CMake file is found, it stops with a clear error.

Open the intended top-level project folder (or its `main.c`). If a nested
folder has its own `CMakeLists.txt`, that nearer CMake file wins; use the explorer
at the top-level folder to build the enclosing project. The helper does not
attempt to parse or guess arbitrary CMake build structures.

Build output stays in `<project>/build-pico/`, not in the Vim repository.
The original `build/` directory is not touched. The current source is saved
before build/flash. Other unsaved project buffers prevent the operation; save
them first. Do not run simultaneous builds/flashes for the same project.

## Kept deliberately unchanged

This is a relocation of the previously working school-project helper, **not** a
new universal Pico build system. The explicit defaults at the top of `pico.py`
remain `pico_w`, RP2040, target `blink`, `build-pico/blink.elf`, CMSIS-DAP, and
5000 kHz SWD. The SDK/tool versions and command sequence are unchanged. Different
boards or target names require deliberately changing those settings; discovery
finds the project directory, not its complete board/tool configuration.

The project keeps its sources, `CMakeLists.txt`, `pico_sdk_import.cmake`, and any
other genuine project dependencies. Keep the standalone CMake changes from the
previous patch: moving the helper does not remove extension-dependent CMake
includes from an unmodified VS Code project.

## Migration

In the installed vim-config checkout, update the `staging` branch and restart Vim.
Run `:PicoCheck` from your Pico project, then test `:build_pico`. No manual source
step is required. After that succeeds, the **two old helper copies**
`tools/pico.py` and `tools/pico.vim` in the project can be removed; do not delete
unrelated files from `tools/`. The old `optional/` directory in this repository
has been replaced by `extensions/`. The installers need no changes because they
already load the checkout's vimrc in place.

## Without Vim

From the project directory (substitute the actual vim-config checkout path):

```sh
python3 /path/to/vim-config/extensions/pico/pico.py check
python3 /path/to/vim-config/extensions/pico/pico.py build
```

Or supply the project explicitly from anywhere:

```sh
python3 /path/to/vim-config/extensions/pico/pico.py check --project /path/to/project
python3 /path/to/vim-config/extensions/pico/pico.py flash --project /path/to/project --dry-run
```

On native Windows, use `py -3` instead of `python3` as appropriate. Python 3.8+
is required; the helper uses the standard library only.

## Existing tool locations and overrides

By default the helper uses the previous bundle beneath `~/.pico-sdk`:
SDK 2.3.1, toolchain 15_2_Rel1, CMake v4.3.4, Ninja v1.13.2 and OpenOCD 0.12.0+dev.
Those are preserved project defaults, not a claim of latest available versions.
Executable selection is explicit environment override, then the known bundle,
then PATH. Do not delete the SDK/tool files when removing VS Code.

| Variable | Meaning |
| --- | --- |
| `PICO_TOOLS_HOME` | Alternative root for the bundled tools. |
| `PICO_SDK_PATH` | SDK directory containing `pico_sdk_init.cmake`. |
| `PICO_TOOLCHAIN_PATH` | Root containing `bin/arm-none-eabi-gcc`. |
| `PICO_CC` | Explicit Arm compiler executable. |
| `PICO_CMAKE`, `PICO_NINJA`, `PICO_OPENOCD` | Executable paths or names. |
| `OPENOCD_SCRIPTS` | Directory containing the CMSIS-DAP and RP2040 configs. |
| `PICOTOOL_DIR`, `PIOASM_DIR` | Optional installed CMake package directories. |
| `PICO_SWD_SPEED` | Positive SWD speed in kHz; defaults to 5000. |

The helper does not fetch tools. The SDK itself may fetch/build its auxiliary
tools if they are not installed. Building does not require OpenOCD; check/flash
do. Physical flashing requires access to the intended USB probe and board.
UART monitoring, GDB UI, and toolchain installation are not implemented here.

## Regression tests

From the vim-config checkout:

```sh
python3 -m unittest discover -s extensions/pico -p 'test_*.py' -v
```

The relocation was tested with 15 Python orchestration tests and 15 tests using
real Vim 9.1 on Linux with a fake project helper. Coverage includes automatic
silent loading, missing folders/helpers/Python, broken extension isolation,
project discovery from source/explorer/cwd, path spaces and Unicode, saving,
unsaved sibling refusal, lowercase aliases, help rows, build failure, and
refusal to flash without successful build output.

These are host-side tests with simulated build/probe tools. They do not establish
a hardware flash, real Arm compilation, or native macOS/Windows validation of
this revision. The user reported a successful build before this relocation;
physical SWD flashing remains untested. Production is not changed by staging work.
