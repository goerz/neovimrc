return {
  { -- nvim-cmp: Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },

    config = function()

      -- See `:help cmp`
      local cmp = require 'cmp'

      cmp.setup {
        completion = {
          autocomplete = false,  -- activates dynamically with <C-Space> (see below)
          completeopt = 'menu,menuone,noinsert',
        },

        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger / activate a completion from nvim-cmp.
          --  Completion is off by default. When we trigger a completion with
          --  CTRL+Space, that also switches on automatic completion...
          ['<C-Space>'] = function()
            cmp.complete()
            require("libraries._cmp").toggle_autocomplete()
          end,
          -- ... Until we confirm a completion with "Enter".
          ['<CR>'] = function(fallback)
            if cmp.visible() then
              cmp.confirm({select=true})
              require("libraries._cmp").toggle_autocomplete()
            else
              fallback()
            end
          end,
          -- But we can also accept completions with Tab, without deactivating auto-completion.
          ['<Tab>'] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'path' },
        },
      }

      vim.api.nvim_create_user_command('AutocompleteToggle', function()
        require("libraries._cmp").toggle_autocomplete()
      end, {})

    end,  -- config
  },
}

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
