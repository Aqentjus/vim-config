# Vim configuration

A portable editor first: custom Kanagawa Dragon, built-in netrw, search, clipboard
shortcuts and small Vimscript helpers. Development tools are optional.

## Install

Use your system's **standard Vim package with its runtime files**. The basic setup
targets Vim 8+; there is no CoC-driven version gate. A tiny/minimal Vim build may
lack syntax, netrw, signs or terminal support. Missing optional tools do not block
ordinary editing. Linux, macOS and native Windows use the same configuration.

Get this repository's `staging` branch with Git, or transfer an extracted archive
to a restricted/offline machine. Git is not needed to run the basic installer.

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
sh ./install.sh
```

Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The basic install copies local files only. **No Node, npm, Python, compiler,
plugin manager, language servers, font installation or network access required.**
The shell installer uses standard system utilities; Windows uses PowerShell.

The small loader goes to `~/.vimrc` (`~/_vimrc` on Windows); modules and themes go
to `~/.vim-config/`. Changed managed files are backed up under
`~/.vim-config/backups/`. Identical files are left alone. Personal `local.vim` and
`coc-settings.json` survive updates. The checkout can be moved or deleted afterward.

```sh
sh ./install.sh --check     # Verify base prerequisites; no writes/downloads
sh ./install.sh --dry-run   # Describe the install; no writes/downloads
```

Windows equivalents are `-Check` and `-DryRun`. To update, get the newer `staging`
files (`git pull --ff-only` for a checkout) and rerun the installer. Close Vim
before updating. To restore a changed managed file, copy it back from the printed
backup path. Updates preserve personal settings and separately installed packages.

## Personal settings and layout

Edit **`~/.vim-config/local.vim`** for your own mappings, indentation and theme
choices. The installer creates this file once from `config/local.vim.example`.
It is loaded after the shared modules; optional completion respects personal mappings.

```text
~/.vimrc                       Small loader
~/.vim-config/
  core/
    options.vim, theme.vim      Editing defaults and appearance
    explorer.vim, icons.vim     netrw and optional icon signs
    search.vim, clipboard.vim   Navigation and copy/paste
    terminal.vim, runner.vim    Per-tab shell/tasks and single-file runner
    completion.vim             Optional CoC integration
    help.vim, doctor.vim        Explicit help and tool report
    extensions.vim             Bundled extension loader
  colors/kanagawa-dragon.vim    Plain Vimscript theme
  extensions/pico/              Optional Python Pico helper
  local.vim                    Your preserved settings
```

Only installed extensions are loaded, never scripts from the project being opened.
For a checkout preview without installing, set `VIM_CONFIG_HOME` to its absolute
`config` directory and run `vim -u /path/to/config/vimrc`.

## Theme and tree icons

The bundled Kanagawa Dragon port uses our brighter Neovim syntax palette, with
no theme plugin, Lua or Tree-sitter. True-color terminals use the full palette;
256-color terminals use approximations. Limited-color terminals keep Vim's default
theme. Set your terminal background to `#181616` if you want it to match.
Vim's native language syntax can color individual tokens differently from Tree-sitter.

Icons are **optional and off by default**. Try one while in the explorer:

```vim
:TreeIcons unicode
:TreeIcons nerd
:TreeIcons off
```

To keep your choice, put this in `local.vim`:

```vim
let g:vim_config_icons = 'unicode'
```

`unicode` uses simple symbols; `nerd` uses folder/file/code/config/image glyphs and
needs a Nerd Font selected in **your local terminal**, including when connected
through SSH. No font or icon package is installed on the server. Unsupported fonts
may show boxes; switch to `unicode` or `off`.

Icons use Vim's built-in sign column on tree/simple listings and do not alter
filenames or netrw actions. They require a Vim build with sign functions. Wide/long
listings remain plain. No icon or explorer plugin is installed.

## Optional completion

Without CoC, **Ctrl-n / Ctrl-p** provide Vim's native word completion. File
completion is available with Ctrl-x Ctrl-f. There are no startup downloads.

For language-server completion, explicitly opt in:

```sh
sh ./install.sh --with-coc
```

Windows: `.\install.ps1 -WithCoc`. This optional path requires Git, npm,
**Vim 9.0.0438+ and Node.js 22.15+**, and downloads CoC if it is not already
installed. The base editor has none of those development-tool requirements.
`--with-coc --check` / `--with-coc --dry-run` inspect this path without downloading.

Then install **only the languages you need**, explicitly inside Vim:

```vim
:CocInstall coc-pyright
:CocInstall coc-clangd
:CocInstall coc-tsserver
```

