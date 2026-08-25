-- Headless config check: load the full config, force every lazy.nvim plugin to
-- load (so `config`/`opts` bodies actually run), and collect any warnings or
-- errors. Exits nonzero (via `:cquit`) if anything is reported, so it can be
-- used as a pass/fail gate. Invoked by `scripts/check-config.sh`.

local problems = {}

-- Intercept notifications raised while plugins load. Anything at WARN or above
-- (which is how lazy.nvim and most plugins surface load-time trouble) counts.
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(level) == "number" and level >= vim.log.levels.WARN then
    -- Parens truncate gsub's second (count) return so `insert` gets one arg.
    table.insert(problems, (tostring(msg):gsub("%s+$", "")))
  end
  return orig_notify(msg, level, opts)
end

local ok, lazy = pcall(require, "lazy")
if not ok then
  table.insert(problems, "cannot require lazy.nvim: " .. tostring(lazy))
else
  local names = vim.tbl_keys(require("lazy.core.config").plugins)
  local loaded, err = pcall(function()
    lazy.load({ plugins = names })
  end)
  if not loaded then
    table.insert(problems, "lazy.load failed: " .. tostring(err))
  end
end

-- lazy.nvim reports plugin load errors asynchronously via `vim.schedule`, so
-- give those scheduled callbacks a chance to run before we tally problems.
vim.wait(500, function()
  return false
end)

-- Write our own result to stdout; headless Neovim sends `print`/messages to
-- stderr, and we want stderr to mean "Neovim itself raised an error".
local function out(line)
  io.stdout:write(line .. "\n")
end

if #problems == 0 then
  out("OK: config loaded and all plugins loaded without warnings or errors")
else
  out(string.format("FAIL: %d problem(s):", #problems))
  for _, p in ipairs(problems) do
    out("  - " .. p)
  end
  vim.cmd("cquit 1")
end

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
