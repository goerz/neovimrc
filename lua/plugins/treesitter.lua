return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    version = '0.9.3',
    build = ':TSUpdate',
    dependencies = {
      {"nvim-treesitter/nvim-treesitter-textobjects", commit="b91c98afa6c42819aea6cbc1ba38272f5456a5cf"},
    },
    opts = {
      ensure_installed = {
        'bash', 'diff', 'html', 'julia', 'luadoc', 'vim', 'comment', 'python'
      },
      -- Neovim comes with some built-in parsers, see `:help treesitter`. This
      -- includes a Markdown parser in particular. That parser (as well as the
      -- equivalent parser that we could install through nvim-treesitter) is
      -- lacking some important Markdown extensions, sich as LaTeX math.
      -- It is best to compile the Markdown parser manually and to put the
      -- resulting `.so` files in `~/.config/nvim/parser/`, see the `README` in
      -- that folder.
      auto_install = false,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = {
          "julia",  -- messes up, better to use patched julia-vim/indent/julia.vim
        }
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "gnn",
          scope_incremental = false,
          node_decremental = "gnm",
        },
      },
      textobjects = {
        enable = true,
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = { query = "@function.outer", desc = "Select function" },
            ["if"] = { query = "@function.inner", desc = "Select inner function" },
            ["ac"] = { query = "@class.outer", desc = "Select class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner class" },
            ["al"] = { query = "@loop.outer", desc = "Select loop" },
            ["a="] = { query = "@assignment.outer", desc = "Select assignment" },
            ["i="] = { query = "@assignment.inner", desc = "Select inner assignment (RHS)" },
            -- TODO: frame in latex -- extend to blocks sendable with slime
            -- TODO: [a.] for statement
            -- TODO: ["is", "as"] for generalized strings
            -- TODO: ["i$", "a$"] for math in markdown
            -- TODO: ["il", "al"] for links in markdown
            ["aS"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },

          },
        },
      },
      -- TODO: set up move shortcuts (`]]`, `]m` etc. overriding `:help object-motions`, `:help various-motions`)
    },
    config = function(_, opts)
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
