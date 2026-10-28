# Vim configuration

A portable Vim setup, designed one decision at a time.

## Branches

- `staging` is the development branch: experiments and changes are reviewed here.
- `production` is the intended stable branch: only agreed, checked changes belong there.

The current setup includes the theme, explorer shortcuts, single-file runner,
editing, search, completion, clipboard support, and portable installers.
All changes are tested first on staging; production stays stable.

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
- The sidebar uses Vim's bundled netrw. A `VimEnter` hook opens it once
  and returns focus to the editor.
- **Enter on a file in the explorer always targets the existing editor window.**
  The hook explicitly stores that window's number in `g:netrw_chgwin` and uses
  `g:netrw_browse_split=0` so netrw respects the target instead of replacing
  the explorer buffer. It determines the target from the actual editing window,
  rather than assuming it must always be window number 2.
- `production` is unchanged while this correction is tested on macOS.

### Regression check: editor vs. explorer

This corrects a macOS report where opening a file from the tree replaced
the tree itself. The issue can be reproduced if netrw's `g:netrw_chgwin`
mistakenly points at the explorer (window 1).

Locally tested using Vim 9.1 on Linux: starting with either netrw's default
target or a deliberately incorrect target, opening a file with Enter retained
the explorer on the left and loaded the chosen file on the right. macOS
requires confirmation using the user's installed Vim build.

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

## Decision 10: Mouse selection and system clipboard

- **Left-click** positions the cursor; **click-and-drag** selects and
  highlights text using Vim's Visual mode. It remains selected after release.
- Keyboard selection still works via `v` (characters) and `V` (lines).
- **Space then y** copies the selection to the operating system's clipboard.
  From Normal mode, it copies the whole current line.
- **Space then p** pastes from the operating system clipboard in Normal mode.
- Regular Vim `y` / `p` continue to work. When a clipboard-capable Vim
  build is available, the native `clipboard` setting also integrates
  normal yank/put operations with the desktop clipboard.
- Native Visual highlighting comes from Gruvbox; no UI extension is needed.
- UTF-8 is explicitly selected to preserve Unicode text across machines.

### How cross-platform clipboard access works

The configuration detects the platform and prefers Vim's own clipboard
registers when available. Otherwise it uses existing platform tools:

| Platform | Built-in or fallback |
| --- | --- |
| Windows | Vim's native clipboard; otherwise `clip.exe` and PowerShell |
| macOS | Vim's native clipboard; otherwise system `pbcopy` / `pbpaste` |
| Linux Wayland | Vim's desktop clipboard, or `wl-copy` / `wl-paste` |
| Linux X11 | Vim's desktop clipboard, or `xclip` / `xsel` |

A Linux graphical session needs access to its compositor/display and a
clipboard-capable Vim build **or** one of the mentioned command-line tools
installed. Headless SSH sessions do not automatically have a local desktop
clipboard. The config reports failure rather than silently copying nowhere.

Use **`:ClipboardHealth`** to see the selected backend and Vim's feature
status. It reports detection, not a proven live connection.

### Familiar desktop shortcuts

The preferred workflow is **mouse drag to select**, followed by the system
copy/paste shortcuts:

| Environment | Copy selection | Paste |
| --- | --- | --- |
| Windows native Vim / Windows Terminal | Ctrl+C | Ctrl+V |
| Linux native Vim / GUI terminals that pass these keys | Ctrl+C | Ctrl+V |
| MacVim GUI | Command+C | Command+V |
| macOS iTerm2 | Command+C with the profile mapping below | Command+V (terminal paste) |

Ctrl+C is mapped in **Visual mode only**, so it does not replace Vim's
normal interrupt/cancel behaviour elsewhere. Ctrl+V is mapped in Normal,
Insert, and Visual modes; in Visual mode it replaces the selected text.
This overrides Vim's original Ctrl+V block-selection shortcut. The existing
Space+y and Space+p are retained as fallback controls rather than primary
shortcuts.

**Terminal limitation:** a terminal emulator may intercept Ctrl+C/V or
Command+C/V instead of passing them to Vim. With `mouse=a`, dragging
normally creates a Vim Visual selection, not a terminal selection. In Windows
Terminal, Ctrl+C copies a terminal selection if present, but otherwise sends
the key through to Vim. Ctrl+V is normally intercepted by Windows Terminal
and pasted from the clipboard; Vim's bracketed-paste support handles this.
Other terminal programs may use different shortcuts.

**For macOS with iTerm2** (recommended terminal path): open
*iTerm2 → Settings → Profiles → Keys → Key Mappings*. Set Command+C
to **Copy or send ^C**. If iTerm2 has a normal terminal selection it will
copy that; otherwise it sends Ctrl+C to Vim, where our Visual-mode
mapping copies the selection. Keep Command+V assigned to **Paste**.
These are iTerm2 settings, not Vim settings, and are not synchronized
by the vim-config Git repository. For Apple Terminal.app or other Mac
terminals, their own keybinding behaviour must be configured; the
`.vimrc` alone cannot see an intercepted Command key.

