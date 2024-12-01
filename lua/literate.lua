local M = {}

-- Load special settings for Julia files for Literate.jl. This use top-level
-- comment blocks that contain Markdown and should e formatted as such.
-- This is done by adding the `./literate` folder to the runtimepath, which
-- contains Treesitter queries with custom highlights and inclusions.

function M.init()
  local folder = debug.getinfo(1, "S").source:match("@(.+)%..+")
  local augroup = vim.api.nvim_create_augroup('JuliaLiterateAutocmds', { clear = true })
  if not vim.tbl_contains(vim.opt.runtimepath:get(), folder) then
    vim.opt.runtimepath:append(folder)
  end
  vim.api.nvim_set_hl(0, '@literate-md', { link = "String" })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    pattern = '*.jl',
    callback = function()
      vim.opt_local.wrap = true
      print('Opened Julia as Literate.jl')
    end
  })
end


function M.deactivate()
  local augroup = 'JuliaLiterateAutocmds'
  local folder = debug.getinfo(1, "S").source:match("@(.+)%..+")
  vim.api.nvim_clear_autocmds({ group = augroup })
  if vim.tbl_contains(vim.opt.runtimepath:get(), folder) then
    vim.opt.runtimepath:remove(folder)
  end
  vim.api.nvim_set_hl(0, '@literate-md', {})
end


return M
