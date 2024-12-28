return {
  { -- Gitsigns: Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    version = '~0.9',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match('%.ipynb$') then
          -- Do not attach for .ipynb file, since these are converted with jupytext.nvim
          return false
        end
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
