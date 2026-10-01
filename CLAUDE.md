# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration (Lua-only, no Vimscript config), managed as a git repo cloned to `~/.config/nvim`. Plugin versions are pinned in `lazy-lock.json`.

## Verifying changes

Run `scripts/check-config.sh` after changing the config. It loads the config headlessly, force-loads every lazy.nvim plugin (so `config`/`opts` bodies actually execute), and exits nonzero if anything produces a warning or error. Pass a binary to smoke-test a different Neovim version: `scripts/check-config.sh /path/to/other/nvim` (or `NVIM=/path/to/other/nvim scripts/check-config.sh`). A clean load prints `PASS`; this is the quickest way to confirm a change loads without errors. It cannot exercise interactive behavior or keymaps, so still restart Neovim for those.

## Architecture

- `init.lua` — general options, global keymaps, and custom commands. At the end it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and imports all plugin specs from `lua/plugins/`.
- `lua/plugins/*.lua` — one file per plugin (or plugin group), each returning a lazy.nvim spec table. This is where plugin-specific options and keymaps live. Add a new plugin by adding a new file here; lazy.nvim picks it up automatically.
- `lua/plugins/lspconfig.lua` — everything LSP-related: Mason, per-server settings, LSP keymaps, and diagnostics UI. Exception: the Julia language server is set up manually (not via Mason). It is [JETLS](https://github.com/aviatesk/JETLS.jl), installed as a Pkg app so that `jetls` is on `$PATH`. LSP formatting is switched off for it on purpose: projects format via their own `make codestyle`, and the language server must not compete with that. `helpers/julia_languageserver.jl` and the `julials` config are a disabled fallback to LanguageServer.jl, which needs a `@languageserver` environment and Julia 1.12 (it does not load on 1.13).
- `lua/libraries/` — shared helper modules (`_lsp.lua`, `_telescope.lua`, `_cmp.lua`) required by plugin specs.
- `lua/blockobjects.lua` — custom `ib`/`ab` "block" text object (lines separated by blank lines; fenced code blocks in Markdown), designed to work with vim-slime.
- `lua/literate.lua` + `lua/literate/` — toggleable alternative settings for Literate.jl scripts (`:LiterateOn`/`:LiterateOff`).
- `lua/align_to_mark.lua` — `,a` alignment helper.
- `luasnippets/` — LuaSnip snippets, one file per filetype (`all/` for every filetype, `static_templates/` for file templates).
- `after/ftplugin/` — per-filetype settings (legacy Vimscript files).
- `queries/` — Treesitter queries that *replace* the ones from nvim-treesitter; `after/queries/` *extends* them instead. See `queries/README.md`.

## Conventions

- The leader key is `,`; localleader is `\`.
- Lua files use 2-space indentation and end with a `--`-comment Vim modeline setting `ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen`.
- LaTeX deliberately uses neither Treesitter nor LSP; it relies on vimtex and LuaSnip snippets (`luasnippets/tex.lua`).
- The README documents user-facing keymaps and workflows in detail; when adding or changing keymaps, update the corresponding README section.
- Plugin may be loaded from local dev checkouts
