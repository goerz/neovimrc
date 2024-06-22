return {
  {
    'nvim-lualine/lualine.nvim',
    commit = "0a5a66803c7407767b799067986b4dc3036e1983",
    opts = {
      options = {
        icons_enabled = false,
        padding = 0,
        theme = 'goerz',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          function()
            return vim.api.nvim_get_mode().mode:upper()
          end,
          function()
            return "%{' '}%3p%% ¶%3l/%L:%2c⟩"
          end,
        },
        lualine_b = {
          function()
            local statusline_flags = {}
            -- Check for non-ASCII symbols
            if vim.fn.search('[^\\x00-\\x7F]', 'nw') ~= 0 then
              -- Add "‟" if non-ASCII punctuation ([\u00A0-\u00BB\u2010-\u203A])
              if vim.fn.search('[\\u00A0-\\u00BB\\u2010-\\u203A]', 'nw') ~= 0 then
                table.insert(statusline_flags, "‟")
              end
              -- Add "ä" if Latin-extended characters ([\u00C0-\u017F])
              if vim.fn.search('[\\u00C0-\\u017F]', 'nw') ~= 0 then
                table.insert(statusline_flags, "ä")
              end
              -- Add "α" if non-Latin characters ([^\x00-\x7F\u00C0-\u017F\u00A0-\u00BB\u2010-\u203A])
              if vim.fn.search('[^\\x00-\\x7F\\u00C0-\\u017F\\u00A0-\\u00BB\\u2010-\\u203A]', 'nw') ~= 0 then
                table.insert(statusline_flags, "α")
              end
            end
            -- Add "␣" if trailing whitespace or mixed tab/space at the beginning of a line
            if vim.fn.search('\\s\\+$', 'nw') ~= 0 or vim.fn.search('^\\t\\+ ', 'nw') ~= 0 or vim.fn.search('^ \\+\\t', 'nw') ~= 0 then
              table.insert(statusline_flags, "␣")
            end
            return "%{' " .. table.concat(statusline_flags, "") .. " '}"
          end,
        },
        -- lualine_c = {"%{' '}%m%<%f%R%W"},
        lualine_c = {
          {
            "filename",
            path = 1,
          }
        },
        lualine_x = {},
        lualine_y = {"%{'⟨'}", 'filetype'},
        lualine_z = {"%{'⟨'}", 'branch'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {{"filename", path = 1}},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {"fugitive", "quickfix"},
    }
  },
}

--[[ TODO
Maybe we can use something more efficient to check for non-ascii, e.g.,
function check_non_ascii()
  -- Assumes UTF8. If non-UTF8, better to just show the encoding here.
  local lines = vim.api.nvim_buf_get_lines(0, 0, 2000, true)
  for n, line in ipairs(lines) do
    for i = 1, (#line-1) do
      local byte = line:byte(i)
      if byte > 127 then
        return true
      else
        if byte == 194 -- and next byte is between 160 and 194
          -- punctuation
        end
        -- ...
      end
    end
    if n == 2000
      -- Mark file as big
    end
  end
  return false
end
--]]

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
