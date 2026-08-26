local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta

return {
  ls.snippet({trig="breakpoint", dscr="Add an ipynb breakpoint"},
    fmta(
      [[breakpoint()  # export PYTHONBREAKPOINT=ipdb.set_trace  # DEBUG]],
      { }
    )
  ),
}
