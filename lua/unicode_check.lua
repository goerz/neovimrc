-- Unicode normalization: NFC on save for prose filetypes, statusline flags for
-- text that is not in NFC or that mixes equivalent forms of a character, and
-- the :NFC and :UnicodeCheck commands. The normalization itself is in
-- lua/libraries/_unicode.lua.

local unicode = require('libraries._unicode')

local M = {}

-- Buffers larger than this (in bytes) are neither checked nor normalized,
-- because the check runs after every change
local max_bytes = 1024 * 1024

-- Filetypes that are normalized to NFC on save. Set `vim.b.nfc_on_save = false`
-- to skip a buffer. Code (in particular Julia) is not normalized: string
-- literals may need a specific form, and other people's files would change.
M.nfc_filetypes = {
  markdown = true, pandoc = true, tex = true, plaintex = true,
  mail = true, text = true, human = true,
}

local results = {}  -- buffer number → { nfc = n, mixed = n, items = {...} }
local timers = {}   -- buffer number → debounce timer

-- Skip buffers that are too large, or not stored as UTF-8 (a file with
-- invalid UTF-8 is usually opened as latin1, for example)
local function skip(buf)
  local fenc = vim.bo[buf].fileencoding
  return (fenc ~= '' and fenc ~= 'utf-8')
    or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > max_bytes
end

local function resolve(buf)
  return (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
end

-- Count the occurrences of the ASCII character `key` in `lines` that are not
-- followed by a combining mark
local function count_ascii(lines, key)
  local n = 0
  for _, line in ipairs(lines) do
    local start = 1
    while true do
      local i = line:find(key, start, true)
      if not i then
        break
      end
      if not unicode.mark_at(line, i + 1) then
        n = n + 1
      end
      start = i + 1
    end
  end
  return n
end

-- Check `buf` for text that is not in NFC and for characters that appear in
-- more than one equivalent form (see `unicode.key`). Store the result for the
-- statusline and return it: { nfc = n, mixed = n, items = {...} }, where
-- `nfc` counts the characters not in NFC, `mixed` counts the characters with
-- mixed forms, and `items` is a quickfix list. Lines that are not valid UTF-8
-- are skipped.
function M.check(buf)
  buf = resolve(buf)
  local result = { nfc = 0, mixed = 0, items = {} }
  if skip(buf) then
    results[buf] = result
    return result
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local count = {}  -- count[key][form]: number of occurrences
  local where = {}  -- where[form]: list of { lnum, col }
  local seen = {}   -- seen[form]: { key = ..., nfc = ... }, computed once per form
  local function add(lnum, col, text)
    table.insert(result.items, { bufnr = buf, lnum = lnum, col = col, text = text })
  end

  for lnum, line in ipairs(lines) do
    for _, f in ipairs(unicode.forms(line) or {}) do
      local form, col = f[1], f[2]
      local info = seen[form]
      if not info then
        info = { key = unicode.key(form), nfc = unicode.nfc(form) }
        seen[form] = info
      end
      local key, nfc = info.key, info.nfc
      count[key] = count[key] or {}
      count[key][form] = (count[key][form] or 0) + 1
      where[form] = where[form] or {}
      table.insert(where[form], { lnum, col })
      if nfc ~= form then
        result.nfc = result.nfc + 1
        add(lnum, col, ('not NFC: %s → %s (%s)'):format(
          unicode.codepoints(form), unicode.codepoints(nfc), nfc))
      end
    end
  end

  for key, forms in pairs(count) do
    -- A non-ASCII form can be equivalent to plain ASCII (K KELVIN SIGN is K)
    if not key:find('[\128-\255]') then
      local n = count_ascii(lines, key)
      if n > 0 then
        forms[key] = n
      end
    end
    local list = vim.tbl_keys(forms)
    if #list > 1 then
      result.mixed = result.mixed + 1
      -- Most common form first; on a tie, the form that is the key itself
      table.sort(list, function(a, b)
        if forms[a] ~= forms[b] then
          return forms[a] > forms[b]
        elseif (a == key) ~= (b == key) then
          return a == key
        end
        return a < b
      end)
      local summary = {}
      for _, form in ipairs(list) do
        table.insert(summary, ('%s (%d×)'):format(unicode.codepoints(form), forms[form]))
      end
      local text = ('mixed forms of %s: %s'):format(key, table.concat(summary, ', '))
      -- Point at the less common forms, since those are the ones to change.
      -- If all of those are plain ASCII, point at the non-ASCII forms instead.
      local report = vim.tbl_filter(function(form) return where[form] ~= nil end,
        vim.list_slice(list, 2))
      if #report == 0 then
        report = vim.tbl_filter(function(form) return where[form] ~= nil end, list)
      end
      for _, form in ipairs(report) do
        for _, pos in ipairs(where[form]) do
          add(pos[1], pos[2], text)
        end
      end
    end
  end

  table.sort(result.items, function(a, b)
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    elseif a.col ~= b.col then
      return a.col < b.col
    end
    return a.text < b.text
  end)
  results[buf] = result
  return result
end

local function check_later(buf, delay)
  local timer = timers[buf]
  if timer then
    timer:stop()
  else
    timer = vim.uv.new_timer()
    timers[buf] = timer
  end
  timer:start(delay, 0, vim.schedule_wrap(function()
    if vim.api.nvim_buf_is_valid(buf) then
      M.check(buf)
      vim.cmd.redrawstatus()
    end
  end))
end

-- Statusline flags for `buf`: "◌" if some text is not in NFC (U+25CC DOTTED
-- CIRCLE, the placeholder Unicode uses to show a combining mark on its own),
-- "≢" if a character appears in more than one equivalent form.
function M.flags(buf)
  local result = results[resolve(buf)]
  if not result then
    return ''
  end
  return (result.nfc > 0 and '◌' or '') .. (result.mixed > 0 and '≢' or '')
end

-- Normalize lines `first` to `last` (1-based, inclusive) of `buf` to NFC,
-- changing only the lines that differ and skipping lines that are not valid
-- UTF-8. Return the number of changed lines and the number of skipped lines.
function M.normalize(buf, first, last)
  buf = resolve(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, first - 1, last, true)
  local changed, skipped = 0, 0
  for i, line in ipairs(lines) do
    local nfc = unicode.nfc(line)
    if nfc == nil then
      skipped = skipped + 1
    elseif nfc ~= line then
      local lnum = first + i - 1
      vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, true, { nfc })
      changed = changed + 1
    end
  end
  return changed, skipped
