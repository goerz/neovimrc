-- [[ General Settings and Options ]]

-- Prefer light backgrounds
vim.opt.background = 'light'
local colorfgbg = vim.fn.getenv('COLORFGBG')
if colorfgbg and colorfgbg ~= '' then
  local bg_color_code = tonumber(vim.fn.split(colorfgbg, ';')[2])
  if bg_color_code ~= nil then
    if bg_color_code == 8 or bg_color_code <= 6 then
      vim.opt.background = 'dark'
    else
      vim.opt.background = 'light'
    end
  end
end

vim.opt.termguicolors = true

-- Set Leader Key(s)
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'  -- for filetype plugin shortcuts

-- Enable per-directory .vimrc files
vim.opt.exrc = true

-- Do not sync clipboard between OS and Neovim.
-- Otherwise, I can't do things like `ci"<cmd-v>` to change the content of a
-- string to the text in the clipboard (`ci"` would overwrite the clipboard)
-- yank into the */+ registers to copy text to the OS clipboard
-- E.g., select region visually, then hit `"*Y` to copy the complete selected
-- lines to the clipboard. (Capital Y! Small y yanks the exact selected range)
vim.opt.clipboard = ''

-- Persistent undo
local undodir = vim.fn.stdpath('data') .. '/undo'
if not vim.fn.isdirectory(undodir) then
  vim.fn.mkdir(undodir, 'p')   -- 'p' means "create parents"
end
vim.opt.undodir = undodir
vim.opt.undofile = true

-- Folding
vim.opt.foldenable = false

-- Note to show the value of an option in nvim, use, e.g.,
--     :lua vim.print(vim.opt.exrc:get())
-- Without the `get()`, this shows more technical information
--
-- `vim.print` is better than just `print`.

-- Disable unsafe commands in local .vimrc files
vim.opt.secure = true

-- Case-insensitive search unless search term contains a capital letter
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Search the first 5 lines for modelines
vim.opt.modelines = 5

-- Temporary files
vim.opt.wildignore:append({ '*.o', '*.obj', '*.bak', '*~', '*.tmp', '*.backup' })

-- Set default language to American English
vim.opt.spelllang = 'en_us'

-- Unmap Y in Neovim (behave like classic vim: Y yanks entire line)
-- https://github.com/neovim/neovim/pull/13268
-- https://github.com/neovim/neovim/issues/416
vim.api.nvim_del_keymap('n', 'Y')

-- Mouse toggle function and mapping
vim.opt.mouse = ''
vim.api.nvim_set_keymap('n', '<Leader>m', ':lua ToggleMouse()<CR>', { noremap = true, silent = true, desc="Toggle mouse"})
function ToggleMouse()
  if next(vim.opt.mouse:get()) == nil then  -- table is empty
    vim.opt.mouse = 'a'
    print('Mouse enabled')
  else
    vim.opt.mouse = ''
    print('Mouse disabled')
  end
end

-- Windowing commands and vertical splits
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.api.nvim_set_keymap('n', '<c-w>f', ':vertical wincmd f<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-w>gf', ':vertical wincmd f<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-w>]', ':vertical wincmd ]<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-w>n', ':vnew<CR>', { noremap = true, silent = true })

-- Window move cursor wrap
local function GotoNextWindow(direction, count)
  local prevWinNr = vim.fn.winnr()
  vim.cmd(count .. 'wincmd ' .. direction)
  return vim.fn.winnr() ~= prevWinNr
end

local function JumpWithWrap(direction, opposite)
  if not GotoNextWindow(direction, vim.v.count1) then
    GotoNextWindow(opposite, 999)
  end
end

vim.api.nvim_set_keymap('n', '<C-w>h', '', { noremap = true, silent = true, callback = function() JumpWithWrap("h", "l") end })
vim.api.nvim_set_keymap('n', '<C-w>j', '', { noremap = true, silent = true, callback = function() JumpWithWrap("j", "k") end })
vim.api.nvim_set_keymap('n', '<C-w>k', '', { noremap = true, silent = true, callback = function() JumpWithWrap("k", "j") end })
vim.api.nvim_set_keymap('n', '<C-w>l', '', { noremap = true, silent = true, callback = function() JumpWithWrap("l", "h") end })
vim.api.nvim_set_keymap('n', '<C-w><Left>', '', { noremap = true, silent = true, callback = function() JumpWithWrap("h", "l") end })
vim.api.nvim_set_keymap('n', '<C-w><Down>', '', { noremap = true, silent = true, callback = function() JumpWithWrap("j", "k") end })
vim.api.nvim_set_keymap('n', '<C-w><Up>', '', { noremap = true, silent = true, callback = function() JumpWithWrap("k", "j") end })
vim.api.nvim_set_keymap('n', '<C-w><Right>', '', { noremap = true, silent = true, callback = function() JumpWithWrap("l", "h") end })


