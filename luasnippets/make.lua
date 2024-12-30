local ls = require("luasnip")

local fmta = require("luasnip.extras.fmt").fmta

return {
  ls.snippet({trig="help", descr="Insert the help phony target"},
    fmta("help:   ## Show this help\n\t@grep -E '^([a-zA-Z_-]+):.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf \"%-20s %s\\n\", $$1, $$2}'", {})
  ),
}
