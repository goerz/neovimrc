return {
  { -- Julia editor support
    'goerz/julia-vim',
    branch="tweaks",
    -- dir="~/Documents/Programming/julia-vim",
    -- dev = true,
    config = function()
      vim.g.latex_to_unicode_file_types = {'julia', 'python', 'mail', 'markdown', 'pandoc', 'human'}
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
