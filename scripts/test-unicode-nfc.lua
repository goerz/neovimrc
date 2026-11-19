-- Conformance test for the NFC implementation in lua/libraries/_unicode.lua,
-- against Unicode's NormalizationTest.txt (downloaded with curl).
--
-- Usage: nvim -l scripts/test-unicode-nfc.lua
--
-- Prints PASS, or the failing cases and exits nonzero.

local config = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
package.path = config .. '/lua/?.lua;' .. package.path
local unicode = require('libraries._unicode')
local data = require('libraries._unicode_data')

local url = ('https://www.unicode.org/Public/%s/ucd/NormalizationTest.txt'):format(data.version)
local obj = vim.system({ 'curl', '-sSfL', url }, { text = true }):wait()
if obj.code ~= 0 then
  io.stderr:write('Could not download ' .. url .. '\n' .. obj.stderr)
  os.exit(2)
end

local function str(field)
  local cps = {}
  for hex in field:gmatch('%x+') do
    cps[#cps + 1] = tonumber(hex, 16)
  end
  return unicode.encode(cps)
end

local failures, cases = 0, 0
local function expect(source, expected, line)
  cases = cases + 1
  local got = unicode.nfc(source)
  if got ~= expected then
    failures = failures + 1
    if failures <= 20 then
      print(('FAIL: NFC(%s) = %s, expected %s  [%s]'):format(
        unicode.codepoints(source), got and unicode.codepoints(got) or 'nil',
        unicode.codepoints(expected), line))
    end
  end
end

-- Each test line has five columns c1;c2;c3;c4;c5 with
-- c2 == NFC(c1) == NFC(c2) == NFC(c3) and c4 == NFC(c4) == NFC(c5)
local part1 = {}  -- code points listed in Part 1
local part = nil
for line in vim.gsplit(obj.stdout, '\n', { plain = true }) do
  local name = line:match('^@(Part%d)')
  if name then
    part = name
  elseif line ~= '' and not line:match('^#') then
    local c = vim.split(line:gsub('#.*', ''), ';', { plain = true })
    local s = {}
    for i = 1, 5 do
      s[i] = str(c[i])
    end
    for i = 1, 3 do
      expect(s[i], s[2], line)
    end
    for i = 4, 5 do
      expect(s[i], s[4], line)
    end
    if part == 'Part1' then
      part1[tonumber(c[1], 16)] = true
    end
  end
end

-- Every code point not listed in Part 1 is unchanged by NFC
for cp = 0, 0x10FFFF do
  if not part1[cp] and (cp < 0xD800 or cp > 0xDFFF) then
    local s = unicode.encode({ cp })
    expect(s, s, ('U+%04X (not in Part 1)'):format(cp))
  end
end

-- Invalid UTF-8 is rejected
for _, bad in ipairs({ '\xFF', '\xC0\xAF', '\xED\xA0\x80', 'a\xCC', '\xF4\x90\x80\x80' }) do
  cases = cases + 1
  if unicode.nfc(bad) ~= nil then
    failures = failures + 1
    print('FAIL: invalid UTF-8 accepted: ' .. vim.inspect(bad))
  end
end

print(('Unicode %s: %d cases, %d failures'):format(data.version, cases, failures))
if failures > 0 then
  os.exit(1)
end
print('PASS')

-- vim: ts=2 sts=2 sw=2 et fdm=marker fmr={,} nofen
