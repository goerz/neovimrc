return {
  {
    "goerz/gp.nvim",
    event = "VeryLazy",
    config = function()

      require("gp").setup(
        {
          openai_api_key = { "cat", os.getenv("HOME") .. "/.openai-api-key.txt"},
          chat_confirm_delete = false,
          chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
          chat_user_prefix = "🧑:",
          chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>." },
          command_auto_select_response = false,
          chat_conceal_model_params = false,
          agents = {
            {
              name = "ChatGPT4",
              chat = true,
              command = false,
              -- string with model name or table with model name and parameters
              model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
              -- system prompt (use this to specify the persona/role of the AI)
              system_prompt = "You are a general AI assistant.\n\n"
                .. "Follow these instructions when responding:\n\n"
                .. "- If you're unsure don't guess and say you don't know instead.\n"
                .. "- Ask question if you need clarification to provide a better answer.\n"
                .. "- Be as concise as possible, unless asked to elaborate.\n"
                .. "- Assume that you are talking to an expert unix user comfortable with working on the command line.\n"
                .. "- Assume that the user is an expert programmer. When generating code, only add necessary comments.\n"
                .. "- Don't elide any code from your output if the answer requires coding.\n"
                .. "- You are talking to a computational physicist who programs in Julia, Fortran, and Python.\n",
            },
            {
              name = "ChatGPT4o-Mini",
              chat = true,
              command = false,
              -- string with model name or table with model name and parameters
              model = { model = "gpt-4o-mini", temperature = 1.1, top_p = 1 },
              -- system prompt (use this to specify the persona/role of the AI)
              system_prompt = "You are a general AI assistant.\n\n"
                .. "Follow these instructions when responding:\n\n"
                .. "- If you're unsure don't guess and say you don't know instead.\n"
                .. "- Ask question if you need clarification to provide a better answer.\n"
                .. "- Be as concise as possible, unless asked to elaborate.\n"
                .. "- Assume that you are talking to an expert unix user comfortable with working on the command line.\n"
                .. "- Assume that the user is an expert programmer. When generating code, only add necessary comments.\n"
                .. "- Don't elide any code from your output if the answer requires coding.\n"
                .. "- You are talking to a computational physicist who programs in Julia, Fortran, and Python.\n",
            },
            {
              name = "CodeGPT4",
              chat = false,
              command = true,
              -- string with model name or table with model name and parameters
              model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
              -- system prompt (use this to specify the persona/role of the AI)
              system_prompt = "You are an AI working as a code editor.\n\n"
                .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
                .. "START AND END YOUR ANSWER WITH:\n\n```",
            },
            {
              name = "CodeGPT4o-Mini",
              chat = false,
              command = true,
              -- string with model name or table with model name and parameters
              model = { model = "gpt-4o-mini", temperature = 0.8, top_p = 1 },
              -- system prompt (use this to specify the persona/role of the AI)
              system_prompt = "You are an AI working as a code editor.\n\n"
                .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
                .. "START AND END YOUR ANSWER WITH:\n\n```",
            },
          },
          hooks = {
            CheckGrammar = function(gp, params)
              local system_prompt = require("plenary.strings").dedent([[

                You are a professional copyeditor for non-fiction. Your job is to lightly edit
                text for spelling, grammar, and punctuation. Your instructions are as follows:

                Edited text should be in American English and follow modern style guides.
                In addition, take into account the following in-house rules:

                * Use the Oxford comma.
                * Extra commas can sometimes be used for emphasis.
                * It is perfectly fine to use they/them as a singular pronoun.
                * Do not use em-dashes (—)
                * En-dashes (–) should be surrounded by spaces
                * Headings at level 2 or higher may use title case or sentence case. Be consistent.

                Text can be in a markup language such as Markdown or LaTeX. Any markup
                syntax must be preserved. The text may contain mathematical
                formulas in LaTeX syntax, which must not be modified.

              ]])
              local system_prompt_extra = {
                markdown = require("plenary.strings").dedent([[

                Recognize the given text as Markdown, with syntax extensions for CommonMark and Pandoc.
                In Markdown, text enclosed with backticks (`) is inline
                code, which must not be modified. Fenced codeblocks
                surrounded by multiple backticks or tildes must not be modified.
                Inline mathematics can be enclosed in dollar signs or using double backticks
                and should not be modified. DO NOT REMOVE LINEBREAKS.
                Keep multiple blank lines, especially before headers.
                If a link is on a line by itself, keep it like that.

                ]]),
              }
              local system_prompt_post = require("plenary.strings").dedent([[

                Keep the original structure and style of the text,
                and make as few changes as possible to ensure the text is free
                of spelling errors or grammatical mistakes and is well-written.
                DO NOT REFLOW THE TEXT. DO NOT ADD OR REMOVE BLANK LINES.
                THE OUTPUT MUST HAVE THE SAME NUMBER OF LINES AS THE INPUT TEXT.
                Do not add any commentary.

              ]])
              local template = ""
              .. "Edit the following text for spelling and grammar. "
              .. "Respond with an edited version of the text only. "
              .. "This concludes your instructions. "
              .. "This is the text to edit:\n\n{{selection}}\n"
              local filetype = vim.bo.filetype
              if system_prompt_extra[filetype] ~= nil then
                system_prompt = system_prompt .. system_prompt_extra[filetype] .. system_prompt_post
              else
                system_prompt = system_prompt .. system_prompt_post
              end
              vim.api.nvim_command("diffthis")
              -- vim.api.nvim_out_write(vim.inspect(params)) -- DEBUG
              local model = "gpt-4o-mini"
              for _, arg in ipairs(params.fargs) do
                if arg:match("gpt") and arg:match("4") and not arg:match("mini") then
                  model = "gpt-4o"
                end
              end
              gp.Prompt(
                params,
                gp.Target.vnew(vim.bo.filetype),
                nil, -- command will run directly without any prompting for user input
                model,
                template,
                system_prompt
              )
              vim.api.nvim_create_autocmd('User', {
                pattern = {'GpDone'},
                callback = function()
                  vim.api.nvim_command("diffthis")
                end,
                once = true,
              })
            end,
          },
        }
      )  -- setup

      local function keymapOptions(desc)
        return {
          noremap = true,
          silent = true,
          nowait = true,
          desc = "GPT prompt " .. desc,
        }
      end

      -- Chat commands
      vim.keymap.set({"n", "i"}, "<C-g>C", "<cmd>GpChatNew<cr>", keymapOptions("Create Fullscreen Chat"))
      vim.keymap.set({"n", "i"}, "<C-g>c", "<cmd>GpChatNew vsplit<cr>", keymapOptions("Create Chat"))
      vim.keymap.set({"n", "i"}, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
      vim.keymap.set({"n", "i"}, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

      vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
      vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Create Chat"))
      vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

      -- Prompt commands
      vim.keymap.set({"n", "i"}, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
      vim.keymap.set({"n", "i"}, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
      vim.keymap.set({"n", "i"}, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

      vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
      vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
      vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
      vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

      vim.keymap.set({"n", "i"}, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
      vim.keymap.set({"n", "i"}, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
      vim.keymap.set({"n", "i"}, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
      vim.keymap.set({"n", "i"}, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))

      vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
      vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
      vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
      vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))

      vim.keymap.set({"n", "i"}, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
      vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

      -- vim.keymap.set({"n", "i", "v", "x"}, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
      vim.keymap.set({"n", "i", "v", "x"}, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

      -- Custom commands
      vim.keymap.set({"n"}, "<C-g>s", "<cmd>%GpCheckGrammar<cr>", keymapOptions("Grammar Check File"))
      vim.keymap.set({"n"}, "<C-g>S", "<cmd>%GpCheckGrammar gpt-4<cr>", keymapOptions("Grammar Check File with GPT4"))
      vim.keymap.set({"v"}, "<C-g>s", ":<C-u>'<,'>GpCheckGrammar<cr>", keymapOptions("Grammar Check File"))
      vim.keymap.set({"v"}, "<C-g>S", ":<C-u>'<,'>GpCheckGrammar gpt-4<cr>", keymapOptions("Grammar Check File with GPT4"))

    end,  -- config
  },
}
-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
