return {
  {

    "L3MON4D3/LuaSnip",
    version = "2.3.0",
    config = function()

      local ls = require("luasnip")
      ls.setup({
        keep_roots = true,
        link_roots = true,
        link_children = true,
        update_events = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
        enable_autosnippets = false,
      })

      -- # Keybindings
      --
      -- Note: "Select mode" is what luasnip ends up in when snippets contain
      -- placeholder text
      --

      vim.keymap.set({ "i", "s" }, "<C-k>",
        function()
          if ls.expand_or_locally_jumpable() then
            ls.expand_or_jump()
          end
        end,
        { desc = "Expand or jump forward in lua-snippet", silent = true })

      if os.getenv("TMUX") then
        -- I use ctrl-j as my tmux prefix key, so that makes the shortcut
        -- `ctrl-j j`
        vim.keymap.set({ "i", "s" }, "<C-j>", function()
          if ls.jumpable(-1) then
            ls.jump(-1)
          end
        end, { desc = "Jump backward in lua-snippet", silent = true })
      else
        -- If we're not in TMUX, we still want `ctrl-j j`, so the same key
        -- combination always works
        vim.keymap.set({ "i", "s" }, "<C-j>j", function()
          if ls.jumpable(-1) then
            ls.jump(-1)
          end
        end, { desc = "Jump backward in lua-snippet", silent = true })
      end

      vim.keymap.set({ "i", "s" }, "<C-b>", function()
        -- An additional shortcut if the conflict with the TMUX prefix key
        -- becomes too much to deal with. May be removed in the future.
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { desc = "Jump backward in lua-snippet", silent = true })

      vim.keymap.set({"i", "s"}, "<C-e>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { desc = "Switch between choices in lua-snippet", silent = true})

      require("luasnip.loaders.from_lua").load()
      -- load snippet from ~/.config/nvim/luasnippets

    end,  -- config

  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
