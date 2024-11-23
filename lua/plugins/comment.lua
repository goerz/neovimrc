return {
  { -- Comment plugin (see help comment-nvim)
    'numToStr/Comment.nvim',
    commit = 'e30b7f2008e52442154b66f7c519bfd2f1e32acb',
    opts = {
      toggler = {
        line = '<leader>c<space>',  -- use line comments
        block = '<leader>cb<space>',  -- use block comments
      },
      opleader = {  -- in front of a motion; or in visual mode
        line = '<leader>c',
        block = '<leader>cb',
      },
      -- The above mappings are pretty smart: with `,` as my leader, always use
      -- `,c ` to toggle things (current line or visual selection), or
      -- `,c<motion>` to toggle the comments for a motion.
      -- TODO: test with syntax-aware motions ("in function")
      mappings = {
        basic = true,
        extra = false,
        extended = false,
      },
    }
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
