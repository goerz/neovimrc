return {
  {

    "L3MON4D3/LuaSnip",
    version = "2.3.0",
    config = function()

      local ls = require("luasnip")
      local types = require("luasnip.util.types")
      ls.setup({
        keep_roots = true,
        link_roots = true,
        link_children = true,
        update_events = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { "choiceNode", "Comment" } },
            },
          },
        },
        -- treesitter-hl has 100, use something higher (default is 200).
        ext_base_prio = 300,
        -- minimal increase in priority.
        ext_prio_increase = 1,
        enable_autosnippets = false,
      })

      -- "Select mode" is what luasnip ends up in when snippets contain placeholder text
      vim.keymap.set({ "i", "s" }, "<C-K>",
        function()
          if ls.expand_or_locally_jumpable() then
            ls.expand_or_jump()
          end
        end,
        { desc = "Expand or jump forward in lua-snippet", silent = true })

      vim.keymap.set({ "i", "s" }, "<C-J>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { desc = "Jump backward in lua-snippet", silent = true })

      vim.keymap.set({ "i", "s" }, "<C-B>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { desc = "Jump backward in lua-snippet", silent = true })

      vim.keymap.set({"i", "s"}, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { desc = "Switch between choices in lua-snippet", silent = true})

      require("luasnip.loaders.from_lua").load() -- load from ~/.config/nvim/luasnippets

    end,  -- config

  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
