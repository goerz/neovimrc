return {
  { -- Basic Emacs bindings
    'goerz/emacs-bindings.nvim',
    init = function()
      vim.g.emacs_bindings_modes = 'c' -- Enables bindings for command modes
      -- Do not enable for insert mode! This will conflict with LuaSnip bindings
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen

