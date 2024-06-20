return {
    {
    "folke/trouble.nvim",
    enabled = false,   -- XXX: Telescope is probably a better solution for showing diagnostics. But we'll see.
    opts = {
      icons = {
        indent = {
          top           = "│ ",
          middle        = "├╴",
          last          = "└╴",
          fold_open     = "⏷",
          fold_closed   = "⏵",
          ws            = "  ",
        },
        folder_closed   = "📁",
        folder_open     = "📂",
        kinds = {
          Array         = "📚",
          Boolean       = "🔘",
          Class         = "🏫",
          Constant      = "🔒",
          Constructor   = "🚀",
          Enum          = "📊",
          EnumMember    = "📈",
          Event         = "🎉",
          Field         = "🌱",
          File          = "📄",
          Function      = "🔧",
          Interface     = "🔗",
          Key           = "🔑",
          Method        = "🏷️",
          Module        = "📦",
          Namespace     = "🌐",
          Null          = "🚫",
          Number        = "🔢",
          Object        = "🔲",
          Operator      = "➕",
          Package       = "📦",
          Property      = "🏠",
          String        = "🧵",
          Struct        = "🏛️",
          TypeParameter = "🔠",
          Variable      = "🔀",
        },
      },
    },
    cmd = "Trouble",
    keys = {
      {
        "<leader>xD",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  }
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
