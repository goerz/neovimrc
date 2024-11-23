return {
  { -- vim-symlink: follow symlinks
    -- This fixes issues with Fugitive
    'aymericbeaumet/vim-symlink',
    commit = "fec2d1a72c6875557109ce6113f26d3140b64374",
    dependencies = {
      {
        'moll/vim-bbye',
        commit = "25ef93ac5a87526111f43e5110675032dbcacf56",
      },
    }
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
