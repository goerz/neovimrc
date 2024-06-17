return {
  "tpope/vim-fugitive",
  commit = "64d6cafb9dcbacce18c26d7daf617ebb96b273f3",
  keys = {
    { "<Leader>gd", ":Gvdiffsplit<CR>", desc = "git diff" },
    { "<Leader>gD", ":Gvdiffsplit HEAD<CR>", desc = "git diff (HEAD)" },
    { "<Leader>gs", ":Gstatus<CR>", desc = "git status" },
    { "<Leader>ga", ":Gwrite<CR>", desc = "git add" },
    { "<Leader>gc", ":Gcommit<CR>", desc = "git commit" },
    { "<Leader>gb", ":Git blame<CR>", desc = "git blame" },
  },
  cmd = { "Git"},
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
