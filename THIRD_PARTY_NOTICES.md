# Third-party notices

## Gruvbox

`config/colors/gruvbox.vim` is an unmodified copy of the original Gruvbox colour scheme.

- Author: Pavel Pertsev (morhetz), <morhetz@gmail.com>.
- Upstream: https://github.com/morhetz/gruvbox
- Revision: `ef8864bb42bf244f0295d1c5a403b27e3d139695`.
- Source: https://github.com/morhetz/gruvbox/blob/ef8864bb42bf244f0295d1c5a403b27e3d139695/colors/gruvbox.vim
- Git blob: `66246fba24fd49eeb50dd833094d272f0bbab640`.
- SHA-256: `55116926ba2b625837d9ae89349a5688d60d0b32acdbd8887e1c0d225f079c3d`.

The upstream source header, including its author and source attribution, is
preserved verbatim.

### Upstream licence declarations

The [upstream README at this revision](https://github.com/morhetz/gruvbox/blob/ef8864bb42bf244f0295d1c5a403b27e3d139695/README.md)
declares its licence as **MIT/X11**, linking to
<https://en.wikipedia.org/wiki/MIT_License>.

The [upstream package metadata at this revision](https://github.com/morhetz/gruvbox/blob/ef8864bb42bf244f0295d1c5a403b27e3d139695/package.json)
identifies the author as `Pavel Pertsev <morhetz@gmail.com>` and declares
`"license": "MIT"`.

Upstream does not include a standalone `LICENSE` file at this revision. This
notice preserves its published licence declarations without representing an
invented licence file as an upstream original.

### Included scope

Only the colour file is included. The optional Gruvbox autoload convenience
functions and integrations are not used. Loading the theme makes no network
requests and requires no package manager or external language runtime.

## Plugins installed separately

The repository does **not** contain copies of the following plugins.
The installer downloads coc.nvim from its upstream `release` branch, and
coc.nvim fetches the configured extensions on first launch. Their versions
and transitive dependencies can change independently of this repository.

| Component | Upstream | License |
| --- | --- | --- |
| **coc.nvim** | https://github.com/neoclide/coc.nvim | MIT |
| **coc-clangd** | https://github.com/clangd/coc-clangd | Apache-2.0 WITH LLVM-exception |
| **coc-pyright** | https://github.com/fannheyward/coc-pyright | MIT |

- **coc.nvim** — Copyright 2018–2026 Qiming Zhao. See the
  [upstream MIT license](https://github.com/neoclide/coc.nvim/blob/master/LICENSE.md).
- **coc-clangd** — its [package metadata](https://github.com/clangd/coc-clangd/blob/master/package.json)
  declares `Apache-2.0 WITH LLVM-exception`. The
  [upstream license file](https://github.com/clangd/coc-clangd/blob/master/LICENSE)
  contains Apache License 2.0 and the LLVM exceptions.
- **coc-pyright** — Copyright (c) 2021 Heyward Fann. See the
  [upstream MIT license](https://github.com/fannheyward/coc-pyright/blob/master/LICENSE).

These components retain their own upstream copyright notices and license
terms; this project does not claim ownership of them. Any separately
downloaded language servers (such as clangd), runtime packages, and other
dependencies are subject to their respective licenses, which should be
consulted in the installed packages or upstream repositories.