These are Python, C/C++ (also needs clangd), and JavaScript/TypeScript respectively.
Run only the commands for desired extensions. Check `:CocInfo` and `:CocList extensions`.
Extension installation can fetch additional language-server packages; use your
organization's approval process when applicable. No extension set is installed
automatically. Existing extensions are preserved and can run when CoC is enabled.
Plugin/extension versions are unpinned.

An old `pack/coc/start/coc.nvim` installation is preserved but does **not** auto-load
on upgrade. `--with-coc` reuses it and records the choice in `completion-enabled`.
Later ordinary installs preserve that choice. To disable CoC without deleting its
files, add `let g:vim_config_completion = 0` to `local.vim` and restart Vim.
If an enabled CoC setup lacks its runtime requirements, editing still opens quietly;
`:ConfigDoctor` explains what is unavailable.

## Keys and commands

Space is the leader. Help opens explicitly with `Space h`, `Space ?` or `:Keys`.

| Keys / command | Action |
| --- | --- |
| `Space e` | Focus persistent file explorer |
| `Enter` / `Space n` in explorer | Open/expand entry / create file or `/folder` |
| `Space f` / `Space s` | Find file / search project text from current directory |
| `Space c` | Clear search highlighting |
| `Space t` | Open shell / stop and close this tab's managed shell or task |
| `Space r` / `:RunCode` | Save and run current source file |
| `Ctrl-w N` in terminal | Leave terminal input mode |
| `Space y` | Copy line or visual selection to system clipboard |
| `Space Y` | Copy whole file without moving cursor |
| `Space p` / `Space P` | Paste after/before; Visual: replace while keeping clipboard |
| `:ClipboardHealth` | Show clipboard backend |
| `:ConfigDoctor` | Read-only optional feature/tool report |
| `:BuildPico` / `:FlashPico` / `:PicoCheck` | Build / build and flash / inspect Pico setup |

With CoC enabled: Tab/Shift-Tab select suggestions, Enter accepts, `gd`/`gr` jump to
definitions/references, `K` opens hover, `[d`/`]d` move between diagnostics, and
`Space R` renames a symbol.

## Optional tools, only where needed

| Feature | Tools |
| --- | --- |
| Shell and run output | Vim built with `+terminal`; your shell |
| Run Python | `python3` / `python` (Windows also `py -3`); active virtualenv preferred |
| Run C/C++ | `cc`/`gcc`/`clang` and `c++`/`g++`/`clang++` |
| Run JavaScript | `node` (`.js`, `.mjs`, `.cjs`) |
| Run shell / PowerShell / Lua | `bash` / `pwsh` or `powershell.exe` / `lua` or `luajit` |
| Desktop clipboard | Native Vim clipboard, or existing OS clipboard tools |
| Pico | Python 3.8+, SDK, CMake, Ninja, ARM toolchain; OpenOCD for SWD flashing |

The runner handles single files, not arbitrary project build systems. Each tab has
one managed shell/task. Stop an active task with `Space t` before starting another;
completed output stays visible and is replaced by the next task. Closing a managed
terminal stops its job; detached processes may have their own lifecycle.

The clipboard uses native Vim support where available, then macOS `pbcopy/pbpaste`,
Windows `clip.exe`/PowerShell, or Linux `wl-clipboard`, `xclip`, `xsel` if already
installed. SSH clipboard tools address the remote machine, not necessarily your
local desktop. Terminal copy/paste is always separate; this config adds no OSC 52
transport. Regular yanks/deletes use the system clipboard when native integration
is enabled; use `"_dd` to delete without replacing it. Existing Ctrl-C (Visual) and
Ctrl-V paste mappings remain; Ctrl-q can enter Visual Block mode when received by Vim.
If native clipboard support is unreliable, `let g:vim_config_native_clipboard = 0`
and `set clipboard=` in `local.vim` select available external tools instead.

Pico commands are available only with Python and `+terminal`; no tools are installed
for them. See [Pico details](config/extensions/pico/README.md). Use `:PicoCheck`
before explicitly flashing hardware. The editor never flashes anything at startup.

## Validation

Development-only checks (Python is not required to install/use the editor):

```sh
python3 -m unittest discover -s tests -v
python3 -m unittest discover -s config/extensions/pico -p 'test_*.py'
```

The Unix integration tests use temporary profiles and a restricted PATH without
Node/npm/Git/Python/compilers. They cover copy-only installation, check/dry-run,
upgrade preservation, opt-in completion with fake tools, clipboard with fake OS
tools, netrw icons, and terminal tasks. Pico tests simulate tooling; no hardware is
flashed. Tests require a normal system Vim and Python on the development machine.
Windows installer behavior still needs a native Windows smoke test; the Unix suite
does not validate PowerShell or desktop font rendering.
