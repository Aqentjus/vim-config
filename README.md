# Vim configuration

Gruvbox · netrw explorer · coc.nvim (C/C++ and Python) · Pico build/flash tools.

## Prerequisites

**Required on `PATH` for installation:**

| Command | Requirement |
| --- | --- |
| `vim` | Vim **9.0.0438+** (full build with `+terminal` for running code/Pico) |
| `git` | Clone this repository and install coc.nvim |
| `node` | Node.js **22.15.0+** for coc.nvim |
| `npm` | CoC language extensions |

**Only needed for the features you use:**

| Feature | Commands / dependencies |
| --- | --- |
| Run Python or use Pico commands | Python **3.8+**: `python3` or `python` on `PATH` (Windows also supports `py -3`) |
| Run C / C++ | `cc` / `gcc` / `clang` and `c++` / `g++` / `clang++`, respectively |
| Run JavaScript / shell | `node` / `bash`, respectively |
| C/C++ IntelliSense | `clangd` on `PATH`, or install it with `:CocCommand clangd.install` |
| Pico build | Pico SDK, `cmake`, `ninja`, `arm-none-eabi-gcc` |
| Pico flash | Pico build dependencies + `openocd` and CMSIS-DAP/OpenOCD scripts |
| Linux system clipboard fallback | `wl-copy` + `wl-paste`, `xclip`, or `xsel` if Vim lacks native clipboard support |

Pico tools can instead live in the expected `~/.pico-sdk/` directories or be configured with `PICO_*` environment variables; they do **not** all need to be on `PATH`. See [Pico details](config/extensions/pico/README.md). Internet access is needed to download coc.nvim and CoC extensions.

## Install

**macOS / Linux**

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
sh ./install.sh
```

**Windows (PowerShell)**

```powershell
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The installer copies `vimrc` to `~/.vimrc` (Windows: `~/_vimrc`) and everything else into `~/.vim-config/`. Existing changed files are backed up; your `coc-settings.json` is preserved. The checkout is no longer needed after installation.

To update the configuration: `git pull --ff-only`, then rerun the installer. On first launch, use `:CocInfo` to check CoC.

## Keybindings

`Space` is the leader key.

| Keys / command | Action |
| --- | --- |
| `Space e` | Focus the persistent file explorer |
| `Enter` / `Space n` (explorer) | Open a file or directory / create a file or directory |
| `Space r` | Save and run the current source file |
| `Space f` / `Space s` | Find a file / search project text |
| `Space c` / `Space h` | Clear search highlights / open help |
| `Space y` / `Space p` | Copy selection or line / paste from system clipboard |
| `Tab` / `Shift+Tab` | Navigate CoC suggestions (Tab indents when appropriate) |
| `Enter` (completion) | Accept suggestion |
| `gd` / `gr` | Go to definition / find references |
| `K` | Show symbol documentation |
| `[d` / `]d` | Previous / next diagnostic |
| `Space R` | Rename symbol |
| `:BuildPico` / `:FlashPico` | Build / build and flash Pico |
| `:PicoCheck` | Check Pico tool configuration |
| `:CocInfo` / `:CocConfig` | CoC status / settings |

Full shortcuts: `Space h` or `:Keys` inside Vim.
