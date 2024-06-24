return {
  { -- vim-slime plugin
    'jpalardy/vim-slime',
    config = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_no_mappings = 1
      vim.g.slime_python_ipython = 1
      vim.api.nvim_set_keymap('n', '<leader>s', ':SlimeSend<CR>', { noremap = true, silent = true, desc="Send to SLIME"}) -- normal mode
      vim.api.nvim_set_keymap('x', '<leader>s', ":'<,'>SlimeSend<CR>'>", { noremap = true, silent = true, desc="Send to SLIME"}) -- visual mode
    end
  },
}

