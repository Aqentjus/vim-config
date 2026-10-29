# Local extensions

Each extension belongs in its own directory. Keep its Vim entry point, helper
programs, documentation, and tests together:

```text
extensions/
  pico/
    init.vim
    pico.py
    README.md
    test_pico.py
    test_vim.py
```

The core vimrc silently sources `extensions/*/init.vim` from **this installed
vim-config checkout** at startup. No manual `:source` or `:runtime` is needed.
A missing extensions directory or a missing entry point is a no-op. Loading
errors are caught so an optional extension cannot stop Vim startup. Extension
entry points should check their requirements before defining commands and use
`finish` quietly when unavailable. Nothing downloads or installs dependencies.

Only the `init.vim` files are sourced. Python helpers run only when you invoke
the relevant command. No scripts are loaded from the project being edited;
install only extension code you trust in this repository. This loader is not a
sandbox and cannot roll back arbitrary side effects of faulty extension code.

Pico skips registration when its helper, a Python executable, or Vim's terminal
support is missing. Missing SDK/compiler/OpenOCD is reported **when you explicitly
run a Pico command**, not during startup. Build and flashing errors must remain
visible; a failed build must never be treated as permission to flash.

Extensions can optionally add rows to the existing Space+h / :Keys table via
`g:vim_config_extension_help`, a dictionary of lists of display strings keyed
by extension name. The ordinary editor works without this dictionary.

To disable one extension locally, move its `init.vim` out of the pattern (for
example rename it to `init.vim.disabled`) and restart Vim. Git will see that as a
local change; keep or revert it deliberately before updating the checkout.
