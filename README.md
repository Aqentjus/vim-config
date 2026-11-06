# Vim configuration

Vim with **Gruvbox**, a persistent netrw explorer, clipboard shortcuts,
single-file code execution, Raspberry Pi Pico build/flash commands, and
**coc.nvim** for IntelliSense and automatic suggestions.

The `staging` branch is for changes and testing. `production` is stable.

## Installation

Requires **Vim 9.0.0438+**, **Node.js 22.15+**, npm and Git. The installers
check these dependencies rather than installing system software.

macOS / Linux:

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
sh ./install.sh
```

Windows (PowerShell):

```powershell
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The installer **copies** the configuration from the checkout (no symlinks and
no dependency on that checkout afterward). macOS and Linux use `~/.vimrc`;
native Windows Vim uses `~/_vimrc`.

```text
~/
├── .vimrc                           macOS/Linux; _vimrc on Windows
└── .vim-config/
    ├── colors/gruvbox.vim
    ├── extensions/pico/             custom extension and Python helper
    ├── coc-settings.json            your settings; never overwritten
    ├── pack/coc/start/coc.nvim/     release branch, installed via Git
    ├── coc-data/                   CoC extensions and state
    └── backups/                    replaced files, when necessary
```

Rerun the installer after any repository update. It copies changed managed
files, backs up prior versions under `~/.vim-config/backups/`, skips unchanged
files and preserves extra files you added. Existing `coc-settings.json` is
never overwritten. The repo can be moved or removed after installation.

## First launch and CoC

Start Vim from the source project's directory. CoC automatically installs
`coc-clangd` (C/C++) and `coc-pyright` (Python) the first time it starts.
These extension downloads require internet connectivity. Check status with
`:CocInfo` or `:CocList extensions`.

For C/C++, clangd must be on PATH or downloaded via
`:CocCommand clangd.install`. For Raspberry Pi Pico builds, make
`build-pico/compile_commands.json` discoverable to clangd (for example, by a
symlink from the project root). The compilation database is needed for SDK
headers and correct include paths.

Use `:CocConfig` to edit the JSON file within your private Vim folder.

## Key bindings

| Keys / command | Behavior |
| --- | --- |
| Space e | Focus explorer (netrw) |
| Enter (explorer) | Open file / expand directory |
| Space n (explorer) | Create a file / folder |
| Space r | Save and run Python, C/C++, JS, or shell source |
| Space f / Space s | Find file / search project text |
| Space c | Clear search highlight |
| Space h / :Keys | Show built-in help |
| Typing | Auto-suggest using CoC |
| Tab / Shift+Tab | Next / previous completion, or indent |
| Enter | Confirm completion |
| gd / gr | Definition / references |
| K | Hover information |
| [d / ]d | Previous / next diagnostic |
| Space R | Rename symbol |
| :CocInfo / :CocConfig | CoC health / config |
| :BuildPico / :build_pico | Configure and build Pico project |
| :FlashPico / :flash_pico | Build, SWD flash and verify |
| :PicoCheck | Inspect Pico tool paths without flashing |

The editor's existing clipboard, mouse selection, indentation and terminal
key bindings are preserved. Use `:Keys` for the full built-in cheatsheet.
See [the Pico extension](config/extensions/pico/README.md) for build details.

## Source repository

```text
vim-config/
├── config/
│   ├── vimrc
│   ├── coc-settings.json
│   ├── colors/gruvbox.vim
│   └── extensions/
│       ├── README.md
│       └── pico/                  init.vim, pico.py, tests and docs
├── install.sh                     macOS / Linux
├── install.ps1                    Windows
├── THIRD_PARTY_NOTICES.md         theme attribution and licensing
└── README.md
```

`config/` contains everything copied into the standalone installation.
coc.nvim itself is fetched from its official release branch, rather than
being vendored in this repository.

## Updating, testing and recovery

To update the source configuration, run `git pull --ff-only` inside the
checkout and rerun the installer. Your previous files are backed up.

To update coc.nvim itself:

```sh
git -C "$HOME/.vim-config/pack/coc/start/coc.nvim" pull --ff-only origin release
```

To update CoC's language extensions, run `:CocUpdate` within Vim.
To preview source code without installing:

```sh
VIM_CONFIG_HOME="$(pwd)/config" vim -Nu ./config/vimrc
```

This preview won't install coc.nvim; CoC's keys activate after actual install.
The Pico tests simulate tools without touching real hardware:

```sh
python3 -m unittest discover -s config/extensions/pico -p 'test_*.py' -v
```
