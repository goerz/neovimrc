return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim', -- allows mason-tool-installer to accept lspconfig package names
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'j-hui/fidget.nvim',
    },
    config = function()

      -- Remove Neovim's default `gr`-prefixed LSP mappings (`:help grr` etc.,
      -- added in 0.11/0.12). Their functionality is covered by the LspAttach
      -- keymaps below, and their existence makes our `gr` mapping wait for
      -- 'timeoutlen' to rule out a longer match.
      for _, lhs in ipairs({ 'grr', 'grn', 'gra', 'gri', 'grt' }) do
        pcall(vim.keymap.del, { 'n', 'x' }, lhs)
      end

      vim.api.nvim_create_autocmd('LspAttach', {

        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)

          -- A small helper that lets us more easily define mappings specific for LSP related items.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor. To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Note: `K` shows hover documentation by default (`:help K-lsp-default`)

          -- This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Echo diagnostics in the command line bar
          -- https://www.reddit.com/r/neovim/comments/tkcvlc/how_do_you_tame_lsp_diagnostic_messages/
          vim.api.nvim_create_autocmd("CursorMoved", {
            pattern = "*",
            callback = function()
              require("libraries._lsp").echo_diagnostic()
            end,
          })

        end,

      })

      -- Function to set diagnostics in the quickfix list. We limit that to
      -- diagnostics in the current buffer. For project-wide diagnostic, use
      -- Telescope instead (`ctrl-f d`)
      local function set_diagnostics_in_quickfix()
        local bufnr = vim.api.nvim_get_current_buf()
        local diagnostics = vim.diagnostic.get(bufnr)
        local quickfix_list = {}

        for _, diag in ipairs(diagnostics) do
          table.insert(quickfix_list, {
            bufnr = diag.bufnr,
            lnum = diag.lnum + 1,  -- Neovim uses 0-indexed positions, so we adjust it
            col = diag.col + 1,    -- Adjust for 0-indexing
            text = diag.message,
            type = diag.severity == vim.diagnostic.severity.ERROR and 'E'
                  or diag.severity == vim.diagnostic.severity.WARN and 'W'
                  or 'I',  -- Default to 'I' for other types
          })
        end

        vim.fn.setqflist({}, ' ', { -- creates a new quickfix list
          title = 'LSP Diagnostics',
          items = quickfix_list,
        })
      end

      -- Autocmd to update the quickfix list whenever diagnostics change
      vim.api.nvim_create_autocmd('DiagnosticChanged', {
        callback = set_diagnostics_in_quickfix,
      })

      -- Note: diagnostic `virtual_text` (too distracting) is disabled by
      -- default since Neovim 0.11; we echo diagnostics in the command line
      -- bar instead (see above).

      -- Prevent LSP from overwriting treesitter color settings
      -- https://github.com/NvChad/NvChad/issues/1907
      vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

      -- LSPs and other tools can (but don't have to) be installed via Mason/Mason-Tool-Installer
      --
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()
      require('mason-tool-installer').setup {
        -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim?tab=readme-ov-file#configuration
        ensure_installed = {
          'lua_ls',  -- automatically installs tools for Lua language server
          -- Julia language server is installed manually, so we keep it ouf of Mason
          'stylua',
          'basedpyright',
          'ruff',
        }
      }

      -- Server configurations. The defaults (cmd, filetypes, root markers)
      -- come from the `lsp/<name>.lua` files in nvim-lspconfig; the tables
      -- below are merged with those defaults. See `:help lsp-config`.

      -- Advertise the extra capabilities provided by nvim-cmp to all servers.
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = {
              globals = { 'vim', 'describe', 'it' },
              disable = { 'missing-fields' }
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })

      local julia_ls_script = vim.fs.joinpath(vim.fn.stdpath('config'), "helpers", "julia_languageserver.jl")
      vim.lsp.config('julials', {
        cmd = {"julia", "--startup-file=no", "--history-file=no", julia_ls_script},
        on_attach = function(_, bufnr)
          -- Disable automatic formatexpr since the LS.jl formatter isn't so nice.
          vim.bo[bufnr].formatexpr = ''
        end,
      })

      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off",
            }
          },
        },
        on_attach = function(client, _)
          -- disable LSP semantic highlights (use only Treesitter)
          client.server_capabilities.semanticTokensProvider = nil
        end
      })

      vim.lsp.enable({ 'lua_ls', 'julials', 'basedpyright', 'ruff' })

    end,  -- end of config function

  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
