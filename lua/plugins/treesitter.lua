return {
  { -- Treesitter parser/query management ("main" rewrite, requires Neovim 0.12+)
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- the plugin does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      -- Parsers (and their queries) are installed to `stdpath('data')/site`.
      -- Neovim itself bundles parsers for c, lua, vim, vimdoc, query, and
      -- markdown. The bundled Markdown parser (as well as the equivalent
      -- parser that we could install through nvim-treesitter) is lacking some
      -- important Markdown extensions, such as LaTeX math. It is best to
      -- compile the Markdown parser manually and to put the resulting `.so`
      -- files in `~/.config/nvim/parser/`, see the `README` in that folder.
      -- Hence, `markdown` must not be in the list of parsers below.
      require('nvim-treesitter').install {
        'bash', 'comment', 'diff', 'html', 'julia', 'luadoc', 'python',
      }
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(ev)
          -- Highlighting, for any filetype with an available parser
          if not pcall(vim.treesitter.start, ev.buf) then
            return
          end
          -- Treesitter-based indentation (experimental), except for Julia,
          -- where it messes up; better to use patched julia-vim/indent/julia.vim
          if vim.bo[ev.buf].filetype ~= 'julia' then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  { -- Syntax-aware text objects (functions, classes, loops, assignments)
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
        },
      }
      -- You can use the capture groups defined in textobjects.scm
      local function sel(query, group)
        return function()
          require('nvim-treesitter-textobjects.select').select_textobject(query, group or 'textobjects')
        end
      end
      local map = function(keys, func, desc)
        vim.keymap.set({ 'x', 'o' }, keys, func, { desc = desc })
      end
      map('af', sel('@function.outer'), 'Select function')
      map('if', sel('@function.inner'), 'Select inner function')
      map('ac', sel('@class.outer'), 'Select class')
      map('ic', sel('@class.inner'), 'Select inner class')
      map('al', sel('@loop.outer'), 'Select loop')
      map('a=', sel('@assignment.outer'), 'Select assignment')
      map('i=', sel('@assignment.inner'), 'Select inner assignment (RHS)')
      -- TODO: frame in latex -- extend to blocks sendable with slime
      -- TODO: [a.] for statement
      -- TODO: ["is", "as"] for generalized strings
      -- TODO: ["i$", "a$"] for math in markdown
      -- TODO: ["il", "al"] for links in markdown
      map('aS', sel('@local.scope', 'locals'), 'Select language scope')
      -- TODO: set up move shortcuts (`]]`, `]m` etc. overriding
      -- `:help object-motions`, `:help various-motions`)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
