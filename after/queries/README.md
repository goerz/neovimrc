# Tree-Sitter Query Extensions

This folder contains *extensions* to tree-sitter queries, in subfolders by language. The extension is on top of the queries provided by the `nvim-treesitter` plugin, or the queries in `~/.config/nvim/queries`. Any `.scm` in `after` must have an "extend" modeline (`;; extends`). Without this, the file will be ignored, since the `nvim-treesitter` plugin directory comes before the `after` directory in the runtimepath:

>  Nvim looks for queries as `*.scm` files in a `queries` directory under
> `runtimepath`, where each file contains queries for a specific language and
> purpose, e.g., `queries/lua/highlights.scm` for highlighting Lua files. By
> default, the first query on `runtimepath` is used (which usually implies that
> user config takes precedence over plugins, which take precedence over queries
> bundled with Nvim).