-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'  -- subfolder of ~/.local/share
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Indicate textwidth with color column
vim.opt.colorcolumn = '+1'

-- Enable incremental search and search highlighting
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.api.nvim_set_keymap('n', '<esc><esc>', ':nohlsearch<CR><esc>', { noremap = true, silent = true })

-- Always show status line
vim.opt.laststatus = 2

-- Show cursor line and column, if no status line
vim.opt.ruler = true

-- Shorten messages
vim.opt.shortmess:append('atI')

-- Allow cursor to move beyond the end of the line in block mode
vim.opt.virtualedit = 'block'


-- Set listchars but keep 'list' disabled by default
vim.opt.listchars = { tab = '>-', trail = '-', nbsp = '~' }
vim.opt.list = false

-- Don't wrap text by default
vim.opt.wrap = false
vim.opt.showbreak = '∟'
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Tab and indent settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.autoindent = false

-- Text formatting options
vim.opt.formatoptions = 'tcql'
vim.opt.textwidth = 0

-- Remap ' and `
vim.api.nvim_set_keymap('n', "'", '`', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '`', "'", { noremap = true, silent = true })

-- Pastetoggle
if pcall(vim.api.nvim_get_option, 'pastetoggle') then
  vim.opt.pastetoggle = '<C-L>p'
  vim.api.nvim_set_keymap('n', '<Leader>p', ':set invpaste<CR>', { noremap = true, silent = true })
end

-- Save
vim.api.nvim_set_keymap('n', '<Leader>w', ':w!<CR>', { noremap = true, silent = true, desc="Save (:w!)"})

-- Arrow keys behavior in insert mode
vim.api.nvim_set_keymap('i', '<Up>', 'pumvisible() ? "<Up>" : "<C-O>gk"', { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('i', '<Down>', 'pumvisible() ? "<Down>" : "<C-O>gj"', { noremap = true, expr = true, silent = true })

-- Make hjkl work on visual (wrapped) lines
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'j', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'k', 'gk', { noremap = true, silent = true })

-- In visual mode, paste without cutting selected text
vim.api.nvim_set_keymap('v', 'p', '"_dP', { noremap = true, silent = true })

-- When editing a file, always jump to the last known cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end
})


-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- LaTeX to Unicode (from julia-vim)
vim.api.nvim_set_keymap('n', '<leader>l', ':call LaTeXtoUnicode#Toggle()<CR>', { noremap = true, silent = true, desc="Toggle latex-to-unicode conversion" })

-- Custom commands

vim.api.nvim_create_user_command('German', function()
  vim.opt.spell = true
  vim.opt.spelllang = 'de_20'
end, {})

vim.api.nvim_create_user_command('English', function()
  vim.opt.spell = true
  vim.opt.spelllang = 'en'
end, {})

vim.api.nvim_create_user_command('Python', function()
  vim.opt.spell = false
  vim.bo.filetype = 'python'
end, {})

vim.api.nvim_create_user_command('ManualFolding', function()
  vim.opt.foldenable = true
  vim.opt.foldmethod = 'manual'
end, {})

vim.api.nvim_create_user_command('Dark', function()
  vim.opt.background = 'dark'
  vim.cmd('colorscheme evening')
end, {})

-- Command abbreviation
vim.cmd([[cabbr AB 'a,'b]])

-- Do not use Nerd Font
vim.g.have_nerd_font = false  -- some plugins may use this

-- TODO
-- * For some programming languages, delete trailing spaces on save
-- * set wildmode=longest,full
-- * go to defn of tag under the cursor (case sensitive)
-- * Tagbar replacement
-- * ALE replacements - LanguageServer, presumably
-- * Align to mark 'a
-- * LaTeX
-- * jupytext (rewrite)
-- * Goyo
-- * Snippets
-- * termguicolors?
-- * "Human" text with better statusline


-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
require('lazy').setup(
{ -- Plugins are loaded from lua/custom/plugins folder
  import = "custom/plugins"
},
{ -- Options for Lazy manager itself
  -- See https://github.com/folke/lazy.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
  install = {
    -- install missing plugins on startup. This doesn't increase startup time.
    missing = true,
    -- try to load one of these colorschemes when starting an installation during startup
    colorscheme = { "goerz" },
  },
})

vim.cmd.colorscheme "goerz"

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
