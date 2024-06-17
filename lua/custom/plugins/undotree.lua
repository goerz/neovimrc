return {
  { -- Undotree
    'mbbill/undotree',
    commit = '56c684a805fe948936cda0d1b19505b84ad7e065',
    keys = { -- load the plugin only when using its keybinding:
      { "<leader>u", ":UndotreeToggle<CR>", { noremap = true, silent = true, desc="Toggle Undotree" } },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
