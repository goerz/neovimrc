# Neovim Configuration

This configuration is intended to work with [Neovim][] only. It is a fresh
restart from an [earlier configuration](https://github.com/goerz/vimrc) that
works for both [Vim][] and [Neovim][]. Here, we go all-in on using Lua for the
configuration an generally following the most modern best practices.

Clone this repository to
[`$XDG_CONFIG_HOME/nvim`](https://neovim.io/doc/user/nvim.html#nvim-from-vim),
generally `~/.config/nvim`:

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

Run `:Lazy reload <plugin name>`


### Commenting

To comment out a line or block, use `,c ` in normal or visual mode.


### Git (fugitive)

Use `,gd` to "git diff" the current file in such a way that editing the fugitive buffer stages the changes. This is the primary way in which stage commits on a line-by-line basis.

Use `,ga` to stage the current file with all changes. Create a commit with `,gc`.


### Telescope

Telescope is mapped to `CTRL-F`. Typing `CTRL-F` by itself shows the telescope selector after a timeout. The `CTRL-F` shortcut can also be combined with other keys to directly jump to some of the most common modules, e.g.

* `CTRL-F F` - Find Files
* `CTRL-F H` – Find vim help tags
* `CTRL-F K` - Find Keymap
* `CTRL-F D` - Find LSP diagnostics
* `CTRL-F B` - Find Buffers

etc. (use `CTRL-F K` to find all keymaps)

Telescope replaces the [ctrlp.vim](https://github.com/kien/ctrlp.vim) plugin I was using with vim. `CTRL-P` directly searches for files. Any file can be opened in a vertical or horizontal split with `CTRL-V`/`CTRL-O V` and `CTRL-X`/`CTRL-O H`, respectively.
