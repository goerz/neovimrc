return {
  {
    'goerz/openwhispr.nvim',
    -- dir = "~/Documents/Programming/openwhispr.nvim/",
    cmd = 'OpenWhispr',
    keys = {
      { '<leader>v', '<Plug>(openwhispr-toggle)', mode = { 'n', 'x' }, desc = 'Dictation' },
      { '<C-x><C-v>', '<Plug>(openwhispr-toggle)', mode = 'i', desc = 'Dictation' },
    },
    opts = {
      history = { enabled = true },
    },
  }
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
