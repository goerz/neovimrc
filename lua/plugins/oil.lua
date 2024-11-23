return {
  {
    'stevearc/oil.nvim',
    commit = "64a3a555b40d96faae488ed6cf5d0f8b38520891",
    opts = {
      columns = {},
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
      git = {
        -- Return true to automatically git add/mv/rm files
        add = function(path)
          return true
        end,
        mv = function(src_path, dest_path)
          return true
        end,
        rm = function(path)
          return true
        end,
      },
    },
  }
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