end

local function report(prefix, changed, skipped)
  local msg = ('%s: normalized %d line(s)'):format(prefix, changed)
  if skipped > 0 then
    msg = msg .. (', skipped %d line(s) with invalid UTF-8'):format(skipped)
  end
  vim.notify(msg, skipped > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('unicode_check', {})

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    callback = function(ev)
      if not M.nfc_filetypes[vim.bo[ev.buf].filetype]
          or vim.b[ev.buf].nfc_on_save == false or skip(ev.buf) then
        return
      end
      local changed, skipped = M.normalize(ev.buf, 1, vim.api.nvim_buf_line_count(ev.buf))
      if changed > 0 or skipped > 0 then
        report('NFC on save', changed, skipped)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
    group = group,
    callback = function(ev) check_later(ev.buf, 0) end,
  })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    group = group,
    callback = function(ev) check_later(ev.buf, 500) end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev)
      if timers[ev.buf] then
        timers[ev.buf]:stop()
        timers[ev.buf]:close()
        timers[ev.buf] = nil
      end
      results[ev.buf] = nil
    end,
  })

  vim.api.nvim_create_user_command('NFC', function(opts)
    report('NFC', M.normalize(0, opts.line1, opts.line2))
  end, { range = '%', desc = 'Normalize lines to Unicode NFC' })

  vim.api.nvim_create_user_command('UnicodeCheck', function()
    local result = M.check(0)
    vim.cmd.redrawstatus()
    vim.fn.setqflist({}, ' ', { title = 'UnicodeCheck', items = result.items })
    if #result.items > 0 then
      vim.cmd.copen()
    else
      vim.notify('UnicodeCheck: no problems found')
    end
  end, { desc = 'List text that is not in NFC or mixes equivalent forms' })
end

return M

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
