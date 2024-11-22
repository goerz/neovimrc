local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta

return {
  ls.snippet({trig="infil", dscr="Add an Infiltrator breakpoint"},
    fmta(
      [[
      if isdefined(Main, :Infiltrator)  # DEBUG
          Main.infiltrate(@__MODULE__, Base.@locals, @__FILE__, @__LINE__) # DEBUG
      end # DEBUG
      ]],
      { }
    )
  ),
}
