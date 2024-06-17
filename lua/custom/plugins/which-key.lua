return {
  { -- Which-key: show you pending keybinds.
    'folke/which-key.nvim',
    cmd = "WhichKey",
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
