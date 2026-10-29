# Optional Pico commands

Nothing in this directory is loaded by the core vimrc. No toolchain is installed
by Vim's installer, and the normal Space-r single-file runner is unchanged.

## Enable for this Vim session

```vim
:runtime optional/pico.vim
```

This requires the optional file to be present in the active vim-config checkout.
A project-local copy can instead be loaded with `:source tools/pico.vim`.
There is no project auto-execution on entering a directory or opening a file.

## Commands

| Command | Project helper invoked |
| --- | --- |
| `:BuildPico` | Python 3, `tools/pico.py build` |
| `:FlashPico` | Python 3, `tools/pico.py flash` |
| `:PicoCheck` | Python 3, `tools/pico.py check` |

When typed, `:build_pico` and `:flash_pico` expand to the capitalized commands.
These exact-command abbreviations avoid changing unrelated command arguments.
Use the capitalized forms in Vim scripts. Vim user-command names must start
with an uppercase letter and otherwise contain letters or digits.

The optional bridge searches upward from the current file for a project
containing both `CMakeLists.txt` and `tools/pico.py`. Run it in a trusted project.
It opens a bottom terminal and leaves the command output visible. Build/flash
save the current buffer and refuse to proceed when other project files have
unsaved changes; save those first. The project helper owns ALL board, SDK,
compiler, OpenOCD and build settings. It can also be used without Vim.

## Project-side requirement

Place the reviewed, project-specific `pico.py` helper in the project's `tools/`
directory. This bridge does not invent, download or generate that helper. The
Pico project patch supplied alongside this change includes it, its setup guide,
and the CMake adjustment removing the VS Code extension include. Application
source files and SDK/toolchain binaries are not published in this Vim repo.

Python 3 and Vim +terminal are required. There are no Vim plugin dependencies.
Use a machine with access to the intended USB debug probe for physical flashing.
Do not run simultaneous builds/flashes against the same project.

## Validation

Tested with Vim 9.1 on Linux using a fake project helper: all three commands,
both lowercase abbreviations, terminal output, project paths with spaces and
Unicode, saving the current buffer, and refusal of unsaved sibling edits.
These tests do not establish a successful hardware build or SWD upload.
Native Windows/macOS and the actual toolchain/probe still need validation.

References: https://vimhelp.org/map.txt.html#user-commands and
https://vimhelp.org/terminal.txt.html#term_start()
