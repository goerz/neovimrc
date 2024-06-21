return {
  {
    "lukas-reineke/indent-blankline.nvim",
    commit = "d98f537c3492e87b6dc6c2e3f66ac517528f406f",
    main = "ibl",
    config = function()
      require("ibl").setup {
        enabled = false,
        indent = {char = "▏"},
      }
      vim.api.nvim_set_keymap('n', '<leader>i', ':IBLToggle<CR>', { noremap = true, silent = true, desc="Toggle indent-blankline"})
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen

