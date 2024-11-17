# Tree-Sitter Queries

This folder contains tree-sitter queries that take precedence over queries provided by the `nvim-treesitter` plugin.

>  Nvim looks for queries as `*.scm` files in a `queries` directory under
> `runtimepath`, where each file contains queries for a specific language and
> purpose, e.g., `queries/lua/highlights.scm` for highlighting Lua files. By
> default, the first query on `runtimepath` is used (which usually implies that
> user config takes precedence over plugins, which take precedence over queries
> bundled with Nvim).

Since `~/.config/nvim/` should be the first entry in the runtimepath, this uses queries from this folder unconditionally, and ignores any other file that do not have an "extends" modeline. Such extensions could still be loaded from the `~/.config/nvim/after/queries` folder.
