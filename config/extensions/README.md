# Local extensions

Each custom extension lives under config/extensions/<name>/ with an init.vim
entry point and any Python helpers, documentation and tests next to it.

The installer copies them to ~/.vim-config/extensions/. The installed core/extensions.vim
sources extensions/*/init.vim at startup, never scripts in the edited project.
An unavailable extension is quietly skipped. An explicit build/flash error
is never silenced.

Extensions can add lines to :Keys using g:vim_config_extension_help.
To disable one locally, rename its installed init.vim file. The next installer
run may restore the shipped entry point.

Pico requires Python and Vim +terminal. Missing SDK/compiler/OpenOCD is
reported when a Pico command is run, not at editor startup.
