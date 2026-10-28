# Vim configuration

A portable Vim setup, designed one decision at a time.

## Branches

- `staging` is the development branch: experiments and changes are reviewed here.
- `production` is the intended stable branch: only agreed, checked changes belong there.

The current setup includes the theme and explorer shortcuts. An installer
and the remaining editor behaviour will be designed separately.

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
| Space, then `e` | Focus an existing explorer in this tab, or open a left sidebar. |
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

This uses Vim's bundled **netrw** explorer. Enter and directory navigation
remain netrw's own behavior. Our two helpers only focus the explorer and
combine file/directory creation into the requested prompt. Creation uses
Vim's `mkdir()` and `writefile()`, without shell commands or extra packages.

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

The explorer code was reviewed against Vim's netrw documentation and source,
including the Vim 9.1 and current bundled versions. The preparation environment
only has tiny Vim without evaluation or netrw, and fetching a full runtime was
unavailable. The explorer shortcuts have therefore not been runtime-tested here.
