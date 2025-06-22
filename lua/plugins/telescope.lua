return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "L3MON4D3/LuaSnip", -- see separate configuration
      {
        "goerz/telescope-luasnip.nvim",
        branch = "insert-below-line"
      },
      "nvim-lua/plenary.nvim", --  Lua module for asynchronous programming using coroutines
      { -- Use native port of `fzf` command line program
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      {
        -- telescope-ui-select exists to use telescope's UI in more places
        -- outside of the :Telescope command. specifically, it overrides :h
        -- vim.ui.select calls. so if you use a different plugin or a builtin
        -- command that uses vim.ui.select (like selecting a code action) then
        -- it will use telescope.
        "nvim-telescope/telescope-ui-select.nvim",
      },
    },
    config = function()
      -- See `:help telescope` and `:help telescope.setup()`
      local actions = require("telescope.actions")
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          fzf = {},
        },
        defaults = {
          mappings = {
            i = {
              --  From CTRL-P plugin, and it's easier to reach than the default <C-p>
              ["<C-o>h"] = actions.select_horizontal, -- From CTRL-P, but needs to be typed quickly
              ["<C-o>v"] = actions.select_vertical, -- From CTRL-P, but needs to be typed quickly
            },
          },
        },
        pickers = {
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--glob", "!**/.venv/*" },
          },
        },
      })
      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      require("telescope").load_extension("luasnip")
      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")
      local my = require("libraries._telescope")
      vim.keymap.set("n", "<c-p>", my.find_all_files, { desc = "Search Files" })
      vim.keymap.set("n", "<c-f>c", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[F]ind [C]onfiguration" })
      vim.keymap.set("n", "<c-f>", ":Telescope<CR>", { desc = "[F]ind with Telescope" })
      vim.keymap.set("n", "<c-f>h", builtin.help_tags, { desc = "[F]ind [H]elp" })
      vim.keymap.set("n", "<c-f>f", my.find_sibling_files, { desc = "[F]ind sibling [F]iles" })
      vim.keymap.set("n", "<c-f>.", builtin.find_files, { desc = "[F]ind Files in CWD ([.])" })
      vim.keymap.set("n", "<c-f>p", my.find_project_files, { desc = "[F]ind Files in [P]roject" })
      vim.keymap.set("n", "<c-f>g", builtin.live_grep, { desc = "[F]ind by [G]rep" })
      vim.keymap.set("n", "<c-f>d", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
      vim.keymap.set("n", "<c-f>r", builtin.oldfiles, { desc = "[F]ind [R]ecent Files" })
      vim.keymap.set("n", "<c-f>b", builtin.buffers, { desc = "[F]ind existing [B]uffers" })
      vim.keymap.set(
        "n",
        "<c-f>/",
        builtin.current_buffer_fuzzy_find,
        { desc = "Fuzzily search in current buffer" }
      )
      vim.keymap.set(
        "n",
        "<c-f>s",
        require("telescope").extensions.luasnip.luasnip,
        { desc = "[F]Find [S]nippets" }
      )
      vim.keymap.set("n", "<c-f>k", function()
        builtin.keymaps({
          show_plug = false,
        })
      end, { desc = "Search [K]eymaps" })
      vim.keymap.set("n", "<c-f>o", function()
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "Search [/] in Open Files" })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
