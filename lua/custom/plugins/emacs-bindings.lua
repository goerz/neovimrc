return {
  { -- Basic Emacs bindings
    'goerz/emacs-bindings.nvim',
    config = function()
      vim.g.emacs_bindings_modes = 'ic' -- Enables bindings for insert and command modes
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen

