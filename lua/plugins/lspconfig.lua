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

      require('vim.lsp.log').set_format_func(vim.inspect)
      -- This doesn't seem to work, but it would be nice to have a better log

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

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

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

      -- Function to set diagnostics in the quickfix list
      local function set_diagnostics_in_quickfix()
        local diagnostics = vim.diagnostic.get()
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

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      vim.diagnostic.config(
        {
          virtual_text = false, -- Too distracting. Instead, we'll echo diagnostics in the command line bar (see below)
          signs = true,
          update_in_insert = false,
          underline = true,
        }
      )

      -- Prevent LSP from overwriting treesitter color settings
      -- https://github.com/NvChad/NvChad/issues/1907
      vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

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

      require('lspconfig').lua_ls.setup({
        -- cmd = {...},
        -- filetypes = { ...},
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = {
              globals = { 'vim' },
              -- disable = { 'missing-fields' }
            },
          },
        },
      })

      local julia_ls_script = vim.fs.joinpath(vim.fn.stdpath('config'), "helpers", "julia_languageserver.jl")
      require'lspconfig'.julials.setup({
        cmd = {"julia", "--startup-file=no", "--history-file=no", julia_ls_script},
        single_file_support = true,
        on_attach = function(_, bufnr)
          -- Disable automatic formatexpr since the LS.jl formatter isn't so nice.
          vim.bo[bufnr].formatexpr = ''
        end,
        capabilities = capabilities,
      })

      require('lspconfig').basedpyright.setup({
        filetypes = { "python" },
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

      require('lspconfig').ruff.setup({
        filetypes = { "python" }
      })

    end,  -- end of config function

  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
