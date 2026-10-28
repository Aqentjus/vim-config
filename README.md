# Vim configuration

A portable Vim setup, designed one decision at a time.

## Branches

- `staging` is the development branch: experiments and changes are reviewed here.
- `production` is the intended stable branch: only agreed, checked changes belong there.

The current setup includes the theme, explorer shortcuts, single-file runner,
and basic editing, search, completion, and help facilities. An installer will
be designed separately.

## Decision 1: Gruvbox

- Original `morhetz/gruvbox` colour scheme, stored directly in this repository.
- Dark mode, medium contrast.
- True-colour background `#282828` and normal foreground `#ebdbb2`.
- No plugin manager, automatic downloads, or external runtime for the theme.
- A supplied Vim colour scheme is used when the theme file is missing or the
  terminal cannot display it.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the pinned upstream
revision, attribution and licence information.

## Decision 2: Explorer

The leader key is **Space**. Press the keys in sequence in Normal mode
(press Escape first when leaving Insert mode).

| Keys | Action |
| --- | --- |
| Space, then `e` | Focus the persistent left explorer; never opens or closes it. |
| Enter in the explorer | Open a file in the editing pane, or enter a directory. |
| Space, then `n` in the explorer | Prompt for a new file or directory. |

At the prompt:

- `main.py` creates an empty file in the directory shown by the explorer.
- `/directory1` creates a directory there. The initial slash is a directory
  marker, not an absolute path.
- Escape or an empty answer cancels.
- Existing entries are refused; existing file contents are not overwritten.
- Enter one name at a time. Spaces and Unicode are accepted; nested paths are
  not part of this prompt.

After creation the listing refreshes and focus stays in the explorer. Use
Enter to open the new entry. The sidebar uses 25% of the available width.

**The explorer opens automatically every time Vim starts.** It stays on the
left when you open files through Enter. The editing pane remains focused
initially; Space then e moves the cursor into the explorer without toggling
anything. Deliberately closing the pane with an explicit window command can
still close it; this configuration does not intercept Quit.

This uses Vim's bundled **netrw** explorer. Enter and directory navigation
remain netrw's own behavior. Our two helpers only focus the explorer and
combine file/directory creation into the requested prompt. Creation uses
Vim's `mkdir()` and `writefile()`, without shell commands or extra packages.

## Decision 3: No bells or flashes

Vim's invalid-key and cursor-boundary sounds are silenced using
`belloff=all` and `noerrorbells`. `visualbell` with an empty `t_vb`
also prevents Vim's visual bell from flashing the screen. This only
affects Vim; it does not silence Windows or other applications.

## Decision 4: Persistent explorer

- Running `vim justus.txt` opens the file on the right and its containing
  directory in the always-visible left explorer.
- Running `vim path/to/justus.txt` starts the explorer inside `path/to`,
  even if Vim was launched from a different working directory.
- Running `vim` without a filename shows the current working directory.
- File opening and Space then e never hide the sidebar.
- The initial directory is chosen **only at startup**; subsequent edits do
  not forcibly reset the folder you're browsing.
- The sidebar uses Vim's bundled netrw. The only startup customization is a
  short `VimEnter` hook that opens it once and returns focus to the editor.

## Decision 5: Single-file code runner

In the source-file pane, press Escape, then **Space, r**. The runner saves
that file and opens a new 12-row terminal at the bottom. The file and explorer
remain visible. Input goes to the running program, and output stays visible
after it exits. Each run gets a new pane; existing runs are not killed or reused.

| File extension | Command selection |
| --- | --- |
| `.py` | Active `VIRTUAL_ENV` interpreter; otherwise `py -3` on Windows when available, then `python3` or `python`. Python 3 is expected. |
| `.c` | First available `cc`, `gcc`, or `clang`; compile as C17 with `-Wall -Wextra`, then run. |
| `.cpp`, `.cc`, `.cxx`, `.C` | First available `c++`, `g++`, or `clang++`; compile as C++17 with `-Wall -Wextra`, then run. |
| `.js` | `node` runs the file directly; no npm command or package installation. |
| `.sh` | `bash` runs the file. On native Windows this requires a working native Bash environment, not merely a WSL launcher. |

The operating-system check is automatic. macOS and Linux use the same Unix
path for compilation; native Windows uses `cmd.exe`. No `system = "mac"`
setting is required. Tools must already be installed and discoverable on
`PATH`. Missing tools produce a message without opening an empty terminal.
Vim itself must have `+terminal` support.

### What compiling means

Python source is passed to the Python interpreter. C/C++ source is first
translated into an executable by the compiler. This runner uses `&&` to
execute that result only after successful compilation. Errors stay in the
terminal and an old program is never used as a fallback.

This first version runs **one source file**, not an entire project. A complete
program in `main.c` works. A project with `main.c` plus `sensor.c`, library
linking requirements, a Pico SDK, or a build system needs its own build command.
The runner deliberately does not guess those commands or invoke a package manager.

### Behaviour and controls

- The process runs in the source file's directory, independent of the
  directory currently browsed in the explorer.
- A failed save stops the run instead of executing the old file on disk.
- Interpreted commands use argument lists. Compiled commands pass paths in
  quoted environment variables, avoiding filename interpolation into shell code.
- C/C++ executables use a temporary path and are removed on process exit.
  No executable is written over an existing file in the project.
- Completion is reported as `Runner: process exited with code N` in Vim's
  messages; output and errors remain in the terminal.
