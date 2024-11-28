return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    version = '0.9.3',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'julia', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'comment', 'python' },
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
        enable = false,
      },
      textobjects = {
        enable = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup(opts)
      -- TODO: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
