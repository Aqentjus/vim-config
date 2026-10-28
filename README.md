# Vim configuration

A portable Vim setup, designed one decision at a time.

## Branches

- `staging` is the development branch: experiments and changes are reviewed here.
- `production` is the intended stable branch: only agreed, checked changes belong there.

The initial milestone is the theme. An installer and the remaining editor
behaviour will be designed separately.

## Decision 1: Gruvbox

- Original `morhetz/gruvbox` colour scheme, stored directly in this repository.
- Dark mode, medium contrast.
- True-colour background `#282828` and normal foreground `#ebdbb2`.
- No plugin manager, automatic downloads, or external runtime for the theme.
- A supplied Vim colour scheme is used when the theme file is missing or the
  terminal cannot display it.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the pinned upstream
revision, attribution and licence information.

## Try the staging version

Install Git and a full Vim build with evaluation and syntax support, then:

```sh
git clone --branch staging https://github.com/Aqentjus/vim-config.git
cd vim-config
vim -u ./vimrc
```

This loads this repository's configuration for that Vim session without
installing it over your personal configuration.

The config enables true colour when Vim supports it and the terminal advertises
`COLORTERM=truecolor` or `COLORTERM=24bit`. An already-enabled `termguicolors`
setting is preserved. Otherwise Gruvbox uses its 256-colour approximations.
A terminal with neither capability uses Vim's default scheme.

## Validation

The included colour file is byte-for-byte identical to the pinned upstream
Git blob. Its basic theme does not depend on the optional Gruvbox autoload
helpers. Full Vim runtime testing has not yet been performed for this
milestone; the preparation environment only has a tiny Vim build.