- **Ctrl+W, w** switches panes using Vim's existing terminal controls.
- **Ctrl+W, N** enters Terminal-Normal mode for scrolling or normal mappings;
  press `i` to send input to a still-running program again.
- After the program exits, **Ctrl+W, c** closes that output pane. A running
  program can normally be interrupted with **Ctrl+C** while its terminal is focused.

No new editor plugin, package manager, runtime download, or custom process
manager is introduced. Only a dispatch function and an exit/cleanup callback
are added to `vimrc`. Interpreters, compilers, and their installed launchers
remain external programs with their own configuration.

## Decision 6: Line numbers and indentation

- Code buffers use absolute line numbers; the explorer, terminal, and help
  page do not display them.
- Vim's built-in filetype indentation and autoindent are enabled.
- Tabs insert spaces. The default width is **2 spaces**, including C/C++
  and JavaScript. Python uses its conventional **4 spaces**.
- No external formatter, indentation engine, or plugin is installed.

## Decision 7: Search

- `/text` and `?text`: search forward/backward in the current file.
- `n` and `N`: next/previous match.
- Incremental highlighting, case-insensitive search by default, and
  uppercase-sensitive matching (`ignorecase` + `smartcase`).
- **Space then c**: clear search highlighting.
- **Space then f**: start built-in `:find` filename lookup (type a filename
  and Enter). Vim's path contains recursive `**`.
- **Space then s**: prompt for literal text, recursively run built-in
  `:vimgrep` from the **current working directory**, and show quickfix
  results. Navigate with `:cnext` and `:cprev`, close with `:cclose`.

Check the search root using `:pwd` or change it with `:cd path`. For
project-wide searching, start Vim in that project's root directory.
`:vimgrep` may be slower for very large trees; no external `rg`,
package manager, or search plugin is required.

## Decision 8: Insert-mode Tab completion

- On an empty/indented line, Tab inserts indentation as usual.
- After a word prefix, Tab shows keyword suggestions using Vim's built-in
  completion from open buffers.
- Python also has a small, explicit list of common built-in calls,
  including `print()`. In a new `.py` file, type `pri`, then Tab,
  then Enter to accept `print()`.
- While suggestions are open, Tab cycles forward; Shift+Tab cycles back
  when the terminal supports that key combination.
- Enter accepts a selected candidate; Ctrl+E cancels completion.

This is intentionally **not IDE/LSP semantic completion**: it does not
understand imports, types, every library API, or whole-project symbols.
Only common Python built-ins are bundled as callable suggestions; other
languages use matching words already present in buffers.

## Decision 9: Keyboard reference

Press **Space then h** or type **`:Keys`** to open a simple, self-contained
table of shortcuts and everyday commands in a temporary Vim tab.
Press **q** to close that tab and return to the editor and explorer.
Native `:help {topic}` remains unchanged and available.

## Try the staging version

Install Git and a full Vim build with evaluation and syntax support, then:

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
vim -u ./vimrc
```

This loads this repository's configuration for that Vim session without
installing it over your personal configuration. The config explicitly selects
Vim defaults (`set nocompatible`), which are needed because `-u` by itself does
not disable Vi compatibility mode.

The same commands work in PowerShell when `git` and `vim` are on `PATH`.
Run `vim -u ./vimrc` from inside the cloned repository, on `staging`.

The config enables true colour when Vim supports it and either its built-in
`has('vcon')` check detects a working Windows virtual console, or the terminal
advertises `COLORTERM=truecolor` or `COLORTERM=24bit`. An already-enabled
`termguicolors` setting is preserved. Otherwise Gruvbox uses its 256-colour
approximations. A terminal with neither capability uses Vim's default scheme.

## Validation

The included colour file is byte-for-byte identical to the pinned upstream
Git blob. Its basic theme does not depend on the optional Gruvbox autoload
helpers. The effect of `set nocompatible` with `-u` was checked using Vim 9.1's
tiny build: it selects Vim defaults and enables the line continuations the
theme needs. Full theme rendering and native Windows execution of this
revision have not been tested in the preparation environment.

The focus-only explorer mapping was exercised with Vim 9.1 (huge build):
without an explorer it leaves the layout unchanged; with a netrw window
open it focuses that window, and repeating the command does not close it.
Vim reported `belloff=all`, `noerrorbells`, `visualbell`, and an empty
`t_vb` in the same test. The persistent explorer startup was also tested locally using Vim 9.1 in a
real terminal: starting with no filename, opening a file in a nested folder,
focusing the explorer, and opening a different file through Enter all kept
a two-pane layout. Native Windows execution still needs to be checked
on the actual machine.

The single-file runner was tested with Vim 9.1.1244 (huge build, +terminal)
on Linux. Passing checks covered Python, C, C++, JavaScript, Bash, interactive
Python/C input, automatic saving, filenames with spaces and shell-special
characters, source-directory working paths, compile/runtime failures, missing
tools, unsupported extensions, failed saves, and visible source/explorer/output
panes. Temporary-executable cleanup was checked too. Native Windows and macOS
execution have not been tested here; these branches remain staging work.

The new editor features were tested with Vim 9.1 (huge, terminal build) on
Linux: `pri<Tab><Enter>` generated `print()` in Python; a JavaScript buffer
word completed; Python and C indented by four and two spaces respectively;
recursive search populated quickfix; and `:Keys` and Space then h opened the
closable help tab. Native Windows and macOS runs still require verification.
