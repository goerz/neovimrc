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
configuration for each plugin in the subfolder `./lua/custom/plugins/`.

Run `:Lazy` to open the plugin manager.

Run `:Lazy reload <plugin name>`.


### Commenting

To comment out a line or block, use `,c ` in normal or visual mode.

## Indentation Guides

The [Indent Blankline](https://github.com/lukas-reineke/indent-blankline.nvim) plugin provides useful indentation guides. These are off by default but can be toggled on with `,i`.

### Git (fugitive)

Use `,gd` to "git diff" the current file in such a way that editing the fugitive buffer stages the changes. This is the primary way in which stage commits on a line-by-line basis.

Use `,ga` to stage the current file with all changes. Create a commit with `,gc`.


### ChatGPT Integration

Integration with [ChatGPT](https://chatgpt.com) or more specifically the [OpenAI API](https://platform.openai.com) is provided by the [GP.nvim](https://github.com/Robitx/gp.nvim) plugin.

The ChatGPT functionality uses the `ctrl-g` prefix. Most importantly, `ctrl-g c` opens a new Chat window in a vertical split.

There is a custom `GPCheckGrammar` command tied to the shortcut `ctrl-g s` (GPT-4o-mini) or `ctrl-g shift-s` (GPT-4o, possibly better but more expensive) that performs grammar and spell checking in a diffed split.


### Autocompletion

cmp: ctrl-space activates, enter deactivates.


### Telescope

Telescope is mapped to `ctrl-f`. Typing `ctrl-f` by itself shows the telescope selector after a timeout. The `ctrl-f` shortcut can also be combined with other keys to directly jump to some of the most common modules, e.g.

* `ctrl-f f` - Find Files
* `ctrl-f h` – Find vim help tags
* `ctrl-f k` - Find Keymap
* `ctrl-f d` - Find LSP diagnostics
* `ctrl-f b` - Find Buffers

etc. (use `ctrl-f k` to find all keymaps)

Telescope replaces the [ctrlp.vim](https://github.com/kien/ctrlp.vim) plugin I was using with vim. `ctrl-p` directly searches for files. Any file can be opened in a vertical or horizontal split with `ctrl-v`/`ctrl-o v` and `ctrl-x`/`ctrl-o h`, respectively.


### LSP
