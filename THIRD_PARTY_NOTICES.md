# Third-party notices

## Molokai

`config/colors/molokai.vim` is a copy of Tomas Restrepo's
[Molokai Vim colorscheme](https://github.com/tomasr/molokai).
Based on the Monokai theme by Wimer Hazenberg and its darker variant
by Hamish Stuart Macpherson.

The source file is redistributed under the **MIT License**.
The upstream copyright and license notice follows:

monokai theme copyright Wimer Hazenberg.

molokai.vim source code is licensed as follows:

The MIT License (MIT)

Copyright (c) 2011 Tomas Restrepo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

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
| **coc-html** | https://github.com/neoclide/coc-html | MIT |
| **coc-css** | https://github.com/neoclide/coc-css | MIT |
| **coc-tsserver** | https://github.com/neoclide/coc-tsserver | MIT |
| **coc-json** | https://github.com/neoclide/coc-json | MIT |
| **coc-yaml** | https://github.com/neoclide/coc-yaml | MIT |
| **coc-sh** | https://github.com/josa42/coc-sh | MIT |
| **coc-powershell** | https://github.com/coc-extensions/coc-powershell | MIT |
| **coc-docker** | https://github.com/josa42/coc-docker | MIT |
| **coc-luals** | https://github.com/xiyaowong/coc-luals | MIT |
| **coc-sql** | https://github.com/fannheyward/coc-sql | MIT |
| **coc-markdownlint** | https://github.com/fannheyward/coc-markdownlint | MIT |

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
