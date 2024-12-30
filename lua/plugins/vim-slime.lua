return {
  { -- vim-slime plugin
    'goerz/vim-slime',
    init = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_no_mappings = 1
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>s', ':SlimeSend<CR>', { noremap = true, silent = true, desc="Send to SLIME"}) -- normal mode
      vim.api.nvim_set_keymap('n', '<c-c><c-c>', ":lua require('blockobjects').select_block()<CR>:'<,'>SlimeSend<CR>'>", { noremap = true, silent = true, desc="Send block to SLIME"}) -- normal mode
      vim.api.nvim_set_keymap('x', '<leader>s', ":'<,'>SlimeSend<CR>'>", { noremap = true, silent = true, desc="Send to SLIME"}) -- visual mode
      vim.api.nvim_set_keymap('x', '<c-c><c-c>', ":'<,'>SlimeSend<CR>'>", { noremap = true, silent = true, desc="Send to SLIME"}) -- visual mode
    end
  },
}

