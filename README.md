# Neovim Configuration

This configuration is intended to work with [Neovim][] only. It is a fresh restart from an [earlier configuration](https://github.com/goerz/vimrc) that works for both [Vim][] and [Neovim][]. Here, we go all-in on using Lua for the configuration and generally following the most modern best practices.

Clone this repository to [`$XDG_CONFIG_HOME/nvim`](https://neovim.io/doc/user/nvim.html#nvim-from-vim), generally `~/.config/nvim`:

    user@host:~/.config/> git clone https://github.com/goerz/neovimrc.git nvim

Update at any time by running `git pull` inside the `~/.config/nvim` folder.

[Vim]: http://www.vim.org
[Neovim]: https://neovim.io


## Notes


### General

* My leader key is `,`.


### Plugin management

Plugins are managed via [Lazy](https://github.com/folke/lazy.nvim). I keep the
configuration for each plugin in the subfolder `./lua/plugins/`.

Run `:Lazy` to open the plugin manager.

Run `:Lazy reload <plugin name>`.


### Treesitter

Treesitter is a built-in part of Neovim, but the [`nvim-treesitter` plugin](https://github.com/nvim-treesitter/nvim-treesitter) sets up which parsers are installed, and which Treesitter features are used for particular filetypes. The plugin also provides the queries that connect between the syntax tree and highlight groups. These queries may be customized in the `./queries` (replacing existing queries) and `./after/queries/` (extending existing queries) folders.

When Treesitter is active, use `:InspectTree` to see the parser tree, and to develop or debug queries.

<!-- Textobjects… -->


### Autocompletion

cmp: ctrl-space activates, enter deactivates.

Use `:AutoCompleteToggle` to switch auto-completion on or off.


### Snippets

Snippets are handled by [LuaSnip](https://github.com/L3MON4D3/LuaSnip). The snippet files are organized by file type in the `./luasnippets/` folder.

Shortcuts are in insert mode:

* `ctrl-k` to complete a snippet or to jump forward
* `ctrl-j j` to jump backward. This is set up under the assumption that if running inside tmux (TMUX env variable exists), `ctrl-j` is the Tmux prefix key. Experimental: `ctrl-b` can also be used to jump back
* `ctrl-e` to switch between "choice nodes"

Alternatively, in normal mode, use Telescope (`ctrl-f s`, `:Telescope luasnip`) to find and insert a snippet.


### Telescope

Telescope is mapped to `ctrl-f`. Typing `ctrl-f` by itself shows the telescope selector after a timeout. The `ctrl-f` shortcut can also be combined with other keys to directly jump to some of the most common modules, e.g.

* `ctrl-f f` - Find Files
* `ctrl-f h` – Find vim help tags
* `ctrl-f k` - Find Keymap
* `ctrl-f d` - Find LSP diagnostics
* `ctrl-f b` - Find Buffers
* `ctrl-f s` - Find snippets

etc. (use `ctrl-f k` to find all keymaps)

Telescope replaces the [`ctrlp.vim`](https://github.com/kien/ctrlp.vim) plugin I was using with vim. `ctrl-p` directly searches for files. Any file can be opened in a vertical or horizontal split with `ctrl-v`/`ctrl-o v` and `ctrl-x`/`ctrl-o h`, respectively.


### LSP

Everything related to LSP is set up in `./lua/plugins/lspconfig.lua`. This includes auxiliary plugins like [Mason](https://github.com/williamboman/mason.nvim) and shortcut/UI customization.

Use `:lua =vim.lsp.buf_get_clients()[1]` to show the first LSP client attached to the current buffer (`=` is a shortcut for `vim.print`).

You can inspect various information about the LSP client/server, eg., the name or server capabilities (`:lua =vim.lsp.get_active_clients()[1].server_capabilities`).

LSP Diagnostics for the local file are set up to appear in the quickfix windows (`:copen`), i.e., the window that traditionally shows the results of  `:make`. The project-wide diagnostics are better viewed through Telescope (`ctrf-f d`).


### Outlines

Outlines are generally provided by the [`outline.nvim` plugin](https://github.com/hedyhli/outline.nvim). The shortcut to open the outline is `go`.

### Commenting

To comment out a line or block, use `,c ` in normal or visual mode.

## Indentation Guides

The [Indent Blankline](https://github.com/lukas-reineke/indent-blankline.nvim) plugin provides useful indentation guides. These are off by default but can be toggled on with `,i`.

### Git (fugitive)

Use `,gd` to "git diff" the current file in such a way that editing the fugitive buffer stages the changes. This is the primary way in which stage commits on a line-by-line basis.

Use `,ga` to stage the current file with all changes. Create a commit with `,gc`.


### ChatGPT Integration

Integration with [ChatGPT](https://chatgpt.com) or more specifically the [OpenAI API](https://platform.openai.com) is provided by the [`GP.nvim`](https://github.com/Robitx/gp.nvim) plugin.

The ChatGPT functionality uses the `ctrl-g` prefix. Most importantly, `ctrl-g c` opens a new Chat window in a vertical split.

There is a custom `GPCheckGrammar` command tied to the shortcut `ctrl-g s` (GPT-4o-mini) or `ctrl-g shift-s` (GPT-4o, possibly better but more expensive) that performs grammar and spell checking in a diffed split.


### LaTeX

LaTeX support is via [`vimtex`](https://github.com/lervag/vimtex).

Start continuous compilation with `:VimtexCompile` (stop with `:VimtexStop`). View the outline with `go`. This is a buffer-local mapping equivalent to `\lt` using the outline provided by vimex, instead of the outline plugin.

Omni-completion (`<ctrl-x><ctr-o>`) is available to complete, e.g., citation keys.

Insert-mode keymaps are disabled, we use LuaSnip instead.

Jumping to the PDF is done with the `,s` shortcut. This is a buffer-local mapping. Usually, `,s` is use for slime-send. In Skim (my PDF viewer on macOS), to go back from the PDF to the source code, under the assumption that nvim is running inside tmux, use `ctrl-shift` with a double-click. This is a Skim feature, though, and relies on a custom setup to interact with tmux.

The `vimtex` plugin provides the following text objects in addition to the default (`:help text-objects`) ones:

* `ic`/`ac`: in/around command
* `ie`/`ae`: in/around environment
* `id`/`ad`: in/around delimiter (parenthesis with `\left`/`\right`)
* `im`/`am`: in/around item
* `i$`/`a$`: in/around math (all of `$`, `$$`, `\(\)`

We not not use either Treesitter or LSP for LaTeX


### Python

We use two LSP servers for Python:

* [`basedpyright`](https://github.com/DetachHead/basedpyright) for access to project symbols ([outlines](#outlines)!) and auto-completion. Since most of my own Python code does not use type hints, the type checking features of `basedpyright` are disabled in `./lua/plugins/lspconfig.lua`.
* [`ruff`](https://github.com/astral-sh/ruff) for linting. Options for `ruff` should be set in the `pyproject.toml`.

Both of these linters are installed through Mason.


### Julia

Julia support is provided by the [`julia-vim` plugin](https://github.com/JuliaEditorSupport/julia-vim). Most importantly, it enables LaTeX-to-Unicode via tab key. Since this is extremely useful even outside of Julia, this feature of the plugin is active in some other filetypes as well (like markdown), and can be activated with `,l` in other buffers.

We also have Treesitter and LSP set up for Julia, providing syntax highlighting, linting, outlines (via `go`), etc. The LSP for Julia is set up manually (not via Mason). It relies on the script in `./helpers/julia_languageserver.jl`, which in turn depends on a Julia environment in `~/.julia/environments/nvim-lspconfig` that has the [`LanguageServer`](https://github.com/julia-vscode/LanguageServer.jl) package installed.

For `.jl` files that are [`Literate.jl`](https://fredrikekre.github.io/Literate.jl/v2/) scripts, alternative settings can be activated with the `:LiterateOn` commands (which invokes the `init` function in `./lua/literate.lua`). To return to the normal settings, use `:LiterateOff`.
