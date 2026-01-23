local ls = require("luasnip")

local fmta = require("luasnip.extras.fmt").fmta

local open = io.open

local function get_script_dir()
    local info = debug.getinfo(1, "S")
    local script_path = info.source:match("@(.*)")
    return script_path and script_path:match("(.*[/\\])") or "."
end

local script_dir = get_script_dir()

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local TEX_MAKE = read_file(script_dir .. "static_templates/tex.make")

return {
  ls.snippet({trig="help", descr="Insert the help phony target"},
    fmta("help:   ## Show this help\n\t@grep -E '^([a-zA-Z_-]+):.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf \"%-20s %s\\n\", $$1, $$2}'", {})
  ),
  ls.snippet({trig="maketex", descr="Insert the makefile for a sing"},
    fmta(TEX_MAKE, {})
  ),
}