In a headless SSH session or a terminal without a working clipboard backend,
native desktop shortcuts cannot guarantee OS clipboard access. Run
`:ClipboardHealth` to identify the backend.

The Ctrl+C and Ctrl+V maps were tested with Vim 9.1 on Linux using a mock
X11 clipboard utility. Visual-mode Ctrl+C copied the selected text,
Ctrl+V pasted in Normal and Insert modes, and Ctrl+V replaced a selection
in Visual mode. Windows Terminal, Linux graphical terminals, iTerm2, and
MacVim must still be checked on their actual systems.

When a program is running in a Vim terminal pane, use
**Ctrl+W then N** to enter Terminal-Normal mode before using Vim's text
selection and copy controls on its output.

### Validation and limitations

The config and fallback clipboard commands were exercised using Vim 9.1
(huge build, without +clipboard) on Linux, with a simulated X11 `xclip`
utility. Tests covered Visual copy, whole-line copy, paste from an external
clipboard value, Unicode characters, preserved Vim registers, and the
`:ClipboardHealth` diagnostic. The built-in Visual highlight group is
present. The pre-existing Neovim-only `TermOpen` autocmd was corrected to
Vim's `TerminalWinOpen` to prevent a startup error.

Actual GUI mouse dragging and native Windows, macOS, and Linux desktop
clipboard integration still require checks in those environments.

## Decision 11: Built-in explorer tree

The permanent left sidebar now uses netrw's built-in **tree-style** listing,
with the informational banner hidden. These are only two netrw settings:
`g:netrw_liststyle=3` and `g:netrw_banner=0`. No NERDTree,
Neo-tree, icon dependency, or plugin manager is installed.

- **Enter** on a directory expands/collapses the corresponding branch.
- **Enter** on a file continues to open it in the large editor window.
- **Space then e** only changes focus, never hides the explorer.
- **Space then n** still creates a file or folder in the directory currently
  being browsed. It now refreshes the tree without replacing the editor pane.
- **i** in netrw cycles through the built-in listing styles if you prefer
  to compare thin, long, wide, or tree views.

The tree changes were tested on Vim 9.1 (Linux), including nested directory
expansion, opening files in the right-hand pane, and refreshing after creating
a new file. Tree-mode Windows compatibility is **not yet verified**. Some
recent Windows Vim/netrw versions have a reported tree-mode navigation bug:
https://github.com/vim/vim/issues/19264
We should test this on your Windows and macOS machines before promoting it.

## Decision 12: One-command portable installation

**These installers are on staging only until tested on Windows and macOS.**
The commands below explicitly clone staging. After promotion to production,
a normal default-branch clone will work without `--branch staging`.

The installers require **Vim already installed**, and Git to clone the
repository. They do not install software packages, Vim plugins, or change
machine-wide settings, and **do not require administrator/sudo privileges**.

### macOS / Linux

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
sh ./install.sh
```

This creates `~/.vimrc` as a symbolic link directly to the cloned
`vimrc`. The colour scheme remains inside the checkout; the
configuration locates it relative to its real file path. Previous `~/.vimrc`
is moved to a timestamped backup before installing. Running the installer
again against the same checkout is a no-op.

### Native Windows (PowerShell)

```powershell
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Inspect the script before invoking it. The execution-policy setting applies
only to that PowerShell process; it is not a permanent change to Windows.

The script creates `~\_vimrc` containing a tiny Vimscript loader
pointing to this checkout's `vimrc`, rather than creating a symlink.
Windows therefore needs no Developer Mode or elevated permissions. It
backs up an existing `_vimrc` with a timestamp, and running the same
installer twice does not create extra backups.

Note: `_vimrc` takes precedence over `.vimrc` on native Windows Vim.
An existing `.vimrc` is left untouched, so you can restore it later.

### Testing staging without replacing the installed configuration

From a normal clone on the default `production` branch:

```sh
git switch --track origin/staging
vim -u ./vimrc
```

This runs the staging configuration for that Vim session without installing
it. If you decide to install staging, run the appropriate installer in that
checkout. The loader follows whichever branch you check out there.

### Updates, backups and limitations

From the **same checkout that you installed**, run `git pull --ff-only`,
then restart Vim. Since the config points into the checkout, no second copy
step is required. Do not move or delete the checkout while it is installed.

If you want to undo installation, remove the installed link/loader and restore
the timestamped `.vimrc.backup.*` or `_vimrc.backup.*`
file that the script printed. Neither installer modifies existing Vim plugin
directories, so separately installed plugins on an older machine might still
load. This configuration itself fetches no plugins.

The macOS/Linux installer was tested on Linux with pre-existing config,
a path containing spaces, repeated installation, backups, and updated Vim
settings loaded from the checkout. The generated Windows loader syntax was
tested in Vim with spaces and apostrophes in paths. PowerShell itself has not
been run on Windows in the test environment.

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
