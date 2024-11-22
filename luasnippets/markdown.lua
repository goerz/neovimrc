local ls = require("luasnip")

local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {

  ls.snippet({trig="l", descr="Insert a link"},
    fmt(
      [[
      [{}]({})
      ]],
      { i(1, "text"), i(2, "url"), }
    )
  ),

  ls.snippet({trig="img", descr="Insert an image"},
    fmt(
      [[
      ![{}]({})
      ]],
      { i(1, "alt text"), i(2, "src")}
    )
  ),

}
